# YogaFlow - Digital Yoga Community Platform

A blockchain-based platform built on Stacks that enables yoga practitioners to share sequences, log practice sessions, and earn token rewards for consistent practice and community contributions.

## 🧘 Overview

YogaFlow creates a decentralized wellness ecosystem where yogis can:
- Share custom yoga sequences with the community
- Log practice sessions with detailed metrics
- Track personal wellness journey and progression
- Earn YZT (YogaFlow Zen Token) rewards for dedication
- Review and rate yoga sequences
- Achieve milestones for consistent practice
- Build a verifiable yoga practice portfolio

## 💎 Token Economics

**YogaFlow Zen Token (YZT)**
- **Symbol**: YZT
- **Decimals**: 6
- **Max Supply**: 48,000 YZT (48,000,000,000 micro-tokens)

### Reward Structure
- **Practice Session**: 2.0 YZT base reward
- **Mindful Practice Bonus**: +0.8 YZT (total 2.8 YZT)
- **Sequence Creation**: 3.2 YZT
- **Milestone Achievement**: 9.3 YZT

### Reward Philosophy
The reward structure incentivizes:
- **Consistent practice** through session logging
- **Mindful engagement** via bonus rewards
- **Community sharing** through sequence creation
- **Long-term dedication** via milestone achievements

## ✨ Core Features

### 1. Practitioner Profiles

Comprehensive tracking of your yoga journey:
- **Username**: Custom display name (up to 24 characters)
- **Yoga Style**: Primary practice style (hatha, vinyasa, ashtanga, yin, restorative)
- **Practices Logged**: Total session count
- **Sequences Shared**: Number of sequences created
- **Total Minutes**: Cumulative practice time
- **Yogi Level**: Skill progression (1-5 scale, grows with practice)
- **Join Date**: Platform registration timestamp

### 2. Yoga Sequences

Create and share yoga flows with rich metadata:
- **Sequence Name**: Descriptive title (up to 24 characters)
- **Style**: Yoga tradition (hatha, vinyasa, ashtanga, yin, restorative)
- **Difficulty**: Skill level (beginner, intermediate, advanced)
- **Duration**: Expected practice time in minutes
- **Poses Count**: Number of asanas in sequence
- **Focus Area**: Primary benefit (flexibility, strength, balance, relaxation)
- **Practice Count**: Community engagement metric
- **Average Rating**: Dynamic quality score (1-10 scale)

### 3. Practice Logs

Document your sessions with comprehensive tracking:

**Session Metrics:**
- **Session Duration**: Actual practice time in minutes
- **Intensity**: Physical exertion level (1-5 scale)
- **Environment**: Practice location (home, studio, outdoor, online)
- **Energy Level**: Post-practice state (low, medium, high, balanced)
- **Practice Notes**: Personal reflections (up to 80 characters)
- **Mindful Flag**: Indicates focused, present practice

**Mindful Practice Benefits:**
When logging a mindful practice session, practitioners receive:
- Base reward: 2.0 YZT
- Mindfulness bonus: +0.8 YZT
- **Total**: 2.8 YZT (40% bonus for quality practice)

### 4. Sequence Reviews

Community-driven quality assessment:
- **Rating**: Overall sequence quality (1-10 scale)
- **Review Text**: Detailed feedback (up to 80 characters)
- **Effectiveness**: Practice outcome (excellent, good, fair, poor)
- **Helpful Votes**: Community endorsement system
- **Dynamic Ratings**: Average rating updates with each new review

### 5. Practitioner Milestones

Celebrate dedication with blockchain-verified achievements:

**Available Milestones:**
- **Yogi-75**: Complete 75+ practice sessions
- **Teacher-14**: Share 14+ yoga sequences

Each milestone awards **9.3 YZT** and creates permanent record of achievement.

## 📋 Contract Functions

### Public Functions

