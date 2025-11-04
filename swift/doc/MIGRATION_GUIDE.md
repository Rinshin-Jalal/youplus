# 🚀 NRN React Native → Swift iOS Migration Guide

Complete migration roadmap from React Native (nrn) to native Swift/iOS implementation.

---

## 📋 Table of Contents

1. [App Flow Overview](#app-flow-overview)
2. [Navigation Architecture](#navigation-architecture)
3. [Screen-by-Screen Migration](#screen-by-screen-migration)
4. [API Integration](#api-integration)
5. [Data Models & Storage](#data-models--storage)
6. [Third-Party Services](#third-party-services)
7. [Implementation Checklist](#implementation-checklist)

---

## 🎯 App Flow Overview

```
┌─────────────────┐
│   App Launch    │
│   EntryView     │
└────────┬────────┘
         │
         ├─ Loading? → LoadingView
         │
         ├─ Not Authenticated? → WelcomeScreen
         │                           ├─→ "START TALKING" → OnboardingView (60 steps)
         │                           └─→ "Sign In" → AuthView
         │
         └─ Authenticated?
                 ├─ Onboarding Complete? → HomeView
                 └─ Onboarding Incomplete? → OnboardingView
```

---

## 🗺️ Navigation Architecture

### Current RN Structure (nrn/app/):
```
app/
├── _layout.tsx                      # Root layout with providers
├── index.tsx                        # Entry point (routing logic)
├── (public)/
│   └── onboarding.tsx              # 60-step onboarding
├── (auth)/
│   ├── auth.tsx                    # Apple Sign In
│   └── signup.tsx                  # Signup flow
├── (app)/
│   ├── home.tsx                    # Main dashboard
│   ├── history.tsx                 # Call history
│   ├── settings.tsx                # Settings
│   └── call.tsx                    # Active call screen
├── (purchase)/
│   ├── paywall.tsx                 # Subscription paywall
│   ├── celebration.tsx             # Purchase success
│   └── secret-plan.tsx             # Hidden plan
└── almost-there.tsx                # Post-onboarding confrontation
```

### Target Swift Structure:
```swift
// App entry point
@main
struct bigbruhhApp: App {
    var body: some Scene {
        WindowGroup {
            EntryView()  // Routing logic here
        }
    }
}

// Views to create:
EntryView.swift           → Routes based on auth state
WelcomeView.swift         → Landing screen
AuthView.swift            → Apple Sign In (DONE ✅)
OnboardingView.swift      → 60-step flow coordinator
AlmostThereView.swift     → Confrontation sequence
PaywallView.swift         → RevenueCat integration
CelebrationView.swift     → Success screen
HomeView.swift            → Main dashboard
HistoryView.swift         → Call history
SettingsView.swift        → Settings
CallView.swift            → Active call
```

---

## 📱 Screen-by-Screen Migration

---

### 1️⃣ **EntryView** (Routing Logic)

**RN Source:** `nrn/app/index.tsx`

**Purpose:** App entry point that routes users based on authentication state

#### Functionality:
```typescript
// Current RN logic (index.tsx)
const { isAuthenticated, loading, user } = useAuth();
const { isNavigationReady } = useNavigationGuard();

if (loading || !isNavigationReady) {
  return <LoadingScreen />;
}

if (!isAuthenticated) {
  return <WelcomeScreen />;
}

// Authenticated users handled by useAuthNavigation hook
// which redirects to /home
return <LoadingScreen />;
```

#### Swift Implementation:
**File:** `bigbruhh/Core/Views/EntryView.swift` ✅ (Already exists)

**Current State:** Basic routing implemented
```swift
@StateObject private var authService = AuthService.shared

var body: some View {
    Group {
        if authService.loading {
            LoadingView()
        } else if authService.isAuthenticated {
            if authService.user?.onboardingCompleted == true {
                HomeView()
            } else {
                OnboardingView()
            }
        } else {
            AuthView()
        }
    }
}
```

**Required Changes:**
- [ ] Update routing to show `WelcomeView` instead of `AuthView` for unauthenticated users
- [ ] Add transition animations between views
- [ ] Implement NavigationStack wrapper for deep linking

#### API Calls:
- **None** (relies on AuthService session check)

#### Navigation:
- `loading = true` → `LoadingView`
- `!authenticated` → `WelcomeView`
- `authenticated + !onboarded` → `OnboardingView`
- `authenticated + onboarded` → `HomeView`

---

### 2️⃣ **WelcomeView** (Landing Screen)

**RN Source:** `nrn/components/WelcomeScreen.tsx`

**Purpose:** First screen users see - marketing/CTA screen

#### UI Components:
```
┌─────────────────────────────────┐
│                                 │
│        [BigBruh Logo]           │ ← assets/logo/logo-red.png (300x100)
│                                 │
│   "Your accountability brother  │ ← Gray text, Inter-Black, 16pt
│    is here to help you stay     │
│         on track."              │
│                                 │
│                                 │
│   ┌─────────────────────────┐  │
│   │    START TALKING        │  │ ← Red button (#FF0033)
│   └─────────────────────────┘  │   Black text, Inter-Bold, 18pt
│                                 │   Uppercase, letter-spacing: 3
│                                 │
│                                 │
│  Already have an account?       │ ← Link text (#CC6666)
│         Sign in                 │   Inter-Regular, 14pt
│                                 │
└─────────────────────────────────┘
```

#### Functionality:
- **CTA appears after 800ms delay** (psychological timing effect)
- **Fade-in animation** for CTA (300ms duration)
- **Haptic feedback** on button press (Heavy impact)
- **Long-press support** (500ms) shows "CONNECTING..." text

#### Buttons & Navigation:
1. **START TALKING button**
   - `onPress` → `router.replace("/onboarding")`
   - Haptic: Heavy impact
   - Delay: 200ms before navigation

2. **"Sign in" link**
   - `onPress` → `router.push("/auth")`
   - No haptic feedback

#### Swift Implementation:
**File:** `bigbruhh/Features/Welcome/Views/WelcomeView.swift` (NEW)

```swift
struct WelcomeView: View {
    @State private var showCTA = false
    @State private var isLongPressing = false
    @Environment(\.router) var router

    var body: some View {
        ZStack {
            Color.brutalBlack.ignoresSafeArea()

            VStack {
                Spacer()

                // Logo
                Image("logo-red")
                    .resizable()
                    .frame(width: 300, height: 100)

                Text("Your accountability brother is here to help you stay on track.")
                    .font(.custom("Inter-Black", size: 16))
                    .foregroundColor(Color(hex: "#888888"))
                    .multilineTextAlignment(.center)
                    .letterSpacing(2)

                Spacer()

                // CTA Button (delayed appearance)
                if showCTA {
                    Button(action: handleStartTalking) {
                        Text(isLongPressing ? "CONNECTING..." : "START TALKING")
                            .font(.custom("Inter-Bold", size: 18))
                            .fontWeight(.black)
                            .letterSpacing(3)
                            .foregroundColor(.brutalBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.brutalRed)
                            .cornerRadius(16)
                            .shadow(color: Color.brutalRed.opacity(0.3), radius: 8)
                    }
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            isLongPressing = true
                            HapticManager.heavy()
                        }
                    )
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.3), value: showCTA)
                }

                // Sign in link
                Button(action: { router.push(.auth) }) {
                    Text("Already have an account? Sign in")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(Color(hex: "#CC6666"))
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showCTA = true
            }
        }
    }

    func handleStartTalking() {
        HapticManager.heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            router.replace(.onboarding)
        }
    }
}
```

#### Assets Required:
- [ ] Add `logo-red.png` to Assets.xcassets (300x100pt)

#### API Calls:
- **None**

#### Navigation Targets:
- `START TALKING` → `OnboardingView`
- `Sign in` → `AuthView`

---

### 3️⃣ **AuthView** (Apple Sign In)

**RN Source:** `nrn/app/(auth)/auth.tsx`

**Status:** ✅ **Already implemented** at `bigbruhh/Features/Authentication/Views/AuthView.swift`

#### Functionality:
- Apple Sign In button (iOS only)
- Fade-in + slide-up animations on mount
- Button glow animation (pulse effect)
- Dev mode fallback for non-Apple devices

#### API Calls:
**Via AuthService:**
1. **Apple Sign In** → `AuthService.signInWithApple()`
   - Calls Supabase auth: `supabase.auth.signInWithIdToken()`
   - Creates/updates user session
   - No direct API endpoint

#### Swift Current Implementation:
```swift
// Already exists at Features/Authentication/Views/AuthView.swift
- Apple Sign In button
- Loading states
- Error handling
- Animation effects
```

#### Post-Auth Navigation:
**RN Logic:** `useAuthNavigation` hook redirects to `/home` after successful auth

**Swift Required:**
- [ ] Add observer in `EntryView` to auto-navigate after `AuthService.isAuthenticated` changes
- [ ] Implement smooth transition animation to `HomeView`

---

### 4️⃣ **OnboardingView** (60-Step Flow)

**RN Source:** `nrn/app/(public)/onboarding.tsx` + `nrn/components/onboarding/index.tsx`

**Purpose:** Collect user data through 60-step psychological questionnaire

#### Architecture:

**State Management (RN):**
```typescript
interface OnboardingState {
  currentStep: number;
  responses: Record<number, UserResponse>;
  userName: string;
  brotherName: string;
  startedAt: string;
  completedAt?: string;
}

interface UserResponse {
  value: any;
  type: 'voice' | 'text' | 'choice' | 'dual_sliders' |
        'timezone_selection' | 'time_window_picker' |
        'long_press_activate' | 'explanation';
  timestamp: string;
  duration?: number; // For voice recordings
  voiceUri?: string; // Local file path
}
```

**Swift Models Required:**
**File:** `bigbruhh/Features/Onboarding/Models/OnboardingState.swift` ✅ (Already exists)

**Enhance with:**
```swift
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var responses: [Int: UserResponse] = [:]
    @Published var userName: String = ""
    @Published var brotherName: String = ""
    @Published var startedAt: Date = Date()
    @Published var completedAt: Date?

    // Auto-save to UserDefaults every 5 steps
    func saveProgress() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(responses) {
            UserDefaults.standard.set(encoded, forKey: "onboarding_responses")
            UserDefaults.standard.set(currentStep, forKey: "onboarding_current_step")
        }
    }

    // Resume from saved state
    func loadProgress() {
        currentStep = UserDefaults.standard.integer(forKey: "onboarding_current_step")
        if let data = UserDefaults.standard.data(forKey: "onboarding_responses"),
           let decoded = try? JSONDecoder().decode([Int: UserResponse].self, from: data) {
            responses = decoded
        }
    }
}
```

---

#### Step Types & Components:

##### 1. **ExplanationStep** (Animated Text Only)
**RN:** `nrn/components/onboarding/steps/ExplanationStep.tsx`

**UI:**
```
┌─────────────────────────────────┐
│                                 │
│                                 │
│      [Multi-line text with      │
│       fade-in animation]        │
│                                 │
│                                 │
│                                 │
│           [TAP TO                │
│           CONTINUE]              │
│                                 │
└─────────────────────────────────┘
```

**Props:**
- `prompt`: String (multi-line text)
- `viralBackgroundColor`: Color (default: black)
- `viralTextColor`: Color (default: white)
- `viralAccentColor`: Color (for "TAP TO CONTINUE")

**Behavior:**
- Text fades in over 800ms
- Tap anywhere → `advanceStep()`
- Haptic: Light impact on tap

**Swift Implementation:**
```swift
struct ExplanationStepView: View {
    let step: OnboardingStep
    let advanceStep: () -> Void

    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            Color(step.backgroundColor ?? .brutalBlack)
                .ignoresSafeArea()

            VStack {
                Spacer()

                Text(step.prompt)
                    .font(.custom("Inter-Bold", size: 24))
                    .foregroundColor(Color(step.textColor ?? .white))
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                    .padding(.horizontal, 40)

                Spacer()

                Text("TAP TO CONTINUE")
                    .font(.custom("Inter-Medium", size: 14))
                    .foregroundColor(Color(step.accentColor ?? .brutalRed))
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) {
                textOpacity = 1
            }
        }
        .onTapGesture {
            HapticManager.light()
            advanceStep()
        }
    }
}
```

---

##### 2. **TextStep** (Text Input)
**RN:** `nrn/components/onboarding/steps/TextStep.tsx`

**UI:**
```
┌─────────────────────────────────┐
│  What's your name?              │ ← Prompt
│                                 │
│  ┌───────────────────────────┐ │
│  │ [Text Input Field]        │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │        CONTINUE           │ │ ← Disabled if empty
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

**Props:**
- `prompt`: Question text
- `placeholder`: Input placeholder
- `validation`: Optional regex pattern
- `maxLength`: Character limit

**Behavior:**
- CONTINUE button enabled only when text is not empty
- Auto-capitalize first letter
- Trim whitespace on submit

**Swift Implementation:**
```swift
struct TextStepView: View {
    let step: OnboardingStep
    let saveResponse: (String) -> Void

    @State private var inputText: String = ""
    @FocusState private var isFocused: Bool

    var isValid: Bool {
        !inputText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 40) {
            Text(step.prompt)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            TextField(step.placeholder ?? "Type here...", text: $inputText)
                .font(.custom("Inter-Regular", size: 18))
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .focused($isFocused)
                .autocapitalization(.words)

            Button(action: handleContinue) {
                Text("CONTINUE")
                    .font(.custom("Inter-Bold", size: 16))
                    .foregroundColor(isValid ? .brutalBlack : .gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.brutalRed : Color.gray.opacity(0.3))
                    .cornerRadius(12)
            }
            .disabled(!isValid)
        }
        .padding(.horizontal, 30)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }

    func handleContinue() {
        HapticManager.medium()
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        saveResponse(trimmed)
    }
}
```

---

##### 3. **ChoiceStep** (Multiple Choice)
**RN:** `nrn/components/onboarding/steps/ChoiceStep.tsx`

**UI:**
```
┌─────────────────────────────────┐
│  How do you feel about goals?  │
│                                 │
│  ┌───────────────────────────┐ │
│  │  I set them & crush them  │ │ ← Option 1
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │  I set them but fail      │ │ ← Option 2
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │  I avoid setting goals    │ │ ← Option 3
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

**Props:**
- `prompt`: Question
- `options`: Array of choice strings
- `multiSelect`: Boolean (default: false)

**Behavior:**
- Tap option → Highlight + Haptic + Auto-advance (single select)
- Multi-select: Show CONTINUE button

**Swift Implementation:**
```swift
struct ChoiceStepView: View {
    let step: OnboardingStep
    let saveResponse: (String) -> Void

    @State private var selectedOption: String? = nil

    var body: some View {
        VStack(spacing: 24) {
            Text(step.prompt)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            ForEach(step.options ?? [], id: \.self) { option in
                Button(action: { handleSelect(option) }) {
                    Text(option)
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedOption == option ?
                            Color.brutalRed :
                            Color.white.opacity(0.1)
                        )
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 30)
    }

    func handleSelect(_ option: String) {
        selectedOption = option
        HapticManager.medium()

        // Auto-advance after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            saveResponse(option)
        }
    }
}
```

---

##### 4. **DualSlidersStep** (Two Sliders)
**RN:** `nrn/components/onboarding/steps/DualSlidersStep.tsx`

**UI:**
```
┌─────────────────────────────────┐
│  Rate yourself (1-10)           │
│                                 │
│  Discipline:            [8]     │
│  ●━━━━━━━━○━━━━━━━━━━━         │
│                                 │
│  Consistency:           [5]     │
│  ●━━━━━○━━━━━━━━━━━━━━         │
│                                 │
│  ┌───────────────────────────┐ │
│  │        CONTINUE           │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

**Props:**
- `prompt`: Question
- `sliders`: Array of `{ label: string, min: number, max: number }`

**Swift Implementation:**
```swift
struct DualSlidersStepView: View {
    let step: OnboardingStep
    let saveResponse: ([Int]) -> Void

    @State private var slider1Value: Double = 5
    @State private var slider2Value: Double = 5

    var body: some View {
        VStack(spacing: 40) {
            Text(step.prompt)
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 30) {
                // Slider 1
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(step.sliders[0].label)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(slider1Value))")
                            .foregroundColor(.brutalRed)
                            .font(.bold)
                    }
                    Slider(value: $slider1Value, in: 1...10, step: 1)
                        .accentColor(.brutalRed)
                }

                // Slider 2
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(step.sliders[1].label)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(slider2Value))")
                            .foregroundColor(.brutalRed)
                            .font(.bold)
                    }
                    Slider(value: $slider2Value, in: 1...10, step: 1)
                        .accentColor(.brutalRed)
                }
            }

            Button(action: handleContinue) {
                Text("CONTINUE")
                    .font(.custom("Inter-Bold", size: 16))
                    .foregroundColor(.brutalBlack)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brutalRed)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 30)
    }

    func handleContinue() {
        HapticManager.medium()
        saveResponse([Int(slider1Value), Int(slider2Value)])
    }
}
```

---

##### 5. **VoiceStep** (Audio Recording) ⚠️ COMPLEX
**RN:** `nrn/components/onboarding/steps/VoiceStep.tsx`

**UI States:**
```
IDLE:
┌─────────────────────────────────┐
│  Tell me about your biggest    │
│         goal this year          │
│                                 │
│         ┌───────┐               │
│         │  🎤   │               │ ← Tap to start
│         └───────┘               │
│                                 │
│      HOLD TO RECORD             │
└─────────────────────────────────┘

