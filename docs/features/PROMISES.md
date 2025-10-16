# Promises Feature

**Complete guide to daily commitments, promise tracking, and the accountability engine.**

---

## 🎯 What are Promises?

Promises are **daily commitments** users make during evening accountability calls. Each promise is a specific action they commit to completing, tracked with kept/broken status and excuses when they fail.

Think of promises as the core measurement of accountability - the difference between words and action.

---

## 📊 Database: `promises` Table

**Key fields**:
- `promise_text`: What they committed to ("Wake up at 6am")
- `promise_date`: Which day it applies to
- `status`: pending/kept/broken
- `excuse_text`: Why they broke it (if broken)
- `priority_level`: low/medium/high/critical
- `time_specific`: Has a target time or not
- `target_time`: Specific time for time-bound promises

**References**:
- Type definition: [be/src/types/database.ts:132-150](../../be/src/types/database.ts#L132)
- Full schema: [DATABASE.md - Table 5](../DATABASE.md#table-5-promises)

---

## 🏗️ How Promises are Created

### During Evening Call

**When**: User's evening accountability call (typically 8-9pm their timezone)
**Who creates**: AI agent during conversation
**How**: Via tool function call

**The Conversation Flow**:
```
AI: "What are you committing to for tomorrow?"
User: "I'll wake up at 6am and go to the gym"
AI: "Let me lock that in for you."
  ↓
AI calls createPromise tool function
  ↓
Promise saved to database
```

### Backend Promise Creation

**Endpoint**: `POST /tool/function/createPromise`
**Handler**: [be/src/routes/tool-handlers/createPromise.ts](../../be/src/routes/tool-handlers/createPromise.ts)

**Request from 11labs AI**:
```json
{
  "userId": "uuid-here",
  "promiseText": "Wake up at 6am and workout",
  "promiseDate": "2024-01-16",
  "priorityLevel": "high",
  "timeSpecific": true,
  "targetTime": "06:00",
  "category": "health"
}
```

**Process**:
1. Validate user ID matches authenticated user
2. Validate promise date (must be today or future)
3. Check if promise for that date already exists
4. Determine promise order (1, 2, 3 for multiple promises)
5. Create promise record with status="pending"
6. Return confirmation to AI

**Record created**:
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "promise_date": "2024-01-16",
  "promise_text": "Wake up at 6am and workout",
  "status": "pending",
  "priority_level": "high",
  "category": "health",
  "time_specific": true,
  "target_time": "06:00",
  "promise_order": 1,
  "created_during_call": true,
  "created_at": "2024-01-15T20:35:00Z"
}
```

**AI Response**:
```
AI: "Got it. Wake up at 6am and workout - high priority. I'll ask you about this tomorrow at 8pm."
```

### Multiple Promises Per Day

Users can make multiple promises:
- **Typical**: 2-3 promises per day
- **Maximum**: No hard limit, but AI discourages >5
- **Order**: `promise_order` field (1, 2, 3...)

**Why multiple**:
- Different areas of life (health, work, relationships)
- Some days need more accountability
- Allows granular tracking

**AI behavior**:
- Encourages 2-3 focused commitments
- Discourages making too many (sets up for failure)
- Prioritizes most important ones

---

## ✅ How Promises are Completed

### During Next Evening Call

**When**: The evening AFTER promise_date (24 hours later)
**Process**: AI reviews each promise made yesterday

**The Conversation Flow**:
```
AI: "Yesterday you promised to wake up at 6am and workout. Did you do it?"
User: "Yes, I did it!"
AI: "Excellent. Marking it as kept."
  ↓
AI calls completePromise tool function
```

OR

```
AI: "Did you wake up at 6am and workout?"
User: "No... I hit snooze and skipped the gym"
AI: "Why did you break this promise?"
User: "I was too tired after staying up late"
AI: "Marking it broken with excuse 'too tired after staying up late'"
  ↓
AI calls completePromise tool function
```

### Backend Promise Completion

**Endpoint**: `POST /tool/function/completePromise`
**Handler**: [be/src/routes/tool-handlers/completePromise.ts](../../be/src/routes/tool-handlers/completePromise.ts)

**Request for KEPT promise**:
```json
{
  "userId": "uuid",
  "promiseId": "uuid",
  "status": "kept"
}
```

**Request for BROKEN promise**:
```json
{
  "userId": "uuid",
  "promiseId": "uuid",
  "status": "broken",
  "excuseText": "I was too tired after staying up late"
}
```

**Process**:
1. Fetch promise by ID
2. Verify belongs to user
3. Verify promise is pending (not already completed)
4. Update status (kept/broken)
5. If broken, save excuse_text
6. Return confirmation
7. **Trigger identity status sync** (updates trust %, streak)

**Record updated**:
```json
{
  "id": "uuid",
  "status": "broken",
  "excuse_text": "I was too tired after staying up late",
  "updated_at": "2024-01-16T20:31:00Z"
}
```

### What Happens After Completion

**Immediate effects**:
1. Promise status permanently set (can't change)
2. Identity status recalculated:
   - Trust % adjusted based on broken promises
   - Streak updated (continues or resets)
   - Promise counts incremented
3. Memory embedding created for excuse (if broken)
4. AI continues conversation with context

**Long-term tracking**:
- Excuse stored for pattern analysis
- Used in future calls: "You said this last week too"
- Feeds brutal reality reviews
- Builds excuse history database

---

## 🔄 How Promises Can Be Edited

### Can't Edit After Status Set

**Rule**: Once promise status is "kept" or "broken", it's permanent.

**Why**:
- Prevents gaming the system
- Maintains accountability integrity
- Historical record must be accurate
- Trust/streak calculations depend on immutability

### Before Completion (Pending State)

**Technically possible but not exposed**:
- Could update `promise_text` via API
- Could update `priority_level`
- Could delete if made in error

**Not implemented because**:
- Promises made during call should be final
- Editing defeats accountability
- User had chance to clarify during call

### Admin/Support Override

**Rare cases**:
- User accidentally said "broken" when meant "kept"
- System bug marked wrong status
- Duplicate promise created by mistake

**Process**:
1. Support accesses database
2. Updates promise status
3. Updates excuse_text if needed
4. Triggers `syncIdentityStatus()` to recalculate
5. User's metrics corrected

**Very rare**: AI is accurate, overrides almost never needed.

---

## 🎯 Where Promises are Used

### Backend Usage

#### 1. **Evening Call Review**
**Service**: [be/src/services/prompt-engine/](../../be/src/services/prompt-engine/)

Before evening call:
```
Fetch promises for yesterday
  ↓
Include in call prompt
  ↓
AI: "Let's review. Yesterday you promised to:
1. Wake up at 6am ✓ or ✗
2. No phone after 9pm ✓ or ✗
3. Workout for 30min ✓ or ✗"
```

**Why**: Accountability requires review. Can't let promises disappear.

#### 2. **Identity Status Calculation**
**Service**: [be/src/utils/identity-status-sync.ts](../../be/src/utils/identity-status-sync.ts)

Trust % calculation:
```
Get all promises (last 7 days)
  ↓
Count broken promises
  ↓
trust = 100 - (broken × 10)
```

Streak calculation:
```
Get all promises (all time)
  ↓
Group by date
  ↓
Count consecutive days where ALL kept
```

**See**: [IDENTITY_STATUS.md](IDENTITY_STATUS.md) for full calculation details.

#### 3. **Excuse Pattern Analysis**
**Tool**: [be/src/routes/tool-handlers/analyzeExcusePattern.ts](../../be/src/routes/tool-handlers/analyzeExcusePattern.ts)

During call, AI can ask:
```
"What's your go-to excuse?"
  ↓
AI calls analyzeExcusePattern
  ↓
Fetches all broken promises
  ↓
Groups by excuse_text
  ↓
Returns: "You've said 'I'm too tired' 7 times this month"
```

**Why**: Catch users using same excuse repeatedly.

#### 4. **Excuse History Tool**
**Tool**: [be/src/routes/tool-handlers/getExcuseHistory.ts](../../be/src/routes/tool-handlers/getExcuseHistory.ts)

AI can reference past excuses:
```
Fetch last 10 broken promises
  ↓
Show excuse_text for each
  ↓
AI: "Last week you said 'too tired'
     Two weeks ago: 'too tired'
     Yesterday: 'too tired'
     See the pattern?"
```

**Psychological impact**: Confronting users with their own words is powerful.

#### 5. **Brutal Reality Reviews**
**Service**: [be/src/services/brutal-reality-engine.ts](../../be/src/services/brutal-reality-engine.ts)

Daily review includes:
```
Fetch promises (last 7 days)
  ↓
Calculate kept vs broken
  ↓
Find most common excuse
  ↓
Generate harsh but accurate assessment:
"You broke 5 promises this week.
Your 'I'm too tired' excuse is getting old.
Either change or admit you don't want it."
```

#### 6. **Memory Embeddings**
**Service**: [be/src/services/memory-ingestion-service.ts](../../be/src/services/memory-ingestion-service.ts)

When promise broken:
```
Extract excuse_text
  ↓
Create OpenAI embedding (vector)
  ↓
Store in memory_embeddings table
  ↓
Type = "excuse"
  ↓
Later: Find similar excuses via vector search
```

**See**: [MEMORY.md](MEMORY.md) for embedding details.

### Frontend (iOS) Usage

#### 1. **Promise List View**
**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Home/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Home/)

**Today's promises**:
- Shows all promises for today
- Status indicators (pending/kept/broken)
- Priority badges (high/critical in red)
- Time-specific promises show target time
- Swipe actions (future: mark kept/broken manually)

**Visual design**:
```
📌 Wake up at 6am [HIGH]
   ⏰ 06:00 | Status: Pending

✅ No phone after 9pm
   Status: Kept

❌ Workout for 30min [CRITICAL]
   Status: Broken
   Excuse: "I was too tired"
```

#### 2. **Promise History**
Shows past promises:
- Filter by kept/broken
- Group by week/month
- Statistics per day
- Excuse viewing

**Why useful**:
- See patterns in behavior
- Identify which promises hardest to keep
- Review excuse frequency
- Motivate with kept promise history

#### 3. **Statistics Dashboard**
Display metrics:
- Total promises made (all time)
- Total kept vs broken
- Success rate percentage
- Most broken promise type
- Most common excuse
- Longest streak achieved

#### 4. **Pre-Call Reminder**
Before evening call notification:
```
"Your call is in 30 minutes.
You have 3 promises to discuss:
- Wake up at 6am ✓
- No phone after 9pm ?
- Workout 30min ?

Be ready to account for yesterday."
```

**Psychological prep**: User reviews their commitments before call.

---

## 📊 Promise Priority System

### Priority Levels

| Level | When Used | AI Behavior |
|-------|-----------|-------------|
| **LOW** | Nice-to-have habits | Checks on it briefly |
| **MEDIUM** | Important commitments | Standard accountability |
| **HIGH** | Critical to goals | Extra pressure, more time discussing |
| **CRITICAL** | Non-negotiable, life-changing | Maximum intensity, consequences if broken |

### How Priority is Set

**During creation**:
- AI analyzes promise importance based on conversation
- User's identity influences priority (daily_non_negotiable = critical)
- Repeated failures make promise higher priority next time

**Examples**:
```
"I'll wake up early" → MEDIUM
  (Important but not urgent)

"I will not drink tonight" → HIGH
  (Specific commitment, clear binary)

"I'll finish my project deadline" → CRITICAL
  (Has deadline, affects livelihood)

"I might read a book" → LOW
  (Wishy-washy language, not committed)
```

### Priority Affects Behavior

**During review**:
- **CRITICAL**: AI spends most time, asks detailed questions
- **HIGH**: Significant focus, demands explanation if broken
- **MEDIUM**: Standard review, moves on quickly if kept
- **LOW**: Brief mention, skips if tight on time

**After broken**:
- **CRITICAL broken**: Emergency tone, escalate to crisis mode
- **HIGH broken**: Serious accountability, extract detailed excuse
- **MEDIUM broken**: Standard consequence
- **LOW broken**: Acknowledged, encouraged to do better

---

## 🤔 Design Decisions

### Why "Promises" Not "Goals"?

**Psychological difference**:
- Goals = aspirational (can fail without shame)
- Promises = commitment (breaking = personal failure)
- "I'll try" vs "I promise"

**Accountability**:
- Promises create obligation
- Breaking promise = lie to yourself
- Stronger motivation to follow through

### Why Daily Scope?

**Manageable**:
- 24 hours is short enough to plan
- Can't procrastinate "I'll do it next week"
- Forces daily action

**Clear deadline**:
- promise_date is specific
- No ambiguity about when it's due
- Must report within 24 hours

**Fresh start**:
- New promises each day
- Yesterday's failure doesn't chain to today
- Can rebuild momentum daily

### Why Require Excuse for Broken?

**Accountability**:
- Forces confrontation with failure
- Can't just mark broken and move on
- Must articulate why

**Pattern detection**:
- Builds excuse database
- AI can spot repeated excuses
- "You said this 3 times this week"

**Self-awareness**:
- Users hear their own excuses
- Sometimes excuses sound hollow when spoken
- Builds awareness of rationalization patterns

### Why Immutable After Status Set?

**Integrity**:
- Can't rewrite history
- Metrics depend on accurate record
- Trust system requires truth

**Prevents gaming**:
- Can't retroactively mark promises kept
- Can't delete broken promises
- Can't edit excuses to sound better

**Accountability**:
- Decisions have permanent consequences
- Builds seriousness around commitments
- Can't undo broken trust

### Why AI Creates Promises (Not User Form)?

**Natural conversation**:
- Flows from discussion organically
- AI can challenge weak commitments
- More engaging than form filling

**AI validation**:
- Catches vague promises ("I'll try to workout")
- Pushes for specific commitments ("Workout at 6am for 30 minutes")
- Discourages over-committing (too many promises)

**Context-aware**:
- AI considers identity, past failures, current situation
- Sets appropriate priority level
- References previous promises

---

## 📈 Promise Lifecycle Example

### Monday Evening (8pm)
```
AI Call:
  "What are you committing to for tomorrow?"

User:
  "I'll wake up at 6am and workout"

AI:
  "That's high priority. I'm locking that in."
  [Creates promise via tool function]

Promise created:
  {
    date: "2024-01-16",
    text: "Wake up at 6am and workout",
    status: "pending",
    priority: "high"
  }
```

### Tuesday (6am)
```
User's alarm goes off
User decisions pending...
Promise status still: "pending"
```

### Tuesday Evening (8pm)
```
AI Call:
  "Yesterday you promised to wake up at 6am and workout. Did you?"

User:
  "No, I hit snooze and skipped it"

AI:
  "Why did you break this promise?"

User:
  "I stayed up too late the night before"

AI:
  "Marking it broken."
  [Calls completePromise tool function]

Promise updated:
  {
    status: "broken",
    excuse_text: "I stayed up too late the night before"
  }

Identity status updated:
  trust_percentage: 90% (was 100%)
  current_streak_days: 0 (was reset)
  promises_broken_count: 1

AI continues:
  "So staying up late caused you to break your promise.
   What time did you actually go to bed?"
```

---

## 📁 Key File References

### Backend
- Create promise handler: [be/src/routes/tool-handlers/createPromise.ts](../../be/src/routes/tool-handlers/createPromise.ts)
- Complete promise handler: [be/src/routes/tool-handlers/completePromise.ts](../../be/src/routes/tool-handlers/completePromise.ts)
- Excuse history: [be/src/routes/tool-handlers/getExcuseHistory.ts](../../be/src/routes/tool-handlers/getExcuseHistory.ts)
- Excuse pattern analysis: [be/src/routes/tool-handlers/analyzeExcusePattern.ts](../../be/src/routes/tool-handlers/analyzeExcusePattern.ts)
- Type definitions: [be/src/types/database.ts:132-150](../../be/src/types/database.ts#L132)

### Frontend (iOS)
- Home screen (promise list): [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Home/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Home/)

### Related Documentation
- Identity status (trust/streak): [IDENTITY_STATUS.md](IDENTITY_STATUS.md)
- Call system: [CALLS.md](CALLS.md)
- Memory embeddings: [MEMORY.md](MEMORY.md)
- Database schema: [DATABASE.md](../DATABASE.md)

---

## 🎓 Common Questions

**Q: Can I make promises without a call?**
A: Not currently. Promises created during AI conversation for accountability. Future: Could add manual creation.

**Q: What if I keep a promise but AI marked it broken by mistake?**
A: Very rare. Contact support to manually correct. Promise is immutable but support can override.

**Q: Can I delete a promise?**
A: No. Once created, it's part of your record. Deleting defeats accountability purpose.

**Q: What if I make too many promises?**
A: AI will challenge you. "That's 6 promises - you're setting yourself up to fail. Pick your top 3."

**Q: Why can't I edit my excuse after submitting?**
A: Excuse is your immediate response. Changing it later = rewriting history. Must own your words.

**Q: Do pending promises affect my trust %?**
A: No. Only completed promises (kept/broken) affect metrics. Pending doesn't count yet.

---

*Last updated: 2025-01-11*