#### `add-yoga-sequence`
```clarity
(add-yoga-sequence 
  (sequence-name (string-ascii 24)) 
  (style (string-ascii 12)) 
  (difficulty (string-ascii 8)) 
  (duration uint) 
  (poses-count uint) 
  (focus-area (string-ascii 16)))
```
Creates a new yoga sequence and awards 3.2 YZT to the creator.

**Example:**
```clarity
(contract-call? .yoga-flow add-yoga-sequence 
  "Morning Sun Salutation" 
  "vinyasa" 
  "beginner" 
  u20 
  u12 
  "flexibility")
```

#### `log-practice`
```clarity
(log-practice 
  (sequence-id uint) 
  (session-duration uint) 
  (intensity uint) 
  (environment (string-ascii 8)) 
  (energy-level (string-ascii 8)) 
  (practice-notes (string-ascii 80)) 
  (mindful bool))
```
Records a practice session. Awards 2.0 YZT (or 2.8 YZT if mindful).

**Example:**
```clarity
(contract-call? .yoga-flow log-practice 
  u1 
  u30 
  u4 
  "home" 
  "balanced" 
  "Great flow, felt centered throughout the practice" 
  true)
```

#### `write-review`
```clarity
(write-review 
  (sequence-id uint) 
  (rating uint) 
  (review-text (string-ascii 80)) 
  (effectiveness (string-ascii 8)))
```
Submits a review for a sequence. One review per practitioner per sequence.

**Example:**
```clarity
(contract-call? .yoga-flow write-review 
  u1 
  u9 
  "Perfect morning routine, clear instructions and great pacing" 
  "excellent")
```

#### `vote-helpful`
```clarity
(vote-helpful (sequence-id uint) (reviewer principal))
```
Marks a review as helpful. Cannot vote for your own reviews.

#### `update-yoga-style`
```clarity
(update-yoga-style (new-yoga-style (string-ascii 12)))
```
Updates your primary yoga practice style.

#### `claim-milestone`
```clarity
(claim-milestone (milestone (string-ascii 12)))
```
Claims a milestone achievement and receives 9.3 YZT reward.

**Example:**
```clarity
(contract-call? .yoga-flow claim-milestone "yogi-75")
```

#### `update-username`
```clarity
(update-username (new-username (string-ascii 24)))
```
Updates your display name on the platform.

### Read-Only Functions

- `get-name()`: Returns token name
- `get-symbol()`: Returns token symbol
- `get-decimals()`: Returns token decimals
- `get-balance(principal)`: Returns YZT balance
- `get-practitioner-profile(principal)`: Retrieves full practitioner profile
- `get-yoga-sequence(uint)`: Retrieves sequence details
- `get-practice-log(uint)`: Retrieves practice session details
- `get-sequence-review(uint, principal)`: Retrieves specific review
- `get-milestone(principal, string)`: Checks milestone achievement status

## 🎯 How It Works

### Yogi Level Progression

Your yogi level increases automatically with practice:

```clarity
yogi-level = base-level + (total-minutes / 30)
```

This means approximately **30 minutes of practice** increases your level by 1 point. The system rewards consistency over intensity.

### Average Rating Calculation

Sequence ratings update dynamically with each review:

```clarity
new-average = ((current-average × practice-count) + new-rating) / (practice-count + 1)
```

This weighted average ensures popular sequences maintain rating accuracy while giving new sequences fair representation.

### Mindful Practice Recognition

The `mindful` boolean flag allows practitioners to indicate:
- Full presence during practice
- Focused attention on breath and alignment
- Quality over quantity mindset
- Intentional, meditative approach

**40% bonus reward** incentivizes mindful practice over rushed sessions.

## 🌟 Use Cases

### For Individual Practitioners
- **Progress Tracking**: Monitor practice consistency and duration
- **Skill Development**: Watch yogi level increase with dedication
- **Personal Library**: Save favorite sequences
- **Community Connection**: Share and discover new flows

### For Yoga Teachers
- **Sequence Sharing**: Distribute custom flows to community
- **Student Engagement**: Track how sequences are received
- **Teaching Credentials**: Build verifiable teaching portfolio
- **Passive Rewards**: Earn tokens when practitioners use your sequences