RECORDING:
┌─────────────────────────────────┐
│  Tell me about your biggest    │
│         goal this year          │
│                                 │
│         ┌───────┐               │
│         │  ⏸️   │               │ ← Recording...
│         └───────┘               │
│       ●●●●●●●●●                  │ ← Waveform animation
│         00:15                    │ ← Timer
│                                 │
│      RELEASE TO STOP            │
└─────────────────────────────────┘

RECORDED:
┌─────────────────────────────────┐
│  Tell me about your biggest    │
│         goal this year          │
│                                 │
│    [Play] [Re-record]           │
│       Duration: 15s             │
│                                 │
│  ┌───────────────────────────┐ │
│  │        CONTINUE           │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

**RN Implementation Details:**
```typescript
// Uses expo-av for recording
import { Audio } from 'expo-av';

const startRecording = async () => {
  const { status } = await Audio.requestPermissionsAsync();
  if (status !== 'granted') return;

  const recording = new Audio.Recording();
  await recording.prepareToRecordAsync({
    android: { /* config */ },
    ios: {
      extension: '.m4a',
      audioQuality: Audio.RECORDING_OPTION_IOS_AUDIO_QUALITY_HIGH,
      sampleRate: 44100,
      numberOfChannels: 1,
      bitRate: 128000,
    },
  });

  await recording.startAsync();
  setRecording(recording);
};

const stopRecording = async () => {
  await recording.stopAndUnloadAsync();
  const uri = recording.getURI(); // Local file path

  // Convert to base64 for storage
  const base64 = await FileSystem.readAsStringAsync(uri, {
    encoding: FileSystem.EncodingType.Base64,
  });

  saveResponse({
    value: `data:audio/m4a;base64,${base64}`,
    voiceUri: uri,
    duration: recording.durationMillis / 1000,
  });
};
```

