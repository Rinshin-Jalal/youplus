# BigBruh MVP Release Checklist
**Generated**: November 4, 2025
**Current Status**: ~30% Complete
**Estimated Time to MVP**: 5-6 weeks

---

## 🔴 CRITICAL BLOCKERS (Must Complete Before Launch)

### 1. Backend Setup & Dependencies
**Status**: ❌ Not Started
**Effort**: 30 minutes
**Priority**: IMMEDIATE

- [ ] Run `npm install` in `/backend` directory
- [ ] Create `.env` file from `.env.example`
- [ ] Test build with `npm run build`
- [ ] Fix any TypeScript compilation errors

**Commands**:
```bash
cd backend
npm install
npm run build
```

---

### 2. Database Schema & Migrations
**Status**: ❌ Missing
**Effort**: 2-3 hours
**Priority**: IMMEDIATE

**Tables Needed** (referenced in backend code):
- [ ] `users` - User accounts and settings
- [ ] `onboarding` - Onboarding responses (JSONB)
- [ ] `identity` - Extracted psychological weapons
- [ ] `calls` - Call history and responses
- [ ] `streaks` - User streak tracking

**Schema Location**: Need to create in `/database/migrations/`

**Key Fields Per Table**:

**users**:
```sql
id UUID PRIMARY KEY,
email TEXT UNIQUE,
name TEXT,
call_time TEXT,
timezone TEXT,
onboarding_completed BOOLEAN DEFAULT FALSE,
voip_push_token TEXT,
apple_id TEXT,
created_at TIMESTAMP DEFAULT NOW(),
updated_at TIMESTAMP DEFAULT NOW()
```

**onboarding**:
```sql
id UUID PRIMARY KEY,
user_id UUID REFERENCES users(id),
responses JSONB,
completed_at TIMESTAMP
```

**identity** (psychological weapons):
```sql
id UUID PRIMARY KEY,
user_id UUID REFERENCES users(id) UNIQUE,
biggest_lie_voice TEXT,
financial_loss_number INTEGER,
opportunity_cost_voice TEXT,
relationship_damage_type TEXT,
gave_up_voice TEXT,
physical_disgust_voice TEXT,
physical_rating INTEGER,
daily_reality_voice TEXT,
shame_trigger TEXT,
identity_gap TEXT,
created_at TIMESTAMP,
updated_at TIMESTAMP
```

**calls**:
```sql
id UUID PRIMARY KEY,
user_id UUID REFERENCES users(id),
call_type TEXT, -- STANDARD, SHAME, EMERGENCY
script TEXT,
weapons_used JSONB,
response TEXT, -- YES, NO, MISSED
audio_url TEXT,
created_at TIMESTAMP
```

**streaks**:
```sql
id UUID PRIMARY KEY,
user_id UUID REFERENCES users(id) UNIQUE,
current_streak INTEGER DEFAULT 0,
longest_streak INTEGER DEFAULT 0,
last_success_date DATE,
total_calls INTEGER DEFAULT 0,
total_successes INTEGER DEFAULT 0,
updated_at TIMESTAMP
```

**Actions**:
- [ ] Create SQL migration files
- [ ] Add RLS (Row Level Security) policies for user data isolation
- [ ] Run migrations in Supabase
- [ ] Test database connectivity from backend

---

### 3. iOS App Development
**Status**: ❌ Not Started (0%)
**Effort**: 4-5 weeks
**Priority**: CRITICAL PATH

#### Phase 1: Project Setup (2-3 days)
- [ ] Create new Swift iOS project in `/swift` directory
- [ ] Set up project structure:
  - [ ] `/Models` - Data models
  - [ ] `/Services` - API client, Auth service
  - [ ] `/Views` - SwiftUI views
  - [ ] `/ViewModels` - MVVM architecture
  - [ ] `/Utilities` - Helpers, extensions
- [ ] Add dependencies (SPM):
  - [ ] Supabase Swift SDK
  - [ ] Keychain wrapper for secure storage
  - [ ] AVFoundation for audio
- [ ] Configure bundle ID and signing
- [ ] Set up Info.plist (microphone permissions, etc.)

#### Phase 2: Authentication (3-4 days)
- [ ] Sign In with Apple implementation
- [ ] Email/password signup/login screens
- [ ] Token storage (Keychain)
- [ ] Session management
- [ ] Auto-login on app launch
- [ ] API client setup with auth headers

