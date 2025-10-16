# BIG BRUH Complete Database & Features Guide

**Every database table, every field, every feature explained in plain English.**

---

## 📊 Database Tables Overview

BIG BRUH uses **8 core database tables** in Supabase (PostgreSQL):

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `users` | User accounts & auth | Authentication, subscription, settings |
| `identity` | Psychological profile | 15 AI-extracted identity fields |
| `identity_status` | Performance tracking | Trust %, streaks, AI discipline messages |
| `onboarding` | Raw onboarding data | 45-step responses in JSONB |
| `promises` | Daily commitments | Promise tracking, excuses, status |
| `calls` | Call recordings & transcripts | Voice call history, AI summaries |
| `memory_embeddings` | Vector search | OpenAI embeddings for pattern detection |
| `voip_debug_events` | Debug logs | VoIP troubleshooting (dev only) |

---

## 👤 Table 1: `users`

**Purpose**: Core user account information and subscription management.

### Fields

| Field | Type | Description | Used For |
|-------|------|-------------|----------|
| `id` | UUID | Primary key | User identification across all tables |
| `email` | TEXT | User's email | Supabase Auth login |
| `name` | TEXT | User's preferred name | Personalization, extracted from onboarding |
| `created_at` | TIMESTAMP | Account creation date | User lifetime tracking |
| `updated_at` | TIMESTAMP | Last update | Data freshness |
| `subscription_status` | TEXT | active/cancelled/past_due | Access control, RevenueCat sync |
| `timezone` | TEXT | User timezone | Call scheduling (e.g., "America/New_York") |
| `call_window_start` | TEXT | Evening call time | When calls start (e.g., "20:30") |
| `call_window_timezone` | TEXT | Call window timezone | May differ from user timezone |
| `voice_clone_id` | TEXT | 11labs voice ID | Personalized voice for calls |
| `push_token` | TEXT | APNS token | VoIP push notifications |
| `onboarding_completed` | BOOLEAN | Onboarding status | Access gate to app features |
| `onboarding_completed_at` | TIMESTAMP | Completion time | Onboarding funnel metrics |
| `schedule_change_count` | INTEGER | Changes this month | Limit: 2 per month |
| `voice_reclone_count` | INTEGER | Reclones this month | Limit: 1 per month |
| `revenuecat_customer_id` | TEXT | RevenueCat ID | Subscription linking |

### Features Using This Table

**Backend**:
- **Authentication** ([auth.ts](be/src/middleware/auth.ts)) - JWT validation, user lookup
- **Subscription Check** ([auth.ts](be/src/middleware/auth.ts)) - `requireActiveSubscription` middleware
- **Call Scheduling** ([scheduler-engine.ts](be/src/services/scheduler-engine.ts)) - Timezone-aware call triggers
- **Settings API** ([settings.ts](be/src/routes/settings.ts)) - Update timezone, call window, subscription

**Frontend (iOS)**:
- **AuthService** ([AuthService.swift](swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/Services/AuthService.swift)) - Session management, user profile
- **Settings Screen** - Edit name, timezone, call preferences
- **Subscription Screen** - Display status, manage via RevenueCat

