# 🧪 End-to-End Testing Checklist - BigBruh/YouPlus

**Last Updated**: 2025-11-05
**App Version**: Super MVP
**Test Environment**: Production-like staging

---

## 📋 Pre-Testing Setup

### Environment Preparation
- [ ] Backend deployed and running (Cloudflare Workers)
- [ ] Supabase database running with latest schema
- [ ] R2 bucket accessible for audio uploads
- [ ] ElevenLabs API key configured
- [ ] OpenAI API key configured
- [ ] RevenueCat configured (sandbox mode)
- [ ] Apple Sign In configured (development)
- [ ] Google Sign In configured (development)
- [ ] iOS device ready (physical device for VoIP testing)

### Test Data Cleanup
- [ ] Clear app data on iOS device
- [ ] Delete test user from Supabase database (if re-testing)
- [ ] Clear test user's onboarding data
- [ ] Clear test user's identity record
- [ ] Verify clean slate in database

### Testing Tools
- [ ] Xcode debugging enabled
- [ ] Backend logs accessible (Cloudflare dashboard)
- [ ] Supabase logs accessible
- [ ] Network inspector ready (Charles/Proxyman)
- [ ] Screenshot/recording tool ready
- [ ] Test credentials documented

---

## 🚀 PHASE 1: App Launch & First Impression

### App Launch (Cold Start)
- [ ] **Test**: Launch app for first time
- [ ] **Verify**: App loads without crash
- [ ] **Verify**: No error alerts appear
- [ ] **Verify**: Splash screen displays correctly
- [ ] **Verify**: Navigates to onboarding automatically
- [ ] **Time**: Record cold start time (target: <3s)

### Welcome Screen
- [ ] **Test**: View initial welcome screen
- [ ] **Verify**: BigBruh branding visible
- [ ] **Verify**: Warning message displays
- [ ] **Verify**: "Start" button clickable
- [ ] **Verify**: Design matches mockups

---

## 📝 PHASE 2: 60-Step Onboarding Flow

### Phase 1: Warning & Initiation (Steps 1-7)

**Step 1 - Warning Explanation**
- [ ] **Test**: Read warning about BigBruh not being friendly
- [ ] **Verify**: Text displays correctly (black background, white text)
- [ ] **Verify**: Continue button appears
- [ ] **Verify**: Phase progress bar shows 1/7 segments

**Step 2 - Voice Commitment** (🎙️ VOICE)
- [ ] **Test**: Record why you're here (10s minimum)
- [ ] **Verify**: Microphone permission requested
- [ ] **Verify**: Recording UI appears (waveform/animation)
- [ ] **Verify**: 10-second minimum enforced
- [ ] **Verify**: Can re-record if needed
- [ ] **Verify**: Audio saves locally
- [ ] **Verify**: Can play back recording
- [ ] **dbField**: `voice_commitment`

**Step 3 - Commitment Acknowledgment**
- [ ] **Test**: Read acknowledgment about voice haunting you
- [ ] **Verify**: Text renders properly
- [ ] **Verify**: Continue button enabled

**Step 4 - Name Input** (📝 TEXT)
- [ ] **Test**: Enter first name
- [ ] **Verify**: Keyboard appears
- [ ] **Verify**: Text converts to UPPERCASE
- [ ] **Verify**: Empty submission shakes with error
- [ ] **Verify**: Name accepted and advances
- [ ] **dbField**: `identity_name`

**Step 5 - Brutal Honesty Warning**
- [ ] **Test**: Read warning about exposing excuses
- [ ] **Verify**: Dark theme displays correctly

**Step 6 - Biggest Lie** (🎙️ VOICE)
- [ ] **Test**: Record biggest lie you tell yourself (7s minimum)
- [ ] **Verify**: 7-second minimum enforced
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `biggest_lie`

**Step 7 - Excuse Discovery Bridge**
- [ ] **Test**: Read transition to excuse discovery
- [ ] **Verify**: Phase progress bar updates (7/7 complete)
- [ ] **Verify**: Background color changes for new phase

