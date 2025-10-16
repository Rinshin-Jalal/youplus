# BIG BRUH Backend API Routes Documentation

Complete reference for all backend routes grouped by functional area.

---

## 🏥 Health & Status Routes

Routes for checking backend health and system status.

### GET `/`
- **Purpose**: Health check endpoint
- **Auth**: None
- **Handler**: [health.ts:getHealth](be/src/routes/health.ts)
- **Returns**: System status and version info

### GET `/stats`
- **Purpose**: Get backend statistics (users, calls, promises)
- **Auth**: None
- **Handler**: [health.ts:getStats](be/src/routes/health.ts)
- **Returns**: Aggregated system statistics

### GET `/test`
- **Purpose**: Simple connectivity test
- **Auth**: None
- **Returns**: Success message with timestamp

---

## 🆔 Identity Management Routes

Routes for managing user identity, psychological profile, and transformation goals.

### GET `/api/identity/:userId`
- **Purpose**: Get complete identity profile with psychological data
- **Auth**: Requires active subscription + must be own identity
- **Handler**: [identity.ts:getCurrentIdentity](be/src/routes/identity.ts:57)
- **Process**:
  1. Fetches identity record from `identity` table (60+ psychological fields)
  2. Fetches identity_status record (trust %, streak, promise counts)
  3. Calculates next call timestamp if not set
  4. Fetches call statistics (total calls, answered calls, success rate)
  5. Calculates days active since identity creation
- **Returns**:
  ```json
  {
    "success": true,
    "data": {
      "id": "uuid",
      "name": "John",
      "summary": "AI-analyzed identity profile",
      "createdAt": "2024-01-15T10:30:00Z",
      "daysActive": 45,
      "current_identity": "Who they are now",
      "aspirated_identity": "Who they want to become",
      "fear_identity": "Who they fear becoming",
      "core_struggle": "Their main struggle",
      "biggest_enemy": "What defeats them",
      "primary_excuse": "Their go-to excuse",
      "trustPercentage": 85,
      "currentStreakDays": 7,
      "promisesMadeCount": 15,
      "promisesBrokenCount": 2,
      "stats": {
        "totalCalls": 20,
        "answeredCalls": 18,
        "successRate": 90
      }
    }
  }
  ```

### PUT `/api/identity/:userId`
- **Purpose**: Update identity profile with new psychological insights
- **Auth**: Requires active subscription + must be own identity
- **Handler**: [identity.ts:updateIdentity](be/src/routes/identity.ts:269)
- **Body**: Any identity fields (identity_name, current_struggle, nightmare_self, etc.)
- **Returns**: Updated identity record

### PUT `/api/identity/status/:userId`
- **Purpose**: Update identity status (trust %, streak, promise counts)
- **Auth**: Requires active subscription + must be own identity
- **Handler**: [identity.ts:updateIdentityStatus](be/src/routes/identity.ts:343)
- **Body**:
  ```json
  {
    "trustPercentage": 85,
    "currentStreakDays": 7,
    "promisesMadeCount": 15,
    "promisesBrokenCount": 2
  }
  ```
- **Returns**: Updated status record

### PUT `/api/identity/final-oath/:userId`
- **Purpose**: Record user's final, binding oath (ultimate commitment)
- **Auth**: Requires active subscription + must be own identity
- **Handler**: [identity.ts:updateFinalOath](be/src/routes/identity.ts:411)
- **Body**: `{ "finalOath": "I will never give up..." }`
- **Returns**: Updated identity with final oath

### GET `/api/identity/stats/:userId`
- **Purpose**: Get comprehensive performance statistics for identity journey
- **Auth**: Requires active subscription + must be own identity
- **Handler**: [identity.ts:getIdentityStats](be/src/routes/identity.ts:474)
- **Returns**:
  ```json
  {
    "success": true,
    "data": {
      "daysActive": 45,
      "trustPercentage": 85,
      "currentStreakDays": 7,
      "promises": {
        "total": 15,
        "kept": 13,
        "broken": 2,
        "successRate": 87
      },
      "calls": {
        "total": 20,
        "answered": 18,
        "answerRate": 90
      },
      "performance": {
        "trending": "excellent",
        "consistencyScore": 7
      }
    }
  }
  ```

