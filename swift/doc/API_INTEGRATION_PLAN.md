# 🚀 Complete API Integration Plan for Swift iOS App

## 📋 OVERVIEW
Connect Swift app to existing backend with full VOIP, 11Labs, and data fetching capabilities. Backend at: `be/src/`, Reference RN app: `nrn/`

---

## 🏗️ **PHASE 1: CORE API INFRASTRUCTURE**

### 1.1 Enhanced APIService
- ✅ Already exists at `APIService.swift`
- Add specific endpoint methods (identity, settings, calls, etc.)
- Add response type safety with Codable models
- Implement retry logic for failed requests
- Add request/response logging for debugging

### 1.2 Data Models (Swift Codable Structs)
Create models matching backend responses:
- `Identity` model (60+ fields from `/api/identity/:userId`)
- `IdentityStatus` model (trust %, streak, promises)
- `CallLog` model (call history from `/api/call-log/:userId`)
- `Settings` model (schedule, rules, consequences)
- `Promise` model (user promises/commitments)
- `VoiceClip` model (onboarding voice recordings)
- `CallConfig` model (11Labs call initialization)

### 1.3 Network State Management
- Create `NetworkMonitor` service for connectivity checks
- Add loading/error states to ViewModels
- Implement pull-to-refresh for all data screens
- Add local caching with UserDefaults/CoreData

---

## 🔐 **PHASE 2: AUTHENTICATION & ONBOARDING**

### 2.1 Auth Integration (✅ Mostly Complete)
- ✅ Apple Sign In already working (`AuthService.swift`)
- ✅ Supabase session management working
- Add VOIP token to user profile on auth
- Store auth token securely in Keychain

### 2.2 Onboarding Data Push
Reference: `nrn/services/OnboardingDataPush.ts`
- Port `OnboardingDataPush.pushToBackend()` to Swift
- Send completed onboarding to `/onboarding/v3/complete`
- Include voice recordings as base64 data URLs
- Handle file uploads (audio) to backend
- Register VOIP token during push
- Clear local data after successful push

### 2.3 VOIP Token Registration
- Get VOIP token from PushKit
- Send token to backend: `POST /token-init-push`
- Update user profile with device token
- Handle token refresh on app launch

---

## 📱 **PHASE 3: DATA FETCHING FOR SCREENS**

### 3.1 Home Screen (Face/Evidence/Control Tabs)
**Endpoints to integrate:**
- `GET /api/identity/:userId` - Get user identity, trust %, streak
- `GET /api/identity/stats/:userId` - Get performance statistics
- `GET /api/mirror/countdown/:userId` - Get next call countdown
- `GET /api/promises/:userId` - Get active promises
- `GET /api/settings/schedule/:userId` - Get call schedule

**Data needed:**
- Trust percentage (0-100)
- Current streak days
- Next call time & countdown
- Promises made/broken counts
- Success rate & grade
- Call eligibility status

**Pull-to-refresh:** Reload all data when user pulls down

### 3.2 Call History Screen
**Endpoint:**
- `GET /api/call-log/:userId` - Full call history
- `GET /api/call-log/week/:userId` - This week's calls
- `GET /api/call-log/receipts/:userId` - Call receipts/transcripts

**Data structure:**
```swift
struct CallLogEntry: Codable {
    let id: String
    let callType: String // "morning", "evening", "apology_call"
    let startedAt: Date
    let endedAt: Date?
    let durationSec: Int
    let transcript: String?
    let mood: String
    let success: Bool
}
```

### 3.3 Settings Screen
**Endpoints:**
- `GET /api/settings/schedule/:userId` - Call schedule
- `PUT /api/settings/schedule/:userId` - Update schedule
- `GET /api/settings/rules/:userId` - Accountability rules
- `PUT /api/settings/consequences` - Update consequences
- `GET /api/settings/limits/:userId` - Usage limits

**Features:**
- Morning/evening call time configuration
- Time zone selection
- Accountability rules management
- Emergency contact settings

### 3.4 Profile/Identity Screen
**Endpoints:**
- `GET /api/identity/:userId` - Full identity profile
- `PUT /api/identity/:userId` - Update identity
- `GET /api/identity/voice-clips/:userId` - Onboarding voice clips
- `PUT /api/identity/final-oath/:userId` - Update oath