**Swift Implementation:**
**File:** `bigbruhh/Features/Onboarding/Views/VoiceStepView.swift` (NEW)

```swift
import AVFoundation

class VoiceRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioURL: URL?

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("onboarding_\(UUID().uuidString).m4a")

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()

            isRecording = true
            recordingDuration = 0

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.recordingDuration += 0.1
            }
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func stopRecording() -> URL? {
        audioRecorder?.stop()
        timer?.invalidate()
        isRecording = false

        let url = audioRecorder?.url
        audioURL = url
        return url
    }

    func convertToBase64(url: URL) -> String? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return "data:audio/m4a;base64," + data.base64EncodedString()
    }
}

struct VoiceStepView: View {
    let step: OnboardingStep
    let saveResponse: (String, TimeInterval) -> Void

    @StateObject private var recorder = VoiceRecorder()
    @State private var hasRecorded = false

    var body: some View {
        VStack(spacing: 40) {
            Text(step.prompt)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            if !hasRecorded {
                // Record button
                Button(action: {}) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 60))
                        .foregroundColor(recorder.isRecording ? .brutalRed : .white)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !recorder.isRecording {
                                recorder.startRecording()
                                HapticManager.heavy()
                            }
                        }
                        .onEnded { _ in
                            if recorder.isRecording {
                                _ = recorder.stopRecording()
                                hasRecorded = true
                                HapticManager.medium()
                            }
                        }
                )

                if recorder.isRecording {
                    Text(String(format: "%02d:%02d",
                               Int(recorder.recordingDuration) / 60,
                               Int(recorder.recordingDuration) % 60))
                        .foregroundColor(.brutalRed)
                        .font(.custom("Inter-Bold", size: 24))
                }

                Text(recorder.isRecording ? "RELEASE TO STOP" : "HOLD TO RECORD")
                    .font(.custom("Inter-Medium", size: 14))
                    .foregroundColor(.gray)
            } else {
                // Playback controls
                Text("Duration: \(Int(recorder.recordingDuration))s")
                    .foregroundColor(.white)

                HStack(spacing: 20) {
                    Button("RE-RECORD") {
                        hasRecorded = false
                        recorder.recordingDuration = 0
                    }
                    .buttonStyle(.bordered)
                }

                Button(action: handleContinue) {
                    Text("CONTINUE")
                        .font(.custom("Inter-Bold", size: 16))
                        .foregroundColor(.brutalBlack)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brutalRed)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 30)
    }

    func handleContinue() {
        guard let url = recorder.audioURL,
              let base64 = recorder.convertToBase64(url: url) else { return }

        HapticManager.medium()
        saveResponse(base64, recorder.recordingDuration)
    }
}
```

**Permissions Required:**
Add to `Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record your voice responses during onboarding</string>
```

---

