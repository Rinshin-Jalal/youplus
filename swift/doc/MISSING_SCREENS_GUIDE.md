# 🚨 Missing Screens Implementation Guide

## Overview
Three critical screens are missing from the Swift iOS rewrite:
1. **Brutal Reality Mirror** - The shareable full-screen takeover after calls
2. **Secret Plan** - Starter paywall ($2.99/week)
3. **Celebration** - Success screen after payment/onboarding

---

## 1. 🪞 BRUTAL REALITY MIRROR (The Shareable Thing!)

### Purpose
**ONE devastating paragraph that creates instant regret and psychological discomfort**

This is NOT a receipt with stats - it's a full-screen psychological intervention that shows ONE sentence designed to haunt the user into better behavior.

### Key Features

#### Psychological Design
- **Single brutal paragraph** - No lists, no cards, no sections to hide behind
- **Forced reading time** - Can't dismiss for 8-10 seconds (based on impact score)
- **Dynamic color psychology** - Background changes based on failure severity
- **Emotion-based effects** - Shame, rage, despair, denial trigger different animations
- **Physical feedback** - Vibration patterns based on psychological impact score

#### Example Brutal Paragraph
```
"I watched you tell yourself 'just 5 minutes on TikTok' at 11:47 AM,
then look up 3 hours later at 2:52 PM with pizza grease on your fingers,
realizing you'd completely destroyed another day while your deadline moved
closer and that gym membership you swore you'd use this month collected
more dust, and the worst part is you'll probably tell yourself the same lie tomorrow."
```

#### Visual Psychology Levels
- 🟢 **Minor fails**: Clean but slightly cold
- 🟡 **Moderate**: Uncomfortable orange/brown tones
- 🔴 **Major failures**: Harsh red/black contrast
- 💀 **Complete disaster**: Glitchy/distorted effects

### RN Implementation Details

**File:** `components/BrutalRealityMirror.tsx`

```typescript
interface BrutalRealityReview {
  id: string;
  brutal_paragraph: string;
  psychological_impact_score: number; // 0-100
  dominant_emotion: string; // "shame", "rage", "despair", "denial"
  color_theme: {
    primary: string;
    secondary: string;
    accent: string;
    text: string;
  };
  pattern_identified: string;
  reading_time_seconds?: number;
}
```

**Effects by Emotion:**
- **Shame** (impact > 70%): Pulsing, vibration if > 80%
- **Rage**: Always pulses, vibrates if > 60%, glitches if > 90%
- **Despair**: No pulse/vibration, glitches if > 80%
- **Denial**: No pulse/vibration, glitches if > 70%

**Animations:**
- Background color transition (1.5s)
- Text fade-in (2s) to force reading
- Pulse animation (800ms loop)
- Glitch effect (3s loop with translateX shake)
- Screen shake on appearance

**Haptic Patterns:**
- Impact score > 80: `[500ms, 200ms, 500ms, 200ms, 500ms]`
- Impact score ≤ 80: `[300ms, 150ms, 300ms]`

### Swift Implementation

#### 1. Create BrutalRealityReview Model

```swift
// Add to APIModels.swift
struct BrutalRealityReview: Codable, Identifiable {
    let id: String
    let brutalParagraph: String
    let psychologicalImpactScore: Int // 0-100
    let dominantEmotion: String // "shame", "rage", "despair", "denial"
    let colorTheme: ColorTheme
    let patternIdentified: String
    let readingTimeSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case brutalParagraph = "brutal_paragraph"
        case psychologicalImpactScore = "psychological_impact_score"
        case dominantEmotion = "dominant_emotion"
        case colorTheme = "color_theme"
        case patternIdentified = "pattern_identified"
        case readingTimeSeconds = "reading_time_seconds"
    }
}

struct ColorTheme: Codable {
    let primary: String
    let secondary: String
    let accent: String
    let text: String
}
```

#### 2. Create BrutalRealityMirrorView

