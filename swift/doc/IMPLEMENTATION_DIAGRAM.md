# Implementation Diagram

## 🎯 Complete Flow: Onboarding → Paywall → Home

```
┌─────────────────────────────────────────────────────────────────────┐
│                         APP LAUNCH                                  │
│  bigbruhhApp.swift                                                  │
│  ├─ OnboardingDataManager.clearInProgressState()                   │
│  ├─ RevenueCatService.shared.configure()                           │
│  └─ EntryView()                                                     │
└─────────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      ENTRY VIEW ROUTING                             │
│  EntryView.swift                                                    │
│  ├─ if !authenticated → WelcomeView                                │
│  ├─ if !onboardingCompleted → OnboardingView                       │
│  ├─ if !almostThereCompleted → AlmostThereView                     │
│  └─ else → HomeView                                                 │
└─────────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    ONBOARDING (45 STEPS)                            │
│  OnboardingView.swift                                               │
│  ├─ Step 1-45: Text, Voice, Choice, Sliders, etc.                  │
│  ├─ UserResponse saved for each step                               │
│  ├─ In-progress state: "onboarding_v3_state"                       │
│  │  (Cleared on app restart)                                       │
│  ├─ On completion:                                                  │
│  │  ├─ OnboardingDataManager.saveCompletedData(state)             │
│  │  │  → Saved to: "completed_onboarding_data"                    │
│  │  │  → Includes ALL responses (text, voice base64, etc.)        │
│  │  └─ Navigate to AlmostThereView                                │
└─────────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    ALMOST THERE (5 STEPS)                           │
│  AlmostThereView.swift                                              │
│  ├─ Step 1-4: Explanation screens                                  │
│  ├─ Step 5: Binary choice                                          │
│  │   ┌─────────────┬─────────────┐                                 │
│  │   │   LEAVE     │   COMMIT    │                                 │
│  │   └─────────────┴─────────────┘                                 │
│  │         ↓              ↓                                         │
│  │    HomeView      PaywallView                                    │
└─────────────────────────────────────────────────────────────────────┘
                               ↓ (User taps COMMIT)
┌─────────────────────────────────────────────────────────────────────┐
│                       PAYWALL CONTAINER                             │
│  PaywallView.swift                                                  │
│  ├─ source: "almost_there"                                         │
│  ├─ onPurchaseComplete: navigate to HomeView                      │
│  ├─ onDismiss: dismiss paywall                                     │
│  └─ Access to onboardingData for personalization                  │
└─────────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────┐
│                  NATIVE REVENUECAT PAYWALL                          │
│  RevenueCatPaywallView.swift                                        │
│  ├─ RevenueCatUI.PaywallView (native component)                    │
│  ├─ Fetches offering from RevenueCat dashboard                     │
│  ├─ Shows plans (Monthly, Yearly, etc.)                            │
│  ├─ Handles purchase, restore, cancel, dismiss                     │
│  └─ Tracks analytics events                                        │
│                                                                     │
│  User Actions:                                                      │
│  ├─ Purchase → onPurchaseCompleted                                 │
│  ├─ Cancel → onPurchaseCancelled                                   │
│  ├─ Restore → onRestoreCompleted                                   │
│  └─ Dismiss → onRequestedDismissal                                 │
└─────────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────┐
│                   REVENUECAT SERVICE                                │
│  RevenueCatService.swift (Singleton)                                │
│  ├─ Purchases.configure(apiKey)                                    │
│  ├─ fetch offerings from dashboard                                 │
│  ├─ fetch customerInfo                                              │
│  ├─ purchase(package)                                               │
│  ├─ restorePurchases()                                              │
│  ├─ updateSubscriptionStatus(customerInfo)                         │
│  │   ┌─────────────────────────────────────┐                       │
│  │   │  #if DEBUG                           │                       │
│  │   │    isActive: true (auto-grant)       │                       │
│  │   │  #else                               │                       │
│  │   │    Check entitlements from RC        │                       │
│  │   └─────────────────────────────────────┘                       │
│  └─ Publishes @Published subscriptionStatus                        │
└─────────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────┐
│                       HOME VIEW                                     │
│  HomeView.swift                                                     │
│  ├─ Access to full onboarding data                                 │
│  ├─ Access to subscription status                                  │
│  └─ Main app functionality                                         │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🗄️ Data Storage Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        USERDEFAULTS                                 │
│                                                                     │
│  📦 "onboarding_v3_state" (In-Progress)                            │
│     ├─ Saved after each step during onboarding                     │
│     ├─ Allows resume if app backgrounded (same session)           │
│     └─ 🗑️  DELETED on app restart (clearInProgressState())        │
│                                                                     │
│  💾 "completed_onboarding_data" (Permanent)                        │
│     ├─ Saved when user completes all 45 steps                     │
│     ├─ Contains OnboardingState with ALL responses                │
│     ├─ Includes voice recordings (base64 data URLs)               │
│     ├─ Includes text responses, sliders, choices, etc.            │
│     └─ ✅ Persists across app restarts                            │
│                                                                     │
│  👤 "user_name" (Special)                                          │
│     ├─ Saved from Step 4 (text input)                             │
│     └─ Used for quick access                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📱 Environment Objects Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│  bigbruhhApp.swift                                                  │
│  └─ .environmentObject(OnboardingDataManager.shared)               │
│  └─ .environmentObject(RevenueCatService.shared)                   │
└─────────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────┐
│  ANY VIEW IN THE APP                                                │
│                                                                     │
│  @EnvironmentObject var onboardingData: OnboardingDataManager      │
│  @EnvironmentObject var revenueCat: RevenueCatService              │
│                                                                     │
│  Access:                                                            │
│  ├─ onboardingData.userName                                        │
│  ├─ onboardingData.brotherName                                     │
│  ├─ onboardingData.voiceResponses                                  │
│  ├─ onboardingData.getResponse(for: stepId)                        │
│  ├─ revenueCat.hasActiveSubscription                               │
│  └─ revenueCat.subscriptionStatus                                  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🎤 Voice Data Storage

```
┌─────────────────────────────────────────────────────────────────────┐
│  VOICE RECORDING FLOW                                               │
│                                                                     │
│  1. User records audio                                              │
│     ├─ VoiceStep.swift: AudioRecorderManager                       │
│     └─ Saved to Documents: "recording_{timestamp}.m4a"            │
│                                                                     │
│  2. Convert to Base64                                               │
│     ├─ Read file as Data                                           │
│     ├─ Encode to base64 string                                     │
│     └─ Format: "data:audio/m4a;base64,AAAAHGZ0eX..."              │
│                                                                     │
│  3. Store in UserResponse                                           │
│     ├─ ResponseValue.text(dataUrl)                                 │
│     ├─ duration: seconds                                           │
│     └─ dbField: ["voice_excuse"]                                   │
│                                                                     │
│  4. Cleanup                                                         │
│     └─ Delete temp .m4a file                                       │
│                                                                     │
│  5. Save to OnboardingState                                         │
│     └─ responses[stepId] = userResponse                            │
│                                                                     │
│  6. On completion                                                   │
│     └─ OnboardingDataManager.saveCompletedData()                   │
│         → All voice data available app-wide                        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Subscription Status Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│  DEVELOPMENT MODE (#if DEBUG)                                       │
│                                                                     │
│  RevenueCatService.updateSubscriptionStatus()                      │
│  ├─ Always returns:                                                 │
│  │   ├─ isActive: true                                             │
│  │   ├─ isEntitled: true                                           │
│  │   ├─ productId: "dev_override_premium"                         │
│  │   └─ expirationDate: +1 year                                   │
│  └─ No real purchase needed                                        │
└─────────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────┐
│  PRODUCTION MODE                                                    │
│                                                                     │
│  RevenueCatService.updateSubscriptionStatus(customerInfo)          │
│  ├─ Check customerInfo.entitlements.active                         │
│  ├─ If active entitlements found:                                  │
│  │   ├─ isActive: true                                             │
│  │   ├─ isEntitled: true                                           │
│  │   ├─ productId: from entitlement                               │
│  │   ├─ expirationDate: from entitlement                          │
│  │   └─ willRenew: from entitlement                               │
│  └─ Else:                                                           │
│      ├─ isActive: false                                            │
│      └─ isEntitled: false                                          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Comparison: NRN vs SwiftUI

| Component | NRN (React Native) | SwiftUI |
|-----------|-------------------|---------|
| **Paywall UI** | `RevenueCatUI.Paywall` | `PaywallView(offering:)` |
| **SDK Import** | `react-native-purchases` | `import RevenueCat` |
| **UI Import** | `react-native-purchases-ui` | `import RevenueCatUI` |
| **Service** | `RevenueCatProvider` (Context) | `RevenueCatService` (Singleton) |
| **Config** | `Purchases.configure()` | `Purchases.configure()` |
| **Purchase** | `purchasePackage()` | `purchase(package:)` |
| **Restore** | `restorePurchases()` | `restorePurchases()` |
| **Dev Mode** | `__DEV__` check | `#if DEBUG` check |
| **Analytics** | PostHog tracking | TODO: Add PostHog |
| **Navigation** | `router.push()` | `NavigationStack` |
| **State Mgmt** | React Context | `@EnvironmentObject` |

**Result: ✅ Architecturally Identical**