##### 6. **TimePickerStep** (Time Selection)
**RN:** `nrn/components/onboarding/steps/TimePickerStep.tsx`

**UI:**
```
┌─────────────────────────────────┐
│  What time works best for      │
│        your daily call?         │
│                                 │
│       ┌─────────────┐           │
│       │   08 : 30   │           │ ← Picker wheels
│       │   AM        │           │
│       └─────────────┘           │
│                                 │
│  ┌───────────────────────────┐ │
│  │        CONTINUE           │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

**Swift Implementation:**
```swift
struct TimePickerStepView: View {
    let step: OnboardingStep
    let saveResponse: (Date) -> Void

    @State private var selectedTime = Date()

    var body: some View {
        VStack(spacing: 40) {
            Text(step.prompt)
                .font(.headline)
                .foregroundColor(.white)

            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)

            Button(action: handleContinue) {
                Text("CONTINUE")
                    .font(.custom("Inter-Bold", size: 16))
                    .foregroundColor(.brutalBlack)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brutalRed)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 30)
    }

    func handleContinue() {
        HapticManager.medium()
        saveResponse(selectedTime)
    }
}
```

---

##### 7. **TimezonePickerStep**
**RN:** Uses system timezone + displays dropdown

**Swift Implementation:**
```swift
struct TimezonePickerStepView: View {
    let step: OnboardingStep
    let saveResponse: (String) -> Void

    @State private var selectedTimezone = TimeZone.current.identifier

    var timezones: [String] {
        TimeZone.knownTimeZoneIdentifiers.sorted()
    }

    var body: some View {
        VStack(spacing: 40) {
            Text(step.prompt)
                .font(.headline)
                .foregroundColor(.white)

            Picker("Timezone", selection: $selectedTimezone) {
                ForEach(timezones, id: \.self) { tz in
                    Text(tz).tag(tz)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 200)

            Button(action: handleContinue) {
                Text("CONTINUE")
                    .font(.custom("Inter-Bold", size: 16))
                    .foregroundColor(.brutalBlack)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brutalRed)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 30)
    }

    func handleContinue() {
        HapticManager.medium()
        saveResponse(selectedTimezone)
    }
}
```

---

##### 8. **LongPressStep** (Hold to Confirm)
**RN:** `nrn/components/onboarding/steps/LongPressStep.tsx`

**UI:**
```
┌─────────────────────────────────┐
│  I commit to showing up every  │
│  day. No excuses. No weakness. │
│                                 │
│       ┌───────────────┐         │
│       │  HOLD TO      │         │
│       │  COMMIT       │         │ ← Hold for 3 seconds
│       │               │         │
│       │ ████████░░░░  │         │ ← Progress bar
│       └───────────────┘         │
│                                 │
└─────────────────────────────────┘
```

**Swift Implementation:**
```swift
struct LongPressStepView: View {
    let step: OnboardingStep
    let saveResponse: () -> Void

    @State private var pressProgress: CGFloat = 0
    @State private var isPressed = false

    let requiredDuration: TimeInterval = 3.0

    var body: some View {
        VStack(spacing: 40) {
            Text(step.prompt)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 80)

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.brutalRed)
                        .frame(width: geo.size.width * pressProgress, height: 80)
                }

                Text(isPressed ? "HOLD..." : "HOLD TO COMMIT")
                    .font(.custom("Inter-Bold", size: 16))
                    .foregroundColor(.white)
            }
            .frame(height: 80)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in startHold() }
                    .onEnded { _ in endHold() }
            )
        }
        .padding(.horizontal, 30)
    }

    func startHold() {
        guard !isPressed else { return }
        isPressed = true
        HapticManager.light()

        withAnimation(.linear(duration: requiredDuration)) {
            pressProgress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + requiredDuration) {
            if isPressed {
                HapticManager.heavy()
                saveResponse()
            }
        }
    }

    func endHold() {
        if pressProgress < 1.0 {
            isPressed = false
            withAnimation {
                pressProgress = 0
            }
        }
    }
}
```

---

#### Onboarding Completion Flow:

**RN Logic (`onboarding.tsx` line 33-326):**

```typescript
const handleOnboardingComplete = async (state: OnboardingState) => {
  // 1. Check if starter plan user
  const planType = await AsyncStorage.getItem("plan_type");

  if (planType === "starter") {
    // Starter plan users skip the call
    await AsyncStorage.setItem("onboarding_completed", "true");
    await AsyncStorage.setItem("user_identity_name", state.brotherName);
    await AsyncStorage.setItem("onboarding_v3_completed", JSON.stringify(state));

    router.replace("/celebration");
    return;
  }

  // 2. Normal users: Save data + trigger call
  await AsyncStorage.setItem("onboarding_completed", "true");
  await AsyncStorage.setItem("user_identity_name", state.brotherName);
  await AsyncStorage.setItem("expecting_fake_call", "true");
  await AsyncStorage.setItem("onboarding_v3_completed", JSON.stringify(state));

  // 3. Trigger VoIP incoming call
  const callUUID = await testIncomingCall("Big Bruuh!!", "No Mercy, No Excuses");
  await AsyncStorage.setItem("fake_call_uuid", callUUID);

  // 4. Wait for user to answer call → then navigate to /almost-there
};
```

**Swift Implementation:**

```swift
class OnboardingViewModel: ObservableObject {
    @Published var isComplete = false

    func completeOnboarding() async {
        // 1. Save all responses to UserDefaults
        saveResponsesToStorage()

        // 2. Check subscription status
        let hasSubscription = await RevenueCatManager.shared.checkSubscription()

        if hasSubscription {
            // Starter plan users
            UserDefaults.standard.set(true, forKey: "onboarding_completed")
            router.replace(.celebration)
            return
        }

        // 3. Normal users: Trigger VoIP call
        UserDefaults.standard.set(true, forKey: "expecting_fake_call")

        do {
            let callUUID = try await VoIPManager.shared.triggerIncomingCall(
                caller: "Big Bruuh!!",
                subtitle: "No Mercy, No Excuses"
            )

            UserDefaults.standard.set(callUUID.uuidString, forKey: "fake_call_uuid")

            // Navigation handled by call answer callback
        } catch {
            print("Failed to trigger call: \(error)")
        }
    }