```swift
// File: Features/BrutalReality/BrutalRealityMirrorView.swift

import SwiftUI

struct BrutalRealityMirrorView: View {
    let review: BrutalRealityReview
    let onDismiss: () -> Void
    let onTrackInteraction: ((Int, Bool) -> Void)?

    @State private var canDismiss = false
    @State private var startTime = Date()
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1.0

    private var readingTime: TimeInterval {
        max(8.0, Double(review.psychologicalImpactScore) / 10.0) // 8-10 seconds
    }

    private var effects: EmotionEffects {
        getEmotionEffects(
            emotion: review.dominantEmotion,
            impactScore: review.psychologicalImpactScore
        )
    }

    var body: some View {
        ZStack {
            // Dynamic background color
            Color(hex: review.colorTheme.primary)
                .ignoresSafeArea()
                .opacity(opacity)

            VStack(spacing: 30) {
                Spacer()

                // Impact Score & Emotion
                VStack(spacing: 8) {
                    Text("Impact: \(review.psychologicalImpactScore)/100")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: review.colorTheme.text).opacity(0.7))

                    Text(review.dominantEmotion.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: review.colorTheme.accent))
                        .tracking(1)
                }

                // The Brutal Paragraph
                Text(review.brutalParagraph)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color(hex: review.colorTheme.text))
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .padding(.horizontal, 30)
                    .opacity(opacity)

                Spacer()

                // Dismiss button (only after reading time)
                if canDismiss {
                    Button(action: handleDismiss) {
                        Text("ACCEPT CONSEQUENCES")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: review.colorTheme.text))
                            .tracking(1)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: review.colorTheme.accent), lineWidth: 2)
                            )
                    }
                } else {
                    // Reading timer
                    Text("Processing reality... \(Int(readingTime - Date().timeIntervalSince(startTime)))s")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: review.colorTheme.accent).opacity(0.8))
                }

                Spacer()
                    .frame(height: 80)
            }
        }
        .onAppear {
            startEffects()

            // Enable dismiss after reading time
            DispatchQueue.main.asyncAfter(deadline: .now() + readingTime) {
                withAnimation {
                    canDismiss = true
                }
                // Light haptic when dismissible
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }

    private func startEffects() {
        // Fade in animation
        withAnimation(.easeIn(duration: 1.5)) {
            opacity = 1.0
        }

        // Heavy haptic on appearance
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        // Vibration based on impact
        if effects.shouldVibrate {
            let pattern = review.psychologicalImpactScore > 80
                ? [0.5, 0.2, 0.5, 0.2, 0.5]
                : [0.3, 0.15, 0.3]
            // Note: iOS doesn't have custom vibration patterns via public APIs
            // Use repeated haptics instead
            vibrate(pattern: pattern)
        }

        // Pulse animation
        if effects.shouldPulse {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                scale = 1.02
            }
        }
    }

    private func handleDismiss() {
        let readingTime = Int(Date().timeIntervalSince(startTime))
        onTrackInteraction?(readingTime, true)

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onDismiss()
    }

    private func vibrate(pattern: [Double]) {
        for (index, duration) in pattern.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }
}

// MARK: - Emotion Effects

struct EmotionEffects {
    let shouldPulse: Bool
    let shouldVibrate: Bool
    let shouldGlitch: Bool
}

func getEmotionEffects(emotion: String, impactScore: Int) -> EmotionEffects {
    let intensity = Double(impactScore) / 100.0

    switch emotion.lowercased() {
    case "shame":
        return EmotionEffects(
            shouldPulse: intensity > 0.7,
            shouldVibrate: intensity > 0.8,
            shouldGlitch: false
        )
    case "rage":
        return EmotionEffects(
            shouldPulse: true,
            shouldVibrate: intensity > 0.6,
            shouldGlitch: intensity > 0.9
        )
    case "despair":
        return EmotionEffects(
            shouldPulse: false,
            shouldVibrate: false,
            shouldGlitch: intensity > 0.8
        )
    case "denial":
        return EmotionEffects(
            shouldPulse: false,
            shouldVibrate: false,
            shouldGlitch: intensity > 0.7
        )
    default:
        return EmotionEffects(
            shouldPulse: intensity > 0.8,
            shouldVibrate: intensity > 0.9,
            shouldGlitch: false
        )
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

#### 3. Integration

Show after calls in CallScreen or as a modal:

```swift
@State private var showBrutalReality = false
@State private var brutalReview: BrutalRealityReview?

// After call ends, fetch brutal reality review
private func endCall() {
    Task {
        let review = try await fetchBrutalRealityReview(callId: currentCallId)
        brutalReview = review
        showBrutalReality = true
    }
}

