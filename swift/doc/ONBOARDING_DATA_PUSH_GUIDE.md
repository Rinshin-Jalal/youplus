# 📤 Onboarding Data Push Implementation Guide

## Overview
Complete implementation of onboarding data push functionality, matching the React Native app's flow (`nrn/services/OnboardingDataPush.ts`).

## 🎯 User Flow

```
1. User completes onboarding (anonymous, no auth)
   ↓ [Saves progress locally to UserDefaults]

2. User sees AlmostThereView
   ↓

3. User clicks "Get Big Bruh" → Paywall appears
   ↓

4. User completes payment via RevenueCat
   ↓

5. User authenticates with Apple Sign In
   ↓

6. Navigator shows OnboardingProcessingView
   ↓ [This is the KEY screen]

7. OnboardingProcessingView automatically:
   - Checks for locally stored onboarding data
   - Tests API connectivity
   - Pushes all data to backend /onboarding/v3/complete
   - Shows progress (Uploading → Analyzing)
   - Backend extracts identity, transcribes voice, clones voice
   - Navigates to Home
```

## 📁 Files Created/Modified

### New Files:
1. **OnboardingDataPush.swift** - Core service (matches RN version)
   - Location: `Features/Onboarding/Services/OnboardingDataPush.swift`
   - Handles local storage and backend push

2. **OnboardingProcessingView.swift** - Processing UI
   - Location: `Features/Onboarding/Views/OnboardingProcessingView.swift`
   - Shows upload/analysis progress

### Modified Files:
3. **RootView.swift** - Added `.processing` screen
4. **PaywallView.swift** - Navigate to processing after payment
5. **APIModels.swift** - Already has onboarding models
6. **APIService.swift** - Already has `pushOnboardingData()`

## 🔑 Key Classes

### OnboardingDataPush

```swift
// Singleton service
let service = OnboardingDataPush.shared

// Check if there's pending data
if service.hasPendingData() {
    // Has data to push
}

// Save progress during onboarding
service.saveProgress(StoredOnboardingData(
    currentStep: 5,
    responses: [...],
    totalResponses: 5,
    progressPercentage: 20,
    startedAt: "2025-01-01T12:00:00Z",
    lastSavedAt: "2025-01-01T12:05:00Z"
))

// Mark as completed (before payment)
service.markCompleted(data)

// Push to backend (after auth & payment)
let response = try await service.pushToBackend(
    userId: "user-123",
    voipToken: "device-token" // optional
)

// Clear local data
service.clearStoredData()
```

### Storage Keys
- `onboarding_v3_progress` - In-progress data
- `onboarding_v3_completed` - Completed but not pushed

### Data Model

```swift
struct StoredOnboardingData: Codable {
    var currentStep: Int
    var responses: [String: OnboardingResponseData]
    var totalResponses: Int
    var progressPercentage: Int
    var startedAt: String  // ISO8601
    var lastSavedAt: String // ISO8601
    var isCompleted: Bool?
    var completedAt: String? // ISO8601
}

struct OnboardingResponseData: Codable {
    let type: String        // "voice", "text", "choice", etc.
    let value: String?      // Text, base64 audio, or JSON
    let timestamp: String
    let voiceUri: String?
    let duration: Double?
    let audioFileSize: Int?
    let audioFormat: String?
}
```

## 🔄 Integration Points

### 1. During Onboarding (Save Progress)

```swift
// In your OnboardingView or step handler
let responseData = OnboardingResponseData(
    type: "voice",
    value: audioBase64DataURL, // "data:audio/m4a;base64,..."
    timestamp: ISO8601DateFormatter().string(from: Date()),
    voiceUri: fileURL.absoluteString,
    duration: 5.2,
    audioFileSize: 12345,
    audioFormat: "m4a"
)

var storedData = OnboardingDataPush.shared.getStoredData() ?? StoredOnboardingData(...)
storedData.responses["\(stepId)"] = responseData
storedData.currentStep = stepId
storedData.totalResponses += 1

OnboardingDataPush.shared.saveProgress(storedData)
```

### 2. When Onboarding Completes

```swift
// In OnboardingView's onComplete handler
let data = OnboardingDataPush.shared.getStoredData()!
OnboardingDataPush.shared.markCompleted(data)

// Navigate to AlmostThere → Paywall → Processing
```

### 3. After Payment (Automatic)

The flow is automatic once payment completes:

```swift
// PaywallView.swift (already updated)
private func handlePurchaseComplete() {
    navigator.showProcessing() // Goes to processing screen
}

// OnboardingProcessingView.swift (already created)
// - Automatically pushes data on appear
// - Shows progress UI
// - Navigates to home when done
```

