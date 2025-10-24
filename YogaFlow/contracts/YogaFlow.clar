;; YogaFlow - Digital Yoga Community Platform
;; A blockchain-based platform for yoga sequences, practice logs,
;; and practitioner community rewards

;; Contract constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))

;; Token constants
(define-constant token-name "YogaFlow Zen Token")
(define-constant token-symbol "YZT")
(define-constant token-decimals u6)
(define-constant token-max-supply u48000000000) ;; 48k tokens with 6 decimals

;; Reward amounts (in micro-tokens)
(define-constant reward-practice u2000000) ;; 2.0 YZT
(define-constant reward-sequence u3200000) ;; 3.2 YZT
(define-constant reward-milestone u9300000) ;; 9.3 YZT

;; Data variables
(define-data-var total-supply uint u0)
(define-data-var next-sequence-id uint u1)
(define-data-var next-practice-id uint u1)

;; Token balances
(define-map token-balances principal uint)

;; Practitioner profiles
(define-map practitioner-profiles
  principal
  {
    username: (string-ascii 24),
    yoga-style: (string-ascii 12), ;; "hatha", "vinyasa", "ashtanga", "yin", "restorative"
    practices-logged: uint,
    sequences-shared: uint,
    total-minutes: uint,
    yogi-level: uint, ;; 1-5
    join-date: uint
  }
)

;; Yoga sequences
(define-map yoga-sequences
  uint
  {
    sequence-name: (string-ascii 24),
    style: (string-ascii 12),
    difficulty: (string-ascii 8), ;; "beginner", "intermediate", "advanced"
    duration: uint, ;; minutes
    poses-count: uint,
    focus-area: (string-ascii 16), ;; "flexibility", "strength", "balance", "relaxation"
    creator: principal,
    practice-count: uint,
    average-rating: uint
  }
)

;; Practice logs
(define-map practice-logs
  uint
  {
    sequence-id: uint,
    practitioner: principal,
    session-duration: uint, ;; minutes
    intensity: uint, ;; 1-5
    environment: (string-ascii 8), ;; "home", "studio", "outdoor", "online"
    energy-level: (string-ascii 8), ;; "low", "medium", "high", "balanced"
    practice-notes: (string-ascii 80),
    practice-date: uint,
    mindful: bool
  }
)

;; Sequence reviews
(define-map sequence-reviews
  { sequence-id: uint, reviewer: principal }
  {
    rating: uint, ;; 1-10
    review-text: (string-ascii 80),
    effectiveness: (string-ascii 8), ;; "excellent", "good", "fair", "poor"
    review-date: uint,
    helpful-votes: uint
  }
)

;; Practitioner milestones
(define-map practitioner-milestones
  { practitioner: principal, milestone: (string-ascii 12) }
  {
    achievement-date: uint,
    practice-count: uint
  }
)

;; Helper function to get or create profile
(define-private (get-or-create-profile (practitioner principal))
  (match (map-get? practitioner-profiles practitioner)
    profile profile
    {
      username: "",
      yoga-style: "hatha",
      practices-logged: u0,
      sequences-shared: u0,
      total-minutes: u0,
      yogi-level: u1,
      join-date: stacks-block-height
    }
  )
)

;; Token functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? token-balances user)))
)

(define-private (mint-tokens (recipient principal) (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? token-balances recipient)))
    (new-balance (+ current-balance amount))
    (new-total-supply (+ (var-get total-supply) amount))
  )
    (asserts! (<= new-total-supply token-max-supply) err-invalid-input)
    (map-set token-balances recipient new-balance)
    (var-set total-supply new-total-supply)
    (ok amount)
  )
)

;; Add yoga sequence
(define-public (add-yoga-sequence (sequence-name (string-ascii 24)) (style (string-ascii 12)) (difficulty (string-ascii 8)) (duration uint) (poses-count uint) (focus-area (string-ascii 16)))
  (let (
    (sequence-id (var-get next-sequence-id))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len sequence-name) u0) err-invalid-input)
    (asserts! (> duration u0) err-invalid-input)
    (asserts! (> poses-count u0) err-invalid-input)
    
    (map-set yoga-sequences sequence-id {
      sequence-name: sequence-name,
      style: style,
      difficulty: difficulty,
      duration: duration,
      poses-count: poses-count,
      focus-area: focus-area,
      creator: tx-sender,
      practice-count: u0,
      average-rating: u0
    })
    
    ;; Update profile
    (map-set practitioner-profiles tx-sender
      (merge profile {sequences-shared: (+ (get sequences-shared profile) u1)})
    )
    
    ;; Award sequence creation tokens
    (try! (mint-tokens tx-sender reward-sequence))
    
    (var-set next-sequence-id (+ sequence-id u1))
    (print {action: "yoga-sequence-added", sequence-id: sequence-id, creator: tx-sender})
    (ok sequence-id)
  )
)