---

## 📞 **PHASE 4: VOIP & 11LABS CALL INTEGRATION**

### 4.1 VOIP Push Notification Setup
Reference: `nrn/modules/expo-voip-push-token-v2/`
- Import PushKit framework
- Register for VOIP notifications on launch
- Handle incoming VOIP push in background
- Store VOIP token and send to backend
- Setup CallKit for native call UI

### 4.2 CallKit Integration
Create `CallKitManager.swift`:
- Report incoming calls to CallKit
- Handle answer/decline actions
- Manage call audio session
- Update call status (connecting, connected, ended)
- Show native iOS call UI

### 4.3 11Labs Agent Connection
Reference: `nrn/components/11labs/ConvAIAgent.tsx`

**Step 1: Get Call Config**
```swift
// POST /call/:userId/:callType
let response = APIService.shared.post("/call/\(userId)/morning")
// Returns: agentId, systemPrompt, firstMessage, voiceId, metadata
```

**Step 2: Start 11Labs Conversation**
- Install `@elevenlabs/react-native` equivalent for Swift (if exists) OR
- Use 11Labs REST API directly with WebSocket
- Configure audio session for background
- Start conversation with prompts from backend
- Handle real-time transcription

**Step 3: Call Lifecycle**
- Configure AVAudioSession for VoIP mode
- Start conversation when call answered
- Handle background audio (app in background)
- Send events to backend during call
- End conversation and cleanup

### 4.4 Call Initiation Flow
```
1. User triggers call OR VOIP push received
2. CallKit shows incoming call UI
3. User answers → Get call config from backend
4. Connect to 11Labs agent with config
5. Start audio conversation
6. Handle real-time events
7. End call → Send transcript to backend
```

### 4.5 Background Call Handling
- Configure `UIBackgroundModes` for VOIP
- Setup `AVAudioSession` for background audio
- Keep connection alive during background
- Handle app termination gracefully

---

## 💾 **PHASE 5: STATE MANAGEMENT & CACHING**

### 5.1 Data Persistence Layer
Create `DataStore.swift`:
- Cache identity data locally
- Cache call history (last 30 days)
- Cache settings for offline access
- Use CoreData or UserDefaults
- Implement cache expiration (e.g., 5 minutes)

### 5.2 Pull-to-Refresh Pattern
For every data screen:
```swift
@State private var isRefreshing = false

.refreshable {
    await refreshData()
}

func refreshData() async {
    isRefreshing = true
    // Fetch from API
    // Update local state
    isRefreshing = false
}
```

### 5.3 Offline Support
- Show cached data when offline
- Queue API calls for retry when online
- Show offline indicator in UI
- Graceful degradation for missing data

---

## 🎯 **PHASE 6: SPECIFIC API ENDPOINTS TO IMPLEMENT**

### Critical Endpoints (Priority 1)
1. `POST /call/:userId/:callType` - Get call config for 11Labs
2. `GET /api/identity/:userId` - Load user identity & stats
3. `GET /api/mirror/countdown/:userId` - Next call countdown
4. `POST /onboarding/v3/complete` - Push onboarding data
5. `POST /token-init-push` - Register VOIP token

### Important Endpoints (Priority 2)
6. `GET /api/promises/:userId` - Load promises
7. `POST /promise/create` - Create new promise
8. `POST /promise/complete` - Mark promise complete
9. `GET /api/call-log/:userId` - Call history
10. `GET /api/settings/schedule/:userId` - Call schedule

### Nice-to-Have Endpoints (Priority 3)
11. `PUT /api/settings/schedule/:userId` - Update schedule
12. `GET /api/identity/voice-clips/:userId` - Voice recordings
13. `PUT /api/identity/:userId` - Update identity
14. `GET /api/call-log/receipts/:userId` - Call transcripts
15. `POST /voice/clone` - Voice cloning (premium)

---

## 🛠️ **IMPLEMENTATION APPROACH**

### Week 1: Foundation
- Enhance APIService with all endpoints
- Create all Codable data models
- Setup VOIP push notifications
- Basic CallKit integration