// Present as full screen cover
.fullScreenCover(isPresented: $showBrutalReality) {
    if let review = brutalReview {
        BrutalRealityMirrorView(
            review: review,
            onDismiss: {
                showBrutalReality = false
                // Navigate to home or history
            },
            onTrackInteraction: { readingTime, dismissed in
                // Track analytics
                Config.log("Brutal reality read for \(readingTime)s", category: "BrutalReality")
            }
        )
    }
}
```

---

## 2. 🤫 SECRET PLAN SCREEN

### Purpose
A **$2.99/week starter package** paywall accessed via Apple Quick Action. After purchase, user goes through onboarding but ends at **celebration** instead of the call flow.

### Key Features
- RevenueCat paywall integration
- Tracks purchase source as "quick_action"
- Saves `plan_type: "starter"` to AsyncStorage/UserDefaults
- Routes to onboarding → celebration → signup
- Different from main paywall (this is cheaper, limited features)

### RN Implementation

**File:** `app/(purchase)/secret-plan.tsx`

```typescript
// After purchase:
await AsyncStorage.setItem("plan_type", "starter");
await AsyncStorage.setItem("purchase_source", source);

router.push({
  pathname: "/onboarding",
  params: {
    userName: userName || "BigBruh",
    plan_type: "starter",
    source
  }
});
```

### Swift Implementation

#### 1. Create SecretPlanView

```swift
// File: Features/Paywall/SecretPlanView.swift

import SwiftUI
import RevenueCat

struct SecretPlanView: View {
    @EnvironmentObject var navigator: AppNavigator
    @EnvironmentObject var revenueCat: RevenueCatService
    @Environment(\.dismiss) private var dismiss

    let userName: String
    let source: String

    init(userName: String = "BigBruh", source: String = "quick_action") {
        self.userName = userName
        self.source = source
    }

    var body: some View {
        // Use RevenueCat's PaywallView with "starter" offering
        RevenueCatPaywallView(
            offering: "starter", // Specific offering identifier
            source: source,
            onPurchaseComplete: {
                handlePurchaseComplete()
            },
            onDismiss: {
                dismiss()
            }
        )
        .onAppear {
            // Track secret paywall view
            Config.log("Secret paywall viewed", category: "Paywall")
        }
    }

    private func handlePurchaseComplete() {
        // Save plan type
        UserDefaults.standard.set("starter", forKey: "plan_type")
        UserDefaults.standard.set(source, forKey: "purchase_source")

        Config.log("✅ Starter plan purchased - routing to onboarding", category: "Paywall")

        // Navigate to onboarding (will end at celebration, not call)
        navigator.currentScreen = .onboarding
    }
}
```

#### 2. Add to RootView Navigation

```swift
enum AppScreen {
    // ... existing cases
    case secretPlan
}

// In RootView switch:
case .secretPlan:
    SecretPlanView()
        .environmentObject(navigator)
```

#### 3. Trigger from Quick Action (AppDelegate or SceneDelegate)

```swift
// Handle 3D Touch / Haptic Touch quick action
func application(
    _ application: UIApplication,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
) {
    if shortcutItem.type == "com.bigbruh.secretPlan" {
        // Show secret plan paywall
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowSecretPlan"),
            object: nil
        )
        completionHandler(true)
    }
}
```

---

## 3. 🎉 CELEBRATION SCREEN

### Purpose
**Success animation** shown after payment/onboarding completion. Different messaging for starter vs normal users. Auto-navigates to signup after 5 seconds.

### Key Features
- Fade-in + scale animation
- Pulsing success effect
- Haptic success feedback
- 5-second countdown
- Different content for starter vs normal users
- Routes to signup screen after countdown

### RN Implementation

**File:** `app/(purchase)/celebration.tsx`

```typescript
interface CelebrationMessages {
  starter: {
    headline: "Starter Plan Activated"
    subtext: "Welcome to YOU+"
    description: "Your accountability journey begins with basic enforcement calls."
    features: ["Morning accountability calls", "Basic enforcement", "Progress tracking"]
  },
  normal: {
    headline: "System Activated"
    subtext: "Accountability begins"
    description: "Your BigBruh is now armed. First call arrives in 24 hours."
    features: ["Twice-daily enforcement calls", "Advanced accountability", "Full consequence delivery"]
  }
}
```

### Swift Implementation

#### 1. Create CelebrationView

```swift
// File: Features/Celebration/CelebrationView.swift