### Phase 2A: Excuse Discovery (Steps 8-14)

**Step 8 - Favorite Excuse** (🎯 CHOICE)
- [ ] **Test**: Select favorite excuse from list
- [ ] **Verify**: All options display correctly
- [ ] **Verify**: Selection highlights
- [ ] **Verify**: "Other" option available
- [ ] **Verify**: Selection advances automatically
- [ ] **dbField**: `favorite_excuse`

**Step 9 - Last Failure** (🎙️ VOICE)
- [ ] **Test**: Describe last complete failure (10s minimum)
- [ ] **Verify**: Recording works
- [ ] **dbField**: `last_failure`

**Step 10 - Pattern Recognition Explanation**
- [ ] **Test**: Read explanation about patterns
- [ ] **Verify**: Text displays

**Step 11 - Weakness Window** (📝 TEXT)
- [ ] **Test**: Enter exact time/situation when you fold
- [ ] **Verify**: Text input works
- [ ] **dbField**: `weakness_window`

**Step 12 - Current Procrastination** (🎙️ VOICE)
- [ ] **Test**: Record what you're procrastinating now (8s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `procrastination_now`

**Step 13 - Pattern Recognition Micro-Explanation**
- [ ] **Test**: Read pattern connection explanation
- [ ] **Verify**: Text renders

**Step 14 - Motivation Dual Sliders** (📊 DUAL SLIDERS)
- [ ] **Test**: Adjust "How much you HATE failing" slider (1-10)
- [ ] **Test**: Adjust "How BAD you want to win" slider (1-10)
- [ ] **Verify**: Both sliders move smoothly
- [ ] **Verify**: Values display correctly
- [ ] **Verify**: Can't proceed without adjusting both
- [ ] **Verify**: Values save
- [ ] **dbField**: `motivation_fear_intensity`, `motivation_desire_intensity`

### Phase 2B: Consequence Confrontation (Steps 15-20)

**Step 15 - Consequence Transition**
- [ ] **Test**: Read consequence explanation
- [ ] **Verify**: Background color changes (to dark)

**Step 16 - Time Waster** (🎯 CHOICE)
- [ ] **Test**: Select what's killing your potential
- [ ] **Verify**: Options display (social media, gaming, porn, etc.)
- [ ] **dbField**: `time_waster`

**Step 17 - Harsh Reality**
- [ ] **Test**: Read "Pathetic" confrontation
- [ ] **Verify**: Text displays