---

## 🎓 Onboarding Routes

Routes for completing onboarding flow and extracting psychological profile.

### POST `/onboarding/v3/complete`
- **Purpose**: Complete 45-step V3 onboarding flow (main endpoint)
- **Auth**: Requires active subscription (user must have paid + signed up)
- **Handler**: [onboarding.ts:postOnboardingV3Complete](be/src/routes/onboarding.ts:76)
- **Process**:
  1. Receives complete onboarding state from frontend (45 responses)
  2. Processes files (uploads audio/images to R2 cloud storage)
  3. Saves responses to `onboarding` table (JSONB format)
  4. Updates `users` table (onboarding_completed, name, timezone, call_window)
  5. Auto-triggers identity extraction using unified AI extractor
  6. Initializes identity status with AI-generated messages
- **Body**:
  ```json
  {
    "state": {
      "currentStep": 45,
      "responses": {
        "step_1": {
          "type": "voice",
          "value": "data:audio/m4a;base64,...",
          "db_field": ["identity_name"]
        },
        "step_2": { ... }
      },
      "userName": "John",
      "brotherName": "Executor",
      "userTimezone": "America/New_York"
    }
  }
  ```
- **Returns**:
  ```json
  {
    "success": true,
    "message": "Onboarding completed successfully",
    "completedAt": "2024-01-15T10:30:00Z",
    "totalSteps": 45,
    "filesProcessed": 8,
    "identityExtraction": {
      "success": true,
      "fieldsExtracted": 13
    }
  }
  ```

### POST `/onboarding/extract-data`
- **Purpose**: Re-extract psychological profile from existing onboarding responses
- **Auth**: Requires active subscription
- **Handler**: [onboarding.ts:postExtractOnboardingData](be/src/routes/onboarding.ts:411)
- **Use Cases**:
  - Users who completed onboarding before AI extraction was implemented
  - Debugging/testing identity extraction
  - Refreshing psychological profile with updated AI
- **Process**:
  1. Fetches existing responses from `onboarding` table
  2. Runs unified identity extraction (voice transcription + AI analysis)
  3. Updates `identity` table with extracted psychological insights
- **Returns**:
  ```json
  {
    "success": true,
    "message": "UNIFIED data extraction completed successfully",
    "unifiedExtraction": {
      "success": true,
      "fieldsExtracted": 13
    }
  }
  ```

### POST `/onboarding/analyze-voice`
- **Purpose**: Analyze voice sample during onboarding (pre-auth)
- **Auth**: None (pre-authentication onboarding step)
- **Handler**: [voice.ts:postOnboardingAnalyzeVoice](be/src/routes/voice.ts)
- **Returns**: Voice analysis results for onboarding guidance

---

## 📞 Call Management Routes

Routes for triggering calls, getting call configs, and viewing call history.

### POST `/call/:userId/:callType`
- **Purpose**: Get call configuration for 11labs conversational AI
- **Auth**: Requires active subscription
- **Handler**: [11labs-call-init.ts:getCallConfig](be/src/routes/11labs-call-init.ts)
- **URL Params**:
  - `userId`: User UUID
  - `callType`: morning | evening | daily_reckoning | first_call | emergency
- **Process**:
  1. Fetches user identity and psychological profile
  2. Generates personalized prompt using prompt engine
  3. Retrieves voice clone ID
  4. Returns 11labs call configuration with tools and custom instructions
- **Returns**: 11labs call config JSON (prompt, voice_id, tools, etc.)

### GET `/api/history/calls`
- **Purpose**: Get user's call history with transcripts
- **Auth**: Requires active subscription
- **Handler**: [brutal-daily.ts:getCallHistory](be/src/routes/brutal-daily.ts)
- **Returns**: Array of call records with transcripts and summaries

### GET `/api/calls/eligibility`
- **Purpose**: Check if user is eligible for calls right now
- **Auth**: Requires authentication
- **Handler**: [settings.ts:getCallEligibility](be/src/routes/settings.ts)
- **Returns**: Eligibility status with next call timestamp

