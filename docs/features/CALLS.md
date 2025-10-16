# Calls Feature

**Complete guide to the accountability call system - scheduling, VoIP delivery, AI conversations, and call processing.**

---

## 🎯 What are Calls?

Calls are **daily accountability conversations** with an AI agent that reviews promises, extracts excuses, and creates new commitments. They're delivered via VoIP push notifications and powered by 11labs conversational AI using the user's psychological profile.

Think of calls as the enforcement mechanism - where accountability moves from theory to practice.

---

## 📊 Database: `calls` Table

**Key fields**:
- `call_type`: evening/morning/first_call/emergency
- `audio_url`: Recording of the conversation
- `transcript_json`: Full conversation transcript
- `transcript_summary`: AI-generated summary
- `duration_sec`: Length of call
- `call_successful`: success/failure/unknown
- `is_retry`, `retry_attempt_number`: Retry tracking
- `acknowledged`: Whether user picked up

**References**:
- Type definition: [be/src/types/database.ts:160-187](../../be/src/types/database.ts#L160)
- Full schema: [DATABASE.md - Table 6](../DATABASE.md#table-6-calls)

---

## 🏗️ How Calls are Created

### Automated Call Scheduling

**System**: Cron job runs every minute on Cloudflare Workers
**Handler**: [be/src/services/scheduler-engine.ts](../../be/src/services/scheduler-engine.ts)

**Process every minute**:
```
Cron triggers
  ↓
Fetch all users with active subscriptions
  ↓
Check each user's call eligibility:
  - onboarding_completed = true
  - subscription_status = 'active'
  - Within their call_window_start time
  - Timezone-adjusted to their local time
  ↓
For eligible users:
  Send VoIP push notification
```

### Call Eligibility Logic

**Function**: `processScheduledCalls()` in scheduler engine

**User qualifies if**:
1. Has active subscription
2. Completed onboarding
3. Has call_window_start time set
4. Current time in their timezone matches call window
5. Hasn't received call today already
6. Not currently on a call

**Example**:
```
User: Mike
Timezone: America/New_York (EST)
Call window: 20:30-21:00

Cron runs at 01:30 UTC (8:30pm EST)
  ↓
Matches call window
  ↓
Mike is eligible
  ↓
Send VoIP push
```

**Why every minute**: Ensures calls delivered within 60 seconds of target time.

---

## 📞 VoIP Push Notification System

### How VoIP Push Works

**Service**: [be/src/services/push-notification-service.ts](../../be/src/services/push-notification-service.ts)

**iOS VoIP Push flow**:
```
Backend generates VoIP push
  ↓
Send to Apple Push Notification Service (APNS)
  ↓
APNS delivers to iOS device
  ↓
iOS wakes app in background
  ↓
App shows incoming call UI (CallKit)
  ↓
User answers or declines
```

**Why VoIP push (not regular push)**:
- Wakes app even if terminated
- Shows as phone call (not notification)
- Can't be ignored or swiped away
- Higher priority than regular notifications
- Works even in Do Not Disturb (if configured)

### VoIP Push Payload

**Structure sent to APNS**:
```json
{
  "aps": {
    "alert": {
      "title": "BIG BRUH Accountability Call",
      "body": "Your evening check-in is ready"
    },
    "sound": "default"
  },
  "call_type": "evening",
  "user_id": "uuid",
  "timestamp": 1705356600
}
```

**iOS receives this and**:
1. Wakes app in background
2. Displays CallKit incoming call UI
3. Shows "BIG BRUH" as caller name
4. Plays ringtone
5. Waits for user action

### Frontend VoIP Handling

**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Call/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Call/)

**When push arrives**:
```swift
func handleVoIPPush(payload: [String: Any]) {
    // Extract call info
    let callType = payload["call_type"] as? String
    let userId = payload["user_id"] as? String

    // Display incoming call UI
    displayIncomingCall(callType: callType)

    // If user answers:
    //   1. Connect to 11labs
    //   2. Request call config from backend
    //   3. Start conversation

    // If user declines:
    //   1. Mark as missed
    //   2. Schedule retry
}
```

**User experience**:
- Phone shows incoming call (like FaceTime)
- Green "Answer" button
- Red "Decline" button
- Keeps ringing until answered or declined

---

## 🤖 AI Call Configuration

### Backend Call Config Generation

**Endpoint**: `POST /call/:userId/:callType`
**Handler**: [be/src/routes/11labs-call-init.ts](../../be/src/routes/11labs-call-init.ts)

**When called**: 11labs AI requests configuration before starting conversation

**Process**:
```
11labs requests config
  ↓
Backend fetches user context:
  - Identity (psychological profile)
  - Identity status (trust %, streak)
  - Yesterday's promises
  - Recent call history
  - Excuse patterns
  ↓
Prompt Engine generates personalized instructions
  ↓
Return config to 11labs with:
  - System prompt
  - Voice clone ID
  - Tool functions
  - Call parameters
```

**Prompt Engine**: [be/src/services/prompt-engine/](../../be/src/services/prompt-engine/)

**Generated prompt includes**:
```
"You are BIG BRUH, speaking to Mike.

IDENTITY:
- Wants to become: Disciplined person who wakes early
- Fears becoming: Lazy like his uncle
- Primary excuse: 'I'm too tired'
- Biggest enemy: Phone scrolling
- War cry: 'I'm not my father'

STATUS:
- Trust: 85%
- Streak: 5 days
- Discipline level: GROWTH

YESTERDAY'S PROMISES:
1. Wake up at 6am - PENDING
2. No phone after 9pm - PENDING
3. Workout 30min - PENDING

YOUR TASK:
1. Review each promise
2. Mark kept or broken
3. Extract excuses if broken
4. Create 2-3 promises for tomorrow
5. Use identity context to personalize
6. Be brutal but fair"
```

**Tools provided to AI**:
- `createPromise`: Create new promise
- `completePromise`: Mark promise kept/broken
- `getUserContext`: Get additional context
- `getExcuseHistory`: Reference past excuses
- `analyzeExcusePattern`: Detect excuse patterns
- `searchMemories`: Find similar past behavior

**Config returned**:
```json
{
  "agent": {
    "prompt": {
      "prompt": "You are BIG BRUH...",
      "llm": "gpt-4o",
      "temperature": 0.7
    },
    "first_message": "Evening, Mike. Let's talk about yesterday.",
    "language": "en"
  },
  "voice": {
    "voice_id": "user_voice_clone_id"
  },
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "createPromise",
        "description": "Create a new promise for tomorrow",
        "parameters": { ... }
      }
    }
  ]
}
```

---

## 🎙️ Call Conversation Flow

### Typical Evening Call

**Duration**: 3-5 minutes
**Structure**: Review → Accountability → Planning

#### Phase 1: Opening (15 seconds)
```
AI: "Evening, Mike. Ready to be honest about yesterday?"
User: "Yeah, let's do it"
AI: "Good. No bullshit tonight."
```

#### Phase 2: Promise Review (2 minutes)
```
AI: "Yesterday you promised three things. First: wake up at 6am and workout. Did you do it?"
User: "Yes, I did"
AI: "Good. Marking it kept." [Calls completePromise tool]

AI: "Second: no phone after 9pm. Did you keep that?"
User: "No... I was scrolling until midnight"
AI: "Why did you break this promise?"
User: "I was bored and couldn't sleep"
AI: "Marking it broken with excuse 'bored and couldn't sleep'." [Calls completePromise tool]

AI: "Third: workout for 30 minutes. Did you?"
User: "Yeah, did 45 minutes actually"
AI: "Excellent. Marking kept." [Calls completePromise tool]
```

#### Phase 3: Excuse Analysis (30 seconds)
```
AI: "You said you were 'bored and couldn't sleep'. You used that excuse twice last week too. What's really going on?"
User: "I don't know, I just can't put the phone down at night"
AI: "That's your biggest enemy - the phone. You told me that during onboarding."
```

#### Phase 4: New Promises (1 minute)
```
AI: "What are you committing to for tomorrow?"
User: "I'll wake up at 6am again and workout"
AI: "That's the same promise. What about the phone?"
User: "I'll put it in another room at 9pm"
AI: "Better. Specific. I'm locking in: 'Put phone in another room at 9pm'. High priority." [Calls createPromise tool]
```

#### Phase 5: Closing (30 seconds)
```
AI: "2 out of 3 kept. Your streak is still alive at 5 days. Don't break it tomorrow with the phone bullshit. Got it?"
User: "Got it"
AI: "Good. Talk tomorrow at 8:30pm."
[Call ends]
```

### AI Behavior Adaptation

**Based on discipline level** (from identity_status):

**GROWTH** (performing well):
- Positive reinforcement
- Encourage momentum
- Challenge to go harder
- "You're on a roll, don't soften now"

**STABLE** (maintaining):
- Standard accountability
- Push for consistency
- Watch for complacency
- "Don't let boredom kill your streak"

**STUCK** (inconsistent):
- Wake-up call tone
- Direct confrontation
- Challenge excuses
- "You're spinning your wheels"

**CRISIS** (multiple failures):
- Maximum intensity
- Emergency intervention
- Harsh truth-telling
- "Every excuse digs you deeper"

---

## 📝 Call Recording & Transcription

### Recording Process

**11labs handles recording**:
1. Call conversation recorded automatically
2. Audio saved to 11labs storage
3. Webhook sent to backend with audio URL

**Backend processing**:
```
Webhook received
  ↓
Extract audio_url from webhook
  ↓
Save to database with call record
  ↓
Optionally: Download and store in R2 for backup
```

### Transcript Generation

**11labs provides**:
- Real-time transcript during call
- Complete transcript after call ends
- JSON format with speaker labels

**Transcript structure**:
```json
{
  "messages": [
    {
      "role": "assistant",
      "content": "Evening, Mike. Ready to be honest?",
      "timestamp": "2024-01-15T20:30:05Z"
    },
    {
      "role": "user",
      "content": "Yeah let's do it",
      "timestamp": "2024-01-15T20:30:08Z"
    }
  ],
  "tool_calls": [
    {
      "function": "completePromise",
      "arguments": {
        "promiseId": "uuid",
        "status": "kept"
      }
    }
  ]
}
```

### Summary Generation

**AI generates summary** after call:
```
OpenAI GPT-4 analyzes transcript
  ↓
Extracts key points:
  - Promises kept vs broken
  - Excuses given
  - New commitments made
  - Overall tone/attitude
  ↓
Generates 2-3 sentence summary
```

**Example summary**:
```
"User kept 2 of 3 promises. Broke phone promise with excuse 'bored and couldn't sleep' - repeated excuse. Made 2 new promises for tomorrow. Streak continues at 5 days. Attitude was defensive about phone usage."
```

**Stored in**: `calls.transcript_summary`

---

## 🔄 How Calls Can Be Retried

### Missed Call Retry System

**Service**: [be/src/services/retry-processor.ts](../../be/src/services/retry-processor.ts)

**When user misses call**:
```
VoIP push sent at 8:30pm
  ↓
User doesn't answer within 60 seconds
  ↓
Call marked as missed
  ↓
Retry scheduled for 9:00pm (30 min later)
  ↓
Retry attempt 1 sent with higher urgency
  ↓
If missed again: Retry 2 at 9:30pm
  ↓
If missed again: Retry 3 at 10:00pm (final)
  ↓
If still missed: No more retries, marked as failed
```

**Retry tracking fields**:
- `is_retry`: true for retry attempts
- `retry_attempt_number`: 1, 2, or 3
- `original_call_uuid`: Links to first attempt
- `retry_reason`: "missed" or "declined"
- `urgency`: escalates from "high" to "critical" to "emergency"

**Escalating urgency**:
- **Retry 1**: "You missed your call. This is your second chance."
- **Retry 2**: "CRITICAL: You missed twice. This is urgent."
- **Retry 3**: "FINAL ATTEMPT: Answer or face consequences tomorrow."

**Why retries**:
- User might genuinely miss first notification
- Escalating urgency creates pressure
- Shows system is serious
- Final attempt prevents endless retries

### Manual Retry (Future)

**Could implement**:
- User requests retry via app
- Support triggers manual retry
- Makeup call next day

**Not currently available**: One shot per day + 3 retries.

---

## 📊 Where Calls are Used

### Backend Usage

#### 1. **Identity Status Update**
After call ends:
```
Webhook received
  ↓
Promises updated (kept/broken)
  ↓
Trigger syncIdentityStatus()
  ↓
Recalculate trust %, streak
  ↓
Generate new discipline message
```

**See**: [IDENTITY_STATUS.md](IDENTITY_STATUS.md)

#### 2. **Memory Embedding Creation**
Excuses from call:
```
Extract broken promise excuses
  ↓
Create OpenAI embeddings
  ↓
Store in memory_embeddings
  ↓
Enable pattern detection
```

**See**: [MEMORY.md](MEMORY.md)

#### 3. **Brutal Reality Input**
Daily reviews use call data:
```
Fetch recent calls (last 7 days)
  ↓
Analyze transcripts for patterns
  ↓
Reference specific excuses
  ↓
Generate harsh but accurate assessment
```

#### 4. **Call History API**
**Endpoint**: `GET /api/history/calls`

Fetch past calls:
- Filter by date range
- Filter by call_type
- Include transcript summaries
- Show success rate

#### 5. **Analytics & Metrics**
Track performance:
- Total calls made
- Calls answered vs missed
- Average call duration
- Promises created per call
- Success rate trending

### Frontend (iOS) Usage

#### 1. **Incoming Call UI**
**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Call/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Call/)

