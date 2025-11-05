# 🚀 BigBruh API Reference - Super MVP

**Last Updated:** 2025-11-05
**Status:** Post-Bloat Cleanup - Production Ready
**Schema:** Super MVP (12 columns + JSONB)

---

## 📋 OVERVIEW

This document describes the **WORKING PRODUCTION ENDPOINTS** after comprehensive bloat elimination (commit `d3578ab`).

**What changed:**
- Removed 15 dead iOS API methods (54% of client code)
- Migrated from bloated schema (60+ fields) to Super MVP (12 columns + JSONB)
- Removed `trust_percentage` field (replaced with `current_streak_days`)
- Documented all debug/test/admin endpoints

---

## 🌐 BASE URL

```
Development: Config.backendURL (from Info.plist)
Production: https://api.bigbruh.app
```

All endpoints require authentication via Supabase JWT:
```
Authorization: Bearer {supabase_access_token}
```

---

## ✅ PRODUCTION ENDPOINTS (Used by iOS App)

These are the **ONLY 8 endpoints** actively used by the iOS app in production.

### 1. Identity Management

#### `GET /api/identity/:userId`
**Purpose:** Fetch user's complete identity profile
**Auth:** Required (subscription)
**Response:** Super MVP Identity (12 fields + onboarding_context JSONB)

```typescript
{
  success: true,
  data: {
    user_id: string,
    name: string,
    daily_non_negotiable: string,
    chosen_path: "monk" | "warrior" | "builder",
    call_time: string,  // "07:00"
    strike_limit: number,

    // Voice URLs
    morning_voice_url: string | null,
    evening_voice_url: string | null,
    confrontation_voice_url: string | null,

    // JSONB field containing all onboarding extraction
    onboarding_context: {
      achievements: string[],
      failure_reasons: string[],
      single_truth_user_hides: string,
      fear_version_of_self: string,
      // ... 30+ extracted fields
    },

    created_at: string,
    updated_at: string
  }
}
```

**Key Change:** No more `trust_percentage`, `promises_made_count`, etc. in identity table. Those moved to `identity_status` table.

---

#### `PUT /api/identity/:userId`
**Purpose:** Update user identity fields
**Auth:** Required (subscription)
**Body:**
```typescript
{
  name?: string,
  daily_non_negotiable?: string,
  chosen_path?: "monk" | "warrior" | "builder",
  call_time?: string,
  strike_limit?: number
}
```

---

#### `PUT /api/identity/status/:userId`
**Purpose:** Update identity status (internal use - called by backend after calls)
**Auth:** Required (subscription)
**Body:**
```typescript
{
  current_streak_days?: number,
  total_calls_completed?: number,
  last_call_timestamp?: string
}
```

**Note:** `trust_percentage` removed in Super MVP migration.

---

#### `GET /api/identity/stats/:userId`
**Purpose:** Get user performance statistics
**Auth:** Required (subscription)
**Response:**
```typescript
{
  success: true,
  data: {
    total_calls: number,
    answered_calls: number,
    success_rate: number,
    current_streak_days: number,
    longest_streak: number
  }
}
```

---

### 2. Call Management

#### `GET /call/config/:userId/:callType`
**Purpose:** Get call configuration for 11Labs agent
**Auth:** Required (subscription)
**Call Types:** `"morning"` | `"evening"` | `"accountability"` | `"onboarding"`

**Response:**
```typescript
{
  success: true,
  data: {
    agent_id: string,
    mood: "Encouraging" | "Confrontational" | "ColdMirror",
    call_uuid: string,
    prompts: {
      system_prompt: string,
      first_message: string
    },
    voice_id: string,
    metadata: {
      user_id: string,
      call_type: string,
      tone_used: string,
      user_streak: number,
      has_onboarding_data: boolean
    }
  }
}
```

**Critical Fix (commit d3578ab):** iOS was calling `POST /call/:userId/:callType` which didn't exist. Now correctly calls `GET /call/config/:userId/:callType`.

---

### 3. Onboarding

#### `POST /onboarding/v3/complete`
**Purpose:** Push completed onboarding data to backend
**Auth:** Required
**Body:**
```typescript
{
  user_id: string,
  state: {
    // All onboarding responses
    achievements: string[],
    failure_reasons: string[],
    single_truth: string,
    fear_self: string,
    desired_outcome: string,
    // ... etc
  },
  voip_token?: string
}
```

**Response:**
```typescript
{
  success: true,
  data: {
    identity: Identity,
    extraction: OnboardingExtraction,
    voice_files_processed: number
  }
}
```

---

### 4. VoIP Token Management

#### `POST /token-init-push`
**Purpose:** Register iOS VoIP push token
**Auth:** Required
**Body:**
```typescript
{
  user_id: string,
  voip_token: string,
  platform: "ios"
}
```

---

### 5. Health Check

#### `GET /test`
**Purpose:** Test API connectivity
**Auth:** None
**Response:**
```typescript
{
  success: true,
  message: "API is working",
  timestamp: string
}
```

---

