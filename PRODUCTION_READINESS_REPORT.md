# Production Readiness Report

## 1. Agent Directory (`agent/`)

### Critical Issues
- **Broken Memory Loop**: `memory.py` saves call memories with generic tags (`["call", mood, "processed"]`) but retrieval relies on specific tags (`"promise"`, `"goal"`, `"progress"`).
  - **Impact**: The agent will never recall past promises or goals, rendering the "accountability" feature useless.
  - **Fix**: Update `save_call_memory` to add tags based on the `insights` data.
- **Intelligence Missing**: `post_call.py` relies on simple keyword matching ("i promise", "i will") instead of LLM extraction.
  - **Location**: `post_call.py` (Line 115)
- **Race Condition**: `entrypoint` in `main.py` attempts to speak the first message immediately. If `agent.say()` is not ready (AttributeError fallback), it appends to chat context, which might cause the agent to "think" it spoke without actually producing audio.
- **Hardcoded Fallbacks**: `room_metadata` parsing defaults `user_id` to "unknown" and `voice_id` to "default". This risks polluting the database with orphan records or breaking TTS.

### Important
- **Device Tools Disconnect**: `main.py` registers tools (`flash_screen`, etc.), but the iOS client (`CallSessionController.swift` / `LiveKitManager.swift`) has **disabled** the data channel logic to receive them.
  - **Impact**: Agent will try to flash the screen or vibrate the phone, and nothing will happen.

## 2. Backend Directory (`be/`)

### Critical Security & Stability
- **Dangerous Auth Bypass**: `middleware/auth.ts` completely disables subscription checks if `NODE_ENV !== "production"`. A configuration error could expose premium features for free.
  - **Fix**: Require an explicit `ENABLE_DEV_BYPASS` env var.
- **Data Integrity Race**: `postOnboardingV3Complete` updates `users` table (marking onboarding as complete) *before* successfully saving the detailed `onboarding` responses.
  - **Impact**: If saving responses fails, a user enters the app with no data, breaking `FaceView` and identity extraction.
- **Performance**: `requireActiveSubscription` performs a database query for `revenuecat_customer_id` on **every single authenticated request**.
  - **Fix**: Cache this ID in the JWT or Redis.
- **Missing Database Fields**: `settings.ts` notes that `subscription_product_id`, `subscription_expiry`, and `subscription_will_renew` may need to be added to the database schema.
  - **Location**: `features/core/handlers/settings.ts` (Line 151)

### Code Quality
- **Excessive Logging**: Onboarding handler logs full PII (names, slider values) to stdout. This violates privacy best practices.
- **Hardcoded URLs**: `r2-upload.ts` uses `https://audio.yourbigbruhh.app/` which should be an environment variable.
  - **Location**: `features/voice/services/r2-upload.ts` (Line 85)
- **Fragile Cron**: `index.ts` uses dynamic imports inside the cron handler. If the build chunks these incorrectly, the cron job will fail silently.
- **Temporary Session ID**: `voice.ts` uses `sessionId` as a temporary user ID for voice analysis, with a TODO to migrate to actual user ID after auth.
  - **Location**: `features/voice/handlers/voice.ts` (Line 79)

## 3. Swift App (`swift/`)

### Critical
- **Crash on Launch**: `APIService.init` calls `fatalError()` if `PUBLIC_BACKEND_URL` is missing. This causes an immediate crash for users if the config is bad.
- **Zombie Auth State**: `AuthService` sets `isAuthenticated = true` even if fetching the user profile fails (e.g., network error).
  - **Impact**: App enters "logged in" state but `user` object is nil, potentially causing crashes in views that force-unwrap `authService.user`.
- **Legacy Code**: `CallSessionController.swift` contains dead code for 11Labs-style tool registration that is incompatible with the new LiveKit architecture.

### Important
- **Missing UI Data**: `FaceView` relies on backend fields (`next_call_timestamp`, `call_time`) that do not exist in the `identity` table.
  - **Location**: `FaceView.swift` (Lines 509, 525)
- **LiveKit Config**: Falls back to example URL if config is missing.
  - **Location**: `AppDelegate+LiveKit.swift` (Line 47)
- **Data Channels Disabled**: `LiveKitManager.swift` has data channel functionality explicitly disabled/commented out.
  - **Location**: `LiveKitManager.swift` (Lines 200, 236)
- **Missing Error Handling**: `ControlView.swift` has a TODO to show error alerts to the user.
  - **Location**: `ControlView.swift` (Line 273)
- **Hardcoded User**: `RootView.swift` has a TODO to get the username from context instead of hardcoding "BigBruh".
  - **Location**: `RootView.swift` (Line 135)

## 4. Recommended Action Plan

### Phase 1: Critical Fixes (Day 1)
1.  **Agent**: Fix `memory.py` to add correct tags during save.
2.  **Backend**: Secure `middleware/auth.ts` and fix race condition in `onboarding.ts`.
3.  **Swift**: Remove `fatalError` from `APIService` and fix `AuthService` error handling.

### Phase 2: Feature Completion (Day 2-3)
1.  **Agent**: Upgrade `post_call.py` to use LLM for extraction.
2.  **Backend**: Add missing fields to `identity` table (`call_time`, `next_call_timestamp`) and `users` table (subscription fields).
3.  **Swift**: Re-implement Device Tools using LiveKit data channels (requires updates to `LiveKitManager.swift`).

### Phase 3: Hardening (Day 4)
1.  **Backend**: Remove PII logging, implement caching for subscription checks, and externalize hardcoded URLs.
2.  **Agent**: Improve metadata validation and error handling.
3.  **Swift**: Implement proper error alerts in `ControlView` and dynamic user context in `RootView`.