### Week 2: Data Integration
- Implement home screen data fetching
- Add pull-to-refresh everywhere
- Setup local caching layer
- Integrate onboarding data push

### Week 3: VOIP & Calls
- Complete CallKit integration
- Integrate 11Labs conversation SDK/API
- Background audio handling
- Call config fetching from backend

### Week 4: Polish & Testing
- Error handling & retry logic
- Offline support
- Loading states & animations
- End-to-end call testing

---

## 📚 **KEY REFERENCE FILES**

**Backend API:**
- `be/src/index.ts` - All routes
- `be/src/routes/11labs-call-init.ts` - Call config
- `be/src/routes/identity.ts` - Identity endpoints
- `be/ARCHITECTURE_BACKEND.md` - Full API docs

**React Native Reference:**
- `nrn/lib/api.ts` - API client (port to Swift)
- `nrn/services/OnboardingDataPush.ts` - Onboarding push logic
- `nrn/components/11labs/ConvAIAgent.tsx` - 11Labs integration
- `nrn/modules/expo-voip-push-token-v2/` - VOIP module
- `nrn/screens/CallScreen.tsx` - Call UI reference

**Swift App:**
- `APIService.swift` - Enhance this
- `AuthService.swift` - Already working ✅
- `User.swift` - Add more models here
- `CallScreen.swift` - Connect to 11Labs here
- `FaceView.swift` - Connect to identity API

---

## ⚡ **QUICK WINS TO START**

1. **Add Identity Data Fetch** (30 mins)
   - Add method to APIService: `fetchIdentity(userId:)`
   - Update FaceView to show real data

2. **Onboarding Push** (1 hour)
   - Port OnboardingDataPush.ts logic
   - Call after payment completion

3. **VOIP Token Registration** (30 mins)
   - Get token from PushKit
   - Send to backend on app launch

4. **Pull-to-Refresh** (15 mins per screen)
   - Add `.refreshable` modifier
   - Fetch data in refresh handler

---

## 🔥 **DETAILED ENDPOINT REFERENCE**

### Backend Base URL
```
Development: https://a0b96cbbf886.ngrok-free.app
Production: TBD (Cloudflare Worker URL)
```

### Authentication Header
```swift
Authorization: Bearer {supabase_access_token}
```

### Complete Endpoint List

#### Health & Test
- `GET /` - Health check
- `GET /stats` - User stats
- `GET /test` - API connectivity test

#### Authentication & Onboarding
- `POST /onboarding/v3/complete` - Push onboarding data after payment
  - Body: `{ userId, state, voipToken }`
  - Returns: `{ success, identityExtraction, filesProcessed }`

#### Identity Management
- `GET /api/identity/:userId` - Get full identity profile
  - Returns: 60+ psychological fields, trust %, streak, etc.
- `PUT /api/identity/:userId` - Update identity fields
- `GET /api/identity/stats/:userId` - Performance statistics
- `GET /api/identity/voice-clips/:userId` - Onboarding voice recordings
- `PUT /api/identity/final-oath/:userId` - Update final oath

#### Calls & VOIP
- `POST /call/:userId/:callType` - Get call config for 11Labs
  - callType: "morning" | "evening" | "apology_call" | "first_call"
  - Returns: `{ agentId, mood, prompts, voiceId, callUUID, metadata }`
- `GET /api/call-log/:userId` - Full call history
- `GET /api/call-log/week/:userId` - This week's calls
- `GET /api/call-log/receipts/:userId` - Call transcripts & receipts
- `POST /token-init-push` - Register VOIP token
  - Body: `{ userId, voipToken, platform: "ios" }`

#### Promises & Commitments
- `GET /api/promises/:userId` - Get all promises
- `POST /promise/create` - Create new promise
  - Body: `{ userId, title, description, deadline }`
- `POST /promise/complete` - Mark promise as complete
  - Body: `{ promiseId, completedAt }`
- `POST /promise/bulk-update` - Update multiple promises

#### Settings & Schedule
- `GET /api/settings/schedule/:userId` - Get call schedule
  - Returns: morning/evening times, timezone, preferences