---

## 🎯 Promise Management Routes (via Tool Functions)

Routes for creating and completing promises during calls (called by 11labs AI).

### POST `/tool/function/createPromise`
- **Purpose**: Create a new promise during accountability call
- **Auth**: Requires active subscription
- **Handler**: [tool-handlers/createPromise.ts](be/src/routes/tool-handlers/createPromise.ts)
- **Body**:
  ```json
  {
    "userId": "uuid",
    "promiseText": "I will wake up at 6am tomorrow",
    "promiseDate": "2024-01-16",
    "priority": "high",
    "timeSpecific": true,
    "targetTime": "06:00"
  }
  ```
- **Returns**: Created promise record

### POST `/tool/function/completePromise`
- **Purpose**: Mark promise as kept or broken during evening call
- **Auth**: Requires active subscription
- **Handler**: [tool-handlers/completePromise.ts](be/src/routes/tool-handlers/completePromise.ts)
- **Body**:
  ```json
  {
    "userId": "uuid",
    "promiseId": "uuid",
    "status": "kept" | "broken",
    "excuseText": "I was too tired" // if broken
  }
  ```
- **Returns**: Updated promise record

---

## 🧠 AI Tool Function Routes

Routes for AI-powered intelligence gathering during calls (called by 11labs AI).

### POST `/tool/function/getUserContext`
- **Purpose**: Get complete user context for AI call personalization
- **Auth**: Requires active subscription
- **Handler**: [tool-handlers/getUserContext.ts](be/src/routes/tool-handlers/getUserContext.ts)
- **Returns**: Complete psychological profile, promises, call history, patterns

### POST `/tool/function/getOnboardingIntelligence`
- **Purpose**: Get intelligence from onboarding responses
- **Auth**: Requires active subscription
- **Handler**: [tool-handlers/getOnboardingIntelligence.ts](be/src/routes/tool-handlers/getOnboardingIntelligence.ts)
- **Returns**: Extracted insights from onboarding (goals, fears, struggles)

### POST `/tool/function/getPsychologicalProfile`
- **Purpose**: Get deep psychological assessment for call strategy
- **Auth**: Requires active subscription
- **Handler**: [tool-handlers/getPsychologicalProfile.ts](be/src/routes/tool-handlers/getPsychologicalProfile.ts)
- **Returns**: Psychological profile with triggers, patterns, vulnerabilities

### POST `/tool/function/analyzeBehavioralPatterns`
- **Purpose**: Analyze user's behavioral patterns over time
- **Auth**: Requires active subscription
- **Handler**: [tool-handlers/analyzeBehavioralPatterns.ts](be/src/routes/tool-handlers/analyzeBehavioralPatterns.ts)
- **Returns**: Behavioral insights (when they break, what triggers them, etc.)

### POST `/tool/function/analyzeExcusePattern`
- **Purpose**: Analyze user's excuse patterns to counter them
- **Auth**: Requires active subscription
- **Handler**: [tool-handlers/analyzeExcusePattern.ts](be/src/routes/tool-handlers/analyzeExcusePattern.ts)
- **Returns**: Excuse pattern analysis with counter-strategies

### POST `/tool/function/getExcuseHistory`
- **Purpose**: Get history of user's excuses for broken promises
- **Auth**: Requires active subscription
- **Handler**: [tool-handlers/getExcuseHistory.ts](be/src/routes/tool-handlers/getExcuseHistory.ts)
- **Returns**: Array of excuse records with frequency and patterns

### POST `/tool/function/detectBreakthroughMoments`
- **Purpose**: Detect moments where user showed breakthrough behavior
- **Auth**: Requires active subscription
- **Handler**: [tool-handlers/detectBreakthroughMoments.ts](be/src/routes/tool-handlers/detectBreakthroughMoments.ts)
- **Returns**: Breakthrough moments for positive reinforcement

### POST `/tool/function/deliverConsequence`
- **Purpose**: Deliver psychological consequence for broken promise
- **Auth**: Requires active subscription
- **Handler**: [tool-handlers/deliverConsequence.ts](be/src/routes/tool-handlers/deliverConsequence.ts)
- **Returns**: Consequence delivered confirmation