## 🎨 OnboardingProcessingView UI States

### Uploading
```
⚙️ Processing Your Responses
   Uploading your responses...
   [████████░░░░░░░░░░░] 40%
```

### Analyzing
```
⚙️ Analyzing Your Profile
   Analyzing your profile and extracting insights...
   [████████████████░░░] 80%
```

### Complete
```
✅ You're All Set!
   Your accountability system is ready. No more excuses.

   [Continue to Big Bruh]
```

### Error
```
⚠️ Something Went Wrong
   Failed to push onboarding data: Network error

   [Retry]
```

## 🧪 Testing

### Create Test Data (Development Only)

```swift
#if DEBUG
OnboardingDataPush.shared.createTestData()

// Check what's stored
print(OnboardingDataPush.shared.getStoredDataSummary())
// "Onboarding: 2 responses, Step 45, 100% (COMPLETED)"
#endif
```

### Test API Connectivity

```swift
let connected = await OnboardingDataPush.shared.testApiConnectivity()
if connected {
    // Safe to push
}
```

### Clear All Data (Development)

```swift
OnboardingDataPush.shared.clearStoredData()
```

## 📊 Backend API

### Endpoint
```
POST /onboarding/v3/complete
```

### Request Body
```json
{
  "userId": "user-uuid",
  "voipToken": "device-push-token",
  "state": {
    "currentStep": 45,
    "responses": {
      "1": {
        "type": "text",
        "value": "My name is John",
        "timestamp": "2025-01-01T12:00:00Z"
      },
      "5": {
        "type": "voice",
        "value": "data:audio/m4a;base64,AAA...",
        "timestamp": "2025-01-01T12:05:00Z",
        "duration": 5.2
      }
    },
    "totalResponses": 45,
    "progressPercentage": 100,
    "startedAt": "2025-01-01T12:00:00Z",
    "lastSavedAt": "2025-01-01T12:30:00Z",
    "isCompleted": true,
    "completedAt": "2025-01-01T12:30:00Z"
  }
}
```

### Response
```json
{
  "success": true,
  "message": "Onboarding completed successfully",
  "completedAt": "2025-01-01T12:30:10Z",
  "totalSteps": 45,
  "filesProcessed": 12,
  "identityExtraction": {
    "success": true,
    "fieldsExtracted": 60,
    "voiceTranscribed": 8,
    "error": null
  }
}
```

## ⚠️ Important Notes

1. **Voice Data Format**
   - Store voice as base64 data URLs: `data:audio/m4a;base64,AAA...`
   - NOT file:// URLs (those become invalid after app restart)

2. **Storage Priority**
   - Completed data takes priority over progress data
   - Always check `isCompleted` flag

3. **Error Handling**
   - Processing view has retry button
   - User can retry if push fails
   - Data stays local until successful push

4. **Cleanup**
   - Local data is cleared ONLY after successful backend push
   - Safe to retry multiple times

5. **VOIP Token**
   - Currently optional (will be added when PushKit implemented)
   - Backend can handle nil token

## 🚀 Next Steps

1. ✅ **Onboarding Data Push** - COMPLETE
2. ⏭️ **VOIP Token Registration** - Integrate PushKit
3. ⏭️ **CallKit Integration** - Native call UI
4. ⏭️ **11Labs Integration** - Actual AI calls

## 📝 Code Example: Full Flow

```swift
// 1. During onboarding - save each response
func handleStepComplete(stepId: Int, response: OnboardingResponseData) {
    var data = OnboardingDataPush.shared.getStoredData() ?? initialData()
    data.responses["\(stepId)"] = response
    data.currentStep = stepId
    data.totalResponses += 1
    data.progressPercentage = calculateProgress(stepId)
    data.lastSavedAt = ISO8601DateFormatter().string(from: Date())

    OnboardingDataPush.shared.saveProgress(data)
}

// 2. When all 45 steps complete
func onboardingComplete() {
    let data = OnboardingDataPush.shared.getStoredData()!
    OnboardingDataPush.shared.markCompleted(data)

    // Navigate to paywall
    navigator.currentScreen = .almostThere
}

// 3. After payment - automatic!
// PaywallView → navigator.showProcessing()
// OnboardingProcessingView → pushToBackend()
// Auto navigate to home when done
```

---

**Status:** ✅ FULLY IMPLEMENTED AND READY TO USE

**Last Updated:** 2025-10-06