**Shows**:
- CallKit native interface
- "BIG BRUH" as caller
- Answer/Decline buttons
- Call type indicator

#### 2. **Call History View**
**Shows past calls**:
- Date and time
- Call duration
- Summary preview
- Full transcript (expandable)
- Promises discussed
- Kept/broken counts

**Why useful**:
- Review past conversations
- See what was discussed
- Track improvement over time
- Reference old promises

#### 3. **Call Statistics**
Display metrics:
- Total calls received
- Calls answered
- Average duration
- Longest call
- Answer rate percentage

#### 4. **Next Call Countdown**
Home screen shows:
```
🕐 Next Call: Today at 8:30 PM
   Countdown: 3 hours 27 minutes

📋 Promises to Review:
   3 pending from yesterday
```

**Creates anticipation**: User knows call is coming.

---

## 🤔 Design Decisions

### Why Evening Calls Only (Currently)?

**Focus**:
- Evening = reflect on day
- Review what happened (not predict)
- Creates accountability cycle

**Morning calls planned**:
- Future feature
- Set intentions for day
- Different tone (motivational vs accountability)

**Why not both yet**:
- Evening proven most effective
- Don't want to overwhelm users
- One call = user takes seriously
- Two calls daily might feel excessive

### Why VoIP Push (Not Regular)?