;; Log practice session
(define-public (log-practice (sequence-id uint) (session-duration uint) (intensity uint) (environment (string-ascii 8)) (energy-level (string-ascii 8)) (practice-notes (string-ascii 80)) (mindful bool))
  (let (
    (practice-id (var-get next-practice-id))
    (sequence (unwrap! (map-get? yoga-sequences sequence-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> session-duration u0) err-invalid-input)
    (asserts! (and (>= intensity u1) (<= intensity u5)) err-invalid-input)
    
    (map-set practice-logs practice-id {
      sequence-id: sequence-id,
      practitioner: tx-sender,
      session-duration: session-duration,
      intensity: intensity,
      environment: environment,
      energy-level: energy-level,
      practice-notes: practice-notes,
      practice-date: stacks-block-height,
      mindful: mindful
    })
    
    ;; Update sequence practice count
    (map-set yoga-sequences sequence-id
      (merge sequence {practice-count: (+ (get practice-count sequence) u1)})
    )
    
    ;; Update profile
    (map-set practitioner-profiles tx-sender
      (merge profile {
        practices-logged: (+ (get practices-logged profile) u1),
        total-minutes: (+ (get total-minutes profile) session-duration),
        yogi-level: (+ (get yogi-level profile) (/ session-duration u30))
      })
    )
    
    ;; Award practice tokens with mindful bonus
    (let (
      (base-reward reward-practice)
      (mindful-bonus (if mindful u800000 u0))
    )
      (try! (mint-tokens tx-sender (+ base-reward mindful-bonus)))
    )
    
    (var-set next-practice-id (+ practice-id u1))
    (print {action: "practice-logged", practice-id: practice-id, sequence-id: sequence-id})
    (ok practice-id)
  )
)

;; Write sequence review
(define-public (write-review (sequence-id uint) (rating uint) (review-text (string-ascii 80)) (effectiveness (string-ascii 8)))
  (let (
    (sequence (unwrap! (map-get? yoga-sequences sequence-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (and (>= rating u1) (<= rating u10)) err-invalid-input)
    (asserts! (> (len review-text) u0) err-invalid-input)
    (asserts! (is-none (map-get? sequence-reviews {sequence-id: sequence-id, reviewer: tx-sender})) err-already-exists)
    
    (map-set sequence-reviews {sequence-id: sequence-id, reviewer: tx-sender} {
      rating: rating,
      review-text: review-text,
      effectiveness: effectiveness,
      review-date: stacks-block-height,
      helpful-votes: u0
    })
    
    ;; Update sequence average rating (simplified calculation)
    (let (
      (current-avg (get average-rating sequence))
      (practice-count (get practice-count sequence))
      (new-avg (if (> practice-count u0)
                 (/ (+ (* current-avg practice-count) rating) (+ practice-count u1))
                 rating))
    )
      (map-set yoga-sequences sequence-id (merge sequence {average-rating: new-avg}))
    )
    
    (print {action: "review-written", sequence-id: sequence-id, reviewer: tx-sender})
    (ok true)
  )
)

;; Vote review helpful
(define-public (vote-helpful (sequence-id uint) (reviewer principal))
  (let (
    (review (unwrap! (map-get? sequence-reviews {sequence-id: sequence-id, reviewer: reviewer}) err-not-found))
  )
    (asserts! (not (is-eq tx-sender reviewer)) err-unauthorized)
    
    (map-set sequence-reviews {sequence-id: sequence-id, reviewer: reviewer}
      (merge review {helpful-votes: (+ (get helpful-votes review) u1)})
    )
    
    (print {action: "review-voted-helpful", sequence-id: sequence-id, reviewer: reviewer})
    (ok true)
  )
)

;; Update yoga style
(define-public (update-yoga-style (new-yoga-style (string-ascii 12)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-yoga-style) u0) err-invalid-input)
    
    (map-set practitioner-profiles tx-sender (merge profile {yoga-style: new-yoga-style}))
    
    (print {action: "yoga-style-updated", practitioner: tx-sender, style: new-yoga-style})
    (ok true)
  )
)

;; Claim milestone
(define-public (claim-milestone (milestone (string-ascii 12)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (is-none (map-get? practitioner-milestones {practitioner: tx-sender, milestone: milestone})) err-already-exists)
    
    ;; Check milestone requirements
    (let (
      (milestone-met
        (if (is-eq milestone "yogi-75") (>= (get practices-logged profile) u75)
        (if (is-eq milestone "teacher-14") (>= (get sequences-shared profile) u14)
        false)))
    )
      (asserts! milestone-met err-unauthorized)
      
      ;; Record milestone
      (map-set practitioner-milestones {practitioner: tx-sender, milestone: milestone} {
        achievement-date: stacks-block-height,
        practice-count: (get practices-logged profile)
      })
      
      ;; Award milestone tokens
      (try! (mint-tokens tx-sender reward-milestone))
      
      (print {action: "milestone-claimed", practitioner: tx-sender, milestone: milestone})
      (ok true)
    )
  )
)

;; Update username
(define-public (update-username (new-username (string-ascii 24)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-username) u0) err-invalid-input)
    (map-set practitioner-profiles tx-sender (merge profile {username: new-username}))
    (print {action: "username-updated", practitioner: tx-sender})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-practitioner-profile (practitioner principal))
  (map-get? practitioner-profiles practitioner)
)

(define-read-only (get-yoga-sequence (sequence-id uint))
  (map-get? yoga-sequences sequence-id)
)

(define-read-only (get-practice-log (practice-id uint))
  (map-get? practice-logs practice-id)
)

(define-read-only (get-sequence-review (sequence-id uint) (reviewer principal))
  (map-get? sequence-reviews {sequence-id: sequence-id, reviewer: reviewer})
)

(define-read-only (get-milestone (practitioner principal) (milestone (string-ascii 12)))
  (map-get? practitioner-milestones {practitioner: practitioner, milestone: milestone})
)