### References
- Type definition: [database.ts:15-32](be/src/types/database.ts#L15)
- Auth middleware: [auth.ts](be/src/middleware/auth.ts)

---

## 🧬 Table 2: `identity`

**Purpose**: AI-extracted psychological profile for personalized accountability.

### Fields

| Field | Type | Category | Description |
|-------|------|----------|-------------|
| `id` | UUID | System | Primary key |
| `user_id` | UUID | System | Foreign key → users |
| `name` | TEXT | Basic | Identity name (not user's real name) |
| `identity_summary` | TEXT | Basic | AI-generated summary of profile |
| **OPERATIONAL FIELDS** | | | |
| `daily_non_negotiable` | TEXT | Operational | ONE daily commitment (e.g., "Wake up at 6am") |
| `transformation_target_date` | TEXT | Operational | Goal date (e.g., "2025-06-01") |
| **IDENTITY FIELDS (AI-Extracted)** | | | |
| `current_identity` | TEXT | Identity | Who they are now (2-3 sentences) |
| `aspirated_identity` | TEXT | Identity | Who they want to become |
| `fear_identity` | TEXT | Identity | Who they fear becoming |
| `core_struggle` | TEXT | Identity | Main life struggle right now |
| `biggest_enemy` | TEXT | Identity | Pattern/thing that always defeats them |
| `primary_excuse` | TEXT | Identity | Go-to excuse for giving up |
| `sabotage_method` | TEXT | Identity | How they ruin their own success |
| **BEHAVIORAL FIELDS (AI-Extracted)** | | | |
| `weakness_time_window` | TEXT | Behavioral | When they typically break (time/situation) |
| `procrastination_focus` | TEXT | Behavioral | What they're avoiding RIGHT NOW |
| `last_major_failure` | TEXT | Behavioral | Recent complete give-up moment |
| `past_success_story` | TEXT | Behavioral | Time they actually followed through |
| `accountability_trigger` | TEXT | Behavioral | What makes them move (shame/confrontation/etc) |
| `war_cry` | TEXT | Behavioral | Motivational phrase for tough moments |
| `created_at` | TIMESTAMP | System | Identity creation date |
| `updated_at` | TIMESTAMP | System | Last modification |

**Total**: 15 identity fields (13 AI-extracted + 2 operational)

### How Identity is Created

1. **User completes 45-step onboarding** (voice + text + choices)
2. **Backend receives data** via POST `/onboarding/v3/complete`
3. **Voice recordings transcribed** using Deepgram API
4. **AI analyzes all responses** using OpenAI/GitHub Models (GPT-4o-mini)
5. **13 psychological fields extracted** from AI analysis
6. **2 operational fields extracted** directly from responses
7. **Identity saved** to this table with auto-generated summary

### Features Using This Table

**Backend**:
- **Prompt Engine** ([prompt-engine/](be/src/services/prompt-engine/)) - Creates personalized AI call instructions
- **Brutal Reality** ([brutal-reality-engine.ts](be/src/services/brutal-reality-engine.ts)) - Daily performance reviews
- **Tool Functions** ([tool-handlers/getUserContext.ts](be/src/routes/tool-handlers/getUserContext.ts)) - Provides identity to AI during calls
- **Identity API** ([identity.ts](be/src/routes/identity.ts)) - GET/PUT identity data

**Frontend (iOS)**:
- **Identity Screen** - Display and edit psychological profile
- **Call Preparation** - Shows identity before calls for psychological prep
- **Settings** - View transformation progress

### References
- Complete identity flow: [IDENTITY.md](IDENTITY.md)
- Type definition: [database.ts:48-77](be/src/types/database.ts#L48)
- Extraction process: [unified-identity-extractor.ts](be/src/services/unified-identity-extractor.ts)
- AI analyzer: [ai-psychological-analyzer.ts](be/src/services/ai-psychological-analyzer.ts)

---

## 📈 Table 3: `identity_status`

**Purpose**: Real-time performance tracking and AI-generated discipline messages.

### Fields

| Field | Type | Description | How It's Calculated |
|-------|------|-------------|---------------------|
| `id` | UUID | Primary key | Auto-generated |
| `user_id` | UUID | Foreign key → users | Links to user account |
| `trust_percentage` | INTEGER | Psychological pressure (0-100) | 100 - (broken promises last 7 days × 10) |
| `next_call_timestamp` | BIGINT | Unix timestamp | Calculated from call_window_start + timezone |
| `promises_made_count` | INTEGER | Total promises with status | Count where status = 'kept' OR 'broken' |
| `promises_broken_count` | INTEGER | Total broken promises | Count where status = 'broken' |
| `current_streak_days` | INTEGER | Consecutive days of kept promises | Breaks on first day with ANY broken promise |
| `last_updated` | TIMESTAMP | Last sync time | Auto-updated on every sync |
| `status_summary` | JSONB | AI-generated messages | See structure below |

### Status Summary Structure (JSONB)

```json
{
  "disciplineLevel": "CRISIS|GROWTH|STUCK|STABLE|UNKNOWN",
  "disciplineMessage": "Brutal but motivating message about current state",
  "notificationTitle": "Short notification title",
  "notificationMessage": "Brief notification message",
  "generatedAt": "2024-01-15T10:30:00Z"
}
```

### Discipline Levels Explained

| Level | Criteria | Message Tone |
|-------|----------|--------------|
| **CRISIS** | Success <40% OR trust <50% OR 3+ broken last 7 days | Emergency intervention, harsh reality |
| **STUCK** | Success <60% OR streak = 0 | Momentum dead, wake-up call |
| **STABLE** | Success 60-80% AND streak 1-2 | Holding ground, push harder |
| **GROWTH** | Success ≥80% AND streak ≥3 AND trust ≥70% | Momentum building, stay aggressive |
| **UNKNOWN** | No promises made yet | Make first commitment |

### How Status is Synced

**Function**: `syncIdentityStatus()` in [identity-status-sync.ts](be/src/utils/identity-status-sync.ts#L33)

**Triggered by**:
1. Onboarding completion (initial sync)
2. Promise completion (evening call)
3. Manual refresh from frontend
4. Cron job (periodic sync)

**Process**:
1. Fetch all user's promises from `promises` table
2. Calculate metrics (made, broken, streak, trust %)
3. Call OpenAI GPT-4o-mini to generate discipline message
4. Upsert to `identity_status` table

### Features Using This Table

**Backend**:
- **Push Notifications** - Uses `notificationTitle` + `notificationMessage`
- **Status API** ([identity.ts:474](be/src/routes/identity.ts#L474)) - GET identity stats
- **Dashboard Data** - Trust %, streak, discipline level

**Frontend (iOS)**:
- **Home Screen** - Display trust %, streak, discipline message
- **Progress View** - Show performance trending
- **Notifications** - Display status summary messages

### References
- Sync function: [identity-status-sync.ts:33-139](be/src/utils/identity-status-sync.ts#L33)
- Type definition: [database.ts:80-99](be/src/types/database.ts#L80)

---

## 📋 Table 4: `onboarding`

**Purpose**: Stores raw 45-step onboarding responses in JSONB format.

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | Foreign key → users (unique constraint) |
| `responses` | JSONB | Complete 45-step responses (see structure below) |
| `created_at` | TIMESTAMP | Initial save time |
| `updated_at` | TIMESTAMP | Last modification |

### Responses Structure (JSONB)

Each step is stored with this format:

```json
{
  "step_1": {
    "type": "voice",
    "value": "https://pub-xxx.r2.dev/audio/user-123/step-1.m4a",
    "db_field": ["identity_name"],
    "timestamp": "2024-01-15T10:30:00Z",
    "duration": 5.2
  },
  "step_2": {
    "type": "text",
    "value": "I want to become disciplined",
    "db_field": ["aspirated_identity"],
    "timestamp": "2024-01-15T10:31:00Z"
  },
  "step_19": {
    "type": "choice",
    "value": "Ruthless",
    "db_field": ["enforcement_tone"],
    "selected_option": "Ruthless - Maximum psychological pressure",
    "timestamp": "2024-01-15T10:45:00Z"
  }
}
```

### Response Types

| Type | Description | Value Format |
|------|-------------|--------------|
| `voice` | Audio recording | Cloud URL (after R2 upload) or base64 (during upload) |
| `text` | Text input | Plain text string |
| `choice` | Single selection | Selected option text |
| `dual_sliders` | Two sliders | Array: `[slider1_value, slider2_value]` |
| `time_window_picker` | Time range | Object: `{ start: "20:30", end: "21:00" }` |
| `timezone_selection` | Timezone picker | Timezone string: "America/New_York" |
| `long_press_activate` | Long press button | Boolean + duration ms |

### The 45 Onboarding Steps (Summary)

**Identity Formation** (Steps 1-15):
- Name, goals, fears, struggles, enemy identification
- Past failures, success stories, daily routine
- Voice recordings capturing emotional tone

**Behavioral Patterns** (Steps 16-30):
- Weakness windows, procrastination focus, sabotage methods
- Accountability preferences, enforcement tone selection
- Daily non-negotiable, transformation target date

**System Configuration** (Steps 31-45):
- Timezone, call window, notification preferences
- Voice recording for voice cloning
- Final oath, commitment confirmation

### Features Using This Table

**Backend**:
- **Identity Extraction** ([unified-identity-extractor.ts](be/src/services/unified-identity-extractor.ts)) - Reads responses for AI analysis
- **Re-extraction** ([onboarding.ts:411](be/src/routes/onboarding.ts#L411)) - POST `/onboarding/extract-data` re-analyzes responses
- **Debugging** - View raw responses to troubleshoot extraction issues

**Frontend (iOS)**:
- **Onboarding Flow** - Submits all 45 responses via POST `/onboarding/v3/complete`
- **Progress Save** - Temporarily stores responses locally during onboarding
- **Resume Feature** - Could restore from JSONB if implemented

### References
- Completion endpoint: [onboarding.ts:76-371](be/src/routes/onboarding.ts#L76)
- Type definition: [database.ts:102-108](be/src/types/database.ts#L102)
- File processor: [onboardingFileProcessor.ts](be/src/utils/onboardingFileProcessor.ts)

---

## 🎯 Table 5: `promises`

**Purpose**: Track daily commitments, promise-keeping, and excuses.

### Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | UUID | Primary key | Auto-generated |
| `user_id` | UUID | Foreign key → users | Links to user |
| `promise_date` | DATE | Date promise applies to | "2024-01-15" |
| `promise_text` | TEXT | What user committed to | "Wake up at 6am and workout" |
| `status` | TEXT | pending/kept/broken | Initial: pending, Updated: kept/broken |
| `excuse_text` | TEXT | Reason if broken | "I was too tired and hit snooze" |
| `promise_order` | INTEGER | Display order | 1, 2, 3 (for multiple promises) |
| `priority_level` | TEXT | low/medium/high/critical | Affects AI call focus |
| `category` | TEXT | Promise type | "health", "work", "habits", etc. |
| `time_specific` | BOOLEAN | Has target time? | true if has target_time |
| `target_time` | TEXT | Specific time | "06:00" for time-specific promises |
| `created_during_call` | BOOLEAN | Made during which call | true if from evening call |
| `parent_promise_id` | UUID | Related promise | For follow-up/sub-promises |
| `created_at` | TIMESTAMP | When created | Auto-set |

### Promise Lifecycle

1. **Evening Call**: AI conducts accountability check
2. **Promise Creation**: User makes commitments for tomorrow
   - Called via POST `/tool/function/createPromise`
   - AI sets priority based on conversation context
3. **Next Day**: Promises become active (`promise_date` = today)
4. **Next Evening Call**: AI asks about each promise
5. **Status Update**: User reports kept or broken
   - Called via POST `/tool/function/completePromise`
   - If broken, AI extracts excuse via conversation
6. **Identity Status Update**: Triggers `syncIdentityStatus()` to recalculate metrics

### Features Using This Table

**Backend**:
- **Tool Functions**:
  - [createPromise.ts](be/src/routes/tool-handlers/createPromise.ts) - Create new promise
  - [completePromise.ts](be/src/routes/tool-handlers/completePromise.ts) - Mark kept/broken
  - [getExcuseHistory.ts](be/src/routes/tool-handlers/getExcuseHistory.ts) - Analyze excuse patterns
- **Identity Status Sync** ([identity-status-sync.ts](be/src/utils/identity-status-sync.ts)) - Calculate trust %, streak
- **Brutal Reality** ([brutal-reality-engine.ts](be/src/services/brutal-reality-engine.ts)) - Reference broken promises

**Frontend (iOS)**:
- **Promise List** - Today's active promises with status
- **Promise History** - Past promises with kept/broken stats
- **Streak Display** - Visual representation of consecutive days

### References
- Type definition: [database.ts:132-150](be/src/types/database.ts#L132)
- Create handler: [tool-handlers/createPromise.ts](be/src/routes/tool-handlers/createPromise.ts)
- Complete handler: [tool-handlers/completePromise.ts](be/src/routes/tool-handlers/completePromise.ts)

---

## 📞 Table 6: `calls`

**Purpose**: Store call recordings, transcripts, and AI summaries.

### Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | UUID | Primary key | Auto-generated |
| `user_id` | UUID | Foreign key → users | Links to user |
| `call_type` | TEXT | morning/evening/emergency/first_call | "evening" |
| `audio_url` | TEXT | Cloud storage URL | "https://r2.dev/audio/call-123.mp3" |
| `duration_sec` | INTEGER | Call length in seconds | 180 (3 minutes) |
| `transcript_json` | JSONB | Full conversation transcript | See structure below |
| `transcript_summary` | TEXT | AI-generated summary | "User completed 2/3 promises..." |
| `confidence_scores` | JSONB | Sentiment/confidence data | From 11labs |
| `conversation_id` | TEXT | 11labs conversation ID | For linking to 11labs dashboard |
| `status` | TEXT | Call status | "completed", "missed", "failed" |
| `cost_cents` | INTEGER | API cost | 45 (= $0.45) |
| `start_time` | TIMESTAMP | Call start | "2024-01-15T20:30:00Z" |
| `end_time` | TIMESTAMP | Call end | "2024-01-15T20:33:00Z" |
| `call_successful` | TEXT | success/failure/unknown | Outcome classification |
| `source` | TEXT | vapi/elevenlabs | Which AI provider |
| **RETRY TRACKING** | | | |
| `is_retry` | BOOLEAN | Is this a retry call? | false for first attempt |
| `retry_attempt_number` | INTEGER | Which retry (1, 2, 3) | null if not retry |
| `original_call_uuid` | UUID | First call ID | Links retries to original |
| `retry_reason` | TEXT | missed/declined/failed | Why retry was needed |
| `urgency` | TEXT | high/critical/emergency | Escalating urgency |
| `acknowledged` | BOOLEAN | Call answered? | true if user picked up |
| `acknowledged_at` | TIMESTAMP | When answered | null if missed |
| `timeout_at` | TIMESTAMP | Retry deadline | When to give up |
| `created_at` | TIMESTAMP | Record creation | Auto-set |

### Transcript JSON Structure

```json
{
  "messages": [
    {
      "role": "assistant",
      "content": "Good evening, Mike. Let's talk about your promises.",
      "timestamp": "2024-01-15T20:30:05Z"
    },
    {
      "role": "user",
      "content": "Yeah, I kept 2 out of 3. I missed my workout.",
      "timestamp": "2024-01-15T20:30:12Z"
    }
  ],
  "promises_discussed": ["workout", "wake_up_early", "no_phone_after_9pm"],
  "promises_made": ["workout_tomorrow", "phone_in_other_room"],
  "excuses_given": ["too tired after work"],
  "sentiment": "defensive initially, committed at end"
}
```

### Call Types

| Type | When | Purpose |
|------|------|---------|
| `morning` | User's morning time | (Future) Morning check-in |
| `evening` | User's evening window | Daily accountability, promise review |
| `first_call` | After onboarding | Introduction, set expectations |
| `emergency` | User-triggered | On-demand support/accountability |
| `apology_call` | After broken promises | (Future) Escalation for failures |
| `daily_reckoning` | End of day | Complete daily review |

### Features Using This Table

**Backend**:
- **Webhook Handler** ([elevenlabs-webhooks.ts](be/src/routes/elevenlabs-webhooks.ts)) - Receives call data from 11labs
- **Call History API** ([brutal-daily.ts:getCallHistory](be/src/routes/brutal-daily.ts)) - GET `/api/history/calls`
- **Retry Processor** ([retry-processor.ts](be/src/services/retry-processor.ts)) - Handle missed calls
- **Brutal Daily** ([brutal-daily.ts](be/src/routes/brutal-daily.ts)) - Combine call + review

**Frontend (iOS)**:
- **Call History Screen** - List past calls with summaries
- **Call Detail View** - Full transcript, duration, promises discussed
- **Statistics** - Total calls, average duration, answer rate

### References
- Type definition: [database.ts:160-187](be/src/types/database.ts#L160)
- Webhook handler: [elevenlabs-webhooks.ts](be/src/routes/elevenlabs-webhooks.ts)
- Retry system: [retry-processor.ts](be/src/services/retry-processor.ts)

---

## 🧠 Table 7: `memory_embeddings`

**Purpose**: Vector embeddings for semantic search and pattern detection.

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | Foreign key → users |
| `source_id` | UUID | Foreign key to source table (promises/calls/etc) |
| `content_type` | TEXT | excuse/craving/demon/echo/pattern/breakthrough |
| `text_content` | TEXT | Original text that was vectorized |
| `embedding` | FLOAT[] | 1536-dimensional OpenAI vector |
| `metadata` | JSONB | Additional context (see structure below) |
| `created_at` | TIMESTAMP | When created |

### Content Types

| Type | Description | Source | Example |
|------|-------------|--------|---------|
| `excuse` | Reasons for broken promises | Promise excuse_text | "I was too tired" |
| `craving` | Temptations/urges mentioned | Call transcripts | "I really wanted to scroll my phone" |
| `demon` | Negative patterns/thoughts | Call transcripts | "I'm not good enough anyway" |
| `echo` | Repeated phrases/beliefs | Call transcripts | "I'll start tomorrow" (said 5+ times) |
| `pattern` | Behavioral patterns | AI analysis | "Always quits after 3 days" |
| `breakthrough` | Positive moments | Call transcripts | "I actually did it without excuses" |

### Metadata Structure

```json
{
  "source_table": "promises",
  "source_date": "2024-01-15",
  "promise_id": "uuid",
  "call_id": "uuid",
  "frequency_count": 3,
  "first_occurrence": "2024-01-10",
  "last_occurrence": "2024-01-15",
  "context": "evening call discussion"
}
```

### How Embeddings Work

1. **Content Extraction**: System identifies key phrases from promises/calls
2. **Vectorization**: OpenAI `text-embedding-ada-002` creates 1536D vector
3. **Storage**: Vector stored alongside original text
4. **Semantic Search**: Find similar content by vector similarity (cosine distance)
5. **Pattern Detection**: Cluster similar excuses/patterns

### Use Cases

**Excuse Analysis**:
- "I'm too tired" → Find all similar excuses semantically
- Cluster excuses by theme (energy, time, motivation)
- Show user their excuse patterns

**Behavioral Insights**:
- Detect emerging patterns (new excuses appearing frequently)
- Identify breakthrough moments (sudden positive changes)
- Track "demons" (recurring negative thoughts)

**AI Personalization**:
- Search memories during calls: "Have you made this excuse before?"
- Reference past breakthroughs: "Remember when you overcame this?"
- Predict failure patterns: "This is your usual Wednesday weakness"

### Features Using This Table

**Backend**:
- **Memory Ingestion** ([memory-ingestion-service.ts](be/src/services/memory-ingestion-service.ts)) - Create embeddings
- **Embedding Services**:
  - [identity.ts](be/src/services/embedding-services/identity.ts) - Identity-related memories
  - [behavioral.ts](be/src/services/embedding-services/behavioral.ts) - Pattern detection
  - [calls.ts](be/src/services/embedding-services/calls.ts) - Call transcript memories
  - [patterns.ts](be/src/services/embedding-services/patterns.ts) - Excuse clustering
- **Search Tool** ([searchMemories.ts](be/src/routes/tool-handlers/searchMemories.ts)) - Vector search during calls
- **Pattern Analysis** ([analyzeExcusePattern.ts](be/src/routes/tool-handlers/analyzeExcusePattern.ts)) - Excuse clustering

**Frontend (iOS)**:
- **Pattern View** - Visual representation of excuse clusters
- **Insight Cards** - "You've used this excuse 5 times this month"
- **Breakthrough Timeline** - Positive moments highlighted

### References
- Type definition: [database.ts:197-206](be/src/types/database.ts#L197)
- Memory ingestion: [memory-ingestion-service.ts](be/src/services/memory-ingestion-service.ts)
- Embedding services: [embedding-services/](be/src/services/embedding-services/)
- Search handler: [tool-handlers/searchMemories.ts](be/src/routes/tool-handlers/searchMemories.ts)

---

## 🐛 Table 8: `voip_debug_events`

**Purpose**: Debug logging for VoIP push notification troubleshooting (development only).

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `event_type` | TEXT | registration/push_received/call_initiated/error |
| `event_data` | JSONB | Complete event details |
| `device_info` | JSONB | iOS version, app version, device model |
| `timestamp` | TIMESTAMP | When event occurred |
| `user_id` | UUID | Optional user ID |

### Event Types

| Type | When Logged | Purpose |
|------|-------------|---------|
| `registration` | Push token registered | Verify token reaches backend |
| `push_received` | VoIP push arrives | Confirm APNS delivery |
| `call_initiated` | Call setup starts | Track call flow |
| `call_answered` | User picks up | Measure answer rate |
| `call_failed` | Connection error | Debug failures |
| `error` | Any error | General debugging |

### Features Using This Table

**Backend**:
- **Debug Routes** ([voip-debug.ts](be/src/routes/voip-debug.ts)):
  - POST `/debug/voip` - Log event
  - GET `/debug/voip` - Retrieve events
  - GET `/debug/voip/summary` - Event statistics
  - DELETE `/debug/voip` - Clear logs

**Frontend (iOS)**:
- **Debug Panel** - View VoIP events in app
- **Auto-logging** - Automatic event capture in dev builds
- **Error Reports** - Send debug data to support

### References
- Debug routes: [voip-debug.ts](be/src/routes/voip-debug.ts)
- Type definition: Defined in voip-debug route file

---

## 🎨 Complete Feature List

### Backend Features

#### Authentication & Authorization
- **Supabase Auth Integration** ([auth.ts](be/src/middleware/auth.ts))
  - JWT token validation
  - Session management
  - User lookup by ID or email
- **Subscription Verification** ([auth.ts](be/src/middleware/auth.ts))
  - RevenueCat status check
  - Subscription middleware (`requireActiveSubscription`)
- **Security Middleware** ([security.ts](be/src/middleware/security.ts))
  - CORS headers for mobile app
  - Rate limiting
  - Debug access token protection
  - Security headers (HSTS, CSP, etc.)

#### Onboarding System
- **45-Step Onboarding Flow** ([onboarding.ts](be/src/routes/onboarding.ts))
  - Accept all 45 responses in single request
  - Process voice recordings, text, choices
- **File Processing** ([onboardingFileProcessor.ts](be/src/utils/onboardingFileProcessor.ts))
  - Base64 → binary conversion
  - Upload to Cloudflare R2 cloud storage
  - Replace URLs in responses
- **Voice Transcription** ([ai-psychological-analyzer.ts:40-76](be/src/services/ai-psychological-analyzer.ts#L40))
  - Deepgram Nova-2 API
  - Smart format + punctuation
  - Error handling for empty/corrupted audio
- **Identity Extraction** ([unified-identity-extractor.ts](be/src/services/unified-identity-extractor.ts))
  - Orchestrates AI analysis
  - Extracts 15 identity fields
  - Fallback to operational fields
- **AI Psychological Analysis** ([ai-psychological-analyzer.ts](be/src/services/ai-psychological-analyzer.ts))
  - GitHub Models (GPT-4o-mini)
  - Extract 13 psychological fields
  - Parse and validate AI response

#### Identity Management
- **Identity API** ([identity.ts](be/src/routes/identity.ts))
  - GET `/api/identity/:userId` - Complete profile
  - PUT `/api/identity/:userId` - Update profile
  - PUT `/api/identity/status/:userId` - Update metrics
  - PUT `/api/identity/final-oath/:userId` - Record oath
  - GET `/api/identity/stats/:userId` - Performance stats
- **Identity Status Sync** ([identity-status-sync.ts](be/src/utils/identity-status-sync.ts))
  - Calculate trust %, streak, promise counts
  - Generate AI discipline messages
  - Heuristic fallback if AI fails

#### Call System
- **Call Configuration** ([11labs-call-init.ts](be/src/routes/11labs-call-init.ts))
  - Generate 11labs call config
  - Include personalized prompt
  - Voice clone ID, tools, functions
- **Prompt Engine** ([prompt-engine/](be/src/services/prompt-engine/))
  - Mode-based prompt generation
  - User context injection
  - Onboarding intelligence
  - Behavioral insights
- **Scheduler Engine** ([scheduler-engine.ts](be/src/services/scheduler-engine.ts))
  - Timezone-aware scheduling
  - Process eligible users
  - Trigger VoIP pushes
- **VoIP Push Service** ([push-notification-service.ts](be/src/services/push-notification-service.ts))
  - APNS integration
  - Certificate validation
  - Payload creation
  - Delivery tracking
- **Call Retry System** ([retry-processor.ts](be/src/services/retry-processor.ts))
  - Handle missed calls
  - Escalating urgency
  - Timeout management
  - Retry attempt tracking
- **Webhook Handler** ([elevenlabs-webhooks.ts](be/src/routes/elevenlabs-webhooks.ts))
  - Receive call events from 11labs
  - Store transcripts
  - Process call results
  - Extract promises/excuses

#### Promise Management
- **Promise Tool Functions** ([tool-handlers/](be/src/routes/tool-handlers/))
  - Create promise ([createPromise.ts](be/src/routes/tool-handlers/createPromise.ts))
  - Complete promise ([completePromise.ts](be/src/routes/tool-handlers/completePromise.ts))
  - Get excuse history ([getExcuseHistory.ts](be/src/routes/tool-handlers/getExcuseHistory.ts))
  - Analyze excuse patterns ([analyzeExcusePattern.ts](be/src/routes/tool-handlers/analyzeExcusePattern.ts))

#### Intelligence & Context
- **User Context Provider** ([database.ts:getUserContext](be/src/utils/database.ts))
  - Complete user profile
  - Recent promises
  - Call history
  - Memory insights
  - Statistics
- **Tool Functions for AI** ([tool-handlers/](be/src/routes/tool-handlers/))
  - getUserContext - Complete profile
  - getOnboardingIntelligence - Onboarding insights
  - getPsychologicalProfile - Deep analysis
  - analyzeBehavioralPatterns - Pattern detection
  - detectBreakthroughMoments - Positive moments
  - searchMemories - Vector search

#### Memory & Embeddings
- **Memory Ingestion** ([memory-ingestion-service.ts](be/src/services/memory-ingestion-service.ts))
  - Create OpenAI embeddings
  - Classify content types
  - Store with metadata
- **Embedding Services** ([embedding-services/](be/src/services/embedding-services/))
  - Identity embeddings
  - Behavioral pattern detection
  - Call transcript processing
  - Pattern clustering
- **Vector Search** ([searchMemories.ts](be/src/routes/tool-handlers/searchMemories.ts))
  - Semantic similarity search
  - Excuse pattern matching
  - Breakthrough detection

#### Brutal Reality System
- **Brutal Reality Engine** ([brutal-reality-engine.ts](be/src/services/brutal-reality-engine.ts))
  - Generate daily performance reviews
  - Use identity + promises + calls
  - Brutal but motivating tone
- **Brutal Reality API** ([brutal-reality.ts](be/src/routes/brutal-reality.ts))
  - GET `/api/brutal-reality/today` - Today's review
  - GET `/api/brutal-reality/history` - Past reviews
  - POST `/api/brutal-reality/generate` - Force regenerate
  - POST `/api/brutal-reality/interaction` - Track interactions
- **Brutal Daily** ([brutal-daily.ts](be/src/routes/brutal-daily.ts))
  - Combine brutal reality + call summary
  - GET `/api/brutal-daily/today`
  - GET `/api/brutal-daily/:date`
  - GET `/api/brutal-daily/history`

#### Voice Cloning
- **Voice Clone Service** ([voice-cloning.ts](be/src/services/voice-cloning.ts))
  - 11labs API integration
  - Upload voice samples
  - Create voice clone
  - Store voice_clone_id
- **Voice Clone API** ([voice.ts](be/src/routes/voice.ts))
  - POST `/voice/clone` - Create clone
  - POST `/onboarding/analyze-voice` - Pre-clone analysis

#### Settings & Configuration
- **Settings API** ([settings.ts](be/src/routes/settings.ts))
  - GET `/api/settings/schedule` - Get schedule
  - PUT `/api/settings/subscription-status` - Update status
  - PUT `/api/settings/revenuecat-customer-id` - Link RevenueCat
  - GET `/api/calls/eligibility` - Check call eligibility

#### Admin & Debug
- **Debug Routes** ([triggers.ts](be/src/routes/triggers.ts), [voip-debug.ts](be/src/routes/voip-debug.ts))
  - Manual call triggers
  - VoIP debug logging
  - Schedule inspection
  - Transcription retry
  - Identity re-extraction
- **Health Checks** ([health.ts](be/src/routes/health.ts))
  - System status
  - Statistics
  - Schedule overview

### Frontend Features (iOS)

#### Authentication
- **AuthService** ([AuthService.swift](swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/Services/AuthService.swift))
  - Supabase Auth integration
  - Sign in with Apple
  - Sign in with Google
  - Session persistence
  - Auto-refresh tokens
- **Auth Screens**
  - Welcome screen
  - Sign in screen
  - Sign up screen

#### Onboarding
- **45-Step Onboarding Flow**
  - Progressive disclosure
  - Voice recording (15+ steps)
  - Text input
  - Choice selection
  - Dual sliders
  - Time pickers
  - Timezone selection
  - Long press activation
- **Local State Management**
  - Save progress in memory
  - Resume capability
  - Validation per step
- **File Upload**
  - Convert to base64
  - Embed in JSON payload
  - Single submission to backend

#### Main Features
- **Home Screen**
  - Trust percentage display
  - Current streak
  - Discipline message
  - Next call countdown
  - Quick actions
- **Promise Management**
  - Today's promises list
  - Promise history
  - Kept/broken status
  - Excuse viewing
  - Statistics
- **Call History**
  - Past calls list
  - Call details
  - Transcript viewing
  - Duration, date, type
  - Success rate
- **Identity Profile**
  - View psychological profile
  - Edit identity fields
  - Progress tracking
  - Transformation timeline
- **Brutal Reality**
  - Daily performance review
  - Review history
  - Interaction tracking
  - Swipe to dismiss
- **Settings**
  - Edit name, timezone
  - Call window configuration
  - Subscription management
  - Voice reclone (1/month)
  - Schedule changes (2/month)
  - Notification preferences

#### VoIP System
- **VoIP Push Integration**
  - APNS token registration
  - Background wake-up
  - CallKit integration
  - Call UI
- **Call Management**
  - Answer/decline
  - Audio routing
  - Connection to 11labs
  - Real-time conversation

#### Subscription
- **RevenueCat Integration**
  - Paywall display
  - Purchase flow
  - Restore purchases
  - Subscription status sync
- **Trial Management**
  - Trial period display
  - Expiration countdown
  - Upgrade prompts

---

## 🔗 Database Relationships

```
users (central hub)
├──> identity (1:1)
│    └──> Used by: prompt engine, brutal reality, tool functions
├──> identity_status (1:1)
│    └──> Updated by: promise completion, sync function
├──> onboarding (1:1)
│    └──> Used by: identity extraction, re-extraction
├──> promises (1:many)
│    └──> Drives: identity_status calculations, call discussions
├──> calls (1:many)
│    └──> Generates: promises, excuses, transcripts
├──> memory_embeddings (1:many)
│    └──> Sources: promises.excuse_text, calls.transcript_json
└──> voip_debug_events (1:many)
     └──> Development debugging only
```

---

## 📊 Data Flow Examples

### Example 1: Evening Accountability Call

1. **Scheduler triggers** (cron: every minute)
   - Checks `users` table for eligible users (call_window_start)
   - Filters by `subscription_status = 'active'`
2. **VoIP push sent** via APNS
   - Uses `users.push_token`
3. **User answers call**
   - iOS app connects to 11labs
   - 11labs requests config via GET `/call/:userId/evening`
4. **Backend generates prompt**
   - Fetches `identity` + `identity_status` + `promises` (today)
   - Prompt engine creates personalized instructions
5. **AI conducts call**
   - Asks about each promise in `promises` table
   - User reports kept/broken
   - AI extracts excuses
6. **AI calls tool functions**
   - POST `/tool/function/completePromise` (per promise)
   - Updates `promises.status` + `promises.excuse_text`
   - POST `/tool/function/createPromise` (tomorrow's promises)
7. **Call ends**
   - 11labs sends webhook with transcript
   - Backend saves to `calls` table
8. **Post-processing**
   - `syncIdentityStatus()` recalculates metrics
   - Updates `identity_status.trust_percentage`, `current_streak_days`
   - OpenAI generates new discipline message
9. **Memory creation**
   - Excuses embedded via OpenAI
   - Saved to `memory_embeddings` with type='excuse'

### Example 2: Onboarding to First Call

1. **User completes onboarding** (iOS app)
   - 45 steps completed locally
   - Voice recordings converted to base64
2. **User pays** (RevenueCat)
   - `users.subscription_status = 'active'`
3. **User signs up** (Supabase Auth)
   - Account created in `users` table
4. **iOS submits onboarding** POST `/onboarding/v3/complete`
   - All 45 responses in JSONB
   - Files uploaded to R2
5. **Backend processes**
   - Saves to `onboarding.responses`
   - Updates `users` (name, timezone, call_window_start)
   - Triggers identity extraction
6. **Identity extraction**
   - Voice URLs transcribed (Deepgram)
   - AI analyzes all responses (GitHub Models)
   - 15 fields extracted
   - Saved to `identity` table
7. **Identity status init**
   - Creates `identity_status` record
   - trust_percentage = 100, streak = 0
   - AI generates initial discipline message
8. **User ready**
   - `users.onboarding_completed = true`
   - Eligible for first call that evening

### Example 3: Excuse Pattern Analysis

1. **User breaks promise** multiple times
   - Each excuse stored in `promises.excuse_text`
2. **Memory ingestion** (background job)
   - Excuse text embedded via OpenAI
   - Saved to `memory_embeddings` (type='excuse')
3. **AI call requests pattern analysis**
   - POST `/tool/function/analyzeExcusePattern`
   - Backend performs vector similarity search
   - Clusters similar excuses
4. **AI references pattern**
   - "You've said 'I'm too tired' 5 times this month"
   - "This is your go-to escape route"
5. **User sees pattern**
   - Frontend displays excuse clusters
   - Visual representation of recurring themes

---

## 🔑 Key Takeaways

1. **8 Core Tables**: users, identity, identity_status, onboarding, promises, calls, memory_embeddings, voip_debug_events
2. **AI-Powered**: 3 AI services (Deepgram, OpenAI/GitHub Models, 11labs) drive the system
3. **Real-Time Tracking**: identity_status synced on every promise completion
4. **Vector Search**: Memory embeddings enable semantic pattern detection
5. **Complete Lifecycle**: Onboarding → Identity → Calls → Promises → Status → Repeat

---

## 📚 Quick Reference

| Want to understand... | Read this | File reference |
|----------------------|-----------|----------------|
| How identity is created | Identity section + [IDENTITY.md](IDENTITY.md) | [unified-identity-extractor.ts](be/src/services/unified-identity-extractor.ts) |
| How calls work | Calls section + Call System features | [scheduler-engine.ts](be/src/services/scheduler-engine.ts) |
| How promises are tracked | Promises section | [tool-handlers/createPromise.ts](be/src/routes/tool-handlers/createPromise.ts) |
| How trust % is calculated | Identity Status section | [identity-status-sync.ts:62-65](be/src/utils/identity-status-sync.ts#L62) |
| How embeddings work | Memory Embeddings section | [memory-ingestion-service.ts](be/src/services/memory-ingestion-service.ts) |
| All API routes | [ROUTES.md](ROUTES.md) | [index.ts](be/src/index.ts) |

---

*Last updated: 2025-01-11*