**Reliability**:
- Regular push can be swiped away
- VoIP push wakes app from terminated state
- Can't be easily ignored

**Experience**:
- Feels like real phone call
- Uses CallKit (native iOS UI)
- Integrates with Do Not Disturb settings
- Higher sense of urgency

**Technical**:
- Background execution allowed
- Can establish call connection immediately
- Better audio quality preparation

### Why 11labs (Not Vapi)?

**Voice quality**:
- 11labs has best voice cloning
- Natural conversational flow
- Low latency

**Features**:
- Built-in conversation management
- Tool function support
- Webhook system
- Transcript generation

**Originally used Vapi**: Switched to 11labs for better quality.

### Why AI Voice Clone (Not Generic)?

**Personalization**:
- Hearing your own voice creates cognitive dissonance
- "Future you" talking to "current you"
- Harder to argue with yourself

**Psychological impact**:
- More memorable
- Feels personal (because it is)
- Can't dismiss as "some AI"

**User feedback**:
- Most impactful feature
- "It's weird but it works"
- Increases engagement

### Why Tool Functions (Not Scripted)?

**Flexibility**:
- AI can adapt to conversation flow
- No rigid script to follow
- Natural back-and-forth

**Intelligence**:
- AI can ask follow-up questions
- Dig deeper on excuses
- Challenge weak commitments