**Screens Needed**:
- [ ] WelcomeView (landing)
- [ ] SignUpView
- [ ] SignInView

#### Phase 3: Onboarding Flow (1-2 weeks)
- [ ] OnboardingCoordinator (step manager)
- [ ] 10 onboarding screens:
  1. [ ] Step 1: Warning screen
  2. [ ] Step 2: Name input
  3. [ ] Step 3: Voice recording - "Biggest Lie"
  4. [ ] Step 4: Number input - "Financial Loss"
  5. [ ] Step 5: Voice recording - "Opportunity Cost"
  6. [ ] Step 6: Choice selector - "Relationship Damage"
  7. [ ] Step 7: Voice recording - "When They Gave Up"
  8. [ ] Step 8: Voice recording - "Physical Disgust"
  9. [ ] Step 9: Slider - "Physical Rating"
  10. [ ] Step 10: Voice recording - "Daily Reality"
- [ ] Voice recording component (AVAudioRecorder)
- [ ] Audio playback preview
- [ ] Progress indicator
- [ ] Submit responses to backend API
- [ ] Handle completion & navigate to dashboard

#### Phase 4: Dashboard (3-5 days)
- [ ] Tab bar navigation
- [ ] Tab 1: Streaks screen
  - [ ] Current streak display
  - [ ] Longest streak badge
  - [ ] Weekly success rate chart
  - [ ] Calendar view
- [ ] Tab 2: Call History screen
  - [ ] List of past calls
  - [ ] Call details (script, response)
  - [ ] Filter by response type
- [ ] Tab 3: Profile screen
  - [ ] User name/email
  - [ ] Call time settings
  - [ ] Timezone picker
  - [ ] Psychological weapons view (read-only)
  - [ ] Sign out

#### Phase 5: Call Interaction (1 week)
- [ ] CallKit integration
- [ ] VoIP push notification handling
- [ ] Incoming call UI (native iOS call screen)
- [ ] Audio playback (AVPlayer)
- [ ] Response buttons (YES/NO/MISSED)
- [ ] Submit response to backend
- [ ] Update streaks locally

