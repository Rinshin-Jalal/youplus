# Onboarding System Feature

**Complete guide to the 45-step onboarding flow that captures user psychology.**

---

## 🎯 What is Onboarding?

Onboarding is the **45-step questionnaire** that every new user completes BEFORE creating an account. It's designed to extract deep psychological insights through a mix of voice recordings, text inputs, and choice selections.

Think of it as a psychological intake interview that captures who the user is, what they want, and what holds them back - all while they're fresh and committed.

---

## 📊 Database: `onboarding` Table

**Purpose**: Store all 45 raw responses in JSONB format.

**Key fields**:
- `user_id`: Links to user account (after auth)
- `responses`: JSONB with all 45 steps
- `created_at`, `updated_at`: Timestamps

**References**:
- Type definition: [be/src/types/database.ts:102-108](../../be/src/types/database.ts#L102)
- Full schema: [DATABASE.md - Table 4](../DATABASE.md#table-4-onboarding)

---

## 🎬 The 45-Step Journey

### Frontend (iOS): Progressive Disclosure

**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Onboarding/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Onboarding/)

**Design philosophy**: One question at a time. No overwhelming forms. Let user think deeply about each answer.

### Step Categories

#### Identity Formation (Steps 1-15)
**Purpose**: Understand WHO they are and want to become.

**Key steps**:
- **Step 3**: Identity name (what to call them)
- **Step 5**: Current situation voice recording
- **Step 6**: Desired outcome voice recording
- **Step 7**: Nightmare scenario voice recording
- **Step 8**: Past failure story (voice)
- **Step 9**: Enemy identification (what defeats them)
- **Step 10**: Procrastination patterns
- **Step 12-15**: Daily routine, habits, struggles

**Why voice**: Captures emotional tone. "I want to be disciplined" said with conviction vs defeat tells AI everything.

#### Behavioral Patterns (Steps 16-30)
**Purpose**: Understand HOW they behave and fail.

**Key steps**:
- **Step 16**: Weakness time window (when they break)
- **Step 17**: Sabotage methods
- **Step 18**: Accountability style preference
- **Step 19**: Daily non-negotiable commitment
- **Step 20**: Primary excuse (voice recording)
- **Step 22-25**: Success stories, triggers, motivations
- **Step 30**: Transformation target date

**Why these matter**: Pattern detection. If user says "I quit after 3 days" multiple times, AI knows their failure pattern.

#### System Configuration (Steps 31-45)
**Purpose**: Set up technical requirements for accountability.

**Key steps**:
- **Step 32**: Timezone selection
- **Step 33**: Evening call time window
- **Step 34**: Notification preferences
- **Step 35-40**: Voice recording for voice cloning (longer sample)
- **Step 41**: Final oath (voice)
- **Step 42**: Commitment confirmation
- **Step 43-45**: Agreement, review, submit

**Why voice cloning sample**: Need 30+ seconds of voice for 11labs to create accurate clone. Separate from short responses.

### Response Types

**Voice responses** (15+ steps):
- iOS uses AVFoundation to record
- Saved as M4A format
- Converted to base64 data URL
- Included in submission JSON
- Later uploaded to R2 and transcribed

**Why voice dominant**:
- Harder to lie in voice than text
- Captures personality and emotion
- Used for both psychology AND voice cloning
- More engaging than typing

**Text responses** (10-15 steps):
- Simple text input
- Used for names, dates, specific details
- Faster for operational data

**Choice responses** (10-15 steps):
- Single selection from options
- Examples: Enforcement tone, accountability style, time preferences
- Provides structured data for system config

**Special types**:
- Dual sliders: Rate two dimensions (e.g., desperation vs commitment)
- Time pickers: Select call window
- Timezone selector: For accurate scheduling
- Long press: Commitment activation (hold for 5 seconds)

---

## 🏗️ How Onboarding Works

### Frontend Flow

#### Phase 1: Local Storage
**Location**: iOS app memory (not persisted yet)

As user progresses:
1. Each step response stored in local state
2. Progress tracked (e.g., "Step 15 of 45")
3. Can go back and change answers
4. Nothing sent to backend yet

**Why wait**: Don't want partial onboarding data in database. Only submit when complete + authenticated.

#### Phase 2: Completion
User finishes step 45:
1. All 45 responses in memory
2. iOS validates all responses present
3. Shows "Complete Onboarding" button
4. **Still no submission yet**

#### Phase 3: Payment Required
**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Paywall/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Paywall/)

1. User taps "Complete Onboarding"
2. Paywall appears (RevenueCat)
3. User must pay to proceed
4. After payment succeeds, continues to auth

**Why paywall here**:
- User invested time in 45 steps (sunk cost)
- Psychologically committed to program
- No wasted backend resources on non-paying users
- Higher conversion rate than paywall-first

#### Phase 4: Authentication
**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/)