**Database integration**:
- AI can update promises in real-time
- Fetch user history mid-conversation
- Reference past behavior dynamically

---

## 🔧 Call Types Explained

### Evening Call (Primary)
**When**: User's call_window_start time (typically 8-9pm)
**Purpose**: Review yesterday, create tomorrow promises
**Duration**: 3-5 minutes
**Tone**: Accountability, direct, no-nonsense

### First Call (Onboarding)
**When**: After user completes onboarding
**Purpose**: Introduction, set expectations, initial promises
**Duration**: 5-7 minutes
**Tone**: Welcoming but firm, establish relationship

### Morning Call (Future)
**When**: User's wake-up time
**Purpose**: Set intentions, preview challenges
**Duration**: 2-3 minutes
**Tone**: Motivational, energizing

### Emergency Call (User-Triggered)
**When**: User requests accountability
**Purpose**: Crisis intervention, immediate support
**Duration**: 5-10 minutes
**Tone**: Maximum intensity, problem-solving

### Apology Call (Future)
**When**: After multiple broken promises
**Purpose**: Escalation, serious consequences
**Duration**: 10+ minutes
**Tone**: Harsh reality check, intervention

---

## 📈 Call Success Metrics

### What Makes a Call "Successful"?

**Success criteria**:
- User answered (not missed)
- Duration > 60 seconds (actually engaged)
- At least 1 promise reviewed OR created
- Call completed (not hung up mid-way)