## 🧪 DEBUG/TEST ENDPOINTS (Not Used in Production)

These endpoints exist for debugging and testing but are **NOT called by the iOS app**.

### VoIP Debug (@debug-only)
- `POST /voip/debug/voip` - Log VoIP debug event
- `GET /voip/debug/voip` - Get VoIP debug events
- `DELETE /voip/debug/voip` - Clear VoIP debug events
- `GET /voip/debug/voip/summary` - VoIP debug summary

### VoIP Session (Production - Called by iOS)
- `POST /voip/session/init` - Initialize VoIP session
- `POST /voip/session/prompts` - Get deferred prompts

### VoIP Test (@test-only)
- `GET /voip/test-certificates` - Test VoIP certificates
- `POST /voip/simple-test` - Simple VoIP test
- `POST /voip/test` - Advanced VoIP test
- `GET /voip/status` - VoIP status
- `POST /voip/ack` - VoIP acknowledgment
- `GET /voip/debug/pending/:callUUID` - Pending call by UUID
- `GET /voip/debug/pending` - All pending calls
- `POST /voip/acknowledge` - Acknowledge VoIP call

---

## 🔐 ADMIN ENDPOINTS (Manual Triggers Only)

These endpoints are **ADMIN USE ONLY** and protected by `requireAuth` middleware.

**File:** `be/src/features/trigger/router.ts`

- `POST /trigger/morning` - Trigger morning calls for all users (placeholder)
- `POST /trigger/evening` - Trigger evening calls for all users (placeholder)
- `POST /trigger/user/:userId/:callType` - Trigger specific user call (testing)
- `POST /trigger/voip` - Send VoIP push with custom payload
- `POST /trigger/onboarding/:userId` - Trigger onboarding call (testing)
- `POST /trigger/scheduled-calls` - Process scheduled calls queue
- `POST /trigger/retry-queue` - Process retry queue

**Security:** Protected by `debugProtection` middleware in production.

---

## ❌ REMOVED ENDPOINTS (Dead Code Eliminated)

These endpoints were removed in the bloat cleanup (commit `d3578ab`) because they **never existed on the backend** but iOS was trying to call them:

### Promise Endpoints (REMOVED)
- ❌ `GET /api/promises/:userId` - Never implemented
- ❌ `POST /promise/create` - Never implemented
- ❌ `POST /promise/complete` - Never implemented

### Call Log Endpoints (REMOVED)
- ❌ `GET /api/call-log/:userId` - Never implemented
- ❌ `GET /api/call-log/week/:userId` - Never implemented
- ❌ `GET /api/call-log/receipts/:userId` - Never implemented
- ❌ `GET /api/history/calls` - Never implemented

### Settings Endpoints (REMOVED)
- ❌ `GET /api/settings/schedule/:userId` - Wrong format, never worked
- ❌ `PUT /api/settings/schedule/:userId` - Wrong format, never worked
- ❌ `GET /api/settings/rules/:userId` - Never implemented
- ❌ `GET /api/settings/limits/:userId` - Never implemented

### Voice/Mirror Endpoints (REMOVED)
- ❌ `GET /api/identity/voice-clips/:userId` - Never implemented
- ❌ `GET /api/mirror/countdown/:userId` - Never implemented

### Deprecated Endpoints (REMOVED)
- ❌ `PUT /api/identity/final-oath/:userId` - Returned 410 Gone, now deleted

**Impact:** Removed 15 dead iOS API methods that would have caused 404 errors.

---

## 🔄 SUPER MVP SCHEMA MIGRATION

### What Changed

**Old Bloated Schema (60+ fields):**
```typescript
interface OldIdentity {
  user_id: string;
  name: string;
  // 60+ psychological fields...
  trust_percentage: number;  // ❌ REMOVED
  promises_made_count: number;  // ❌ REMOVED
  promises_broken_count: number;  // ❌ REMOVED
  current_streak_days: number;
  // ... etc
}
```

**New Super MVP Schema (12 fields + JSONB):**
```typescript
interface SuperMVPIdentity {
  user_id: string;
  name: string;
  daily_non_negotiable: string;
  chosen_path: "monk" | "warrior" | "builder";
  call_time: string;
  strike_limit: number;

  // Voice URLs
  morning_voice_url: string | null;
  evening_voice_url: string | null;
  confrontation_voice_url: string | null;

  // All extracted onboarding data in JSONB
  onboarding_context: JSONB;

  created_at: timestamp;
  updated_at: timestamp;
}
```

**Separate Status Table:**
```typescript
interface IdentityStatus {
  user_id: string;
  current_streak_days: number;  // ✅ KEPT
  total_calls_completed: number;
  last_call_timestamp: timestamp;
  // trust_percentage REMOVED
  // promises_made_count REMOVED
  // promises_broken_count REMOVED
}
```

### Backend Handlers Updated

**Files Fixed (commit d3578ab):**
1. `be/src/features/call/services/tone-engine.ts`
   - Removed `trust_percentage` reference
   - Now uses `current_streak_days` for collapse risk
   - Logic: 0 streak = critical, <3 = high, <7 = medium, 7+ = low

