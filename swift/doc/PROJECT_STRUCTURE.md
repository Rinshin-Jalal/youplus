# 🏗️ BIGBRUH SWIFT PROJECT - COMPLETE STRUCTURE

**Based on your RN app at `/nrn`, here's the EXACT Swift equivalent**

---

## 📁 FOLDER STRUCTURE

```
BigBruh/                                    # Xcode project root
├── BigBruh.xcodeproj                       # Xcode project file
│
├── BigBruh/                                # Source code folder
│   ├── App/
│   │   ├── BigBruhApp.swift                # Entry point (@main)
│   │   ├── AppDelegate.swift               # VoIP + push setup
│   │   └── ContentView.swift               # Root navigation
│   │
│   ├── Core/
│   │   ├── Networking/
│   │   │   ├── SupabaseClient.swift        # nrn/lib/supabase.ts
│   │   │   ├── APIService.swift            # nrn/lib/api.ts
│   │   │   └── NetworkError.swift
│   │   │
│   │   ├── Storage/
│   │   │   ├── UserDefaultsManager.swift   # AsyncStorage equivalent
│   │   │   └── KeychainManager.swift       # Secure storage
│   │   │
│   │   └── Utilities/
│   │       ├── Logger.swift
│   │       ├── HapticManager.swift         # expo-haptics
│   │       └── Extensions/
│   │           ├── Color+Hex.swift
│   │           ├── Date+Formatting.swift
│   │           └── View+Extensions.swift
│   │
│   ├── Features/
│   │   ├── Authentication/                  # nrn/app/(auth)/
│   │   │   ├── Models/
│   │   │   │   └── User.swift
│   │   │   ├── Services/
│   │   │   │   └── AuthService.swift       # nrn/contexts/AuthContext.tsx
│   │   │   └── Views/
│   │   │       ├── AuthView.swift          # nrn/app/(auth)/auth.tsx
│   │   │       └── SignUpView.swift        # nrn/app/(auth)/signup.tsx
│   │   │
│   │   ├── Onboarding/                      # nrn/components/onboarding/
│   │   │   ├── Models/
│   │   │   │   ├── OnboardingStep.swift    # nrn/types/onboarding.ts → StepDefinition
│   │   │   │   ├── UserResponse.swift      # nrn/types/onboarding.ts → UserResponse
│   │   │   │   ├── OnboardingPhase.swift   # Phase definitions
│   │   │   │   └── StepDefinitions.swift   # All 45 steps (STEP_DEFINITIONS array)
│   │   │   │
│   │   │   ├── ViewModels/
│   │   │   │   ├── OnboardingCoordinator.swift  # Main state manager
│   │   │   │   └── VoiceRecordingViewModel.swift
│   │   │   │
│   │   │   ├── Views/
│   │   │   │   ├── OnboardingContainerView.swift   # nrn/components/onboarding/index.tsx
│   │   │   │   ├── PhaseProgressView.swift         # nrn/components/onboarding/PhaseProgressIndicator.tsx
│   │   │   │   ├── GlitchTransitionView.swift      # nrn/components/onboarding/GlitchTransition.tsx
│   │   │   │   │
│   │   │   │   └── Steps/                          # nrn/components/onboarding/steps/
│   │   │   │       ├── TextStepView.swift          # TextStep.tsx
│   │   │   │       ├── VoiceStepView.swift         # VoiceStep.tsx ⭐ MOST COMPLEX
│   │   │   │       ├── ChoiceStepView.swift        # MultipleChoiceStep.tsx
│   │   │   │       ├── DualSlidersStepView.swift   # DualSlidersStep.tsx
│   │   │   │       ├── TimePickerStepView.swift    # TimePickerStep.tsx
│   │   │   │       ├── TimezonePickerStepView.swift # TimezonePickerStep.tsx
│   │   │   │       ├── LongPressStepView.swift     # LongPressStep.tsx
│   │   │   │       └── ExplanationStepView.swift   # ExplanationStep.tsx
│   │   │   │
│   │   │   └── Services/
│   │   │       ├── VoiceRecordingService.swift     # AVAudioRecorder wrapper
│   │   │       └── OnboardingDataService.swift     # Save responses to backend
│   │   │
│   │   ├── Subscription/                    # nrn/app/(purchase)/
│   │   │   ├── Models/
│   │   │   │   └── SubscriptionPlan.swift
│   │   │   ├── Services/
│   │   │   │   └── RevenueCatService.swift  # nrn/contexts/RevenueCatProvider.tsx
│   │   │   └── Views/
│   │   │       ├── PaywallView.swift        # nrn/app/(purchase)/paywall.tsx
│   │   │       ├── SecretPlanView.swift     # nrn/app/(purchase)/secret-plan.tsx
│   │   │       ├── CelebrationView.swift    # nrn/app/(purchase)/celebration.tsx
│   │   │       └── NoSubscriptionView.swift # nrn/app/(purchase)/no-subscription.tsx
│   │   │
│   │   ├── Home/                            # nrn/app/(app)/home.tsx
│   │   │   ├── Models/
│   │   │   │   ├── UserStatus.swift
│   │   │   │   └── Grade.swift
│   │   │   ├── ViewModels/
│   │   │   │   └── HomeViewModel.swift
│   │   │   └── Views/
│   │   │       ├── HomeView.swift           # Main dashboard
│   │   │       ├── HeroCallTimerView.swift  # Big countdown timer
│   │   │       ├── NotificationCardView.swift # Push notification style card
│   │   │       ├── ProgressBarView.swift    # Discipline progress
│   │   │       └── GradeCardView.swift      # A-F grade cards
│   │   │
│   │   ├── Call/                            # nrn/screens/CallScreen.tsx
│   │   │   ├── Models/
│   │   │   │   └── CallState.swift
│   │   │   ├── ViewModels/
│   │   │   │   └── CallViewModel.swift
│   │   │   ├── Views/
│   │   │   │   ├── CallScreenView.swift
│   │   │   │   └── CallControlsView.swift
│   │   │   └── Services/
│   │   │       ├── CallKitManager.swift     # Native iOS CallKit
│   │   │       ├── LiveKitService.swift     # @livekit/react-native
│   │   │       ├── ElevenLabsService.swift  # @elevenlabs/react-native
│   │   │       └── VoIPPushService.swift    # expo-voip-push-token
│   │   │
│   │   ├── History/                         # nrn/app/(app)/history.tsx
│   │   │   ├── Models/
│   │   │   │   └── CallRecord.swift
│   │   │   ├── ViewModels/
│   │   │   │   └── HistoryViewModel.swift
│   │   │   └── Views/
│   │   │       ├── HistoryView.swift
│   │   │       └── CallHistoryRowView.swift
│   │   │
│   │   └── Settings/                        # nrn/app/(app)/settings.tsx
│   │       ├── ViewModels/
│   │       │   └── SettingsViewModel.swift
│   │       └── Views/
│   │           └── SettingsView.swift
│   │
│   ├── Shared/
│   │   ├── Components/
│   │   │   ├── TabBar.swift                 # nrn/components/TabBar.tsx
│   │   │   ├── LoadingView.swift
│   │   │   └── ErrorView.swift
│   │   │
│   │   └── Theme/
│   │       ├── Colors.swift                 # All color constants
│   │       ├── Typography.swift             # All font styles
│   │       ├── Spacing.swift                # Spacing constants
│   │       └── Animations.swift             # Animation presets
│   │
│   ├── Models/
│   │   ├── User.swift
│   │   ├─��� Subscription.swift
│   │   └── APIResponse.swift
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/                 # Images
│   │   │   ├── Colors/
│   │   │   └── Images/
│   │   ├── Fonts/                           # Custom fonts (if any)
│   │   └── Sounds/                          # Audio files
│   │
│   ├── BigBruh.entitlements                 # iOS capabilities
│   └── Info.plist                           # Auto-generated by Xcode
│
└── Packages/                                # SPM packages (auto-managed)
    ├── supabase-swift
    ├── purchases-ios
    └── client-sdk-swift
```