import SwiftUI

struct CelebrationView: View {
    @EnvironmentObject var navigator: AppNavigator
    @State private var isStarterUser = false
    @State private var countdown = 5
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8

    let userName: String

    var body: some View {
        ZStack {
            Color.brutalBlack
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Success Badge
                HStack {
                    Text(isStarterUser ? "🔓 Starter" : "⚡ Activated")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)

                    Spacer()
                }
                .padding(.horizontal, 20)

                // Main Message
                VStack(alignment: .leading, spacing: 10) {
                    Text(message.headline)
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.brutalRed)
                        .tracking(1)

                    Text(message.subtext)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(0.9)
                }
                .padding(.horizontal, 20)

                // Description
                Text(message.description)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineSpacing(6)
                    .padding(.horizontal, 20)

                // Callout
                HStack {
                    Rectangle()
                        .fill(Color.brutalRed)
                        .frame(width: 4)

                    Text(message.callout)
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.brutalRed)
                        .tracking(1)

                    Spacer()
                }
                .padding(16)
                .background(Color.brutalRed.opacity(0.1))
                .padding(.horizontal, 20)

                // Features List
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(message.features, id: \.self) { feature in
                        Text(feature)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Continue Button
                Button(action: handleContinue) {
                    Text("Continue (\(countdown)s)")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                        .tracking(1)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(isStarterUser ? Color.neonGreen : Color.brutalRed)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)

                // User Name
                Text("\(userName), your transformation begins now.")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                    .italic()
                    .padding(.horizontal, 20)

                Spacer()
                    .frame(height: 40)
            }
        }
        .opacity(opacity)
        .scaleEffect(scale)
        .onAppear {
            checkUserType()
            startAnimation()
            startCountdown()
        }
    }

    private var message: CelebrationMessage {
        if isStarterUser {
            return CelebrationMessage(
                headline: "Starter Plan Activated",
                subtext: "Welcome to YOU+",
                description: "Your accountability journey begins with basic enforcement calls.",
                callout: "Prepare for change",
                features: [
                    "✅ Morning accountability calls",
                    "✅ Basic enforcement system",
                    "✅ Progress tracking"
                ]
            )
        } else {
            return CelebrationMessage(
                headline: "System Activated",
                subtext: "Accountability begins",
                description: "Your BigBruh is now armed. First call arrives in 24 hours.",
                callout: "No retreat",
                features: [
                    "⚡ Twice-daily enforcement calls",
                    "🎯 Advanced accountability system",
                    "🔥 Full consequence delivery"
                ]
            )
        }
    }

    private func checkUserType() {
        let planType = UserDefaults.standard.string(forKey: "plan_type")
        isStarterUser = planType == "starter"
    }

    private func startAnimation() {
        withAnimation(.easeInOut(duration: 0.8)) {
            opacity = 1.0
            scale = 1.0
        }

        // Haptic success feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // Additional haptics
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                handleContinue()
            }
        }
    }

    private func handleContinue() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        // Navigate to signup or home based on auth status
        navigator.currentScreen = .welcome // or .signup
    }
}

struct CelebrationMessage {
    let headline: String
    let subtext: String
    let description: String
    let callout: String
    let features: [String]
}
```

#### 2. Add to RootView Navigation

```swift
enum AppScreen {
    // ... existing cases
    case celebration
}

// In RootView switch:
case .celebration:
    CelebrationView(userName: "BigBruh") // Pass actual username
        .environmentObject(navigator)
```

---

## 📋 Implementation Priority

1. **Brutal Reality Mirror** (HIGH) - Core feature, the "shareable thing"
2. **Celebration Screen** (MEDIUM) - Needed for complete payment flow
3. **Secret Plan** (LOW) - Optional quick action, can be added later

## 🔗 Integration Flow

```
Purchase Complete
    ↓
Onboarding Data Push (already implemented)
    ↓
Celebration Screen (NEW)
    ↓
Signup/Auth
    ↓
Home Screen
    ↓
Call happens
    ↓
Brutal Reality Mirror (NEW) - The shareable!
```

---

**Status:** 📝 DOCUMENTED - Ready for implementation

**Last Updated:** 2025-10-06