    func saveResponsesToStorage() {
        let encoder = JSONEncoder()

        if let encoded = try? encoder.encode(responses) {
            UserDefaults.standard.set(encoded, forKey: "onboarding_v3_completed")
        }

        UserDefaults.standard.set(brotherName, forKey: "user_identity_name")
        UserDefaults.standard.set(userName, forKey: "user_name")
        UserDefaults.standard.set(Date(), forKey: "onboarding_completed_at")
    }
}
```

#### API Calls (On Completion):
**Endpoint:** `POST /api/onboarding/complete`

**Request Body:**
```json
{
  "user_id": "uuid",
  "responses": {
    "1": { "type": "text", "value": "John", "timestamp": "2025-01-01T10:00:00Z" },
    "2": { "type": "voice", "value": "data:audio/m4a;base64,...", "duration": 15.3 },
    "3": { "type": "choice", "value": "I set them & crush them" },
    // ... all 60 responses
  },
  "brother_name": "BigBruh",
  "user_name": "John",
  "started_at": "2025-01-01T09:45:00Z",
  "completed_at": "2025-01-01T10:30:00Z"
}
```

**Swift API Call:**
```swift
func uploadOnboardingData() async {
    let payload: [String: Any] = [
        "user_id": AuthService.shared.user?.id ?? "",
        "responses": responses.mapValues { $0.toDictionary() },
        "brother_name": brotherName,
        "user_name": userName,
        "started_at": ISO8601DateFormatter().string(from: startedAt),
        "completed_at": ISO8601DateFormatter().string(from: Date())
    ]

    do {
        let response = try await APIService.shared.post(
            endpoint: "/api/onboarding/complete",
            body: payload
        )
        print("✅ Onboarding data uploaded")
    } catch {
        print("❌ Failed to upload onboarding: \(error)")
    }
}
```

---

### 5️⃣ **AlmostThereView** (Confrontation Sequence)

**RN Source:** `nrn/app/almost-there.tsx`

**Purpose:** 5-step psychological pressure sequence before paywall

#### UI Flow:

**Steps 1-4:** Use `ExplanationStep` component with escalating intensity

```swift
let confrontationSteps: [OnboardingStep] = [
    OnboardingStep(
        id: 1,
        prompt: "You answered.\n\nGood.\n\nThat call was a test.\n\nNow the real shit begins.",
        type: .explanation,
        backgroundColor: .brutalBlack,
        accentColor: Color(hex: "#90FD0E")
    ),
    OnboardingStep(
        id: 2,
        prompt: "You just told me everything.\n\nYour excuses. Your fears. Your failures.\n\nI have it all.\n\nEvery night, I'll use it.\n\nAgainst you.\n\nUntil you change.",
        type: .explanation,
        backgroundColor: .brutalBlack,
        accentColor: Color(hex: "#90FD0E")
    ),
    OnboardingStep(
        id: 3,
        prompt: "THIS ISN'T COACHING.\n\nTHIS IS WAR.\n\nAGAINST YOUR WEAK SELF.\n\nEVERY. SINGLE. NIGHT.\n\nYOU'LL HATE ME.\n\nGOOD.",
        type: .explanation,
        backgroundColor: .brutalBlack,
        accentColor: Color(hex: "#FF0000") // Red accent
    ),
    OnboardingStep(
        id: 4,
        prompt: "I'll call when you're tired.\nWhen you're busy.\nWhen you failed.\n\nNo blocking.\nNo deleting.\nNo escape.\n\nOnce you pay, I own your accountability.\n\nForever.\n\nStill want this?",
        type: .explanation,
        backgroundColor: .brutalBlack,
        accentColor: Color(hex: "#FF4444")
    )
]
```

**Step 5:** Binary choice screen

**UI:**
```
┌─────────────────────────────────┐
│ [TOP HALF - RED BACKGROUND]     │
│                                 │
│   STAY WEAK                     │
│   STAY THE SAME                 │
│   STAY COMFORTABLE              │
│                                 │
│   ┌─────────────────┐           │
│   │     LEAVE       │           │
│   └─────────────────┘           │
│                                 │
├─────────────────────────────────┤
│ [BOTTOM HALF - PURPLE BG]       │
│                                 │
│   PAY THE PRICE                 │
│   FACE THE TRUTH                │
│   BECOME UNSTOPPABLE            │
│                                 │
│   ┌─────────────────┐           │
│   │     COMMIT      │           │
│   └─────────────────┘           │
│                                 │
└─────────────────────────────────┘
```

**Swift Implementation:**
```swift
struct AlmostThereView: View {
    @State private var currentStep = 0
    @Environment(\.router) var router

    let confrontationSteps: [OnboardingStep] = [/* see above */]

    var body: some View {
        if currentStep < 4 {
            // Steps 1-4: Explanation screens
            ExplanationStepView(
                step: confrontationSteps[currentStep],
                advanceStep: { currentStep += 1 }
            )
        } else {
            // Step 5: Binary choice
            ChoiceView()
        }
    }

    struct ChoiceView: View {
        var body: some View {
            VStack(spacing: 0) {
                // Top half - LEAVE (Red)
                ZStack {
                    Color(hex: "#DC143C")

                    VStack(spacing: 20) {
                        Text("STAY WEAK\nSTAY THE SAME\nSTAY COMFORTABLE")
                            .font(.custom("Inter-Bold", size: 48))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .letterSpacing(2)

                        Button(action: { router.replace(.welcome) }) {
                            Text("LEAVE")
                                .font(.custom("Inter-Black", size: 35))
                                .foregroundColor(.white)
                                .letterSpacing(4)
                                .padding()
                        }
                    }
                }
                .frame(maxHeight: .infinity)

                // Bottom half - COMMIT (Purple)
                ZStack {
                    Color(hex: "#8B00FF")

                    VStack(spacing: 20) {
                        Text("PAY THE PRICE\nFACE THE TRUTH\nBECOME UNSTOPPABLE")
                            .font(.custom("Inter-Bold", size: 48))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .letterSpacing(2)

                        Button(action: { router.push(.paywall) }) {
                            Text("COMMIT")
                                .font(.custom("Inter-Black", size: 35))
                                .foregroundColor(.white)
                                .letterSpacing(4)
                                .padding()
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .ignoresSafeArea()
        }
    }
}
```

#### API Calls:
- **None**

#### Navigation:
- `LEAVE` → `WelcomeView` (router.replace)
- `COMMIT` → `PaywallView` (router.push)

---

### 6️⃣ **PaywallView** (RevenueCat Subscription)

**RN Source:** `nrn/app/(purchase)/paywall.tsx`

**Purpose:** Display subscription plans and handle purchases

#### UI Components:
```
┌─────────────────────────────────┐
│      CHOOSE YOUR PATH           │
│                                 │
│  ┌───────────────────────────┐ │
│  │  💎 PREMIUM PLAN          │ │
│  │  Daily accountability     │ │
│  │  calls                    │ │
│  │                           │ │
│  │  $29.99/month             │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │  ⭐ STARTER PLAN          │ │
│  │  Weekly check-ins         │ │
│  │                           │ │
│  │  $9.99/month              │ │
│  └───────────────────────────┘ │
│                                 │
│  [Restore Purchases]            │
│                                 │
└─────────────────────────────────┘
```

#### RN Implementation (RevenueCat):
```typescript
const { currentOffering, packages, purchasePackage } = useRevenueCat();

const handlePurchase = async (pkg: Package) => {
  try {
    const { customerInfo } = await purchasePackage(pkg);

    if (customerInfo.activeSubscriptions.length > 0) {
      await AsyncStorage.setItem("plan_type", pkg.identifier);
      router.replace("/celebration");
    }
  } catch (error) {
    Alert.alert("Purchase failed", error.message);
  }
};
```

#### Swift Implementation:

**1. Install RevenueCat SDK:**
Add to `Package.swift` dependencies:
```swift
dependencies: [
    .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.0.0")
]
```

**2. Create RevenueCatManager:**
**File:** `bigbruhh/Core/Services/RevenueCatManager.swift` (NEW)

```swift
import RevenueCat

class RevenueCatManager: ObservableObject {
    static let shared = RevenueCatManager()

    @Published var currentOffering: Offering?
    @Published var packages: [Package] = []
    @Published var isSubscribed = false

    private init() {
        configure()
    }

    func configure() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.revenueCatAPIKey)

        fetchOfferings()
        checkSubscriptionStatus()
    }

    func fetchOfferings() {
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                print("❌ Error fetching offerings: \(error)")
                return
            }

            DispatchQueue.main.async {
                self.currentOffering = offerings?.current
                self.packages = offerings?.current?.availablePackages ?? []
            }
        }
    }

    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { info, error in
            DispatchQueue.main.async {
                self.isSubscribed = !(info?.entitlements.active.isEmpty ?? true)
            }
        }
    }

    func purchase(package: Package) async throws -> Bool {
        let (_, customerInfo, _) = try await Purchases.shared.purchase(package: package)

        DispatchQueue.main.async {
            self.isSubscribed = !customerInfo.entitlements.active.isEmpty
        }

        return !customerInfo.entitlements.active.isEmpty
    }

    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()

        DispatchQueue.main.async {
            self.isSubscribed = !customerInfo.entitlements.active.isEmpty
        }
    }
}
```

**3. Create PaywallView:**
**File:** `bigbruhh/Features/Purchase/Views/PaywallView.swift` (NEW)

```swift
struct PaywallView: View {
    @StateObject private var revenueCat = RevenueCatManager.shared
    @State private var selectedPackage: Package?
    @State private var isPurchasing = false
    @Environment(\.router) var router

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("CHOOSE YOUR PATH")
                    .font(.custom("Inter-Black", size: 32))
                    .foregroundColor(.white)

