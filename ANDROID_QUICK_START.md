# You+ Android - Quick Start Guide

## What is This?

**You+** is an accountability app that uses **AI-powered voice calls in your own voice** to enforce daily commitments. This is the plan for porting it from iOS to Android.

---

## 🎯 Project Summary

- **Platform**: Android (Kotlin)
- **Min SDK**: 26 (Android 8.0) - 93% market coverage
- **Target SDK**: 34 (Android 14)
- **Architecture**: Clean Architecture + MVVM
- **UI**: Jetpack Compose (modern declarative UI)
- **Timeline**: 16 weeks to production

---

## 🏗️ Tech Stack at a Glance

| Component | Technology |
|-----------|-----------|
| Language | Kotlin 1.9+ |
| UI | Jetpack Compose |
| Dependency Injection | Hilt |
| Networking | Retrofit + OkHttp |
| Async | Kotlin Coroutines + Flow |
| Local Storage | Proto DataStore |
| VoIP Calls | Android Telecom API |
| Push Notifications | Firebase Cloud Messaging |
| Auth | Supabase + Google Sign-In |
| Payments | RevenueCat Android SDK |
| Audio | MediaRecorder + ExoPlayer |

---

## 📦 Module Structure

```
youplus-android/
├── app/                    # Main application
├── core/                   # Core utilities
│   ├── common/            # Shared code
│   ├── network/           # API layer
│   ├── data/              # Data layer
│   └── ui/                # Shared UI components
└── feature/               # Feature modules
    ├── auth/              # Authentication
    ├── onboarding/        # 38-step flow
    ├── call/              # VoIP calls
    ├── home/              # Dashboard
    ├── promises/          # Daily promises
    ├── settings/          # User settings
    └── paywall/           # Subscriptions
```

---

## 🚀 Core Features to Implement

### 1. Authentication
- Google Sign-In (replaces Apple ID)
- Email/Password fallback
- Anonymous sessions (pre-payment)
- Session migration

### 2. 38-Step Onboarding
- Psychological assessment questions
- 3 voice recordings (60-120 seconds each)
- Demo call playback
- Payment gate
- Voice cloning trigger

### 3. VoIP Call System
- FCM push notifications
- Android Telecom framework (system call UI)
- ElevenLabs Convo AI integration (WebSocket)
- Live call screen with real-time transcript
- Call acknowledgment/missed call handling

### 4. Home Dashboard
- Streak display
- Trust percentage
- Upcoming call info
- Call history

### 5. Daily Promises
- Morning promise creation
- Evening completion check
- Success/failure tracking

### 6. Settings
- Call schedule customization
- Tone preferences
- Account management

---

## 🔧 Key Technical Challenges

### 1. **VoIP Call Reliability**
**Problem**: Android doesn't have native VoIP push like iOS
**Solution**:
- High-priority FCM messages
- Foreground service during call window
- Fallback to regular notifications

### 2. **Audio Quality**
**Problem**: Need high-quality recordings for voice cloning
**Solution**:
- Record in PCM 44.1kHz
- Convert to FLAC before upload

### 3. **Background Task Survival**
**Problem**: Android kills background tasks
**Solution**:
- WorkManager for scheduled checks
- Foreground service during call windows

### 4. **State Persistence**
**Problem**: Users may close app mid-onboarding
**Solution**:
- Proto DataStore for efficient state storage
- Save after each onboarding step

---

## 📱 iOS vs Android Key Differences

| Feature | iOS | Android |
|---------|-----|---------|
| UI Framework | SwiftUI | Jetpack Compose |
| VoIP Calls | CallKit | Telecom API |
| Push | APNS | FCM |
| Auth | Apple ID | Google Sign-In |
| Storage | UserDefaults | DataStore |
| Async | async/await | Coroutines |

---

## 🗓️ Development Phases (16 Weeks)

| Phase | Duration | Focus |
|-------|----------|-------|
| 1 | Week 1-2 | Project setup, networking, DI |
| 2 | Week 3 | Authentication (Google + Supabase) |
| 3 | Week 4-6 | 38-step onboarding + voice recording |
| 4 | Week 7 | Payment integration (RevenueCat) |
| 5 | Week 8-10 | VoIP call system (Telecom + FCM) |
| 6 | Week 11 | Home dashboard |
| 7 | Week 12 | Settings & profile |
| 8 | Week 13-14 | Testing & QA |
| 9 | Week 15 | Polish & optimization |
| 10 | Week 16 | Google Play deployment |

---

## 🎨 Project Structure Example

```kotlin
// Clean Architecture Pattern

┌─────────────────────────────────┐
│    Presentation (UI + ViewModel) │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│    Domain (UseCases + Models)    │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│    Data (Repository + API)       │
└──────────────────────────────────┘
```