---

## 🗺️ FILE MAPPING (RN → SWIFT)

| React Native | Swift Equivalent |
|--------------|------------------|
| `nrn/types/onboarding.ts` | `Features/Onboarding/Models/` (4 files) |
| `nrn/contexts/AuthContext.tsx` | `Features/Authentication/Services/AuthService.swift` |
| `nrn/contexts/RevenueCatProvider.tsx` | `Features/Subscription/Services/RevenueCatService.swift` |
| `nrn/components/onboarding/index.tsx` | `Features/Onboarding/Views/OnboardingContainerView.swift` |
| `nrn/components/onboarding/steps/VoiceStep.tsx` | `Features/Onboarding/Views/Steps/VoiceStepView.swift` |
| `nrn/components/TabBar.tsx` | `Shared/Components/TabBar.swift` |
| `nrn/app/(app)/home.tsx` | `Features/Home/Views/HomeView.swift` |
| `nrn/app/(auth)/auth.tsx` | `Features/Authentication/Views/AuthView.swift` |
| `nrn/lib/api.ts` | `Core/Networking/APIService.swift` |
| `nrn/package.json` dependencies | SPM packages in Xcode |

---

## 🎨 THEME SYSTEM (Exact Colors from RN)

### Colors.swift
```swift
extension Color {
    // Brand
    static let brutalBlack = Color(hex: "#000000")
    static let brutalWhite = Color(hex: "#FFFFFF")
    static let brutalRed = Color(hex: "#DC143C")

    // Onboarding Phases
    static let neonGreen = Color(hex: "#90FD0E")

    // Grades
    static let gradeA = Color(hex: "#00FF00")
    static let gradeB = Color(hex: "#FFD700")
    static let gradeC = Color(hex: "#FF8C00")
    static let gradeF = Color(hex: "#DC143C")
}
```