                ForEach(revenueCat.packages, id: \.identifier) { package in
                    PackageCard(
                        package: package,
                        isSelected: selectedPackage?.identifier == package.identifier,
                        onSelect: { selectedPackage = package }
                    )
                }

                if let selected = selectedPackage {
                    Button(action: handlePurchase) {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .brutalBlack))
                        } else {
                            Text("SUBSCRIBE NOW")
                                .font(.custom("Inter-Bold", size: 18))
                                .foregroundColor(.brutalBlack)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brutalRed)
                    .cornerRadius(12)
                    .disabled(isPurchasing)
                }

                Button("Restore Purchases") {
                    Task { try? await revenueCat.restorePurchases() }
                }
                .foregroundColor(.gray)
            }
            .padding()
        }
        .background(Color.brutalBlack.ignoresSafeArea())
    }

    func handlePurchase() {
        guard let package = selectedPackage else { return }

        isPurchasing = true

        Task {
            do {
                let success = try await revenueCat.purchase(package: package)

                if success {
                    UserDefaults.standard.set(package.identifier, forKey: "plan_type")
                    router.replace(.celebration)
                }
            } catch {
                print("Purchase error: \(error)")
            }

            isPurchasing = false
        }
    }
}

struct PackageCard: View {
    let package: Package
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(package.storeProduct.localizedTitle)
                        .font(.custom("Inter-Bold", size: 20))
                        .foregroundColor(.white)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.brutalRed)
                    }
                }

                Text(package.storeProduct.localizedDescription)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.gray)

                Text(package.localizedPriceString)
                    .font(.custom("Inter-Black", size: 24))
                    .foregroundColor(.brutalRed)
            }
            .padding()
            .background(
                isSelected ?
                Color.white.opacity(0.15) :
                Color.white.opacity(0.05)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.brutalRed : Color.clear, lineWidth: 2)
            )
        }
    }
}
```

#### API Calls:
**RevenueCat handles all API calls internally:**
- Fetch offerings from RevenueCat
- Process purchases via App Store
- Sync subscription status

**After successful purchase:**
**Endpoint:** `POST /api/user/subscription/update`
```json
{
  "user_id": "uuid",
  "subscription_type": "premium",
  "purchased_at": "2025-01-01T12:00:00Z"
}
```

#### Navigation:
- On purchase success → `CelebrationView`

---

### 7️⃣ **CelebrationView** (Purchase Success)

**RN Source:** `nrn/app/(purchase)/celebration.tsx`

**Purpose:** Congratulate user on purchase, set up account

#### UI:
```
┌─────────────────────────────────┐
│                                 │
│           🎉 🎉 🎉             │
│                                 │
│      YOU'RE IN, [NAME]!        │
│                                 │
│    You just committed to       │
│    transformation.             │
│                                 │
│    Your first call is          │
│    scheduled for tonight.      │
│                                 │
│  ┌───────────────────────────┐ │
│  │     LET'S GO              │ │
│  └───────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

**Swift Implementation:**
```swift
struct CelebrationView: View {
    @Environment(\.router) var router
    let userName: String

    var body: some View {
        ZStack {
            Color.brutalBlack.ignoresSafeArea()

            VStack(spacing: 40) {
                Text("🎉 🎉 🎉")
                    .font(.system(size: 60))

                Text("YOU'RE IN, \(userName.uppercased())!")
                    .font(.custom("Inter-Black", size: 32))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("You just committed to transformation.\n\nYour first call is scheduled for tonight.")
                    .font(.custom("Inter-Regular", size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Button(action: { router.replace(.home) }) {
                    Text("LET'S GO")
                        .font(.custom("Inter-Bold", size: 18))
                        .foregroundColor(.brutalBlack)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brutalRed)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
            }
        }
        .onAppear {
            scheduleFirstCall()
        }
    }

    func scheduleFirstCall() {
        // Schedule first accountability call for tonight at 8pm
        let tonight = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!

        Task {
            do {
                try await APIService.shared.post(
                    endpoint: "/api/calls/schedule",
                    body: [
                        "user_id": AuthService.shared.user?.id ?? "",
                        "scheduled_time": ISO8601DateFormatter().string(from: tonight)
                    ]
                )
            } catch {
                print("Failed to schedule first call: \(error)")
            }
        }
    }
}
```

#### API Calls:
**1. Update user onboarding status:**
`POST /api/user/onboarding/complete`
```json
{
  "user_id": "uuid",
  "completed_at": "2025-01-01T12:00:00Z"
}
```

**2. Schedule first call:**
`POST /api/calls/schedule`
```json
{
  "user_id": "uuid",
  "scheduled_time": "2025-01-01T20:00:00Z"
}
```

#### Navigation:
- `LET'S GO` → `HomeView`

---

### 8️⃣ **HomeView** (Main Dashboard)

**RN Source:** `nrn/app/(app)/home.tsx`

**Purpose:** Main authenticated screen showing user stats and next call

#### UI Layout:
```
┌─────────────────────────────────┐
│  [BigBruh Logo]                 │
│                                 │
│  ┌───────────────────────────┐ │
│  │ next call in              │ │
│  │      02:45:30             │ │ ← Countdown timer
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 🔥 BigBruh                │ │
│  │ ACCOUNTABILITY CHECK      │ │ ← Notification card
│  │ No excuses today, USER    │ │
│  └───────────────────────────┘ │
│                                 │
│  Discipline level               │
│  ┌───────────────────────────┐ │
│  │ DISCIPLINE LEVEL     45%  │ │
│  │ ██████████░░░░░░░░░░      │ │ ← Progress bar
│  │ Still making excuses bro  │ │
│  └───────────────────────────┘ │
│                                 │
│  Performance grades             │
│  ┌─────────┐  ┌─────────┐     │
│  │PROMISES │  │EXCUSES  │     │
│  │   B+    │  │   A     │     │ ← Grade cards
│  │ Not bad │  │Creative │     │
│  └─────────┘  └─────────┘     │
│  ┌─────────┐  ┌─────────┐     │
│  │ STREAK  │  │OVERALL  │     │
│  │   C     │  │   C     │     │
│  └─────────┘  └─────────┘     │
│                                 │
│ [Home] [History] [Call] [⚙️]   │ ← TabBar
└─────────────────────────────────┘
```

#### Functionality:

**1. Countdown Timer:**
- Fetches next call time from API
- Updates every second
- Red pulse animation when < 1 hour
- Red flash on exact hour marks