### For Yoga Studios
- **Digital Presence**: Extend community beyond physical space
- **Member Engagement**: Incentivize home practice between classes
- **Quality Metrics**: Objective feedback on sequence effectiveness
- **Retention Tool**: Reward consistent practitioners

### For Wellness Apps
- **Blockchain Integration**: Add verifiable achievement layer
- **Gamification**: Token rewards for app engagement
- **Cross-Platform**: Portable practice history
- **Web3 Community**: Connect yoga and cryptocurrency communities

## 🔧 Technical Details

### String Length Limits

Designed to balance expressiveness with blockchain efficiency:
- Username: 24 characters (full names or creative handles)
- Sequence Name: 24 characters (descriptive titles)
- Practice Notes: 80 characters (meaningful reflections)
- Review Text: 80 characters (detailed feedback)
- Yoga Style: 12 characters (style names)
- Focus Area: 16 characters (benefit categories)

### Validation Rules

**Practice Sessions:**
- Duration must be positive (> 0 minutes)
- Intensity: 1-5 scale (light to vigorous)

**Sequences:**
- Name must be non-empty
- Duration must be positive
- Poses count must be positive

**Reviews:**
- Rating: 1-10 scale
- Review text must be non-empty
- One review per user per sequence

### Gas Optimization

- Single map lookups: O(1) complexity
- No loops or iterations
- Efficient profile updates via `merge`
- Minimal computational overhead
- Print statements for event tracking without storage costs

## 🚀 Quick Start Guide

### 1. Create Your Profile
Your profile is automatically created on first interaction. Customize it:
```clarity
(contract-call? .yoga-flow update-username "ZenMaster_Sarah")
(contract-call? .yoga-flow update-yoga-style "vinyasa")
```

### 2. Share a Sequence
Contribute to the community:
```clarity
(contract-call? .yoga-flow add-yoga-sequence 
  "Evening Wind Down" 
  "yin" 
  "beginner" 
  u45 
  u8 
  "relaxation")
```
**Reward**: 3.2 YZT instantly credited

### 3. Practice Regularly
Log sessions to build your portfolio:
```clarity
(contract-call? .yoga-flow log-practice 
  u1 
  u45 
  u3 
  "studio" 
  "high" 
  "Deep stretches, focused on hip openers" 
  true)
```
**Reward**: 2.8 YZT (mindful bonus included)

### 4. Engage with Community
Review sequences you've practiced:
```clarity
(contract-call? .yoga-flow write-review 
  u1 
  u8 
  "Great sequence for stress relief" 
  "good")
```

### 5. Claim Milestones
After 75 practices:
```clarity
(contract-call? .yoga-flow claim-milestone "yogi-75")
```
**Reward**: 9.3 YZT achievement bonus

## 📊 Token Distribution Strategy

**Estimated Token Allocation (48,000 YZT max supply):**

Assuming active community:
- **Practice Rewards** (60%): ~28,800 YZT for ~14,400 mindful sessions
- **Sequence Creation** (20%): ~9,600 YZT for ~3,000 sequences
- **Milestone Achievements** (15%): ~7,200 YZT for ~774 milestones
- **Reserve** (5%): ~2,400 YZT for platform operations

This distribution encourages consistent practice while rewarding community builders.

## ⚠️ Error Codes