2. `be/src/features/identity/utils/identity-status-sync.ts`
   - Removed `trust_percentage` from interface
   - Removed calculation and database upsert
   - Updated discipline logic to use streak only
   - Updated AI prompts and notifications

---

## 📱 iOS CLIENT IMPLEMENTATION

### Working APIService Methods (After Cleanup)

**File:** `swift/bigbruhh/Core/Networking/APIService.swift`

```swift
// ✅ PRODUCTION ENDPOINTS (8 working methods)

// Identity
func fetchIdentity(userId: String) -> APIResponse<IdentityData>
func updateIdentity(userId: String, updates: [String: Any]) -> APIResponse<IdentityData>
func fetchIdentityStats(userId: String) -> APIResponse<[String: AnyCodableValue]>

// Calls
func getCallConfig(userId: String, callType: String) -> APIResponse<CallConfigResponse>

// Onboarding
func pushOnboardingData(request: OnboardingCompleteRequest) -> APIResponse<IdentityExtraction>

// VoIP
func registerVOIPToken(request: VOIPTokenRequest) -> APIResponse<[String: AnyCodableValue]>

// Health
func testConnection() -> APIResponse<[String: AnyCodableValue]>
```

**Removed Dead Methods (15 total):**
- ❌ `fetchVoiceClips` - Endpoint doesn't exist
- ❌ `fetchCallHistory` - Endpoint doesn't exist
- ❌ `fetchWeekCalls` - Endpoint doesn't exist
- ❌ `fetchCallReceipts` - Endpoint doesn't exist
- ❌ `fetchPromises` - Endpoint doesn't exist
- ❌ `createPromise` - Endpoint doesn't exist
- ❌ `completePromise` - Endpoint doesn't exist
- ❌ `fetchSchedule` - Wrong endpoint format
- ❌ `updateSchedule` - Wrong endpoint format
- ❌ `fetchRules` - Endpoint doesn't exist
- ❌ `fetchLimits` - Endpoint doesn't exist
- ❌ `fetchCountdown` - Endpoint doesn't exist

---

## 🛠️ CONFIGURATION

### iOS App Setup

**File:** `swift/bigbruhh/Config.swift`

```swift
static var backendURL: String? {
    Bundle.main.infoDictionary?["PUBLIC_BACKEND_URL"] as? String
}
```

**Info.plist:**
```xml
<key>PUBLIC_BACKEND_URL</key>
<string>https://api.bigbruh.app</string>
```

**Critical Fix (commit d3578ab):** Removed hardcoded URLs from `CallSessionController.swift`. Now uses `Config.backendURL` for all requests.

---

## 📊 METRICS

### Before Bloat Cleanup
- Backend Routes: 54 total
- iOS API Methods: 28
- Working Endpoints: 8 (15%)
- Dead iOS Code: 15 methods (54%)
- Bloated Schema Handlers: 3

### After Bloat Cleanup
- Backend Routes: 54 (21 marked debug/test/admin)
- iOS API Methods: 13
- Working Endpoints: 8 (100% functional)
- Dead iOS Code: 0
- Bloated Schema Handlers: 0

**Result:** 100% Super MVP compliant with zero dead code! 🚀

---

## 🔍 TROUBLESHOOTING

### Common Issues

**1. Call Config Returns 404**
- ❌ Old: `POST /call/:userId/:callType`
- ✅ Fixed: `GET /call/config/:userId/:callType`

**2. Trust Percentage Field Missing**
- ❌ Removed in Super MVP migration
- ✅ Use: `current_streak_days` from `identity_status` table

**3. Promise Endpoints Return 404**
- ❌ Never implemented on backend
- ✅ Feature removed from iOS app

**4. Hardcoded Backend URL**
- ❌ Old: `https://api.bigbruh.app` hardcoded
- ✅ Fixed: Use `Config.backendURL` from Info.plist

---

## 📚 REFERENCE

### Key Files

**Backend:**
- `be/src/features/identity/router.ts` - Identity routes
- `be/src/features/call/router.ts` - Call routes
- `be/src/features/voip/router.ts` - VoIP routes
- `be/src/features/trigger/router.ts` - Admin triggers
- `be/src/features/onboarding/router.ts` - Onboarding routes

**iOS:**
- `swift/bigbruhh/Core/Networking/APIService.swift` - API client
- `swift/bigbruhh/Features/Call/Services/CallSessionController.swift` - Call handling

**Documentation:**
- `BLOAT_ANALYSIS_COMPLETE.md` - Full bloat analysis
- `COFOUNDER_REVIEW_RESPONSE.md` - Implementation clarification

### Related Commits
- `d3578ab` - Bloat elimination (iOS + backend)
- `0c1ee22` - Bloat analysis (backend + frontend docs)
- `fd23229` - Identity extractor deprecation
- `7f5d473` - Prompt engine Super MVP migration

---

**Questions?** Check `BLOAT_ANALYSIS_COMPLETE.md` for detailed analysis.