**2. User Stats:**
- Promises made vs broken
- Current streak
- Trust percentage
- Overall discipline grade

**3. Grade Calculation:**
```swift
func getGrade(subject: String) -> String {
    switch subject {
    case "PROMISES":
        let rate = (promisesMade - promisesBroken) / promisesMade * 100
        return rate >= 90 ? "A+" : rate >= 80 ? "A" : /* ... */
    case "EXCUSES":
        return promisesBroken <= 2 ? "A+" : promisesBroken <= 5 ? "B+" : "F-"
    case "STREAK":
        return streakDays >= 14 ? "A+" : streakDays >= 7 ? "B+" : /* ... */
    case "TRUSTWORTHINESS":
        return trustPercentage >= 85 ? "A+" : trustPercentage >= 70 ? "B+" : /* ... */
    default:
        return "F-"
    }
}

func getGradeColor(grade: String) -> Color {
    if grade.contains("A") { return Color(hex: "#00FF00") } // Green
    if grade.contains("B") { return Color(hex: "#FFD700") } // Gold
    if grade.contains("C") { return Color(hex: "#FF8C00") } // Orange
    if grade.contains("D") { return Color(hex: "#8B00FF") } // Purple
    return Color(hex: "#DC143C") // Red for F
}
```

#### API Calls:

**1. Fetch user status (on appear):**
`GET /api/identity/{user_id}`

**Response:**
```json
{
  "success": true,
  "data": {
    "nextCallTimestamp": "2025-01-02T08:30:00Z",
    "promisesMadeCount": 12,
    "promisesBrokenCount": 8,
    "currentStreakDays": 3,
    "trustPercentage": 45
  }
}
```

**Swift Implementation:**
```swift
func loadUserStatus() async {
    guard let userId = AuthService.shared.user?.id else { return }

    // Try cache first
    if let cached = loadFromCache(key: "user_status_\(userId)") {
        self.status = cached
    }

    do {
        let response: UserStatusResponse = try await APIService.shared.get(
            endpoint: "/api/identity/\(userId)"
        )

        self.status = response.data
        saveToCache(key: "user_status_\(userId)", value: response.data)
    } catch {
        print("Failed to load user status: \(error)")
    }
}
```

**2. Cache implementation:**
```swift
func saveToCache(key: String, value: Codable) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(value) {
        UserDefaults.standard.set(encoded, forKey: key)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "\(key)_timestamp")
    }
}

func loadFromCache<T: Codable>(key: String) -> T? {
    guard let data = UserDefaults.standard.data(forKey: key),
          let timestamp = UserDefaults.standard.double(forKey: "\(key)_timestamp") else {
        return nil
    }

    // Cache valid for 5 minutes
    let cacheAge = Date().timeIntervalSince1970 - timestamp
    guard cacheAge < 300 else { return nil }

    return try? JSONDecoder().decode(T.self, from: data)
}
```

#### Navigation (TabBar):
- Home → `HomeView` (current)
- History → `HistoryView`
- Call → `CallView`
- Settings → `SettingsView`

---

### 9️⃣ **HistoryView** (Call History)

**RN Source:** `nrn/app/(app)/history.tsx`

**Purpose:** Display past accountability calls and performance

#### UI:
```
┌─────────────────────────────────┐
│       CALL HISTORY              │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Jan 1, 2025  8:30 PM      │ │
│  │ Duration: 5:32            │ │
│  │ ✅ Promises kept: 3/5     │ │
│  │ Grade: B+                 │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Dec 31, 2024  8:30 PM     │ │
│  │ Duration: 4:15            │ │
│  │ ❌ Promises kept: 1/4     │ │
│  │ Grade: F                  │ │
│  └───────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

#### API Calls:
`GET /api/calls/history?user_id={user_id}&limit=20`

**Response:**
```json
{
  "calls": [
    {
      "id": "uuid",
      "scheduled_time": "2025-01-01T20:30:00Z",
      "duration_seconds": 332,
      "promises_kept": 3,
      "promises_broken": 2,
      "grade": "B+",
      "transcript_summary": "User committed to..."
    }
  ]
}
```

#### Swift Implementation:
```swift
struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        List(viewModel.calls) { call in
            CallHistoryCard(call: call)
        }
        .listStyle(.plain)
        .background(Color.brutalBlack)
        .onAppear {
            Task { await viewModel.fetchHistory() }
        }
    }
}

class HistoryViewModel: ObservableObject {
    @Published var calls: [CallRecord] = []

    func fetchHistory() async {
        guard let userId = AuthService.shared.user?.id else { return }

        do {
            let response: CallHistoryResponse = try await APIService.shared.get(
                endpoint: "/api/calls/history",
                parameters: ["user_id": userId, "limit": "20"]
            )

            DispatchQueue.main.async {
                self.calls = response.calls
            }
        } catch {
            print("Failed to fetch history: \(error)")
        }
    }
}
```

---

### 🔟 **SettingsView**

**RN Source:** `nrn/app/(app)/settings.tsx`

#### UI:
```
┌─────────────────────────────────┐
│         SETTINGS                │
│                                 │
│  Account                        │
│  ├─ Email: user@email.com      │
│  └─ Subscription: Premium       │
│                                 │
│  Preferences                    │
│  ├─ Call Time: 8:30 PM          │
│  ├─ Timezone: PST               │
│  └─ Notifications: On           │
│                                 │
│  [Manage Subscription]          │
│  [Sign Out]                     │
│                                 │
└─────────────────────────────────┘
```

#### API Calls:
`GET /api/user/settings`
`PUT /api/user/settings` (to update preferences)

---

### 1️⃣1️⃣ **CallView** (Active Call Screen)

**RN Source:** `nrn/app/(app)/call.tsx`

**Purpose:** Voice call interface with ElevenLabs AI

#### Features:
- Real-time conversation with AI
- Waveform visualization
- Call duration timer
- Mute/Speaker controls
- End call button

#### Third-Party Integration:
**ElevenLabs Conversational AI SDK**

**RN Implementation:**
```typescript
import { useConversation } from '@elevenlabs/react-native';

const { startConversation, endConversation, status } = useConversation({
  agentId: "your-agent-id",
});
```

**Swift Implementation:**
```swift
// Use ElevenLabs iOS SDK
import ElevenLabsSDK

class CallViewModel: ObservableObject {
    @Published var isConnected = false
    @Published var duration: TimeInterval = 0

    private var conversation: ElevenLabsConversation?

    func startCall() {
        conversation = ElevenLabsSDK.startConversation(agentId: Config.elevenLabsAgentId)
        isConnected = true
    }

    func endCall() {
        conversation?.end()
        isConnected = false
    }
}
```

---

### 1️⃣2️⃣ **BrutalRealityMirror** (Evening Review Modal)

**RN Source:** `nrn/components/BrutalRealityMirror.tsx`

**Purpose:** Post-call review modal showing performance

#### UI:
```
┌─────────────────────────────────┐
│   TODAY'S BRUTAL TRUTH          │
│                                 │
│  You said you'd:                │
│  ✅ Wake up at 6am              │
│  ✅ Hit the gym                 │
│  ❌ Finish the project          │
│  ❌ No junk food                │
│                                 │
│  Score: 2/4 (50%)               │
│  Grade: PATHETIC                │
│                                 │
│  "You made excuses. Again."     │
│                                 │
│  [ACKNOWLEDGE FAILURE]          │
└─────────────────────────────────��
```

**Triggered:** After evening accountability call

**Swift Implementation:**
```swift
struct BrutalRealityMirror: View {
    let review: DailyReview
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()