---

## 📋 ONBOARDING: 45 STEPS MAPPED

Based on `nrn/types/onboarding.ts` STEP_DEFINITIONS array:

### Phase 1: WARNING_INITIATION (Steps 1-5)
- Step 1: Explanation - "BIGBRUH ISN'T FOR EVERYONE"
- Step 2: Voice - "Tell me why you're really here"
- Step 3: Text - "What name should I call you?"
- Step 4: Explanation - "I'm about to expose every excuse"
- Step 5: Voice - "What's the biggest lie you tell yourself"

### Phase 2A: EXCUSE_DISCOVERY (Steps 6-11)
- Step 6: Choice - "Which excuse is your favorite?"
- Step 7: Voice - "Tell me about the last time you completely gave up"
- Step 8: Explanation - "Confession without change?"
- Step 9: Text - "When do you always crack?"
- Step 10: Voice - "What are you procrastinating on RIGHT NOW?"
- Step 11: DualSliders - "Rate your fire right now"

### Phase 2B: EXCUSE_CONFRONTATION (Steps 12-16)
### Phase 3A: PATTERN_AWARENESS (Steps 17-21)
### Phase 3B: PATTERN_ANALYSIS (Steps 22-26)
### Phase 4A: IDENTITY_REBUILD (Steps 27-31)
### Phase 4B: COMMITMENT_SYSTEM (Steps 32-36)
### Phase 5A: EXTERNAL_ANCHORS (Steps 37-41)
### Phase 5B: FINAL_OATH (Steps 42-45)

---

## 🎯 STEP TYPES TO IMPLEMENT

From `nrn/types/onboarding.ts`:

1. ✅ **text** → TextStepView.swift
2. ✅ **voice** → VoiceStepView.swift (MOST COMPLEX!)
3. ✅ **choice** → ChoiceStepView.swift
4. ✅ **dual_sliders** → DualSlidersStepView.swift
5. ✅ **explanation** → ExplanationStepView.swift
6. ✅ **long_press_activate** → LongPressStepView.swift
7. ✅ **time_window_picker** → TimePickerStepView.swift
8. ✅ **timezone_selection** → TimezonePickerStepView.swift

---

## 🔥 PRIORITY ORDER (What to Build First)

### ✅ WEEK 1: FOUNDATION
1. Create Xcode project
2. Add SPM packages
3. Create folder structure
4. Build theme system (Colors, Typography, Spacing)
5. Create models (OnboardingStep, UserResponse, User)
6. Build AuthService + AuthView

### ✅ WEEK 2: ONBOARDING CORE
7. Create OnboardingCoordinator
8. Build StepDefinitions.swift (45 steps)
9. Create OnboardingContainerView
10. Build ExplanationStepView (easiest)
11. Build TextStepView
12. Build ChoiceStepView

### ✅ WEEK 3: VOICE RECORDING
13. Create VoiceRecordingService (AVAudioRecorder)
14. Build VoiceStepView (HARDEST - 1747 lines in RN!)
15. Add hostile message cycling
16. Add notification style variants

### ✅ WEEK 4: REMAINING STEPS
17. Build DualSlidersStepView
18. Build TimePickerStepView
19. Build LongPressStepView
20. Build TimezonePickerStepView

### ✅ WEEK 5: HOME & CALLS
21. Build HomeViewModel + HomeView
22. Create CallKitManager
23. Integrate LiveKit
24. Add VoIP push

### ✅ WEEK 6: POLISH
25. Build subscription flow
26. Add animations
27. Test everything

---

## 📦 PACKAGE DEPENDENCIES

```swift
// Package.swift equivalent
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.5.1"),
    .package(url: "https://github.com/RevenueCat/purchases-ios", from: "5.15.0"),
    .package(url: "https://github.com/livekit/client-sdk-swift", from: "2.3.0"),
]
```

---

## 🎯 NEXT STEPS

1. **Create Xcode project** following QUICK_START.md
2. **Tell me when build succeeds**
3. **I'll generate files in this order:**
   - Theme system (Colors, Typography, Spacing)
   - Models (OnboardingStep, UserResponse)
   - AuthService + AuthView
   - OnboardingCoordinator
   - Step views one by one

---

**This is your complete roadmap! Create the Xcode project, then I'll start generating Swift code! 🚀**