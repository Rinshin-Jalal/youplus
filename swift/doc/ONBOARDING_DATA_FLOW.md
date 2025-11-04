# Onboarding Data Flow & Storage

## Overview
The onboarding system stores data in two separate locations:
1. **In-progress state** (temporary, cleared on app restart)
2. **Completed data** (permanent, accessible across the app)

---

## Storage Architecture

### 1. In-Progress State (Session-Only)
**Key:** `"onboarding_v3_state"`
**Type:** `OnboardingState` (JSON-encoded)
**Lifecycle:**
- Created when user starts onboarding
- Updated after each step
- **CLEARED on app restart** (by `OnboardingDataManager.clearInProgressState()`)
- Allows user to continue within same session if app is backgrounded

**Purpose:** Resume progress if user backgrounds the app during onboarding

---

### 2. Completed Data (Permanent)
**Key:** `"completed_onboarding_data"`
**Type:** `OnboardingState` (JSON-encoded)
**Lifecycle:**
- Saved when user completes all 45 steps
- Persists across app restarts
- Accessible to Paywall, Signup, and other views
- Only cleared on logout or manual reset

**Purpose:** Store final onboarding data for use throughout the app

---

## Data Stored

### OnboardingState Structure
```swift
class OnboardingState {
    currentStep: Int                    // 1-45
    responses: [Int: UserResponse]      // All user responses by step ID
    brotherName: String                 // User's chosen "brother" name
    userName: String?                   // User's real name
    isCompleted: Bool
    startedAt: Date
    completedAt: Date?
}
```

### UserResponse Structure (per step)
```swift
struct UserResponse {
    id: UUID
    stepId: Int                         // 1-45
    type: StepType                      // .text, .voice, .choice, .dualSliders, etc.
    value: ResponseValue                // Enum with actual data
    timestamp: Date
    voiceUri: String?                   // Not used (audio is base64)
    duration: Double?                   // Voice recording duration (seconds)
    dbField: [String]?                  // Database field names
    analysis: VoiceAnalysis?            // AI analysis (future)
    evaluation: ResponseEvaluation?     // Quality evaluation (future)
    psychologicalMarkers: PsychologicalMarkers?
    transcript: String?                 // Voice transcript (future)
}
```

### Response Value Types
```swift
enum ResponseValue {
    case text(String)          // Text input + base64 audio data URLs
    case number(Double)
    case bool(Bool)
    case sliders([Double])     // Dual slider values
    case choice(String)
    case voiceData(Data)       // Not used
    case timeWindow(start: String, end: String)  // HH:mm format
    case timezone(String)
}
```

---

## Audio Storage

### Voice Recording Process
1. **Record** → Saved to Documents Directory as `recording_{timestamp}.m4a`
2. **Convert** → Read as Data → Encode to Base64 string
3. **Store** → Wrapped as data URL: `data:audio/m4a;base64,{base64}`
4. **Clean** → Temporary `.m4a` file deleted
5. **Save** → Base64 data URL stored as `ResponseValue.text(dataUrl)` in UserResponse

**Location:** VoiceStep.swift:639-701

**Format:**
```
data:audio/m4a;base64,AAAAHGZ0eXBNNEEgAAACAGlzb21pc28yAA...
```

---

## Access Patterns

### 1. During Onboarding (OnboardingView)
```swift
// Save after each step
state.saveResponse(response)
saveState() // → "onboarding_v3_state"

// Load on view appear (only works within session)
loadSavedState()
```

### 2. After Completion (OnboardingView)
```swift
// Save completed data for app-wide access
OnboardingDataManager.shared.saveCompletedData(state)
```

### 3. In Other Views (Paywall, Signup, etc.)
```swift
@EnvironmentObject var onboardingData: OnboardingDataManager

// Access user info
let userName = onboardingData.userName
let brotherName = onboardingData.brotherName

// Access specific response
if let excuseResponse = onboardingData.getResponse(for: 10) {
    // Use response data
}

// Get all voice recordings
let voiceResponses = onboardingData.voiceResponses
for response in voiceResponses {
    let base64Audio = response.value // text(...) with data URL
    let duration = response.duration
}

// Get all text responses
let textResponses = onboardingData.textResponses
```

---

## App Lifecycle Behavior

### App Launch (First Time)
1. `OnboardingDataManager.clearInProgressState()` called in App init
2. User starts onboarding from Step 1
3. In-progress state saved after each step
4. If user backgrounds app → State preserved (same session)
5. If user completes → Completed data saved

### App Restart
1. `OnboardingDataManager.clearInProgressState()` called in App init
2. In-progress state **DELETED**
3. User must start onboarding from Step 1 again
4. Completed data **PRESERVED** and accessible

### After Onboarding Completion
1. `OnboardingDataManager.saveCompletedData()` called
2. Data accessible via `OnboardingDataManager.shared`
3. Injected as environment object throughout app
4. Available in Paywall, Signup, Profile, etc.

---

## Example Usage in Paywall

```swift
struct PaywallView: View {
    @EnvironmentObject var onboardingData: OnboardingDataManager

    var body: some View {
        VStack {
            // Personalize with user's name
            Text("READY TO COMMIT, \\(onboardingData.userName?.uppercased() ?? "WARRIOR")?")

            // Access specific onboarding responses
            if let excuseResponse = onboardingData.getResponse(for: 10) {
                Text("I know your excuse. I'll use it against you.")
            }

            // Show all voice recordings metadata
            ForEach(onboardingData.voiceResponses) { response in
                Text("Voice \\(response.stepId): \\(response.duration ?? 0)s")
            }
        }
    }
}
```

---

## Data Cleanup

### Clear In-Progress State Only
```swift
OnboardingDataManager.shared.clearInProgressState()
```
Called automatically on app launch.

### Clear All Data (Logout/Reset)
```swift
OnboardingDataManager.shared.clearAllData()
```
Clears both in-progress and completed data.

---

## File Locations

| File | Purpose |
|------|---------|
| `OnboardingDataManager.swift` | Singleton managing completed data access |
| `OnboardingState.swift` | State model (current step, responses, metadata) |
| `UserResponse.swift` | Individual response model |
| `OnboardingView.swift` | Main view with save/load logic |
| `VoiceStep.swift` | Audio recording → Base64 conversion |
| `TextStep.swift` | Text input with special user_name storage |
| `bigbruhhApp.swift` | App init clears in-progress state |

---

## Summary

✅ **On App Restart:** In-progress state cleared → Fresh start from Step 1
✅ **Completed Data:** Persists across restarts
✅ **Access:** Via `OnboardingDataManager.shared` (singleton + environment object)
✅ **Audio:** Stored as base64 data URLs in `ResponseValue.text(...)`
✅ **Text:** Stored as `ResponseValue.text(...)`
✅ **Usage:** Available in Paywall, Signup, Profile, or any view needing onboarding data