### POST `/tool/function/searchMemories`
- **Purpose**: Search user's memories using vector embeddings
- **Auth**: Requires active subscription
- **Handler**: [tool-handlers/searchMemories.ts](be/src/routes/tool-handlers/searchMemories.ts)
- **Returns**: Relevant memories matching search query

---

## 📊 Brutal Reality Routes

Routes for AI-generated daily performance reviews and psychological warfare.

### GET `/api/brutal-reality/today`
- **Purpose**: Get today's brutal reality review (AI-generated assessment)
- **Auth**: Requires active subscription
- **Handler**: [brutal-reality.ts:getTodayBrutalReality](be/src/routes/brutal-reality.ts)
- **Returns**: Brutal assessment of today's performance

### GET `/api/brutal-reality/history`
- **Purpose**: Get history of brutal reality reviews
- **Auth**: Requires active subscription
- **Handler**: [brutal-reality.ts:getBrutalRealityHistory](be/src/routes/brutal-reality.ts)
- **Returns**: Array of past brutal reality reviews

### POST `/api/brutal-reality/generate`
- **Purpose**: Force regeneration of brutal reality review
- **Auth**: Requires active subscription
- **Handler**: [brutal-reality.ts:regenerateBrutalReality](be/src/routes/brutal-reality.ts)
- **Returns**: Newly generated brutal reality review

### POST `/api/brutal-reality/interaction`
- **Purpose**: Track user interaction with brutal reality (read, dismissed, etc.)
- **Auth**: Requires active subscription
- **Handler**: [brutal-reality.ts:trackBrutalRealityInteraction](be/src/routes/brutal-reality.ts)
- **Returns**: Interaction tracking confirmation

---

## 📅 Brutal Daily Routes

Routes for daily summaries combining brutal reality + call transcripts.

### GET `/api/brutal-daily/today`
- **Purpose**: Get today's brutal daily (combined brutal + short summary)
- **Auth**: Requires active subscription
- **Handler**: [brutal-daily.ts:getBrutalDailyToday](be/src/routes/brutal-daily.ts)
- **Returns**: Today's combined daily summary

### GET `/api/brutal-daily/:date`
- **Purpose**: Get brutal daily for specific date
- **Auth**: Requires active subscription
- **Handler**: [brutal-daily.ts:getBrutalDailyByDate](be/src/routes/brutal-daily.ts)
- **URL Params**: `date` in format YYYY-MM-DD
- **Returns**: Brutal daily summary for specified date

### GET `/api/brutal-daily/history`
- **Purpose**: Get history of brutal daily summaries
- **Auth**: Requires active subscription
- **Handler**: [brutal-daily.ts:getBrutalDailyHistory](be/src/routes/brutal-daily.ts)
- **Returns**: Array of past brutal daily summaries

---

## ⚙️ Settings Routes

Routes for managing user settings, schedule, and subscription.

### GET `/api/settings/schedule`
- **Purpose**: Get user's call schedule settings
- **Auth**: Requires active subscription
- **Handler**: [settings.ts:getScheduleSettings](be/src/routes/settings.ts)
- **Returns**: Call window, timezone, schedule preferences

### PUT `/api/settings/subscription-status`
- **Purpose**: Update subscription status (internal use)
- **Auth**: Requires authentication
- **Handler**: [settings.ts:updateSubscriptionStatus](be/src/routes/settings.ts)
- **Body**: `{ "subscriptionStatus": "active" | "cancelled" | "past_due" }`
- **Returns**: Updated user record

### PUT `/api/settings/revenuecat-customer-id`
- **Purpose**: Link RevenueCat customer ID to user account
- **Auth**: Requires authentication
- **Handler**: [settings.ts:updateRevenueCatCustomerId](be/src/routes/settings.ts)
- **Body**: `{ "revenueCatCustomerId": "rc_customer_123" }`
- **Returns**: Updated user record

---

## 🔔 Push Notification Routes

Routes for registering and managing push tokens.