**Example: Onboarding Feature**

```
feature/onboarding/
├── data/
│   ├── repository/OnboardingRepositoryImpl.kt
│   └── model/OnboardingDataDto.kt
├── domain/
│   ├── model/OnboardingStep.kt
│   ├── usecase/CompleteOnboardingUseCase.kt
│   └── repository/OnboardingRepository.kt (interface)
└── presentation/
    ├── viewmodel/OnboardingViewModel.kt
    └── screen/OnboardingContainerScreen.kt
```

---

## 🔐 Required API Keys

Store these in `local.properties` (not committed to git):

```properties
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJxxx...
REVENUECAT_API_KEY=xxx
ELEVENLABS_API_KEY=xxx
OPENAI_API_KEY=xxx (if needed for client-side)
```

---

## 📋 Dependencies Quick Reference

```kotlin
// build.gradle.kts (app level)
dependencies {
    // Core Android
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.activity:activity-compose:1.8.2")

    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.01.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui-tooling-preview")

    // Hilt DI
    implementation("com.google.dagger:hilt-android:2.50")
    kapt("com.google.dagger:hilt-compiler:2.50")

    // Networking
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.2")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

    // DataStore
    implementation("androidx.datastore:datastore:1.0.0")

    // Supabase
    implementation("io.github.jan-tennert.supabase:postgrest-kt:2.0.0")
    implementation("io.github.jan-tennert.supabase:gotrue-kt:2.0.0")

    // RevenueCat
    implementation("com.revenuecat.purchases:purchases:7.0.0")

    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")

    // Image Loading
    implementation("io.coil-kt:coil-compose:2.5.0")

    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
}
```

---

## 🚦 Getting Started

### Step 1: Environment Setup
```bash
# Install Android Studio (latest stable)
# Install JDK 17
# Clone repository
git clone <repo-url>
cd youplus-android
```

### Step 2: Configure API Keys
```bash
# Create local.properties
echo "SUPABASE_URL=your_url" >> local.properties
echo "SUPABASE_ANON_KEY=your_key" >> local.properties
echo "REVENUECAT_API_KEY=your_key" >> local.properties
```

### Step 3: Firebase Setup
1. Create Firebase project
2. Download `google-services.json`
3. Place in `app/` directory

### Step 4: Build & Run
```bash
./gradlew assembleDebug
# Or use Android Studio "Run" button
```

---

## 📞 VoIP Call Flow (Simplified)

```
1. Backend sends FCM push
   ↓
2. Android receives push notification
   ↓
3. TelecomManager shows system incoming call UI
   ↓
4. User answers/rejects
   ↓
5. If answered:
   - Fetch call config from backend
   - Connect to ElevenLabs WebSocket
   - Start audio stream
   - Show live call UI
   ↓
6. Call ends:
   - Send transcript to backend
   - Update user streak
```

---

## 🎯 Success Metrics (Post-Launch)

- Onboarding completion rate > 60%
- Call answer rate > 80%
- Day 7 retention > 40%
- Subscription conversion > 5%
- Crash-free sessions > 99.5%
- App startup time < 2 seconds

---

## 📚 Key Documentation

- **Full Plan**: [`ANDROID_PLAN.md`](./ANDROID_PLAN.md) - Comprehensive 400+ line plan
- **Backend Docs**: [`be/ARCHITECTURE_BACKEND.md`](./be/ARCHITECTURE_BACKEND.md) - Backend API reference
- **iOS Reference**: `swift/bigbruhh/` - iOS implementation for comparison

---

## ❓ Open Questions

1. Should we match iOS design exactly or adapt Material Design 3?
2. Beta launch before iOS parity or wait for feature parity?
3. Tablet-specific layouts or just responsive phone UI?
4. Wear OS support needed?

---

## 🔗 Useful Resources

- [Jetpack Compose Docs](https://developer.android.com/jetpack/compose)
- [Android Telecom Guide](https://developer.android.com/guide/topics/connectivity/telecom)
- [Hilt Documentation](https://dagger.dev/hilt/)
- [Supabase Kotlin Docs](https://supabase.com/docs/reference/kotlin)
- [RevenueCat Android](https://www.revenuecat.com/docs/android)
- [ElevenLabs Convo AI](https://elevenlabs.io/docs/conversational-ai)

---

## 🏁 Next Steps

1. ✅ Review this plan
2. ⬜ Set up Android Studio project
3. ⬜ Configure Firebase & API keys
4. ⬜ Start Phase 1 (Project Setup)
5. ⬜ Create GitHub project board with tasks

---

**Ready to build!** 🚀

For detailed implementation plans, see [`ANDROID_PLAN.md`](./ANDROID_PLAN.md).