#### Phase 6: VoIP & Push Notifications (3-5 days)
- [ ] Register for VoIP push notifications
- [ ] Send device token to backend
- [ ] Handle incoming VoIP pushes (PushKit)
- [ ] Background call handling
- [ ] Test on real device (VoIP doesn't work in simulator)

---

### 4. Backend Integration Fixes
**Status**: ⚠️ Partially Complete
**Effort**: 1 week
**Priority**: HIGH

#### 4a. ElevenLabs Audio Generation
**File**: `/backend/src/services/elevenlabs.ts`
**Issue**: Service exists but not connected to call flow

- [ ] Verify ElevenLabs API key is valid
- [ ] Test `generateAudio()` function
- [ ] Integrate into call generation endpoint
- [ ] Replace hardcoded placeholder:
  ```typescript
  // Current (line ~120 in calls.ts):
  audio_base64: 'base64_audio_data_here'

  // Should be:
  const audioBuffer = await this.elevenLabs.generateAudio(callData.script);
  audio_base64: audioBuffer.toString('base64')
  ```
- [ ] Store audio in R2 bucket
- [ ] Return audio URL instead of base64

#### 4b. VoIP Push Implementation
**File**: `/backend/src/routes/voip.ts:257-295`
**Issue**: `sendVoIPPush()` is stub (only logs)

- [ ] Install APNs library (node-apn or similar)
- [ ] Configure APNs credentials (p8 key from Apple)
- [ ] Implement actual push sending:
  ```typescript
  async function sendVoIPPush(token: string, payload: any): Promise<void> {
    const apn = require('apn');
    const provider = new apn.Provider({
      token: {
        key: env.APNS_KEY_PATH,
        keyId: env.APNS_KEY_ID,
        teamId: env.APNS_TEAM_ID
      },
      production: env.ENVIRONMENT === 'production'
    });

    const notification = new apn.Notification();
    notification.topic = 'com.bigbruh.voip';
    notification.payload = payload;
    notification.pushType = 'voip';

    await provider.send(notification, token);
  }
  ```
- [ ] Add APNs credentials to Cloudflare secrets
- [ ] Test VoIP push delivery

#### 4c. Call Scheduling Implementation
**File**: `/backend/src/routes/voip.ts:233-255`
**Issue**: `scheduleVoIPCall()` only logs, doesn't schedule

- [ ] Create scheduled jobs handler (`/backend/src/scheduled.ts`)
- [ ] Implement cron handler:
  ```typescript
  export default {
    async scheduled(event: ScheduledEvent, env: Env) {
      // Query users with call_time matching current time
      const now = new Date();
      const users = await getScheduledUsers(now, env);

      for (const user of users) {
        await generateAndSendCall(user, env);
      }
    }
  }
  ```
- [ ] Update wrangler.toml cron trigger (already configured at `*/5 * * * *`)
- [ ] Test scheduled execution

#### 4d. Voice Transcription
**Status**: ❌ Missing
**Effort**: 1-2 days

- [ ] Add Whisper API integration (OpenAI)
- [ ] Transcribe voice responses on upload
- [ ] Store transcription text in database
- [ ] Use transcriptions in weapon extraction

---

### 5. Cloudflare Workers Deployment
**Status**: ❌ Not Deployed
**Effort**: 2-3 hours
**Priority**: HIGH

- [ ] Create Cloudflare account (if not exists)
- [ ] Create R2 bucket: `bigbruh-mvp-audio`
- [ ] Set all secrets via CLI:
  ```bash
  wrangler secret put SUPABASE_URL
  wrangler secret put SUPABASE_ANON_KEY
  wrangler secret put SUPABASE_SERVICE_ROLE_KEY
  wrangler secret put OPENAI_API_KEY
  wrangler secret put ELEVENLABS_API_KEY
  wrangler secret put ELEVENLABS_VOICE_ID
  wrangler secret put DEBUG_ACCESS_TOKEN
  wrangler secret put APNS_KEY_ID
  wrangler secret put APNS_TEAM_ID
  wrangler secret put APNS_KEY_PATH
  ```
- [ ] Deploy to staging: `npm run deploy -- --env staging`
- [ ] Test all endpoints
- [ ] Deploy to production: `npm run deploy -- --env production`

---

## 🟡 IMPORTANT (Should Do Before Launch)

### 6. Testing & QA
**Effort**: 1 week
**Priority**: MEDIUM-HIGH

#### Backend Tests
- [ ] Unit tests for:
  - [ ] Auth middleware
  - [ ] Weapon extraction logic
  - [ ] Streak calculation
  - [ ] Call script generation
- [ ] Integration tests:
  - [ ] Full onboarding flow
  - [ ] Call generation + response
  - [ ] Dashboard data retrieval

#### iOS Tests
- [ ] Unit tests for ViewModels
- [ ] UI tests for onboarding flow
- [ ] Test on real devices (minimum: iPhone 12+)
- [ ] Test VoIP calls on physical device

#### End-to-End Tests
- [ ] Complete user journey:
  1. Sign up
  2. Complete onboarding
  3. Receive scheduled call
  4. Respond to call
  5. View updated dashboard
- [ ] Test timezone handling
- [ ] Test offline/online transitions
- [ ] Test error handling (network failures, etc.)

---

### 7. APNs Configuration (iOS)
**Effort**: 2-3 hours
**Priority**: MEDIUM-HIGH

- [ ] Apple Developer account setup
- [ ] Create App ID with VoIP push capability
- [ ] Create VoIP Services Certificate or APNs Auth Key (p8)
- [ ] Download and configure in backend
- [ ] Enable Push Notifications in Xcode capabilities
- [ ] Enable Background Modes (Voice over IP)
- [ ] Test push delivery to real device

---

### 8. Documentation Updates
**Effort**: 1-2 days
**Priority**: MEDIUM

- [ ] Update README.md with:
  - [ ] Actual tech stack used
  - [ ] Setup instructions
  - [ ] Environment variables needed
  - [ ] Deployment steps
- [ ] Update DEPLOYMENT.md with tested deploy process
- [ ] Create API documentation (endpoints, request/response examples)
- [ ] Document onboarding flow for future iterations
- [ ] Create troubleshooting guide

---

## 🟢 NICE TO HAVE (Post-MVP)

### 9. Performance & Optimization
- [ ] Add caching for dashboard queries
- [ ] Optimize audio file sizes
- [ ] Implement lazy loading for call history
- [ ] Add analytics tracking

### 10. Error Handling & Monitoring
- [ ] Add error tracking (Sentry or similar)
- [ ] Implement retry logic for failed API calls
- [ ] Add logging for debugging
- [ ] Set up uptime monitoring

### 11. Security Hardening
- [ ] Rate limiting on API endpoints
- [ ] Input sanitization
- [ ] CORS configuration
- [ ] Audit RLS policies

---

## 📊 COMPLETION TRACKING

### Backend (40% Complete)
- [x] API structure (Hono + Cloudflare Workers)
- [x] Route handlers (auth, onboarding, calls, dashboard, VoIP)
- [x] Database service layer
- [x] Type definitions
- [ ] npm dependencies installed
- [ ] ElevenLabs integration complete
- [ ] VoIP push implementation
- [ ] Call scheduling active
- [ ] Voice transcription

### Database (30% Complete)
- [x] Schema design
- [ ] SQL migration files
- [ ] Supabase project setup
- [ ] RLS policies
- [ ] Test data

### iOS App (0% Complete)
- [ ] Project setup
- [ ] Authentication
- [ ] Onboarding flow
- [ ] Dashboard
- [ ] Call interaction
- [ ] VoIP integration
- [ ] Testing

### Infrastructure (40% Complete)
- [x] wrangler.toml configured
- [x] Environment variables documented
- [ ] Cloudflare account setup
- [ ] R2 bucket created
- [ ] Secrets configured
- [ ] Deployed to staging
- [ ] Deployed to production

---

## ⏱️ TIME ESTIMATES BY ROLE

### Backend Developer (2 weeks)
- Week 1: Fix integrations (ElevenLabs, VoIP, scheduling)
- Week 2: Testing, deployment, bug fixes

### iOS Developer (4-5 weeks)
- Week 1: Project setup + authentication
- Week 2-3: Onboarding flow + voice recording
- Week 4: Dashboard + call interaction
- Week 5: VoIP integration + testing

### DevOps (2-3 days)
- Day 1: Database setup + migrations
- Day 2: Cloudflare deployment + secrets
- Day 3: APNs configuration + testing

**TOTAL TIMELINE: 5-6 weeks (if roles work in parallel)**

---

## 🚀 SUGGESTED SPRINT PLAN

### Sprint 1 (Week 1): Foundation
- Install npm dependencies
- Create database migrations
- Deploy database to Supabase
- Start iOS project setup
- Fix backend integrations (ElevenLabs, VoIP)

### Sprint 2 (Week 2): Core Features
- Complete iOS authentication
- Build onboarding screens 1-5
- Test backend call generation
- Deploy backend to staging

### Sprint 3 (Week 3): Onboarding Completion
- Build onboarding screens 6-10
- Implement voice recording
- Test full onboarding flow
- Fix backend bugs

### Sprint 4 (Week 4): Dashboard & Calls
- Build iOS dashboard (3 screens)
- Implement call interaction UI
- Test call response flow
- Add call scheduling

### Sprint 5 (Week 5): VoIP & Integration
- VoIP push notifications
- CallKit integration
- End-to-end testing
- Bug fixes

### Sprint 6 (Week 6): Polish & Launch
- Final testing on devices
- Deploy backend to production
- TestFlight beta
- Launch preparation

---

## 📝 NEXT IMMEDIATE ACTIONS

**Do These TODAY:**
1. `cd backend && npm install`
2. Create database migration files (use schema above)
3. Decide: Swift iOS or React Native? (docs conflict)
4. Set up Supabase project
5. Run database migrations

**Do This WEEK:**
1. Fix ElevenLabs integration
2. Start iOS project structure
3. Build auth screens
4. Deploy backend to staging
5. Test all backend endpoints

---

## ❓ CRITICAL DECISIONS NEEDED

1. **iOS Framework**: README says Swift, but some docs mention React Native/Expo. Which one?
2. **Voice Cloning**: Use ElevenLabs voice cloning or pre-selected voices?
3. **Audio Storage**: R2 vs. direct streaming? (R2 configured but not used)
4. **Onboarding Steps**: 10 steps (README) vs. 45-60 steps (docs)? Which version?
5. **Testing Strategy**: Manual QA only or automated tests before launch?

---

**END OF CHECKLIST**

*This checklist is based on thorough codebase analysis as of November 4, 2025.*
*Update this document as items are completed.*