1. User sees "Sign in with Apple" or "Sign in with Google"
2. Authenticates via OAuth provider
3. Account created in Supabase
4. JWT session token received
5. **NOW we can submit onboarding**

**Why auth last**:
- Don't create accounts for users who don't pay
- User ID needed to link onboarding data
- Clean database (only paid users)

#### Phase 5: Submission
**Endpoint**: `POST /onboarding/v3/complete`

iOS builds JSON payload:
```json
{
  "state": {
    "currentStep": 45,
    "responses": {
      "step_1": { ... },
      "step_2": { ... },
      ...all 45 steps...
    },
    "userName": "Mike",
    "brotherName": "Executor",
    "userTimezone": "America/New_York"
  }
}
```

Voice recordings embedded as base64 data URLs:
```json
"step_5": {
  "type": "voice",
  "value": "data:audio/m4a;base64,AAAAGG....",
  "db_field": ["current_situation"],
  "duration": 5.2,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Single HTTP request** with entire onboarding state.

---

## 🔧 Backend Processing

**Handler**: [be/src/routes/onboarding.ts:76-371](../../be/src/routes/onboarding.ts#L76)

### Step 1: Receive & Validate
```
POST /onboarding/v3/complete arrives
  ↓
Verify user authenticated
  ↓
Verify subscription active
  ↓
Validate state.responses exists
  ↓
Extract 45 responses
```

### Step 2: File Processing
**Service**: [be/src/utils/onboardingFileProcessor.ts](../../be/src/utils/onboardingFileProcessor.ts)

For each voice response:
1. Detect base64 data URL
2. Extract audio data after `data:audio/m4a;base64,`
3. Decode base64 to binary
4. Generate unique filename: `audio/{userId}/step-{stepId}-{timestamp}.m4a`
5. Upload to Cloudflare R2 bucket
6. Get public URL: `https://pub-xxx.r2.dev/audio/{userId}/...`
7. Replace base64 value with URL

**Why R2 upload**:
- Can't store megabytes of base64 in database
- Need persistent URLs for transcription
- R2 cheaper than database storage
- Enables playback in UI later

**Result**: responses now have URLs instead of base64.

### Step 3: Save to Database
```
supabase.from("onboarding").upsert({
  user_id: userId,
  responses: processedResponses,  // Now with URLs
  updated_at: new Date().toISOString()
})
```

**Upsert**: Updates if user re-submits onboarding (rare but possible).

### Step 4: Extract Call Settings
```
// Find step with db_field="evening_call_time"
// Extract time window: { start: "20:30", end: "21:00" }
callTime = "20:30"  // When calls start
```

### Step 5: Update User Record
```
supabase.from("users").update({
  onboarding_completed: true,
  onboarding_completed_at: now,
  name: state.userName,
  timezone: state.userTimezone,
  call_window_start: callTime,
  call_window_timezone: state.userTimezone
})
```

**This unlocks app features**: User can now receive calls.

### Step 6: Auto-Trigger Identity Extraction
```
extractAndSaveIdentityUnified(userId, env)
  ↓
Read responses from database
  ↓
Transcribe voice URLs via Deepgram
  ↓
Analyze with AI (GitHub Models)
  ↓
Extract 15 identity fields
  ↓
Save to identity table
```

**See**: [IDENTITY.md](IDENTITY.md) for full extraction flow.

### Step 7: Initialize Identity Status
```
syncIdentityStatus(userId, env)
  ↓
Create initial status record
  ↓
trust_percentage = 100
  ↓
current_streak_days = 0
  ↓
Generate AI discipline message
```

**See**: [IDENTITY_STATUS.md](IDENTITY_STATUS.md) for status system.

### Step 8: Return Success
```json
{
  "success": true,
  "message": "Onboarding completed successfully",
  "completedAt": "2024-01-15T10:30:00Z",
  "totalSteps": 45,
  "filesProcessed": 8,
  "identityExtraction": {
    "success": true,
    "fieldsExtracted": 15
  }
}
```

iOS receives this and navigates to main app.

---

## 🎯 Where Onboarding Data is Used

### 1. Identity Extraction
**Primary use**: Source of all psychological insights.

- Voice recordings transcribed
- Transcripts + text responses analyzed by AI
- 15 identity fields extracted
- Becomes user's permanent psychological profile

**Without good onboarding**: Identity extraction fails or produces shallow insights.

### 2. Voice Cloning
**Service**: [be/src/services/voice-cloning.ts](../../be/src/services/voice-cloning.ts)

- Step 35-40: Dedicated voice recording (30-60 seconds)
- Uploaded to 11labs
- Voice clone created
- `voice_clone_id` saved to user record
- Used for personalized accountability calls

**Why good sample needed**: Poor audio = poor voice clone = calls sound robotic.