            VStack(spacing: 30) {
                Text("TODAY'S BRUTAL TRUTH")
                    .font(.custom("Inter-Black", size: 28))
                    .foregroundColor(.brutalRed)

                VStack(alignment: .leading, spacing: 12) {
                    Text("You said you'd:")
                        .foregroundColor(.white)

                    ForEach(review.promises) { promise in
                        HStack {
                            Image(systemName: promise.kept ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(promise.kept ? .green : .red)
                            Text(promise.text)
                                .foregroundColor(.white)
                        }
                    }
                }

                Text("Score: \(review.score)")
                    .font(.custom("Inter-Bold", size: 24))
                    .foregroundColor(review.score >= 70 ? .green : .red)

                Text(review.assessment)
                    .font(.custom("Inter-Regular", size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Button(action: onDismiss) {
                    Text("ACKNOWLEDGE FAILURE")
                        .font(.custom("Inter-Bold", size: 16))
                        .foregroundColor(.brutalBlack)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brutalRed)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}
```

---

## 🔌 API Integration

### Base API Service

**File:** `bigbruhh/Core/Networking/APIService.swift` ✅ (Already exists)

**Enhance with:**
```swift
class APIService {
    static let shared = APIService()
    private let baseURL = Config.supabaseURL

    func get<T: Decodable>(endpoint: String, parameters: [String: String] = [:]) async throws -> T {
        var components = URLComponents(string: baseURL + endpoint)!
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        await addAuthHeaders(to: &request)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func post<T: Decodable>(endpoint: String, body: [String: Any]) async throws -> T {
        var request = URLRequest(url: URL(string: baseURL + endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        await addAuthHeaders(to: &request)

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func addAuthHeaders(to request: inout URLRequest) async {
        if let session = await AuthService.shared.currentSession {
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
    }
}
```

### API Endpoints Summary:

| Endpoint | Method | Purpose | Used In |
|----------|--------|---------|---------|
| `/api/identity/{user_id}` | GET | Fetch user stats | HomeView |
| `/api/onboarding/complete` | POST | Submit onboarding data | OnboardingView |
| `/api/calls/schedule` | POST | Schedule call | CelebrationView |
| `/api/calls/history` | GET | Fetch call history | HistoryView |
| `/api/user/settings` | GET/PUT | User preferences | SettingsView |
| `/api/user/subscription/update` | POST | Update subscription | PaywallView |

---

## 💾 Data Models & Storage

### User Model
**File:** `bigbruhh/Models/User.swift` ✅ (Already exists)

**Enhance with:**
```swift
struct User: Codable, Identifiable {
    let id: String
    var email: String
    var userName: String?
    var brotherName: String?
    var onboardingCompleted: Bool
    var subscriptionType: String? // "premium", "starter", nil
    var nextCallTime: Date?
    var createdAt: Date
}
```

### Storage Strategy:

**1. UserDefaults (for app state):**
- Current step in onboarding
- Cached user stats (5min TTL)
- UI preferences
- Last sync timestamp

**2. Keychain (for sensitive data):**
- Auth tokens
- User session

**3. FileManager (for media):**
- Voice recordings (temporary)
- Cached images

**4. Supabase (backend storage):**
- User profile
- Onboarding responses
- Call history
- Performance data

---

## 🧩 Third-Party Services

### 1. **Supabase** (Auth & Database)
✅ Already configured
- File: `bigbruhh/Core/Networking/SupabaseClient.swift`

### 2. **RevenueCat** (Subscriptions)
❌ Not yet integrated
- [ ] Add RevenueCat SDK
- [ ] Create RevenueCatManager
- [ ] Configure entitlements

### 3. **ElevenLabs** (Voice AI)
❌ Not yet integrated
- [ ] Add ElevenLabs SDK
- [ ] Create ConversationManager
- [ ] Implement CallView

### 4. **VoIP / CallKit** (Incoming Calls)
❌ Not yet integrated
- [ ] Configure Push Notification Certificate
- [ ] Implement VoIPManager with CallKit
- [ ] Handle incoming call UI

---

## ✅ Implementation Checklist

### Phase 1: Core Navigation (Week 1)
- [ ] Create WelcomeView
- [ ] Update EntryView routing logic
- [ ] Implement NavigationStack wrapper
- [ ] Add route enum & Router environment object
- [ ] Test auth flow: Welcome → Auth → Home

### Phase 2: Onboarding Foundation (Week 2)
- [ ] Create OnboardingViewModel
- [ ] Implement ExplanationStepView
- [ ] Implement TextStepView
- [ ] Implement ChoiceStepView
- [ ] Implement DualSlidersStepView
- [ ] Add step progression logic
- [ ] Add progress saving/loading

### Phase 3: Advanced Onboarding (Week 3)
- [ ] Implement VoiceStepView (audio recording)
- [ ] Implement TimePickerStepView
- [ ] Implement TimezonePickerStepView
- [ ] Implement LongPressStepView
- [ ] Test full 60-step flow
- [ ] Implement API upload on completion

### Phase 4: Purchase Flow (Week 4)
- [ ] Integrate RevenueCat SDK
- [ ] Create RevenueCatManager
- [ ] Build PaywallView
- [ ] Build CelebrationView
- [ ] Test purchase flow end-to-end
- [ ] Implement AlmostThereView

### Phase 5: Main Dashboard (Week 5)
- [ ] Build HomeView UI
- [ ] Implement countdown timer
- [ ] Implement grade calculation logic
- [ ] Add API integration for user stats
- [ ] Implement caching layer
- [ ] Create TabBar component

### Phase 6: Secondary Screens (Week 6)
- [ ] Build HistoryView
- [ ] Build SettingsView
- [ ] Implement settings API calls
- [ ] Add subscription management

### Phase 7: Voice Calls (Week 7-8)
- [ ] Integrate ElevenLabs SDK
- [ ] Create CallView
- [ ] Implement ConversationManager
- [ ] Add waveform visualization
- [ ] Configure VoIP/CallKit
- [ ] Test incoming call flow

### Phase 8: Polish & Testing (Week 9-10)
- [ ] Add animations throughout app
- [ ] Implement BrutalRealityMirror modal
- [ ] Error handling & edge cases
- [ ] Offline mode support
- [ ] Performance optimization
- [ ] End-to-end testing

---

## 🎨 Assets Required

### Images:
- [ ] `logo-red.png` (300x100pt) - WelcomeView
- [ ] `logo.png` (400x60pt) - HomeView header

### Fonts:
✅ Inter font family already configured

### Colors:
✅ Already defined in `bigbruhh/Shared/Theme/Colors.swift`

---

## 📊 Success Metrics

**Migration is complete when:**
1. ✅ User can sign up via Apple Sign In
2. ✅ User completes 60-step onboarding
3. ✅ Voice recordings are captured & uploaded
4. ✅ Subscription purchase works via RevenueCat
5. ✅ HomeView displays live user stats
6. ✅ Call history loads from API
7. ✅ Active calls work with ElevenLabs
8. ✅ VoIP incoming calls trigger correctly
9. ✅ All navigation flows work smoothly
10. ✅ App matches RN feature parity

---

**Last Updated:** 2025-01-02
**Estimated Timeline:** 10 weeks for full migration
**Priority:** High (native performance critical for voice calls)
