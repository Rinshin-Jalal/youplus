# Identity Status Feature

**Complete guide to performance tracking, trust percentage, streaks, and AI discipline messages.**

---

## 🎯 What is Identity Status?

Identity Status is the **real-time performance tracker** that measures how well the user is keeping their promises. It calculates trust percentage, current streak, and generates brutal AI-powered discipline messages based on behavior patterns.

Think of it as the scoreboard that holds users accountable and creates psychological pressure to stay consistent.

---

## 📊 Database: `identity_status` Table

**Key fields**:
- `trust_percentage`: 0-100% based on recent broken promises
- `current_streak_days`: Consecutive days of keeping ALL promises
- `promises_made_count`: Total promises with definitive status
- `promises_broken_count`: Total broken promises
- `status_summary`: AI-generated discipline message (JSONB)
- `next_call_timestamp`: When next call will happen

**References**:
- Type definition: [be/src/types/database.ts:80-99](../../be/src/types/database.ts#L80)
- Full schema: [DATABASE.md - Table 3](../DATABASE.md#table-3-identity_status)

---

## 🏗️ How Identity Status is Created

### Initial Creation: After Onboarding

**When**: Automatically during onboarding completion
**Function**: `syncIdentityStatus()` in [be/src/utils/identity-status-sync.ts:33](../../be/src/utils/identity-status-sync.ts#L33)

**Process**:
1. User completes onboarding
2. Backend calls `syncIdentityStatus(userId, env)`
3. No promises exist yet, so:
   - `trust_percentage` = 100 (full trust)
   - `current_streak_days` = 0 (no streak yet)
   - `promises_made_count` = 0
   - `promises_broken_count` = 0
4. AI generates initial discipline message:
   - Level: "UNKNOWN" (no data yet)
   - Message: "No record yet. Make a promise today and actually keep it."
5. Record inserted into `identity_status` table

**Why start at 100% trust**: Everyone deserves full trust initially. Trust drops based on behavior, not assumptions.

---

## 🔄 How Identity Status is Updated

### Automatic Updates

Identity status syncs automatically in these scenarios:

#### 1. After Evening Call (Most Common)
**When**: User completes evening accountability call
**What happens**:
1. During call, user reports which promises were kept/broken
2. AI calls `completePromise` tool function for each promise
3. Promise status updated in database (kept/broken)
4. Call ends, webhook received
5. Backend automatically triggers `syncIdentityStatus()`
6. Metrics recalculated based on ALL promises
7. New discipline message generated

**Why automatic**: Ensures status always reflects latest behavior.

#### 2. Promise Creation (Tomorrow's Promises)
**When**: User makes new promises for tomorrow during call
**What happens**:
1. AI calls `createPromise` tool function
2. New promise record created with status="pending"
3. Status sync NOT triggered yet (promise not due)
4. Will be counted tomorrow when it becomes active

#### 3. Manual Refresh from Frontend
**When**: User pulls to refresh on home screen
**Endpoint**: Could call `POST /api/identity/sync` (if implemented)
**Currently**: Status displayed is from last sync

#### 4. Periodic Background Sync (Future)
**When**: Could run nightly via cron job
**Purpose**: Catch any missed updates, fix inconsistencies
**Not implemented yet**

### Manual Update

User can't directly edit status metrics (by design), but can trigger:
- Re-sync by completing more promises
- Reset via support (rare, for bugs only)

---

## 📐 How Metrics are Calculated

### Trust Percentage Calculation

**Formula**: `100 - (broken promises in last 7 days × 10)`

**Logic**:
```
syncIdentityStatus():
  ↓
Get all promises for user
  ↓
Filter to last 7 days (promise_date >= 7 days ago)
  ↓
Count broken promises in that window
  ↓
trust_percentage = max(0, 100 - (brokenCount × 10))
  ↓
Save to database
```

**Examples**:
- 0 broken in 7 days → 100% trust
- 1 broken in 7 days → 90% trust
- 3 broken in 7 days → 70% trust
- 5 broken in 7 days → 50% trust
- 10+ broken in 7 days → 0% trust (floor)

**Why 7-day window**:
- Recent behavior matters most
- Old failures forgiven over time
- Encourages comeback after bad week
- Weekly reset prevents permanent low trust

**Why ×10 penalty**:
- One broken promise = -10% trust
- Significant but not catastrophic
- Can recover with consistent behavior
- Creates real pressure without being cruel

**Code**: [be/src/utils/identity-status-sync.ts:62-65](../../be/src/utils/identity-status-sync.ts#L62)

### Current Streak Calculation

**Definition**: Consecutive days where ALL promises were kept.

**Algorithm**:
```
calculateStreak(promises):
  ↓
Group promises by date
  ↓
Sort dates descending (most recent first)
  ↓
For each day (starting from today):
  ↓
  Check if ALL completed promises = kept
  ↓
  If yes: streak++, continue
  ↓
  If any broken: STOP, return streak
  ↓
Return final streak count
```

**Examples**:
- Monday: 3 kept, 0 broken → Streak = 1
- Tuesday: 2 kept, 0 broken → Streak = 2
- Wednesday: 2 kept, 1 broken → Streak BROKEN = 0
- Thursday: 3 kept, 0 broken → Streak = 1 (restarted)

**Important rules**:
- Must complete ALL promises to continue streak
- One broken promise = streak resets to 0
- Days with no promises = don't count (neither continue nor break)
- Days with pending promises = don't count yet

**Why harsh**:
- Accountability requires consistency
- Can't coast on 80% performance
- One slip = back to square one
- Builds discipline through all-or-nothing mindset

**Code**: [be/src/utils/identity-status-sync.ts:141-177](../../be/src/utils/identity-status-sync.ts#L141)

### Promises Count Calculation

**Made count**: Promises where `status = 'kept' OR 'broken'`
- Excludes pending promises (not due yet)
- Only counts completed promises (definitive outcome)

**Broken count**: Promises where `status = 'broken'`
- Direct count, straightforward

**Success rate**: `(made - broken) / made × 100`
- Example: 20 made, 3 broken = 85% success rate

**Code**: [be/src/utils/identity-status-sync.ts:54-68](../../be/src/utils/identity-status-sync.ts#L54)

---

## 🤖 AI Discipline Message Generation

### Status Summary Structure

Stored as JSONB in `status_summary` field:
```json
{
  "disciplineLevel": "CRISIS",
  "disciplineMessage": "You're sliding hard, Mike. Every excuse (I'm too tired) puts you deeper in the pit. Decide if you're done being weak.",
  "notificationTitle": "EMERGENCY INTERVENTION",
  "notificationMessage": "Your excuses are stacking (5 broken). Stop pretending tomorrow saves you.",
  "generatedAt": "2024-01-15T20:30:00Z"
}
```

### Discipline Levels

**5 levels based on performance**:

| Level | Criteria | Tone | Use Case |
|-------|----------|------|----------|
| **CRISIS** | Success <40% OR trust <50% OR 3+ broken last 7 days | Harsh emergency intervention | Multiple failures, downward spiral |
| **STUCK** | Success <60% OR streak = 0 | Wake-up call, momentum dead | Inconsistent, no progress |
| **STABLE** | Success 60-80%, streak 1-2 | Push harder, don't get comfortable | Decent but not aggressive |
| **GROWTH** | Success ≥80%, streak ≥3, trust ≥70% | Keep momentum, don't soften | Building positive pattern |
| **UNKNOWN** | No promises made yet | Make first commitment | New user |

**Code**: [be/src/utils/identity-status-sync.ts:310-329](../../be/src/utils/identity-status-sync.ts#L310)

### How Message is Generated

**Function**: `generateStatusSummary()` in [be/src/utils/identity-status-sync.ts:179-308](../../be/src/utils/identity-status-sync.ts#L179)

**Process**:
1. Calculate performance metrics
2. Determine discipline level based on criteria
3. Fetch user identity (for personalization)
4. Fetch latest call summary (for context)
5. Build prompt for OpenAI
6. Send to GPT-4o-mini with strict JSON output
7. Parse response
8. Fallback to heuristic if AI fails

**OpenAI Prompt includes**:
```
"Success rate: 85%
Trust percentage: 90%
Current streak: 7 days
Promises made: 20
Promises broken: 3
Primary excuse: 'I'm too tired'
Fear identity: 'Becoming lazy like uncle'
Core struggle: 'Consistency'

You are BigBruh. Classify discipline state and craft brutal
but motivating notification. Return JSON with keys:
disciplineLevel, disciplineMessage, notificationTitle,
notificationMessage."
```

**AI generates**:
- Personalized message using identity data
- References specific excuses
- Invokes fears when appropriate
- Balances brutal honesty with motivation

**Fallback if AI fails**:
- Pre-written heuristic messages per level
- Still personalized with identity fields
- Ensures user always gets feedback

**Code**: [be/src/utils/identity-status-sync.ts:246-308](../../be/src/utils/identity-status-sync.ts#L246)

---

## 🎯 Where Identity Status is Used

### Backend Usage

#### 1. **Identity API Response**
**Endpoint**: `GET /api/identity/:userId`
**Handler**: [be/src/routes/identity.ts:57](../../be/src/routes/identity.ts#L57)

When fetching identity, backend includes:
- Current trust percentage
- Current streak days
- Promise counts
- Next call timestamp
- Status summary (discipline message)

Used to display complete user profile.

#### 2. **Push Notifications**
**Service**: [be/src/services/push-notification-service.ts](../../be/src/services/push-notification-service.ts)

Status summary fields used for notifications:
- `notificationTitle`: Push notification title
- `notificationMessage`: Push notification body

Examples:
- "MOMENTUM CHECK" - "Success rate 65% with zero streak..."
- "EMERGENCY INTERVENTION" - "Your excuses are stacking (5 broken)..."

#### 3. **Call Prompt Context**
**Service**: [be/src/services/prompt-engine/](../../be/src/services/prompt-engine/)

Prompt engine includes status in AI instructions:
```
"Current status:
- Trust: 75%
- Streak: 3 days
- Discipline level: STABLE

Use this context to calibrate tone and urgency."
```

AI adjusts conversation based on status:
- CRISIS → Maximum intensity, emergency mode
- GROWTH → Positive reinforcement, maintain momentum
- STUCK → Wake-up call, challenge them

#### 4. **Brutal Reality Reviews**
**Service**: [be/src/services/brutal-reality-engine.ts](../../be/src/services/brutal-reality-engine.ts)

Daily reviews reference:
- Trust percentage trends
- Streak status
- Broken promise counts
- Discipline level

Used to craft personalized psychological warfare.

#### 5. **Statistics & Analytics**
**Endpoint**: `GET /api/identity/stats/:userId`

Provides comprehensive stats:
- Days active
- Trust percentage
- Current streak
- Success rate
- Performance trending (excellent/good/needs_improvement)

### Frontend (iOS) Usage

#### 1. **Home Screen Display**
**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Home/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Home/)

**Shows**:
- Trust percentage as circular progress (0-100%)
- Current streak with fire icon 🔥
- Discipline message prominently displayed
- Next call countdown

**Visual indicators**:
- Green trust % (80-100%): Good standing
- Yellow trust % (50-79%): Warning zone
- Red trust % (0-49%): Crisis mode
- Streak number gets bigger as it grows

**Why prominent**: Creates constant psychological pressure. User sees status every time they open app.

#### 2. **Progress View**
Shows trends over time:
- Trust % graph (last 30 days)
- Streak milestones (3 days, 7 days, 30 days)
- Promise success rate trending
- Discipline level changes

#### 3. **Notifications**
Push notifications use status summary:
- Title: `status_summary.notificationTitle`
- Body: `status_summary.notificationMessage`

Timed notifications:
- Morning: Reminder of streak at risk
- Evening: Call countdown with trust %
- After missed call: CRISIS message

#### 4. **Settings Display**
Shows performance metrics:
- Total promises made
- Total promises broken
- Best streak achieved
- Days since onboarding
- Overall success rate

#### 5. **Motivational Prompts**
Pre-call reminders:
- "Your trust is at 85% - keep it up!"
- "7-day streak on the line tonight"
- "CRISIS mode - this call matters"

---

## 🔄 How to Edit/Reset Identity Status

### Can't Directly Edit

**By design**: Users cannot manually edit metrics.

**Why**:
- Maintains integrity of system
- Prevents gaming the system
- Trust must be earned through behavior
- Streak must be built through consistency

### Only Way to Change: Behavior

**Improve trust**:
1. Keep promises consistently
2. Go 7+ days without breaking
3. Trust will rise automatically

**Build streak**:
1. Keep ALL promises today
2. Keep ALL promises tomorrow
3. Repeat

**Reset counts**:
- Can't reset (would defeat purpose)
- Old broken promises stay in history
- But trust % only looks at last 7 days

### Support/Admin Reset

**When needed**:
- Bug in calculation
- Incorrect promise marked broken
- System error

**How**:
1. Admin accesses database
2. Manually fixes promise status if wrong
3. Triggers re-sync: `syncIdentityStatus(userId)`
4. Metrics recalculated correctly

**Not common**: System is accurate, resets rare.

---

## 🤔 Design Decisions

### Why Trust Percentage?

**Psychological pressure**: A number that goes up/down based on behavior creates clear feedback loop.

**Better than points**:
- Points can accumulate forever (inflation)
- Percentage has ceiling (100%) and floor (0%)
- Easy to understand: "I'm at 70% trust"
- Creates urgency when dropping

**Gamification**:
- Watching it rise = rewarding
- Watching it fall = motivating to fix
- Clear goal: Get back to 100%

### Why 7-Day Window?

**Forgiveness**:
- Old mistakes eventually forgotten
- Can recover from bad week
- Prevents permanent low trust

**Recent focus**:
- What you did today matters most
- Yesterday's failure can be fixed tomorrow
- Encourages comeback mentality

**Balance**:
- Not too short (1-2 days = too forgiving)
- Not too long (30 days = one mistake haunts you)
- 7 days = one week of good behavior resets trust

### Why All-or-Nothing Streak?

**Accountability**:
- Can't coast on partial success
- Forces commitment to ALL promises
- One break = one failure (harsh but fair)

**Psychological impact**:
- "7-day streak" sounds impressive
- "7 days but broke 2 promises each day" doesn't
- Creates pride in consistency

**Motivation**:
- Don't want to break streak
- Each day becomes more valuable
- "I've come this far, can't quit now"

### Why AI-Generated Messages?

**Personalization**:
- Uses identity data (fears, excuses, struggles)
- References specific broken promises
- Speaks to user's situation

**Dynamic**:
- Adjusts to performance level
- Escalates when needed
- Positive when deserved

**Brutal honesty**:
- AI can say what humans avoid
- No sugar-coating
- Exactly what user signed up for

### Why Status Summary as JSONB?

**Flexibility**:
- Can add fields without schema changes
- Easy to version messages
- Store full AI response

**Rich data**:
- Multiple message formats (title, body, full)
- Metadata (when generated, by which model)
- Future: Could store message history

---

## 📊 Status Lifecycle

### Day 1: Onboarding Complete
```
trust_percentage: 100%
current_streak_days: 0
promises_made_count: 0
promises_broken_count: 0
disciplineLevel: "UNKNOWN"
message: "No record yet. Make a promise today."
```

### Day 2: First Evening Call
```
User makes 3 promises for tomorrow
Status unchanged (promises not due yet)
```

### Day 3: Second Evening Call
```
User reports: 3 kept, 0 broken
Sync triggered:
  trust_percentage: 100% (no broken)
  current_streak_days: 1
  promises_made_count: 3
  promises_broken_count: 0
  disciplineLevel: "STABLE"
```

### Day 7: Growing Streak
```
User reports: 2 kept, 0 broken
Sync triggered:
  trust_percentage: 100%
  current_streak_days: 5
  promises_made_count: 15
  promises_broken_count: 0
  disciplineLevel: "GROWTH"
  message: "Streak at 5 days. Momentum is real."
```

### Day 8: First Broken Promise
```
User reports: 2 kept, 1 broken
Sync triggered:
  trust_percentage: 90% (1 broken in 7 days)
  current_streak_days: 0 (RESET)
  promises_made_count: 18
  promises_broken_count: 1
  disciplineLevel: "STUCK"
  message: "Momentum dead. Start again."
```

### Day 15: Multiple Failures
```
User reports: 1 kept, 2 broken
Sync triggered:
  trust_percentage: 50% (5 broken in last 7 days)
  current_streak_days: 0
  promises_made_count: 30
  promises_broken_count: 8
  disciplineLevel: "CRISIS"
  message: "You're sliding. Every excuse drags you deeper."
```

---

## 📁 Key File References

### Backend
- Main sync function: [be/src/utils/identity-status-sync.ts](../../be/src/utils/identity-status-sync.ts)
- Identity routes: [be/src/routes/identity.ts](../../be/src/routes/identity.ts)
- Type definitions: [be/src/types/database.ts:80-99](../../be/src/types/database.ts#L80)

### Frontend (iOS)
- Home screen: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Home/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Home/)

### Related Documentation
- Promise system: [PROMISES.md](PROMISES.md)
- Identity system: [IDENTITY.md](IDENTITY.md)
- Database schema: [DATABASE.md](../DATABASE.md)

---

## 🎓 Common Questions

**Q: Can I reset my streak?**
A: No. Streak resets automatically when you break a promise. Must rebuild through consistent behavior.

**Q: Why did my trust % drop so fast?**
A: Each broken promise in the last 7 days = -10%. Break 5 promises = -50% trust.

**Q: How do I get trust back to 100%?**
A: Keep ALL promises for 7+ days straight. Old broken promises fall off the window.

**Q: What if I break one promise but keep 10 others?**
A: Streak resets to 0 (harsh but fair). Trust only drops by 10% (acknowledges the 10 kept).

**Q: Why is the AI message so harsh?**
A: You signed up for brutal accountability. That's the point. Sugar-coating doesn't work.

**Q: Can I see my status history?**
A: Not currently displayed, but backend could implement stats over time (future feature).

---

*Last updated: 2025-01-11*