### 3. Debugging & Re-extraction
If identity extraction fails or needs refresh:
- Original responses preserved in database
- Can re-run extraction: `POST /onboarding/extract-data`
- Useful as AI models improve
- No need to re-do onboarding

### 4. Analytics (Future)
- Which steps users spend most time on
- Which questions get longest voice responses
- Drop-off analysis
- A/B testing different question phrasings

---

## 🤔 Design Decisions

### Why 45 Steps?
- **Enough depth**: Get real psychological insights, not surface-level
- **Not overwhelming**: One at a time, clear progress bar
- **Proven length**: Users who finish are committed (filters out casual browsers)
- **Comprehensive**: Covers identity, behavior, and system config

### Why Anonymous First?
- **Reduce friction**: No email/password upfront
- **Test commitment**: Only serious users finish 45 steps
- **Better conversion**: Sunk cost makes payment more likely
- **Clean database**: No abandoned accounts

### Why Voice-Heavy?
- **Authenticity**: Hard to lie when speaking
- **Efficiency**: Faster to speak than type
- **Dual purpose**: Same recordings used for psychology AND voice cloning
- **Engagement**: More interesting than forms
- **Emotional data**: Tone tells AI about commitment level

### Why Single Submission?
- **Atomicity**: All or nothing, no partial states
- **Simplicity**: One backend endpoint to maintain
- **Speed**: One HTTP request vs 45 requests
- **Reliability**: No need to track which steps saved

### Why JSONB Storage?
- **Flexibility**: Easy to add/change steps without schema migrations
- **Complete data**: Preserve everything, not just extracted fields
- **Re-extraction**: Can reprocess if AI improves
- **Debugging**: See exactly what user submitted

### Why Process After Auth?
- **User ID needed**: Can't link data without account
- **Subscription verified**: Only paying users get processing
- **Security**: Authenticated requests only
- **Resource efficiency**: Don't waste AI credits on non-users

---

## 🔄 Edge Cases & Error Handling

### What if voice recording fails?
- iOS shows retry button
- Can re-record that step
- Optional microphone test before onboarding starts
- If repeated failures, user can skip (but affects identity quality)

### What if submission fails?
- iOS retries automatically (3 attempts)
- If still fails, responses saved to secure storage
- User can retry from settings after fixing network
- Support can manually trigger re-submission

### What if user closes app mid-onboarding?
- **Currently**: Progress lost, must restart
- **Future**: Could save to secure storage and resume
- Trade-off: Complexity vs user frustration

### What if extraction fails?
- Backend continues (doesn't block onboarding completion)
- User marked as onboarding complete
- Identity extraction logged as failed
- Can retry extraction later without re-doing onboarding
- User gets generic calls until identity extracted

### What if user wants to change answers?
- **Currently**: No edit after submission
- Original responses preserved in database
- Support could manually delete onboarding record
- User re-submits (keeps same account)
- **Why not editable**: Onboarding is a snapshot of initial commitment

---

## 📊 Onboarding Metrics (Future)

Could track:
- Completion rate (% who finish all 45 steps)
- Average time spent (measures thoughtfulness)
- Step drop-off points (which questions lose people)
- Voice response lengths (longer = more invested)
- Payment conversion rate (completed → paid)
- Re-submission rate (how often users restart)

---

## 📁 Key File References

### Backend
- Main handler: [be/src/routes/onboarding.ts](../../be/src/routes/onboarding.ts)
- File processor: [be/src/utils/onboardingFileProcessor.ts](../../be/src/utils/onboardingFileProcessor.ts)
- R2 upload service: [be/src/services/r2-upload.ts](../../be/src/services/r2-upload.ts)
- Type definition: [be/src/types/database.ts:102-108](../../be/src/types/database.ts#L102)

### Frontend (iOS)
- Onboarding flow: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Onboarding/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Onboarding/)
- Paywall: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Paywall/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Paywall/)
- Authentication: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/)

### Related Documentation
- Identity extraction: [IDENTITY.md](IDENTITY.md)
- Authentication flow: [AUTHENTICATION.md](AUTHENTICATION.md)
- Database schema: [DATABASE.md](../DATABASE.md)

---

## 🎓 Common Questions

**Q: Why so many steps? Won't users drop off?**
A: Intentional filter. Users who complete 45 steps are serious about change. They're pre-qualified for payment.

**Q: Can users skip steps?**
A: No. Every step required. This ensures complete data for identity extraction.

**Q: What if user doesn't want to use voice?**
A: Voice required for best experience. Could offer text fallback but identity quality suffers.

**Q: How long does onboarding take?**
A: 20-30 minutes for thoughtful responses. Rushing produces poor identity extraction.

**Q: Can onboarding be edited after submission?**
A: Not currently. It's a commitment snapshot. Support can reset if truly needed.

**Q: What happens to audio files after transcription?**
A: Kept in R2 storage. May be used for voice recloning or debugging. Never shared.

---

*Last updated: 2025-01-11*