**Failure scenarios**:
- User missed all 4 attempts (1 initial + 3 retries)
- User answered but hung up immediately
- Technical issue (connection failed)
- AI error (couldn't generate responses)

**Tracked in**: `calls.call_successful` field

### Call Performance Metrics

**System tracks**:
- Answer rate: % of calls answered
- Average duration: Time spent per call
- Completion rate: % that finish conversation
- Retry necessity: % that need retries
- Tool usage: How often AI calls functions

**User-specific**:
- Total calls received
- Calls answered
- Longest/shortest call
- Most common call time
- Promises per call average

---

## 📁 Key File References

### Backend
- Scheduler: [be/src/services/scheduler-engine.ts](../../be/src/services/scheduler-engine.ts)
- Call config: [be/src/routes/11labs-call-init.ts](../../be/src/routes/11labs-call-init.ts)
- Prompt engine: [be/src/services/prompt-engine/](../../be/src/services/prompt-engine/)
- VoIP push: [be/src/services/push-notification-service.ts](../../be/src/services/push-notification-service.ts)
- Retry processor: [be/src/services/retry-processor.ts](../../be/src/services/retry-processor.ts)
- Webhook handler: [be/src/routes/elevenlabs-webhooks.ts](../../be/src/routes/elevenlabs-webhooks.ts)
- Type definitions: [be/src/types/database.ts:160-187](../../be/src/types/database.ts#L160)

### Frontend (iOS)
- Call UI: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Call/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Call/)
- Home screen: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Home/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Home/)

### Related Documentation
- Promises: [PROMISES.md](PROMISES.md)
- Identity Status: [IDENTITY_STATUS.md](IDENTITY_STATUS.md)
- Identity: [IDENTITY.md](IDENTITY.md)
- Database schema: [DATABASE.md](../DATABASE.md)

---

## 🎓 Common Questions

**Q: What if I'm busy and can't answer?**
A: You get 3 automatic retries over 90 minutes. If you miss all 4, call marked as missed and affects your trust %.

**Q: Can I schedule call for different time?**
A: Yes, update call_window_start in settings. Limited to 2 changes per month (prevents gaming).

**Q: What if I hang up mid-call?**
A: Call marked as incomplete. Affects success rate. Promises not updated. Try again with retry.

**Q: Can I request a call anytime?**
A: Not currently. Scheduled calls only. Emergency call feature planned for future.

**Q: Does the AI remember previous calls?**
A: Yes. Transcript summaries stored. AI can reference past conversations, excuses, patterns.

**Q: What if my internet is bad during call?**
A: Call may disconnect. Marked as failed. Retry automatically scheduled. Better connection needed.

**Q: Can I see transcript of my calls?**
A: Yes, in Call History view. Full transcript available for all past calls.

---

*Last updated: 2025-01-11*