### PUT `/api/device/push-token`
### POST `/api/device/push-token`
- **Purpose**: Register or update device push token for VoIP notifications
- **Auth**: Requires authentication
- **Handler**: [token-init-push.ts:postUserPushToken](be/src/routes/token-init-push.ts)
- **Body**: `{ "pushToken": "apns_token_here" }`
- **Returns**: Confirmation of token registration

---

## 🎙️ Voice & Audio Routes

Routes for voice cloning and audio processing.

### POST `/voice/clone`
- **Purpose**: Create voice clone using 11labs API
- **Auth**: Requires active subscription
- **Handler**: [voice.ts:postVoiceClone](be/src/routes/voice.ts)
- **Body**: Audio file(s) for voice cloning
- **Returns**: Voice clone ID from 11labs

### POST `/transcribe/audio`
- **Purpose**: Transcribe audio using Deepgram API
- **Auth**: Requires active subscription
- **Handler**: [transcription.ts:postTranscribeAudio](be/src/routes/transcription.ts)
- **Body**: Audio file to transcribe
- **Returns**: Transcript text

---

## 🔗 Webhook Routes

Routes for receiving webhooks from external services.

### GET `/webhook/elevenlabs`
- **Purpose**: Test endpoint for 11labs webhook
- **Auth**: None (public webhook endpoint)
- **Handler**: [elevenlabs-webhooks.ts:getElevenLabsWebhookTest](be/src/routes/elevenlabs-webhooks.ts)
- **Returns**: Success message

### POST `/webhook/elevenlabs`
- **Purpose**: Receive 11labs conversational AI webhooks
- **Auth**: None (public webhook endpoint, verified by signature)
- **Handler**: [elevenlabs-webhooks.ts:postElevenLabsWebhook](be/src/routes/elevenlabs-webhooks.ts)
- **Process**: Handles call status updates, conversation events, etc.

### POST `/webhook/elevenlabs/audio`
- **Purpose**: Receive 11labs audio webhooks
- **Auth**: None (public webhook endpoint, verified by signature)
- **Handler**: [elevenlabs-webhooks.ts:postElevenLabsAudioWebhook](be/src/routes/elevenlabs-webhooks.ts)
- **Process**: Handles audio recording uploads

---

## 🧪 Debug Routes (Development Only)

Routes for debugging and testing (only available in non-production environments).

### GET `/debug/schedules`
- **Purpose**: View scheduled call information for all users
- **Auth**: Debug access token required
- **Handler**: [health.ts:getDebugSchedules](be/src/routes/health.ts)
- **Returns**: Scheduled call data

### POST `/debug/voip`
- **Purpose**: Log VoIP debug events from iOS app
- **Auth**: None (development only)
- **Handler**: [voip-debug.ts:postVoIPDebug](be/src/routes/voip-debug.ts)
- **Body**: Debug event data
- **Returns**: Confirmation

### GET `/debug/voip`
- **Purpose**: Get VoIP debug events
- **Auth**: None (development only)
- **Handler**: [voip-debug.ts:getVoIPDebugEvents](be/src/routes/voip-debug.ts)
- **Returns**: Array of debug events

### GET `/debug/voip/summary`
- **Purpose**: Get VoIP debug summary
- **Auth**: None (development only)
- **Handler**: [voip-debug.ts:getVoIPDebugSummary](be/src/routes/voip-debug.ts)
- **Returns**: Debug event summary

### DELETE `/debug/voip`
- **Purpose**: Clear VoIP debug events
- **Auth**: None (development only)
- **Handler**: [voip-debug.ts:clearVoIPDebugEvents](be/src/routes/voip-debug.ts)
- **Returns**: Confirmation