- `u100`: Owner-only function (not currently used)
- `u101`: Resource not found (sequence doesn't exist)
- `u102`: Resource already exists (duplicate review or milestone)
- `u103`: Unauthorized action (voting for own review)
- `u104`: Invalid input parameters (out-of-range values)

## 🔒 Security Considerations

**Implemented Protections:**
- ✅ Input validation on all parameters
- ✅ Sequence existence verification before practice logging
- ✅ Duplicate review prevention
- ✅ Self-voting prevention
- ✅ Milestone requirement validation
- ✅ Token supply cap enforcement
- ✅ Integer overflow protection (Clarity built-in)

**Trust-Based Elements:**
- Practitioners self-report mindfulness (incentivized honesty)
- Practice duration is self-declared
- No verification of actual pose performance

**Recommendation**: Future versions could integrate with wearable devices or video verification for enhanced authenticity.

## 🗺️ Roadmap

### Phase 1: Foundation (Current)
- ✅ Core practice logging
- ✅ Sequence sharing
- ✅ Token reward system
- ✅ Review functionality
- ✅ Milestone achievements

### Phase 2: Enhancement
- [ ] Token transfer functionality
- [ ] Sequence favoriting/bookmarking
- [ ] Follow other practitioners
- [ ] Private vs. public sequences
- [ ] Advanced filtering and search

### Phase 3: Integration
- [ ] NFT certificates for milestones
- [ ] Video sequence tutorials (IPFS)
- [ ] Wearable device integration
- [ ] Studio partnership program
- [ ] Cross-platform mobile app

### Phase 4: Ecosystem
- [ ] DAO governance for platform rules
- [ ] Practitioner marketplace (private classes)
- [ ] Sequence competitions and challenges
- [ ] Integration with wellness apps
- [ ] Multi-chain token bridging

## 🤝 Community Guidelines

**For Sequence Creators:**
- Provide clear, safe instructions
- Specify contraindications when relevant
- Update sequences based on feedback
- Credit inspirations/teachers

**For Practitioners:**
- Leave honest, constructive reviews
- Report unsafe sequences
- Vote helpful on quality reviews
- Support community creators

**For Reviewers:**
- Be respectful and encouraging
- Focus on sequence quality
- Share specific insights
- Consider different skill levels

## 📱 Integration Examples

### JavaScript/TypeScript
```javascript
import { makeContractCall, uintCV, stringAsciiCV, trueCV } from '@stacks/transactions';

// Log mindful practice
const logPracticeTx = await makeContractCall({
  contractAddress: 'SP2...',
  contractName: 'yoga-flow',
  functionName: 'log-practice',
  functionArgs: [
    uintCV(1),                           // sequence-id
    uintCV(30),                          // session-duration
    uintCV(4),                           // intensity
    stringAsciiCV('home'),               // environment
    stringAsciiCV('balanced'),           // energy-level
    stringAsciiCV('Morning flow'),       // practice-notes
    trueCV()                             // mindful
  ],
  senderKey: privateKey,
});
```

### Python (using clarity-python)
```python
from clarity import ContractCall

# Add new sequence
sequence = ContractCall(
    contract='yoga-flow',
    function='add-yoga-sequence',
    args={
        'sequence-name': 'Power Flow',
        'style': 'vinyasa',
        'difficulty': 'advanced',
        'duration': 60,
        'poses-count': 20,
        'focus-area': 'strength'
    }
)
```

## 🎓 Educational Resources

**Recommended Reading:**
- Yoga Sutras of Patanjali (foundational philosophy)
- Light on Yoga by B.K.S. Iyengar (comprehensive asana guide)
- The Heart of Yoga by T.K.V. Desikachar (practice principles)

**Yoga Styles Explained:**
- **Hatha**: Traditional, gentle, foundational poses
- **Vinyasa**: Flowing, breath-synchronized movement
- **Ashtanga**: Rigorous, set sequence, athletic
- **Yin**: Passive, long-held poses, deep stretching
- **Restorative**: Relaxation-focused, prop-supported

## 📞 Support & Contact

- **Documentation**: [Link to full documentation]
- **Discord**: [Community server invite]
- **Twitter**: [@YogaFlowChain]
- **Email**: support@yogaflow.io
- **GitHub**: [Repository link]

## 🙏 Acknowledgments

Built with gratitude for the global yoga community. Special thanks to all practitioners, teachers, and wellness advocates who make mindful movement accessible to everyone.

Namaste 🙏

---

**Contract Version**: 1.0.0  
**Blockchain**: Stacks  
**Language**: Clarity  
**License**: [Your chosen license]