- `PUT /api/settings/schedule/:userId` - Update call schedule
  - Body: `{ morningTime, eveningTime, timezone, enabled }`
- `GET /api/settings/rules/:userId` - Get accountability rules
- `PUT /api/settings/consequences` - Update consequences
- `GET /api/settings/limits/:userId` - Usage limits & quotas

#### Mirror & Countdown
- `GET /api/mirror/:userId` - Mirror data (identity reflection)
- `GET /api/mirror/countdown/:userId` - Next call countdown
  - Returns: `{ nextCallTime, timeRemaining, callType }`
- `PUT /api/mirror/trust` - Update trust percentage

#### Voice & Audio
- `POST /voice/clone` - Voice cloning (requires subscription)
  - Body: FormData with audio file
- `POST /onboarding/analyze-voice` - Analyze onboarding voice
  - Body: `{ audioBase64, stepId }`

#### Webhooks (Backend-to-Backend)
- `POST /webhook/elevenlabs` - 11Labs transcript webhook
- `POST /webhook/elevenlabs/audio` - 11Labs audio webhook
- `POST /webhooks/revenuecat` - RevenueCat purchase webhook

---

## 📝 **DATA MODEL EXAMPLES**

### Identity Response
```swift
struct IdentityResponse: Codable {
    let id: String
    let name: String
    let summary: String
    let createdAt: Date
    let updatedAt: Date
    let daysActive: Int

    // Core identity
    let achievements: [String]?
    let failureReasons: [String]?
    let singleTruthUserHides: String?
    let fearVersionOfSelf: String?
    let desiredOutcome: String?
    let keySacrifice: String?
    let identityOath: String?
    let lastBrokenPromise: String?

    // Status
    let trustPercentage: Double
    let currentStreakDays: Int
    let promisesMadeCount: Int
    let promisesBrokenCount: Int
    let nextCallTimestamp: Date?

    // Stats
    let stats: IdentityStats
}

struct IdentityStats: Codable {
    let totalCalls: Int
    let answeredCalls: Int
    let successRate: Int
    let longestStreak: Int
}
```

### Call Config Response
```swift
struct CallConfigResponse: Codable {
    let success: Bool
    let agentId: String
    let mood: String
    let callUUID: String
    let prompts: CallPrompts
    let voiceId: String?
    let metadata: CallMetadata
}

struct CallPrompts: Codable {
    let systemPrompt: String
    let firstMessage: String
}

struct CallMetadata: Codable {
    let userId: String
    let callType: String
    let toneUsed: String
    let userStreak: Int?
    let hasOnboardingData: Bool
    let behavioralIntelligenceActive: Bool
}
```

### Promise Model
```swift
struct Promise: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let description: String?
    let deadline: Date?
    let completed: Bool
    let completedAt: Date?
    let createdAt: Date
    let priority: Int?
}
```

---

## 🎯 **NEXT STEPS**

1. **Read this entire document** - Understand the full scope
2. **Start with Quick Wins** - Get immediate value
3. **Follow the Phases** - Systematic implementation
4. **Reference RN code** - Port logic from nrn/ to Swift
5. **Test incrementally** - Verify each endpoint works
6. **Add error handling** - Graceful failures everywhere

---

## 💡 **TIPS & BEST PRACTICES**

### Error Handling
```swift
do {
    let identity = try await APIService.shared.fetchIdentity(userId: userId)
    // Update UI
} catch APIError.unauthorized {
    // Redirect to login
} catch APIError.networkError(let error) {
    // Show offline message
} catch {
    // Generic error handling
}
```

### Loading States
```swift
@State private var isLoading = false
@State private var error: String?

if isLoading {
    ProgressView()
} else if let error = error {
    ErrorView(message: error)
} else {
    // Show data
}
```

### Caching Strategy
```swift
// Check cache first
if let cached = cache.get("identity_\(userId)"), !cached.isExpired {
    return cached.data
}

// Fetch from API
let fresh = try await APIService.shared.fetchIdentity(userId: userId)

// Update cache
cache.set("identity_\(userId)", data: fresh, ttl: 300) // 5 min

return fresh
```

---

**Last Updated:** 2025-10-06
**Status:** Ready for implementation 🚀