### POST `/debug/onboarding/retry-transcription/:userId`
- **Purpose**: Retry audio transcription for onboarding responses
- **Auth**: Requires authentication + development only
- **Handler**: [index.ts:189](be/src/index.ts#L189)
- **Process**: Re-transcribes audio files with enhanced error handling
- **Returns**: Transcription results with insights

### POST `/debug/onboarding/retry-identity-extraction/:userId`
- **Purpose**: Retry identity extraction from onboarding data
- **Auth**: Requires authentication + development only
- **Handler**: [index.ts:544](be/src/index.ts#L544)
- **Process**: Re-runs unified identity extraction
- **Returns**: Identity extraction results

---

## 🔥 Admin Trigger Routes (Development Only)

Manual trigger routes for testing call systems (high security risk - token protected).

### POST `/trigger/morning`
- **Purpose**: Manually trigger morning calls for all eligible users
- **Auth**: Debug access token required
- **Handler**: [triggers.ts:triggerMorningCallsAdmin](be/src/routes/triggers.ts)
- **Returns**: Trigger confirmation

### POST `/trigger/evening`
- **Purpose**: Manually trigger evening calls for all eligible users
- **Auth**: Debug access token required
- **Handler**: [triggers.ts:triggerEveningCallsAdmin](be/src/routes/triggers.ts)
- **Returns**: Trigger confirmation

### POST `/trigger/user/:userId/:callType`
- **Purpose**: Manually trigger call for specific user
- **Auth**: Debug access token required
- **Handler**: [triggers.ts:triggerUserCallAdmin](be/src/routes/triggers.ts)
- **URL Params**:
  - `userId`: User UUID
  - `callType`: morning | evening | daily_reckoning | emergency
- **Returns**: Trigger confirmation

### POST `/trigger/voip`
- **Purpose**: Manually trigger VoIP push notification
- **Auth**: Debug access token required
- **Handler**: [triggers.ts:triggerVoipPushAdmin](be/src/routes/triggers.ts)
- **Returns**: VoIP push confirmation

### POST `/trigger/onboarding/:userId`
- **Purpose**: Manually trigger onboarding call
- **Auth**: None (development only)
- **Handler**: [index.ts:585](be/src/index.ts#L585)
- **URL Params**: `userId`: User UUID
- **Returns**: Onboarding call trigger confirmation

---

## 🧪 Demo Routes

Routes for testing and demonstrating prompt engine optimization.

### GET `/prompt-demo/:userId/:callType`
- **Purpose**: Demo prompt engine optimization
- **Auth**: Requires active subscription
- **Handler**: [prompt-engine-demo.ts:getPromptEngineDemo](be/src/routes/prompt-engine-demo.ts)
- **URL Params**:
  - `userId`: User UUID
  - `callType`: morning | evening | daily_reckoning
- **Returns**: Optimized prompt comparison

### GET `/prompt-demo-quick/:userId`
- **Purpose**: Quick demo of prompt generation
- **Auth**: Requires active subscription
- **Handler**: [prompt-engine-demo.ts:getQuickDemo](be/src/routes/prompt-engine-demo.ts)
- **URL Params**: `userId`: User UUID
- **Returns**: Quick prompt generation demo

---

## 📱 VoIP Session Routes

Routes for managing VoIP call sessions (mounted at `/voip/session`).

Handlers defined in: [voip-session.ts](be/src/routes/voip-session.ts)

---

## 🧪 VoIP Test Routes

Routes for testing VoIP functionality (mounted at `/voip`).

Handlers defined in: [voip-test.ts](be/src/routes/voip-test.ts)

---

## 🤖 AI Brutal Reality Routes

Additional AI-powered brutal reality routes (mounted at `/`).

Handlers defined in: [ai-brutal-reality.ts](be/src/routes/ai-brutal-reality.ts)

---

## ⏰ Scheduled Cron Jobs

Automated tasks that run on schedule (not HTTP routes).

### Scheduled Call Processing
- **Frequency**: Every minute (via Cloudflare Workers cron)
- **Handler**: [index.ts:handleScheduledEvent](be/src/index.ts#L846)
- **Process**:
  1. Checks for users who need a call and processes them
  2. Processes call timeouts and retries
  3. At 2am UTC: Updates nightly behavioral pattern profiles
- **Functions**:
  - `scheduler.processScheduledCalls()` - [scheduler-engine.ts](be/src/services/scheduler-engine.ts)
  - `processAllRetries()` - [retry-processor.ts](be/src/services/retry-processor.ts)
  - `updateNightlyPatternProfiles()` - [behavioral.ts](be/src/services/embedding-services/behavioral.ts)

---

## 🔐 Authentication & Authorization

### Authentication Middleware
- **Function**: `requireAuth` - [auth.ts](be/src/middleware/auth.ts)
- **Purpose**: Ensures user is authenticated via Supabase JWT
- **Returns 401** if authentication fails

### Subscription Middleware
- **Function**: `requireActiveSubscription` - [auth.ts](be/src/middleware/auth.ts)
- **Purpose**: Ensures user has active subscription via RevenueCat
- **Returns 403** if subscription is not active

### Security Middleware
- **Functions**: [security.ts](be/src/middleware/security.ts)
  - `securityHeaders()` - Adds security headers to all responses
  - `corsMiddleware()` - Handles CORS for mobile app
  - `rateLimit()` - Rate limiting protection
  - `debugProtection()` - Protects debug routes with access token

---

## 📊 Route Statistics

- **Total Routes**: 70+
- **Public Routes**: 5 (health, test, webhooks)
- **Authenticated Routes**: 40+
- **Subscription Required**: 35+
- **Debug Only**: 15+
- **Admin Trigger Routes**: 5+

---

## 🏗️ Backend Architecture

### Tech Stack
- **Framework**: Hono (lightweight web framework)
- **Runtime**: Cloudflare Workers
- **Database**: Supabase (PostgreSQL)
- **Storage**: Cloudflare R2 (audio/images)
- **AI Services**:
  - OpenAI GPT-4 (psychological analysis)
  - GitHub Models (AI extraction)
  - 11labs (voice cloning + conversational AI)
  - Deepgram (voice transcription)
- **Auth**: Supabase Auth (Google/Apple Sign-in)
- **Payments**: RevenueCat (subscription management)

### Key Services
- **Unified Identity Extractor**: [unified-identity-extractor.ts](be/src/services/unified-identity-extractor.ts)
- **AI Psychological Analyzer**: [ai-psychological-analyzer.ts](be/src/services/ai-psychological-analyzer.ts)
- **Identity Status Sync**: [identity-status-sync.ts](be/src/utils/identity-status-sync.ts)
- **Prompt Engine**: [prompt-engine/](be/src/services/prompt-engine/)
- **Scheduler Engine**: [scheduler-engine.ts](be/src/services/scheduler-engine.ts)
- **Voice Cloning**: [voice-cloning.ts](be/src/services/voice-cloning.ts)
- **R2 Upload**: [r2-upload.ts](be/src/services/r2-upload.ts)

---

## 🔍 Quick Reference

### Most Important Routes
1. **POST `/onboarding/v3/complete`** - Complete onboarding (triggers identity extraction)
2. **GET `/api/identity/:userId`** - Get complete identity profile
3. **POST `/call/:userId/:callType`** - Get call config for 11labs AI
4. **POST `/tool/function/*`** - AI tool functions called during calls
5. **GET `/api/brutal-daily/today`** - Get today's performance summary

### Call Flow
1. **Scheduled**: Cron job runs every minute, checks who needs a call
2. **VoIP Push**: System sends VoIP push notification to user's device
3. **User Answers**: iOS app accepts call, connects to 11labs
4. **Call Config**: 11labs fetches config via POST `/call/:userId/:callType`
5. **AI Conversation**: 11labs AI conducts call, uses tool functions to gather intelligence
6. **Promise Creation**: AI calls `/tool/function/createPromise` or `/tool/function/completePromise`
7. **Webhook**: 11labs sends webhook when call ends
8. **Processing**: Backend processes transcript, updates user data

### Identity Creation Flow
1. **Onboarding**: User completes 45-step onboarding (voice + text + choices)
2. **File Upload**: Audio/images uploaded to R2 cloud storage
3. **Voice Transcription**: Deepgram transcribes all voice responses
4. **AI Analysis**: OpenAI analyzes responses, extracts 13 psychological fields
5. **Identity Save**: Unified extractor saves to `identity` table
6. **Status Init**: Identity status initialized with AI-generated messages
7. **Ready**: User ready for daily accountability calls

---

*Last updated: 2025-01-11*