**Step 18 - Fear Version** (🎙️ VOICE)
- [ ] **Test**: Describe loser version of yourself (8s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `fear_version`

**Step 19 - Relationship Damage** (🎙️ VOICE)
- [ ] **Test**: Record who stopped believing in you (8s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `relationship_damage`

**Step 20 - Physical Disgust** (🎙️ VOICE)
- [ ] **Test**: Look in mirror and record what disgusts you (8s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `physical_disgust_trigger`

### Phase 3A: Reality Extraction (Steps 21-26)

**Step 21 - Data vs Feelings Bridge**
- [ ] **Test**: Read transition to data collection
- [ ] **Verify**: Background color changes (to light)

**Step 22 - Formula Reality Check**
- [ ] **Test**: Read harsh reality check
- [ ] **Verify**: Text displays

**Step 23 - Daily Time Audit** (🎙️ VOICE)
- [ ] **Test**: Describe yesterday hour by hour (10s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `daily_time_audit`

**Step 24 - Quit Counter** (📝 TEXT)
- [ ] **Test**: Enter number of times started fresh this year
- [ ] **Verify**: Numeric input works
- [ ] **dbField**: `quit_counter`

**Step 25 - Daily Non-Negotiable** (📝 TEXT)
- [ ] **Test**: Enter ONE thing you'll do every single day
- [ ] **Verify**: Text input works
- [ ] **Verify**: Can't be empty
- [ ] **dbField**: `daily_non_negotiable` → **`identity.daily_commitment`**

**Step 26 - Commitment Skepticism**
- [ ] **Test**: Read skeptical response
- [ ] **Verify**: Text displays

### Phase 3B: Pattern Analysis (Steps 27-34)

**Step 27 - Pattern Analysis Transition**
- [ ] **Test**: Read transition explanation
- [ ] **Verify**: Background color stable

**Step 28 - Financial Consequence** (🎙️ VOICE)
- [ ] **Test**: Record money not made this year (8s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `financial_consequence`

**Step 29 - Financial Significance Explanation**
- [ ] **Test**: Read money/identity connection
- [ ] **Verify**: Text displays

**Step 30 - Intellectual Excuse** (🎙️ VOICE)
- [ ] **Test**: Record smart-sounding bullshit excuse (7s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `intellectual_excuse`

**Step 31 - Parental Sacrifice** (🎙️ VOICE)
- [ ] **Test**: Record what parents sacrificed that you're wasting (8s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `parental_sacrifice`

**Step 32 - Accountability Style** (🎯 CHOICE)
- [ ] **Test**: Select what actually makes you move
- [ ] **Verify**: Options display (fear, confrontation, competition, etc.)
- [ ] **dbField**: `accountability_style`

**Step 33 - Ancestral Shame**
- [ ] **Test**: Read harsh reality about having everything
- [ ] **Verify**: Text displays

**Step 34 - Success Memory** (🎙️ VOICE)
- [ ] **Test**: Record one time you followed through (7s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `success_memory`

### Phase 4A: Identity Rebuild (Steps 35-41)

**Step 35 - Identity Rebuild Transition**
- [ ] **Test**: Read transition to identity extraction
- [ ] **Verify**: Background color changes (to green/growth)

**Step 36 - Identity Goal** (🎙️ VOICE)
- [ ] **Test**: Record WHO you want to become in one year (7s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `identity_goal` → **`identity.why_it_matters_audio_url`**

**Step 37 - Trapped Identity Explanation**
- [ ] **Test**: Read about version of you that exists
- [ ] **Verify**: Text displays

**Step 38 - Success Metric** (📝 TEXT)
- [ ] **Test**: Enter ONE measurable number proving you changed
- [ ] **Verify**: Example shown: "Lose 20lbs by June 1st"
- [ ] **dbField**: `success_metric`

**Step 39 - Breaking Point** (🎙️ VOICE)
- [ ] **Test**: Record what EVENT would force you to change (8s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `breaking_point`

**Step 40 - Breaking Point Acknowledgment**
- [ ] **Test**: Read acknowledgment about breaking point
- [ ] **Verify**: Text displays

**Step 41 - Biggest Enemy** (🎙️ VOICE)
- [ ] **Test**: Record ONE pattern that always defeats you (6s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `biggest_enemy`

### Phase 4B: Commitment System (Steps 42-50)

**Step 42 - System vs Willpower Bridge**
- [ ] **Test**: Read explanation about need for system
- [ ] **Verify**: Background color changes (to stable/beige)

**Step 43 - 90% Quit Statistics**
- [ ] **Test**: Read statistics about quitting
- [ ] **Verify**: Text displays

**Step 44 - Accountability Graveyard** (📝 TEXT)
- [ ] **Test**: Enter number of accountability apps/coaches quit
- [ ] **Verify**: Numeric input works
- [ ] **dbField**: `accountability_graveyard`

**Step 45 - Urgency Mortality** (🎙️ VOICE)
- [ ] **Test**: Record what changes if you have 10 years left (8s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `urgency_mortality`

**Step 46 - Emotional Quit Trigger** (🎯 CHOICE)
- [ ] **Test**: Select emotion that makes you quit
- [ ] **Verify**: Options display (boredom, frustration, fear, etc.)
- [ ] **dbField**: `emotional_quit_trigger`

**Step 47 - Streak Target** (📝 TEXT)
- [ ] **Test**: Enter how many days straight to prove you're different
- [ ] **Verify**: Numeric input works
- [ ] **dbField**: `streak_target`

**Step 48 - Streak Psychology Explanation**
- [ ] **Test**: Read about Day 3, Day 7, Day 30
- [ ] **Verify**: Text displays

**Step 49 - Sacrifice List** (🎯 CHOICE)
- [ ] **Test**: Select what you're willing to sacrifice
- [ ] **Verify**: Options display (comfort, excuses, toxic friends, etc.)
- [ ] **dbField**: `sacrifice_list`

**Step 50 - War Cry Setup Bridge**
- [ ] **Test**: Read about creating war cry weapon
- [ ] **Verify**: Text displays

### Phase 4C: War Mode (Steps 51-53)

**Step 51 - War Cry** (🎙️ VOICE)
- [ ] **Test**: Record your WAR CRY (8s minimum)
- [ ] **Verify**: Recording saves
- [ ] **dbField**: `war_cry`

**Step 52 - War Cry Acknowledgment**
- [ ] **Test**: Read about war cry being recorded
- [ ] **Verify**: Text displays

**Step 53 - Last Shot Declaration**
- [ ] **Test**: Read "I'm not your friend" declaration
- [ ] **Verify**: Text displays

### Phase 5A: External Anchors (Steps 54-58)

**Step 54 - External Accountability Bridge**
- [ ] **Test**: Read about building your cage
- [ ] **Verify**: Background color changes (to dark/mystical)

**Step 55 - Evening Call Time** (⏰ TIME WINDOW PICKER)
- [ ] **Test**: Select time for daily call
- [ ] **Verify**: Time picker displays
- [ ] **Verify**: Can select hour and minute
- [ ] **Verify**: Time window format: "HH:MM-HH:MM"
- [ ] **Verify**: Selection saves
- [ ] **dbField**: `evening_call_time` → **`identity.call_time`**

**Step 56 - External Judge** (📝 TEXT)
- [ ] **Test**: Enter name of person who'd be most disappointed
- [ ] **Verify**: Text input works
- [ ] **dbField**: `external_judge` → **`onboarding_context.witness`**

**Step 57 - Failure Threshold** (🎯 CHOICE)
- [ ] **Test**: Select how many failures to tolerate
- [ ] **Verify**: Options: "3 strikes", "5 strikes", "1 strike - no mercy"
- [ ] **dbField**: `failure_threshold` → **`identity.strike_limit`**

**Step 58 - System Summary**
- [ ] **Test**: Read system configured summary
- [ ] **Verify**: Shows call time, judge, failure threshold

### Phase 5B: Final Sealing (Steps 59-60)

**Step 59 - Last Chance to Run**
- [ ] **Test**: Read final warning about entering
- [ ] **Verify**: Text displays

**Step 60 - Final Oath** (🎙️ VOICE)
- [ ] **Test**: Record oath starting with "I swear that I will..." (6s minimum)
- [ ] **Verify**: Recording saves
- [ ] **Verify**: Progress bar shows 60/60
- [ ] **dbField**: `oath_recording`

### Onboarding Completion
- [ ] **Test**: Complete step 60
- [ ] **Verify**: Completion animation plays
- [ ] **Verify**: Saves completed data to local storage
- [ ] **Verify**: Navigates to "Almost There" screen
- [ ] **Verify**: No crashes or errors
- [ ] **Time**: Record total onboarding time (target: 15-25 min)

---

## 💳 PHASE 3: Payment Flow (RevenueCat)

### AlmostThere Screen
- [ ] **Test**: View "Almost There" screen
- [ ] **Verify**: Shows onboarding completion message
- [ ] **Verify**: "Choose Your Path" button visible
- [ ] **Verify**: Can't proceed without payment

### Payment Selection
- [ ] **Test**: Tap "Choose Your Path"
- [ ] **Verify**: RevenueCat paywall displays
- [ ] **Verify**: Pricing shows correctly
- [ ] **Verify**: Payment methods available (Apple Pay, Card)
- [ ] **Verify**: Terms of service link works
- [ ] **Verify**: Privacy policy link works

### Payment Processing
- [ ] **Test**: Complete payment (sandbox mode)
- [ ] **Verify**: Apple Pay sheet appears
- [ ] **Verify**: Payment processes successfully
- [ ] **Verify**: Loading indicator shows during processing
- [ ] **Verify**: Success message displays
- [ ] **Verify**: RevenueCat webhook fires
- [ ] **Verify**: Subscription status updates in backend

### Payment Failure Handling
- [ ] **Test**: Cancel payment
- [ ] **Verify**: Returns to paywall gracefully
- [ ] **Verify**: Error message clear and actionable
- [ ] **Test**: Use expired card (if testing card flow)
- [ ] **Verify**: Error message displays
- [ ] **Verify**: Can retry payment

---

## 🔐 PHASE 4: Authentication Flow

### Sign Up/Sign In Screen
- [ ] **Test**: Navigate to authentication screen after payment
- [ ] **Verify**: "Sign in with Apple" button visible
- [ ] **Verify**: "Sign in with Google" button visible
- [ ] **Verify**: Buttons styled correctly

### Apple Sign In
- [ ] **Test**: Tap "Sign in with Apple"
- [ ] **Verify**: Apple Sign In sheet appears
- [ ] **Verify**: Can complete authentication
- [ ] **Verify**: Returns to app with success
- [ ] **Verify**: User created in Supabase
- [ ] **Verify**: JWT token saved locally
- [ ] **Record**: User ID from Supabase

### Google Sign In (Alternative)
- [ ] **Test**: Tap "Sign in with Google" (if Apple not available)
- [ ] **Verify**: Google Sign In flow works
- [ ] **Verify**: User created in Supabase

### Authentication Error Handling
- [ ] **Test**: Cancel authentication
- [ ] **Verify**: Returns to auth screen gracefully
- [ ] **Test**: Deny permission (if prompted)
- [ ] **Verify**: Error message clear

---

## 📤 PHASE 5: Onboarding Data Push to Backend

### Automatic Data Push
- [ ] **Test**: After successful authentication
- [ ] **Verify**: Loading screen shows "Setting up your profile..."
- [ ] **Verify**: Network request to `/api/onboarding/v3/complete`
- [ ] **Verify**: Request includes authentication token
- [ ] **Verify**: Request includes all 60 steps of responses
- [ ] **Verify**: VoIP push token included (if granted)

### Backend Processing (Check Logs)
- [ ] **Verify**: Backend receives onboarding data
- [ ] **Verify**: Backend logs show "V3 IDENTITY EXTRACTION START"
- [ ] **Verify**: Core fields extracted (name, daily_commitment, call_time, strike_limit)
- [ ] **Verify**: Voice recordings uploaded to R2 (3 total)
  - [ ] commitment_audio_url (from step 2)
  - [ ] cost_of_quitting_audio_url (from step 18)
  - [ ] why_it_matters_audio_url (from step 36)
- [ ] **Verify**: Onboarding context JSONB built (12+ fields)
- [ ] **Verify**: Identity record created in database
- [ ] **Verify**: Identity status record auto-created (by trigger)
- [ ] **Verify**: User marked as `onboarding_completed: true`
- [ ] **Verify**: Backend returns success response

### Database Verification (Supabase)
- [ ] **Check**: `users` table has record with correct email
- [ ] **Check**: `users.onboarding_completed = true`
- [ ] **Check**: `users.onboarding_completed_at` has timestamp
- [ ] **Check**: `users.call_window_start` has time (e.g., "20:30:00")
- [ ] **Check**: `onboarding` table has record with all responses
- [ ] **Check**: `identity` table has record with:
  - [ ] `name` (from step 4)
  - [ ] `daily_commitment` (from step 25)
  - [ ] `chosen_path` ("hopeful" or "doubtful")
  - [ ] `call_time` (from step 55)
  - [ ] `strike_limit` (from step 57, e.g., 3)
  - [ ] `commitment_audio_url` (R2 URL)
  - [ ] `cost_of_quitting_audio_url` (R2 URL)
  - [ ] `why_it_matters_audio_url` (R2 URL)
  - [ ] `onboarding_context` (JSONB with 12+ fields)
- [ ] **Check**: `identity_status` table has record with:
  - [ ] `current_streak_days = 0`
  - [ ] `total_calls_completed = 0`
  - [ ] `last_call_at = null`

### Data Push Error Handling
- [ ] **Test**: Force network error (turn off WiFi mid-push)
- [ ] **Verify**: Error message displays
- [ ] **Verify**: Retry option available
- [ ] **Test**: Retry after network restored
- [ ] **Verify**: Data pushes successfully on retry

---

## 🏠 PHASE 6: Home Screen & Dashboard

### Initial Home Screen
- [ ] **Test**: Navigate to home screen after onboarding complete
- [ ] **Verify**: Home screen loads without crash
- [ ] **Verify**: User name displays correctly
- [ ] **Verify**: Daily commitment shows (from step 25)
- [ ] **Verify**: Current streak shows (0 days initially)
- [ ] **Verify**: Next call time shows
- [ ] **Verify**: No missing data errors

### Dashboard Sections
- [ ] **Verify**: "Today's Promise" section visible
- [ ] **Verify**: "Call Schedule" section visible
- [ ] **Verify**: "Your Progress" section visible
- [ ] **Verify**: Settings button accessible

### First-Time User Experience
- [ ] **Verify**: Welcome message or tooltip for new users
- [ ] **Verify**: Call-to-action clear ("Wait for your call tonight")

---

## 📞 PHASE 7: Daily Call Flow

### Pre-Call Setup
- [ ] **Test**: Wait until scheduled call time (or test trigger)
- [ ] **Verify**: VoIP push notification received
- [ ] **Verify**: Notification shows correct title/message
- [ ] **Verify**: Notification plays sound
- [ ] **Verify**: Tapping notification opens app

### Call Initiation
- [ ] **Test**: Accept incoming call
- [ ] **Verify**: Call screen displays
- [ ] **Verify**: BigBruh branding shows
- [ ] **Verify**: Audio connects (ElevenLabs AI)
- [ ] **Verify**: No audio lag or stuttering
- [ ] **Verify**: Call quality acceptable

### AI Call Content (Listen & Verify)
- [ ] **Verify**: AI uses user's name (from step 4)
- [ ] **Verify**: AI references daily commitment (from step 25)
- [ ] **Verify**: AI references psychological context (favorite_excuse, etc.)
- [ ] **Verify**: AI plays back user's voice recordings at appropriate times
  - [ ] Commitment audio (from step 2)
  - [ ] Fear version audio (from step 18)
  - [ ] Identity goal audio (from step 36)
- [ ] **Verify**: Conversation flows naturally
- [ ] **Verify**: AI asks about today's promise
- [ ] **Verify**: AI waits for user responses

### Call Interaction
- [ ] **Test**: Respond to AI questions verbally
- [ ] **Verify**: AI transcribes responses
- [ ] **Verify**: AI understands kept/broken promises
- [ ] **Test**: Try to give excuses
- [ ] **Verify**: AI confronts excuses (uses `favorite_excuse` from step 8)
- [ ] **Verify**: Tone matches chosen accountability style (from step 32)

### Call Completion
- [ ] **Test**: Complete full call (5-10 min)
- [ ] **Verify**: Call ends gracefully
- [ ] **Verify**: Summary screen shows
- [ ] **Verify**: Promise status updated (kept/broken)
- [ ] **Verify**: Backend receives call completion webhook
- [ ] **Verify**: `identity_status.total_calls_completed` increments
- [ ] **Verify**: Streak updates correctly

### Call Missed/Declined
- [ ] **Test**: Ignore scheduled call
- [ ] **Verify**: Follow-up notification sent
- [ ] **Test**: Decline call
- [ ] **Verify**: Strike recorded (if applicable)
- [ ] **Verify**: Missed call logged in backend

---

## ⚙️ PHASE 8: Settings & Preferences

### Settings Screen
- [ ] **Test**: Navigate to Settings
- [ ] **Verify**: Settings screen loads
- [ ] **Verify**: All sections visible

### Call Time Modification
- [ ] **Test**: Change call time
- [ ] **Verify**: Time picker works
- [ ] **Verify**: New time saves to backend
- [ ] **Verify**: `users.call_window_start` updates in database
- [ ] **Verify**: Next call scheduled at new time
- [ ] **Note**: Check for TODO about `saveCallWindow` method

### Account Settings
- [ ] **Test**: View account info
- [ ] **Verify**: Email displays correctly
- [ ] **Verify**: Subscription status shows
- [ ] **Test**: Manage subscription (opens RevenueCat)
- [ ] **Verify**: Can cancel subscription
- [ ] **Verify**: Can resubscribe

### Notification Permissions
- [ ] **Test**: Toggle notification permissions
- [ ] **Verify**: iOS permission prompt appears (if needed)
- [ ] **Verify**: Preference saves

### Logout
- [ ] **Test**: Log out
- [ ] **Verify**: Returns to login screen
- [ ] **Verify**: Local data cleared (JWT token)
- [ ] **Verify**: Can log back in successfully

---

## 🔄 PHASE 9: Multi-Day Flow

### Day 2 - Kept Promise
- [ ] **Test**: Complete Day 2 call
- [ ] **Test**: Report kept promise
- [ ] **Verify**: Streak increments to 1
- [ ] **Verify**: `identity_status.current_streak_days = 1`
- [ ] **Verify**: Home screen updates

### Day 3 - Kept Promise
- [ ] **Test**: Complete Day 3 call
- [ ] **Test**: Report kept promise
- [ ] **Verify**: Streak increments to 2
- [ ] **Verify**: AI references streak achievement
- [ ] **Verify**: "Day 3 matters" message (from step 48)

### Day 7 - Milestone
- [ ] **Test**: Complete Day 7 call
- [ ] **Verify**: Streak at 6 days
- [ ] **Verify**: AI celebrates avoiding "90% quit" statistic
- [ ] **Verify**: Special milestone recognition

### Broken Promise - Strike System
- [ ] **Test**: Report broken promise during call
- [ ] **Verify**: Strike recorded
- [ ] **Verify**: Strike count displays on home screen
- [ ] **Verify**: Warning message about strike limit (from step 57)
- [ ] **Verify**: Streak resets to 0
- [ ] **Verify**: External judge notified (if configured in step 56)

### Strike Limit Reached
- [ ] **Test**: Reach strike limit (3 or 5 strikes)
- [ ] **Verify**: Consequences triggered
- [ ] **Verify**: Appropriate message/action taken
- [ ] **Verify**: User understands next steps

---

## 🐛 PHASE 10: Edge Cases & Error Scenarios

### Network Issues
- [ ] **Test**: Lose network during onboarding
- [ ] **Verify**: Error message clear
- [ ] **Verify**: Data saved locally
- [ ] **Verify**: Can resume when network returns

- [ ] **Test**: Lose network during call
- [ ] **Verify**: Graceful degradation
- [ ] **Verify**: Reconnection attempts
- [ ] **Verify**: Call can resume or reschedule

### App Backgrounding
- [ ] **Test**: Background app during onboarding
- [ ] **Verify**: State preserved
- [ ] **Verify**: Can resume from same step

- [ ] **Test**: Background app during call
- [ ] **Verify**: Call continues in background
- [ ] **Verify**: Can return to call screen

### Permissions Denied
- [ ] **Test**: Deny microphone permission
- [ ] **Verify**: Error message explains need for permission
- [ ] **Verify**: Link to Settings to enable
- [ ] **Verify**: Can't proceed with voice steps without permission

- [ ] **Test**: Deny notification permission
- [ ] **Verify**: Warning about missing calls
- [ ] **Verify**: Can still use app (graceful degradation)

### Invalid Data
- [ ] **Test**: Enter extremely long text in text steps
- [ ] **Verify**: Character limit enforced or handles gracefully
- [ ] **Test**: Skip required steps (if possible)
- [ ] **Verify**: Validation prevents skipping
- [ ] **Test**: Provide nonsensical voice responses
- [ ] **Verify**: AI handles appropriately

### Device Issues
- [ ] **Test**: Low battery warning during call
- [ ] **Verify**: Call continues or fails gracefully
- [ ] **Test**: Incoming phone call during BigBruh call
- [ ] **Verify**: Call pauses appropriately
- [ ] **Test**: Force quit app
- [ ] **Verify**: State recovers on relaunch

---

## 📊 PHASE 11: Backend Verification

### API Endpoints
- [ ] **Test**: `/api/health` - Health check
- [ ] **Verify**: Returns 200 OK
- [ ] **Test**: `/api/onboarding/v3/complete` - Onboarding submission
- [ ] **Verify**: Accepts POST with JWT auth
- [ ] **Verify**: Returns success response
- [ ] **Test**: `/api/onboarding/extract-data` - Re-extraction (if needed)
- [ ] **Verify**: Works for existing users

### Database Integrity
- [ ] **Check**: No orphaned records
- [ ] **Check**: All foreign keys valid
- [ ] **Check**: Identity records have all required fields
- [ ] **Check**: Voice URLs are accessible (R2)
- [ ] **Check**: JSONB data well-formed

### Logging & Monitoring
- [ ] **Check**: Cloudflare Workers logs show successful requests
- [ ] **Check**: No unhandled errors in logs
- [ ] **Check**: Voice upload logs show successful R2 uploads
- [ ] **Check**: Identity extraction logs show all fields mapped

---

## ✅ PHASE 12: Final Verification

### Complete User Journey
- [ ] **Verify**: User can complete entire flow end-to-end
- [ ] **Verify**: No crashes at any point
- [ ] **Verify**: No data loss
- [ ] **Verify**: All features work as expected
- [ ] **Verify**: User experience smooth and intuitive

### Performance Metrics
- [ ] **Record**: Cold start time
- [ ] **Record**: Onboarding completion time
- [ ] **Record**: Data push duration
- [ ] **Record**: Call connection time
- [ ] **Record**: API response times

### User Satisfaction
- [ ] **Test**: Is the experience "insanely great"?
- [ ] **Test**: Are pain points clear and actionable?
- [ ] **Test**: Does it meet "ultrathink" standards?

---

## 📝 Bug Reporting Template

When you find a bug, document it:

```markdown
### Bug: [Short Description]

**Severity**: Critical / High / Medium / Low

**Steps to Reproduce**:
1.
2.
3.

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happens]

**Environment**:
- iOS Version:
- Device:
- App Version:
- Backend:

**Screenshots/Video**:
[Attach if available]

**Database State**:
[Check Supabase if relevant]

**Logs**:
[Backend logs from Cloudflare]

**Workaround**:
[If any]
```

---

## 🎯 Success Criteria

The app is ready for launch when:

- [ ] ✅ 100% of critical path tests pass
- [ ] ✅ No P0/P1 bugs remain
- [ ] ✅ All data flows correctly (iOS → Backend → Database)
- [ ] ✅ Identity extraction works (V3 mapper creates records)
- [ ] ✅ AI calls use personalized data
- [ ] ✅ Strike system functions correctly
- [ ] ✅ Performance meets targets
- [ ] ✅ Error handling is robust
- [ ] ✅ User experience is smooth

---

## 📌 Notes

**Test Environment**: Always test in a production-like staging environment first.

**Test Data**: Use realistic test data that mimics real user inputs.

**Regression Testing**: Re-run this checklist after any major backend or iOS changes.

**Automated Testing**: This checklist should eventually be automated where possible (unit tests, integration tests, E2E tests).

**Documentation**: Update this checklist as new features are added or flows change.

---

**Last Tested By**: _________________
**Last Test Date**: _________________
**Pass Rate**: _____ / _____
**Blockers Found**: _________________
