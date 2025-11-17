# You+ Android App - Kotlin Implementation Plan

## Executive Summary

This document outlines the complete plan for porting the **You+ Accountability App** from iOS (Swift/SwiftUI) to Android (Kotlin/Jetpack Compose). The app uses AI-powered voice calls in the user's own voice to enforce daily commitments through a 38-step psychological onboarding and daily accountability call system.

**Key Principle**: The backend API remains unchanged. All existing Cloudflare Workers endpoints, database schema, and business logic are reused. The Android app is a client-side port only.

---

## Table of Contents

1. [Architecture & Tech Stack](#1-architecture--tech-stack)
2. [Project Structure](#2-project-structure)
3. [Core Features Implementation](#3-core-features-implementation)
4. [Technical Challenges & Solutions](#4-technical-challenges--solutions)
5. [Third-Party Integrations](#5-third-party-integrations)
6. [Development Roadmap](#6-development-roadmap)
7. [Testing Strategy](#7-testing-strategy)
8. [Deployment & Distribution](#8-deployment--distribution)

---

## 1. Architecture & Tech Stack

### 1.1 Architecture Pattern

**Clean Architecture with MVVM**

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Jetpack Compose + ViewModels)         │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Domain Layer                    │
│  (Use Cases + Domain Models)            │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Data Layer                      │
│  (Repositories + Data Sources)          │
└──────────────┬──────────────────────────┘
               │
      ┌────────┴────────┐
      │                 │
┌─────▼─────┐    ┌──────▼──────┐
│  Remote   │    │    Local    │
│   (API)   │    │ (DataStore) │
└───────────┘    └─────────────┘
```

**Why This Architecture?**
- **Separation of Concerns**: Each layer has clear responsibilities
- **Testability**: Easy to unit test business logic
- **Scalability**: Can add features without affecting existing code
- **Android Best Practice**: Recommended by Google for modern Android apps

### 1.2 Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Language** | Kotlin 1.9+ | Modern, concise, null-safe |
| **UI Framework** | Jetpack Compose | Declarative UI (SwiftUI equivalent) |
| **Architecture** | MVVM + Clean Architecture | Separation of concerns |
| **Dependency Injection** | Hilt | DI framework (Google's recommended) |
| **Networking** | Retrofit + OkHttp | HTTP client for API calls |
| **JSON Parsing** | Kotlinx Serialization | Type-safe JSON handling |
| **Async Operations** | Kotlin Coroutines + Flow | Reactive async programming |
| **Local Storage** | DataStore (Proto) | Key-value storage (UserDefaults equivalent) |
| **Database** | Room (optional) | Local caching if needed |
| **Image Loading** | Coil | Efficient image loading for Compose |
| **Navigation** | Compose Navigation | Screen routing |
| **VoIP Calls** | Android Telecom API | System call integration |
| **Push Notifications** | Firebase Cloud Messaging | Push notifications |
| **Audio Recording** | MediaRecorder + AudioRecord | Voice recording for onboarding |
| **Audio Playback** | ExoPlayer | High-quality audio playback |
| **Authentication** | Supabase Auth SDK | Backend auth integration |
| **Payments** | RevenueCat Android SDK | Subscription management |
| **Analytics** | (TBD) | User behavior tracking |
| **Crash Reporting** | (TBD) | Production error tracking |

### 1.3 Minimum SDK Version

```kotlin
android {
    compileSdk = 34

    defaultConfig {
        minSdk = 26  // Android 8.0 (Oreo) - 93% market coverage
        targetSdk = 34  // Android 14
    }
}
```

**Rationale for minSdk 26**:
- Required for `android.telecom` improvements (VoIP calls)
- Better notification channels support
- Covers 93% of active Android devices (as of 2024)

---

## 2. Project Structure

### 2.1 Module Organization

```
youplus-android/
├── app/                          # Main application module
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/youplus/
│   │   │   │   ├── YouPlusApplication.kt
│   │   │   │   ├── di/          # Hilt modules
│   │   │   │   ├── navigation/  # Nav graph
│   │   │   │   └── MainActivity.kt
│   │   │   ├── res/
│   │   │   └── AndroidManifest.xml
│   │   └── test/
│   └── build.gradle.kts
│
├── core/                         # Core utilities and base classes
│   ├── common/                   # Shared utilities
│   ├── network/                  # Networking layer
│   ├── data/                     # Base repositories
│   └── ui/                       # Shared UI components
│
├── feature/                      # Feature modules
│   ├── auth/                     # Authentication
│   ├── onboarding/               # 38-step onboarding flow
│   ├── call/                     # VoIP call handling
│   ├── home/                     # Dashboard/mirror screen
│   ├── promises/                 # Daily promise tracking
│   ├── settings/                 # User settings
│   └── paywall/                  # Subscription paywall
│
├── data/                         # Data layer
│   ├── api/                      # API service interfaces
│   ├── models/                   # Data models
│   └── repository/               # Repository implementations
│
└── buildSrc/                     # Build configuration
    └── Dependencies.kt
```

### 2.2 Feature Module Structure (Example: Onboarding)

```
feature/onboarding/
├── data/
│   ├── repository/
│   │   └── OnboardingRepositoryImpl.kt
│   └── model/
│       └── OnboardingDataDto.kt
│
├── domain/
│   ├── model/
│   │   ├── OnboardingStep.kt
│   │   └── OnboardingState.kt
│   ├── usecase/
│   │   ├── SaveOnboardingDataUseCase.kt
│   │   ├── UploadVoiceRecordingUseCase.kt
│   │   └── CompleteOnboardingUseCase.kt
│   └── repository/
│       └── OnboardingRepository.kt (interface)
│
└── presentation/
    ├── viewmodel/
    │   └── OnboardingViewModel.kt
    ├── screen/
    │   ├── OnboardingContainerScreen.kt
    │   ├── steps/
    │   │   ├── WelcomeStep.kt
    │   │   ├── GoalInputStep.kt
    │   │   ├── VoiceRecordingStep.kt
    │   │   └── [... 35 more steps]
    │   └── components/
    │       ├── StepIndicator.kt
    │       ├── AudioRecorderButton.kt
    │       └── ProgressBar.kt
    └── navigation/
        └── OnboardingNavGraph.kt
```

---

## 3. Core Features Implementation

### 3.1 Authentication System

**iOS Implementation**: Apple ID + Supabase Auth

**Android Implementation**: Multi-provider auth with Supabase

```kotlin
// feature/auth/domain/repository/AuthRepository.kt
interface AuthRepository {
    suspend fun signInWithGoogle(): Result<User>
    suspend fun signInWithEmail(email: String, password: String): Result<User>
    suspend fun signUp(email: String, password: String): Result<User>
    suspend fun signOut(): Result<Unit>
    suspend fun getCurrentUser(): User?
    fun observeAuthState(): Flow<AuthState>
}
```

**Auth Providers**:
1. **Google Sign-In** (Primary - equivalent to Apple ID)
2. **Email/Password** (Fallback)
3. **Anonymous Sessions** (Pre-payment onboarding)

**Implementation Steps**:
1. Add Firebase Auth SDK (for Google Sign-In)
2. Configure Supabase client with OAuth providers
3. Implement token refresh logic
4. Persist auth state in DataStore
5. Handle session migration from anonymous → authenticated

**Key Files**:
- `feature/auth/data/SupabaseAuthDataSource.kt`
- `feature/auth/presentation/LoginScreen.kt`
- `feature/auth/presentation/SignUpScreen.kt`

---

### 3.2 38-Step Onboarding Flow

**Architecture**: State Machine Pattern with Jetpack Compose Navigation

```kotlin
// domain/model/OnboardingState.kt
sealed class OnboardingState {
    data object NotStarted : OnboardingState()
    data class InProgress(
        val currentStep: Int,
        val totalSteps: Int,
        val stepData: Map<String, Any>
    ) : OnboardingState()
    data class VoiceRecording(
        val recordingType: VoiceRecordingType,
        val prompt: String
    ) : OnboardingState()
    data class DemoCall(val callId: String) : OnboardingState()
    data class Payment(val products: List<Product>) : OnboardingState()
    data object Completed : OnboardingState()
}

enum class VoiceRecordingType {
    WHY_IT_MATTERS,
    COST_OF_QUITTING,
    COMMITMENT
}
```

**Step Categories** (38 total):

1. **Anonymous Data Collection** (Steps 1-25)
   - Goal + deadline
   - Motivation level
   - Attempt history
   - Obstacles & fears
   - Demographics
   - Success visualization

2. **Voice Recording** (Steps 26-28)
   - Record "Why it matters" (60-120 seconds)
   - Record "Cost of quitting" (60-120 seconds)
   - Record "Commitment" (30-60 seconds)

3. **Demo Call Experience** (Step 29)
   - Play pre-generated demo call
   - Collect rating (1-5 scale)

4. **Payment Gate** (Step 30-32)
   - Show RevenueCat paywall
   - Process payment
   - Grant access

5. **Authentication** (Step 33-35)
   - Google Sign-In
   - Data migration from anonymous session
   - Account creation

6. **Voice Cloning** (Step 36-37)
   - Upload voice recordings to backend
   - Trigger ElevenLabs voice clone
   - Confirm identity creation

7. **Onboarding Complete** (Step 38)
   - Show success screen
   - Schedule first call
   - Navigate to home

**UI Components**:

```kotlin
// presentation/screen/OnboardingContainerScreen.kt
@Composable
fun OnboardingContainerScreen(
    viewModel: OnboardingViewModel = hiltViewModel()
) {
    val state by viewModel.state.collectAsState()

    Scaffold(
        topBar = {
            OnboardingTopBar(
                currentStep = state.currentStep,
                totalSteps = state.totalSteps,
                onBackClick = { viewModel.goToPreviousStep() }
            )
        }
    ) { padding ->
        when (state) {
            is OnboardingState.InProgress -> {
                StepContent(
                    step = state.currentStep,
                    data = state.stepData,
                    onNext = { data -> viewModel.submitStepData(data) }
                )
            }
            is OnboardingState.VoiceRecording -> {
                VoiceRecordingScreen(
                    recordingType = state.recordingType,
                    prompt = state.prompt,
                    onRecordingComplete = { audioFile ->
                        viewModel.saveVoiceRecording(audioFile)
                    }
                )
            }
            // ... other states
        }
    }
}
```

**Data Persistence**:
- Use DataStore (Proto) to save progress after each step
- Allow users to resume if they close the app
- Clear data only after onboarding completion

---

### 3.3 VoIP Call System

**iOS Implementation**: CallKit + VoIP Push + ElevenLabs Convo AI

**Android Implementation**: Telecom Framework + FCM + ConnectionService

#### 3.3.1 Architecture Overview

```
┌──────────────────────────────────────────────────┐
│         Backend (Cloudflare Workers)             │
│  - Schedules daily calls (cron)                  │
│  - Generates call config (prompt, tone, context) │
│  - Sends push notification to device             │
└───────────────┬──────────────────────────────────┘
                │ FCM Push
                ▼
┌──────────────────────────────────────────────────┐
│         Android Device (YouPlus App)             │
│                                                  │
│  1. FCM Receiver                                 │
│     - Receives call notification                 │
│     - Extracts call metadata (call_id, user_id)  │
│                                                  │
│  2. TelecomManager                               │
│     - Shows system incoming call UI              │
│     - Registers ConnectionService                │
│                                                  │
│  3. Custom ConnectionService                     │
│     - Manages call lifecycle (answer/reject)     │
│     - Connects to ElevenLabs Convo AI            │
│                                                  │
│  4. WebRTC/Audio Bridge                          │
│     - Establishes audio stream with ElevenLabs   │
│     - Plays AI voice, captures user voice        │
│                                                  │
│  5. Call UI (Activity/Compose)                   │
│     - Shows live call screen                     │
│     - Displays transcript in real-time           │
│     - Mute/Speaker controls                      │
└──────────────────────────────────────────────────┘
```

#### 3.3.2 Implementation Details

**Step 1: FCM Push Notification Receiver**

```kotlin
// feature/call/data/fcm/CallPushService.kt
class CallPushService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        val data = remoteMessage.data

        when (data["type"]) {
            "incoming_call" -> {
                val callId = data["call_id"] ?: return
                val userId = data["user_id"] ?: return
                val callType = data["call_type"] ?: "morning"

                // Show incoming call UI via Telecom
                showIncomingCall(
                    callId = callId,
                    userId = userId,
                    callType = callType
                )
            }
        }
    }

    private fun showIncomingCall(
        callId: String,
        userId: String,
        callType: String
    ) {
        val telecomManager = getSystemService(TelecomManager::class.java)

        // Create phone account if not exists
        val phoneAccountHandle = PhoneAccountHandle(
            ComponentName(this, YouPlusConnectionService::class.java),
            "YouPlus_$userId"
        )

        // Build call extras
        val extras = Bundle().apply {
            putString("call_id", callId)
            putString("user_id", userId)
            putString("call_type", callType)
        }

        // Show system incoming call screen
        telecomManager.addNewIncomingCall(phoneAccountHandle, extras)
    }
}
```

**Step 2: ConnectionService Implementation**

```kotlin
// feature/call/service/YouPlusConnectionService.kt
class YouPlusConnectionService : ConnectionService() {

    override fun onCreateIncomingConnection(
        connectionManagerPhoneAccount: PhoneAccountHandle,
        request: ConnectionRequest
    ): Connection {
        val callId = request.extras.getString("call_id") ?: ""
        val userId = request.extras.getString("user_id") ?: ""
        val callType = request.extras.getString("call_type") ?: "morning"

        return YouPlusConnection(
            context = applicationContext,
            callId = callId,
            userId = userId,
            callType = callType
        ).apply {
            setAddress(
                Uri.parse("tel:YouPlus"),
                TelecomManager.PRESENTATION_ALLOWED
            )
            setCallerDisplayName(
                "You+ Daily Call",
                TelecomManager.PRESENTATION_ALLOWED
            )
        }
    }
}

class YouPlusConnection(
    private val context: Context,
    private val callId: String,
    private val userId: String,
    private val callType: String
) : Connection() {

    private var elevenLabsClient: ElevenLabsConvoClient? = null
    private var audioStream: AudioStream? = null

    init {
        setConnectionProperties(PROPERTY_SELF_MANAGED)
        setConnectionCapabilities(
            CAPABILITY_SUPPORT_HOLD or
            CAPABILITY_MUTE
        )
    }

    override fun onAnswer() {
        setActive() // Mark call as active

        // Fetch call configuration from backend
        CoroutineScope(Dispatchers.IO).launch {
            val config = apiService.initCall(callId, userId)

            // Start ElevenLabs Convo AI session
            elevenLabsClient = ElevenLabsConvoClient(
                agentId = config.agentId,
                apiKey = BuildConfig.ELEVENLABS_API_KEY
            )

            // Connect audio stream
            audioStream = elevenLabsClient?.connect(
                systemPrompt = config.systemPrompt,
                firstMessage = config.firstMessage,
                onTranscript = { text ->
                    // Update live call UI
                    CallUIManager.updateTranscript(text)
                },
                onComplete = { transcript ->
                    // Send transcript to backend
                    apiService.webhookElevenLabs(callId, transcript)
                    setDisconnected(DisconnectCause(DisconnectCause.LOCAL))
                    destroy()
                }
            )

            // Show call UI activity
            val intent = Intent(context, LiveCallActivity::class.java).apply {
                putExtra("call_id", callId)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        }
    }

    override fun onReject() {
        // Notify backend of missed call
        CoroutineScope(Dispatchers.IO).launch {
            apiService.acknowledgeCall(callId, acknowledged = false)
        }
        setDisconnected(DisconnectCause(DisconnectCause.REJECTED))
        destroy()
    }

    override fun onDisconnect() {
        elevenLabsClient?.disconnect()
        audioStream?.close()
        destroy()
    }

    override fun onHold() {
        setOnHold()
        audioStream?.pause()
    }

    override fun onUnhold() {
        setActive()
        audioStream?.resume()
    }
}
```

**Step 3: ElevenLabs Convo AI Client**

```kotlin
// feature/call/data/elevenlabs/ElevenLabsConvoClient.kt
class ElevenLabsConvoClient(
    private val agentId: String,
    private val apiKey: String
) {
    private var webSocketClient: WebSocket? = null
    private var audioRecorder: AudioRecorder? = null
    private var audioPlayer: AudioPlayer? = null

    suspend fun connect(
        systemPrompt: String,
        firstMessage: String,
        onTranscript: (String) -> Unit,
        onComplete: (String) -> Unit
    ): AudioStream {
        // Establish WebSocket connection to ElevenLabs
        val request = Request.Builder()
            .url("wss://api.elevenlabs.io/v1/convai/conversation?agent_id=$agentId")
            .addHeader("xi-api-key", apiKey)
            .build()

        webSocketClient = OkHttpClient().newWebSocket(request, object : WebSocketListener() {
            override fun onMessage(webSocket: WebSocket, text: String) {
                val message = Json.decodeFromString<ConvoMessage>(text)
                when (message.type) {
                    "transcript" -> onTranscript(message.text)
                    "audio" -> playAudioChunk(message.audioData)
                    "conversation_end" -> onComplete(message.fullTranscript)
                }
            }
        })

        // Start recording user's voice
        audioRecorder = AudioRecorder { audioChunk ->
            // Send user's voice to ElevenLabs
            webSocketClient?.send(audioChunk)
        }
        audioRecorder?.startRecording()

        return AudioStream(audioRecorder, audioPlayer)
    }

    fun disconnect() {
        audioRecorder?.stopRecording()
        audioPlayer?.stop()
        webSocketClient?.close(1000, "Call ended")
    }
}
```

**Step 4: Live Call UI**

```kotlin
// feature/call/presentation/LiveCallScreen.kt
@Composable
fun LiveCallScreen(
    callId: String,
    viewModel: CallViewModel = hiltViewModel()
) {
    val callState by viewModel.callState.collectAsState()
    val transcript by viewModel.transcript.collectAsState()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0A0A0F)) // Dark background
    ) {
        Column(
            modifier = Modifier.align(Alignment.Center),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Avatar or visual representation
            Box(
                modifier = Modifier
                    .size(120.dp)
                    .clip(CircleShape)
                    .background(Color(0xFF1E1E28))
            ) {
                Icon(
                    imageVector = Icons.Default.Person,
                    contentDescription = "You",
                    tint = Color.White,
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(24.dp)
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Call status
            Text(
                text = when (callState) {
                    CallState.Connecting -> "Connecting..."
                    CallState.Active -> "In Call"
                    CallState.Ended -> "Call Ended"
                    else -> ""
                },
                style = MaterialTheme.typography.headlineMedium,
                color = Color.White
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Live transcript
            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 32.dp)
            ) {
                items(transcript) { message ->
                    TranscriptBubble(
                        speaker = message.speaker,
                        text = message.text,
                        timestamp = message.timestamp
                    )
                }
            }

            Spacer(modifier = Modifier.height(32.dp))

            // Call controls
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 32.dp),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                // Mute button
                CallControlButton(
                    icon = if (callState.isMuted) Icons.Default.MicOff else Icons.Default.Mic,
                    onClick = { viewModel.toggleMute() },
                    backgroundColor = if (callState.isMuted) Color.Red else Color.Gray
                )

                // End call button
                CallControlButton(
                    icon = Icons.Default.CallEnd,
                    onClick = { viewModel.endCall() },
                    backgroundColor = Color.Red
                )

                // Speaker button
                CallControlButton(
                    icon = if (callState.isSpeakerOn) Icons.Default.VolumeUp else Icons.Default.VolumeDown,
                    onClick = { viewModel.toggleSpeaker() },
                    backgroundColor = if (callState.isSpeakerOn) Color.Blue else Color.Gray
                )
            }

            Spacer(modifier = Modifier.height(48.dp))
        }
    }
}
```

#### 3.3.3 Permissions Required

```xml
<!-- AndroidManifest.xml -->
<manifest>
    <!-- VoIP Calls -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MANAGE_OWN_CALLS" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.CALL_PHONE" />

    <!-- Push Notifications -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <!-- Internet -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application>
        <!-- FCM Service -->
        <service
            android:name=".feature.call.data.fcm.CallPushService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Connection Service -->
        <service
            android:name=".feature.call.service.YouPlusConnectionService"
            android:permission="android.permission.BIND_TELECOM_CONNECTION_SERVICE"
            android:exported="true">
            <intent-filter>
                <action android:name="android.telecom.ConnectionService" />
            </intent-filter>
        </service>
    </application>
</manifest>
```

---

### 3.4 Audio Recording System

**Purpose**: Record 3 voice clips during onboarding for voice cloning

**Requirements**:
- High-quality audio (16-bit PCM, 44.1kHz)
- Minimum duration validation (30-120 seconds)
- Real-time waveform visualization
- Playback preview before submission
- Upload to Cloudflare R2 via backend

**Implementation**:

```kotlin
// feature/onboarding/data/audio/AudioRecorderManager.kt
class AudioRecorderManager(private val context: Context) {

    private var mediaRecorder: MediaRecorder? = null
    private var audioFile: File? = null
    private val recordingFlow = MutableStateFlow<RecordingState>(RecordingState.Idle)

    sealed class RecordingState {
        object Idle : RecordingState()
        data class Recording(val duration: Long) : RecordingState()
        data class Completed(val file: File, val duration: Long) : RecordingState()
        data class Error(val message: String) : RecordingState()
    }

    suspend fun startRecording(): Flow<RecordingState> = flow {
        try {
            // Create temp file
            audioFile = File(
                context.cacheDir,
                "voice_recording_${System.currentTimeMillis()}.m4a"
            )

            // Initialize MediaRecorder
            mediaRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                MediaRecorder(context)
            } else {
                @Suppress("DEPRECATION")
                MediaRecorder()
            }.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setAudioEncodingBitRate(128000)
                setAudioSamplingRate(44100)
                setOutputFile(audioFile!!.absolutePath)
                prepare()
                start()
            }

            // Emit recording progress every second
            var duration = 0L
            while (recordingFlow.value is RecordingState.Recording) {
                delay(1000)
                duration += 1000
                emit(RecordingState.Recording(duration))
            }

        } catch (e: Exception) {
            emit(RecordingState.Error(e.message ?: "Recording failed"))
        }
    }

    fun stopRecording(): Result<File> {
        return try {
            mediaRecorder?.apply {
                stop()
                release()
            }
            mediaRecorder = null

            val file = audioFile ?: throw IllegalStateException("No recording file")
            Result.success(file)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun cancelRecording() {
        mediaRecorder?.apply {
            stop()
            release()
        }
        audioFile?.delete()
        mediaRecorder = null
        audioFile = null
    }
}
```

**UI Component**:

```kotlin
@Composable
fun VoiceRecordingStep(
    prompt: String,
    minDuration: Long,
    maxDuration: Long,
    onRecordingComplete: (File) -> Unit
) {
    val recorderManager = remember { AudioRecorderManager(LocalContext.current) }
    val recordingState by recorderManager.recordingFlow.collectAsState()

    var isRecording by remember { mutableStateOf(false) }
    var recordedFile by remember { mutableStateOf<File?>(null) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Prompt text
        Text(
            text = prompt,
            style = MaterialTheme.typography.headlineSmall,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Waveform visualization
        when (val state = recordingState) {
            is RecordingState.Recording -> {
                AudioWaveform(duration = state.duration)
            }
            is RecordingState.Completed -> {
                AudioPlaybackPreview(file = state.file)
            }
            else -> {
                // Show microphone icon
            }
        }

        Spacer(modifier = Modifier.height(48.dp))

        // Recording duration
        if (recordingState is RecordingState.Recording) {
            Text(
                text = formatDuration((recordingState as RecordingState.Recording).duration),
                style = MaterialTheme.typography.displayMedium,
                color = Color.Red
            )
        }

        Spacer(modifier = Modifier.weight(1f))

        // Record/Stop button
        RecordButton(
            isRecording = isRecording,
            onClick = {
                if (isRecording) {
                    val result = recorderManager.stopRecording()
                    result.onSuccess { file ->
                        recordedFile = file
                        isRecording = false
                    }
                } else {
                    recorderManager.startRecording()
                    isRecording = true
                }
            }
        )

        Spacer(modifier = Modifier.height(24.dp))

        // Submit button (only show if recording meets minimum duration)
        if (recordedFile != null) {
            Button(
                onClick = { onRecordingComplete(recordedFile!!) },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Continue")
            }
        }
    }
}
```

---

### 3.5 Home/Dashboard Screen

**iOS Implementation**: "Mirror" screen with streak, upcoming calls, recent performance

**Android Implementation**: Same design philosophy with Material 3 design

```kotlin
@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel()
) {
    val user by viewModel.user.collectAsState()
    val identityStatus by viewModel.identityStatus.collectAsState()
    val upcomingCall by viewModel.upcomingCall.collectAsState()
    val recentCalls by viewModel.recentCalls.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("You+") },
                actions = {
                    IconButton(onClick = { /* Navigate to settings */ }) {
                        Icon(Icons.Default.Settings, "Settings")
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp)
        ) {
            // Streak Card
            item {
                StreakCard(
                    streak = identityStatus.streak,
                    trustPercentage = identityStatus.trustPercentage
                )
            }

            item { Spacer(modifier = Modifier.height(16.dp)) }

            // Upcoming Call
            item {
                UpcomingCallCard(
                    callTime = upcomingCall.scheduledTime,
                    callType = upcomingCall.type
                )
            }

            item { Spacer(modifier = Modifier.height(24.dp)) }

            // Recent Calls Section
            item {
                Text(
                    text = "Recent Calls",
                    style = MaterialTheme.typography.titleLarge,
                    modifier = Modifier.padding(vertical = 8.dp)
                )
            }

            items(recentCalls) { call ->
                CallHistoryItem(call = call)
            }
        }
    }
}
```

---

### 3.6 Push Notification System

**iOS**: VoIP Push (APNS) → Instant call UI

**Android**: Firebase Cloud Messaging (FCM) → System incoming call UI

**Backend Changes Required**: None (backend sends push to FCM instead of APNS)

**Implementation**:

1. **Register FCM Token**:
```kotlin
// On app startup
FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
    if (task.isSuccessful) {
        val token = task.result
        // Send to backend
        apiService.registerPushToken(userId, token, platform = "android")
    }
}
```

2. **Handle Incoming Push**:
```kotlin
class CallPushService : FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // Extract call data and show incoming call UI
        // (Implementation shown in section 3.3.2)
    }
}
```

3. **Notification Permissions** (Android 13+):
```kotlin
// Request notification permission
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    ActivityCompat.requestPermissions(
        activity,
        arrayOf(Manifest.permission.POST_NOTIFICATIONS),
        REQUEST_CODE_NOTIFICATIONS
    )
}
```

---

## 4. Technical Challenges & Solutions

### 4.1 Challenge: VoIP Call Reliability

**Problem**: Android doesn't have native "VoIP push" like iOS. Regular FCM pushes may be delayed or dropped if the app is killed.

**Solutions**:

1. **High Priority FCM Messages**:
```kotlin
// Backend sends FCM with high priority
{
  "message": {
    "token": "user_fcm_token",
    "android": {
      "priority": "high",
      "ttl": "60s"
    },
    "data": {
      "type": "incoming_call",
      "call_id": "..."
    }
  }
}
```

2. **Foreground Service for Call Window**:
   - Start a foreground service 30 minutes before expected call time
   - Keep app alive during call window
   - Stop service after call window ends

```kotlin
class CallWindowService : Service() {
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Show persistent notification
        val notification = createCallWindowNotification()
        startForeground(NOTIFICATION_ID, notification)

        // Schedule service stop after call window
        handler.postDelayed({
            stopSelf()
        }, CALL_WINDOW_DURATION_MS)

        return START_STICKY
    }
}
```

3. **Fallback to Regular Notification**:
   - If ConnectionService fails to show, fall back to regular notification
   - User taps notification → Opens call UI manually

### 4.2 Challenge: Audio Quality for Voice Cloning

**Problem**: Need high-quality audio recordings for ElevenLabs voice cloning

**Solution**: Use uncompressed PCM format, then convert to FLAC before upload

```kotlin
// Record in WAV (PCM) format
val audioRecord = AudioRecord(
    MediaRecorder.AudioSource.MIC,
    44100, // Sample rate
    AudioFormat.CHANNEL_IN_MONO,
    AudioFormat.ENCODING_PCM_16BIT,
    bufferSize
)

// After recording, convert to FLAC using FFmpeg Android library
val flacFile = convertToFlac(wavFile)

// Upload FLAC to backend
apiService.uploadVoiceRecording(flacFile)
```

### 4.3 Challenge: Background Call Scheduling

**Problem**: Android kills background tasks aggressively. Users may miss calls.

**Solution**: Use WorkManager with expedited work for time-sensitive tasks

```kotlin
// Schedule daily call check
val callCheckWork = PeriodicWorkRequestBuilder<CallCheckWorker>(
    repeatInterval = 15, // Check every 15 minutes during call window
    repeatIntervalTimeUnit = TimeUnit.MINUTES
)
    .setConstraints(
        Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()
    )
    .build()

WorkManager.getInstance(context).enqueueUniquePeriodicWork(
    "daily_call_check",
    ExistingPeriodicWorkPolicy.KEEP,
    callCheckWork
)
```

### 4.4 Challenge: State Persistence During Onboarding

**Problem**: Users may close app mid-onboarding. Need to resume from exact step.

**Solution**: Use Proto DataStore for efficient state persistence

```kotlin
// data/proto/onboarding_state.proto
syntax = "proto3";

message OnboardingStateProto {
  int32 current_step = 1;
  map<string, string> step_data = 2;
  repeated string voice_recording_paths = 3;
  bool payment_completed = 4;
  string anonymous_user_id = 5;
}

// Save state after each step
suspend fun saveOnboardingState(state: OnboardingState) {
    dataStore.updateData { currentProto ->
        currentProto.toBuilder()
            .setCurrentStep(state.currentStep)
            .putAllStepData(state.stepData)
            .build()
    }
}
```

### 4.5 Challenge: Authentication Flow with Anonymous Sessions

**Problem**: Users start onboarding anonymously, but need to link data after payment

**Flow**:
1. User starts app → Create anonymous Supabase session
2. Complete onboarding steps 1-29 (save data under anonymous ID)
3. Payment → Create RevenueCat customer with anonymous ID
4. Sign in with Google → Create authenticated user
5. **Migration**: Backend links anonymous data to authenticated user

```kotlin
// After Google Sign-In succeeds
suspend fun migrateAnonymousData(
    anonymousUserId: String,
    authenticatedUserId: String
) {
    // Backend handles data migration
    apiService.migrateUserData(
        from = anonymousUserId,
        to = authenticatedUserId
    )

    // Clear local anonymous session
    dataStore.edit { prefs ->
        prefs.remove(KEY_ANONYMOUS_USER_ID)
    }
}
```

---

## 5. Third-Party Integrations

### 5.1 Supabase Auth SDK

**Installation**:
```kotlin
// build.gradle.kts
dependencies {
    implementation("io.github.jan-tennert.supabase:postgrest-kt:2.0.0")
    implementation("io.github.jan-tennert.supabase:gotrue-kt:2.0.0")
    implementation("io.github.jan-tennert.supabase:realtime-kt:2.0.0")
}
```

**Usage**:
```kotlin
val supabase = createSupabaseClient(
    supabaseUrl = BuildConfig.SUPABASE_URL,
    supabaseKey = BuildConfig.SUPABASE_ANON_KEY
) {
    install(GoTrue)
    install(Postgrest)
}

// Google Sign-In
suspend fun signInWithGoogle(idToken: String): User {
    val result = supabase.auth.signInWith(Google) {
        this.idToken = idToken
    }
    return result.user
}
```

### 5.2 RevenueCat SDK

**Installation**:
```kotlin
dependencies {
    implementation("com.revenuecat.purchases:purchases:7.0.0")
}
```

**Configuration**:
```kotlin
// In Application.onCreate()
Purchases.configure(
    PurchasesConfiguration.Builder(context, apiKey = BuildConfig.REVENUECAT_API_KEY)
        .appUserID(userId)
        .build()
)

// Fetch offerings
Purchases.sharedInstance.getOfferingsWith({ error ->
    // Handle error
}) { offerings ->
    val currentOffering = offerings.current
    // Show paywall
}

// Purchase
Purchases.sharedInstance.purchaseWith(
    PurchaseParams.Builder(activity, product).build(),
    onError = { error, userCancelled -> },
    onSuccess = { storeTransaction, customerInfo ->
        // Grant access
    }
)
```

### 5.3 ElevenLabs Convo AI SDK

**Note**: ElevenLabs doesn't have an official Android SDK. Use WebSocket API directly.

**Implementation**:
```kotlin
class ElevenLabsConvoClient(private val apiKey: String) {
    private val client = OkHttpClient()
    private var webSocket: WebSocket? = null

    fun connect(agentId: String, onMessage: (ConvoMessage) -> Unit) {
        val request = Request.Builder()
            .url("wss://api.elevenlabs.io/v1/convai/conversation?agent_id=$agentId")
            .addHeader("xi-api-key", apiKey)
            .build()

        webSocket = client.newWebSocket(request, object : WebSocketListener() {
            override fun onMessage(webSocket: WebSocket, text: String) {
                val message = Json.decodeFromString<ConvoMessage>(text)
                onMessage(message)
            }
        })
    }

    fun sendAudio(audioData: ByteArray) {
        webSocket?.send(ByteString.of(*audioData))
    }
}
```

### 5.4 Firebase Cloud Messaging

**Setup**:
1. Create Firebase project
2. Add `google-services.json` to `app/` directory
3. Add Firebase SDK

```kotlin
// build.gradle.kts (project level)
plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false
}

// build.gradle.kts (app level)
plugins {
    id("com.google.gms.google-services")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")
}
```

**Token Registration**:
```kotlin
FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
    val token = task.result
    // Send to backend
    apiService.updatePushToken(token)
}
```

---

## 6. Development Roadmap

### Phase 1: Project Setup & Core Infrastructure (Week 1-2)

**Tasks**:
- [ ] Create Android Studio project with multi-module structure
- [ ] Set up Hilt dependency injection
- [ ] Configure build variants (debug, staging, production)
- [ ] Set up CI/CD pipeline (GitHub Actions)
- [ ] Implement networking layer (Retrofit + OkHttp)
- [ ] Set up DataStore for local storage
- [ ] Create base ViewModels and UseCases
- [ ] Implement error handling framework
- [ ] Set up logging and crash reporting

**Deliverables**:
- Working project structure
- Network calls to existing backend
- Basic navigation framework

### Phase 2: Authentication (Week 3)

**Tasks**:
- [ ] Integrate Supabase Auth SDK
- [ ] Implement Google Sign-In flow
- [ ] Implement email/password auth
- [ ] Create anonymous session handling
- [ ] Implement token refresh logic
- [ ] Build login/signup UI (Jetpack Compose)
- [ ] Implement auth state persistence
- [ ] Create session migration logic

**Deliverables**:
- Fully functional authentication system
- Login/Signup screens
- Session management

### Phase 3: 38-Step Onboarding Flow (Week 4-6)

**Tasks**:
- [ ] Design onboarding state machine
- [ ] Implement all 38 step screens (Compose)
- [ ] Build audio recording system
- [ ] Create waveform visualization
- [ ] Implement progress persistence (Proto DataStore)
- [ ] Integrate demo call playback
- [ ] Build onboarding navigation graph
- [ ] Implement data validation
- [ ] Create backend integration (POST /onboarding/conversion/complete)
- [ ] Test edge cases (app kill, back navigation)

**Deliverables**:
- Complete 38-step onboarding flow
- Voice recording capability
- Data persistence across app restarts

### Phase 4: Payment Integration (Week 7)

**Tasks**:
- [ ] Integrate RevenueCat SDK
- [ ] Create paywall UI
- [ ] Implement product fetching
- [ ] Handle purchase flow
- [ ] Implement restore purchases
- [ ] Test subscription states (active, expired, cancelled)
- [ ] Implement subscription validation middleware

**Deliverables**:
- Working paywall
- Subscription management
- Payment verification

### Phase 5: VoIP Call System (Week 8-10)

**Tasks**:
- [ ] Set up Firebase Cloud Messaging
- [ ] Implement FCM push notification handler
- [ ] Build ConnectionService for system call UI
- [ ] Implement Telecom integration
- [ ] Create ElevenLabs WebSocket client
- [ ] Build audio stream management (record + playback)
- [ ] Design live call UI (Compose)
- [ ] Implement call transcript display
- [ ] Test call answer/reject flows
- [ ] Implement call acknowledgment backend integration
- [ ] Handle missed call scenarios
- [ ] Test background call delivery

**Deliverables**:
- System-level incoming call UI
- Live call screen with transcript
- Reliable call delivery system

### Phase 6: Home/Dashboard (Week 11)

**Tasks**:
- [ ] Design home screen UI
- [ ] Implement streak display
- [ ] Build upcoming call card
- [ ] Create call history list
- [ ] Implement pull-to-refresh
- [ ] Add empty states
- [ ] Integrate backend APIs (GET /promises, GET /api/call-log)

**Deliverables**:
- Functional home screen
- Real-time data display

### Phase 7: Settings & Profile (Week 12)

**Tasks**:
- [ ] Build settings screen
- [ ] Implement call schedule customization
- [ ] Add tone preference settings
- [ ] Create account management (delete account, logout)
- [ ] Implement notification preferences
- [ ] Add about/help sections

**Deliverables**:
- Settings screen
- User preferences management

### Phase 8: Testing & QA (Week 13-14)

**Tasks**:
- [ ] Write unit tests for ViewModels
- [ ] Write unit tests for UseCases
- [ ] Write unit tests for Repositories
- [ ] Create UI tests (Compose Testing)
- [ ] Test on multiple Android versions (API 26-34)
- [ ] Test on different screen sizes
- [ ] Perform end-to-end testing
- [ ] Test edge cases (network failures, permission denials)
- [ ] Load testing with real backend
- [ ] Security audit (API key handling, token storage)

**Deliverables**:
- 80%+ test coverage
- Bug-free core flows

### Phase 9: Polish & Optimization (Week 15)

**Tasks**:
- [ ] Optimize app size (ProGuard, R8)
- [ ] Implement app startup optimization
- [ ] Add loading skeletons
- [ ] Improve animations and transitions
- [ ] Optimize image loading
- [ ] Implement analytics tracking
- [ ] Add accessibility features (TalkBack support)
- [ ] Localization (if needed)

**Deliverables**:
- Polished user experience
- Optimized performance

### Phase 10: Deployment (Week 16)

**Tasks**:
- [ ] Create Google Play Store listing
- [ ] Generate signed APK/AAB
- [ ] Submit to Google Play (internal testing)
- [ ] Conduct alpha testing
- [ ] Submit to Google Play (open beta)
- [ ] Conduct beta testing
- [ ] Fix critical bugs from beta
- [ ] Submit to Google Play (production)

**Deliverables**:
- App live on Google Play Store

---

## 7. Testing Strategy

### 7.1 Unit Tests

**Target Coverage**: 80%+

**Key Areas**:
- ViewModels (all business logic)
- UseCases (domain layer)
- Repositories (data layer)
- Utility classes

**Example**:
```kotlin
@Test
fun `onboarding state should progress to next step when valid data submitted`() = runTest {
    // Arrange
    val viewModel = OnboardingViewModel(
        saveOnboardingDataUseCase = mockSaveDataUseCase,
        dispatcher = StandardTestDispatcher()
    )

    // Act
    viewModel.submitStepData(mapOf("goal" to "Run 5K"))
    advanceUntilIdle()

    // Assert
    assertEquals(2, viewModel.state.value.currentStep)
}
```

### 7.2 UI Tests

**Framework**: Compose Testing

**Example**:
```kotlin
@Test
fun loginScreen_displaysErrorOnInvalidCredentials() {
    composeTestRule.setContent {
        LoginScreen()
    }

    composeTestRule.onNodeWithText("Email").performTextInput("invalid@email")
    composeTestRule.onNodeWithText("Password").performTextInput("short")
    composeTestRule.onNodeWithText("Sign In").performClick()

    composeTestRule.onNodeWithText("Invalid email or password")
        .assertIsDisplayed()
}
```

### 7.3 Integration Tests

**Test Scenarios**:
- Complete onboarding flow (end-to-end)
- Authentication → Onboarding → Home flow
- Incoming call → Answer → Transcript display
- Payment → Subscription activation

### 7.4 Device Testing

**Test Matrix**:
- Android 8.0 (API 26) - Minimum supported version
- Android 10 (API 29) - Common older version
- Android 12 (API 31) - Mid-range current version
- Android 14 (API 34) - Latest version

**Device Sizes**:
- Phone (small, medium, large)
- Tablet (7", 10")
- Foldable (folded, unfolded)

---

## 8. Deployment & Distribution

### 8.1 App Signing

**Key Generation**:
```bash
keytool -genkey -v -keystore youplus-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias youplus
```

**Gradle Configuration**:
```kotlin
android {
    signingConfigs {
        create("release") {
            storeFile = file("../youplus-release.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = "youplus"
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### 8.2 Google Play Store Listing

**App Details**:
- **Title**: You+ Accountability
- **Short Description**: Daily AI accountability calls in your own voice
- **Full Description**: [Based on iOS App Store listing]
- **Category**: Productivity
- **Content Rating**: Everyone
- **Privacy Policy**: [Required - create policy page]

**Screenshots Required**:
- Phone: 2-8 screenshots (minimum 2)
- 7" Tablet: 1-8 screenshots (optional)
- 10" Tablet: 1-8 screenshots (optional)

**Key Screenshots**:
1. Onboarding welcome screen
2. Voice recording step
3. Live call screen
4. Home/streak dashboard
5. Call history

### 8.3 Release Tracks

1. **Internal Testing**: Team only (immediate upload)
2. **Alpha**: Closed group of testers (100-1000 users)
3. **Beta**: Open or closed beta (1000-10000 users)
4. **Production**: Public release

### 8.4 CI/CD Pipeline

**GitHub Actions Workflow**:
```yaml
name: Android CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'

    - name: Grant execute permission for gradlew
      run: chmod +x gradlew

    - name: Run unit tests
      run: ./gradlew test

    - name: Build debug APK
      run: ./gradlew assembleDebug

    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-debug
        path: app/build/outputs/apk/debug/app-debug.apk
```

---

## 9. Key Differences: iOS vs Android

| Feature | iOS | Android |
|---------|-----|---------|
| **Language** | Swift | Kotlin |
| **UI Framework** | SwiftUI | Jetpack Compose |
| **Architecture** | MVVM | MVVM + Clean Architecture |
| **Networking** | URLSession | Retrofit + OkHttp |
| **JSON Parsing** | Codable | Kotlinx Serialization |
| **Local Storage** | UserDefaults | DataStore |
| **Navigation** | NavigationStack | Compose Navigation |
| **DI** | Manual | Hilt |
| **Async** | async/await | Coroutines + Flow |
| **VoIP Calls** | CallKit + VoIP Push | Telecom + FCM |
| **Push Notifications** | APNS | FCM |
| **Auth** | Apple ID | Google Sign-In |
| **Audio Recording** | AVAudioRecorder | MediaRecorder |
| **Payments** | RevenueCat (iOS SDK) | RevenueCat (Android SDK) |

---

## 10. Open Questions

1. **App Name**: Use "You+" or "Big Bruh"? (iOS uses "You+")
2. **Color Scheme**: Match iOS exactly or adapt Material 3 guidelines?
3. **Launch Strategy**: Beta test before iOS parity or wait for feature parity?
4. **Tablet Support**: Build tablet-specific layouts or just responsive phone UI?
5. **Wear OS**: Should we plan for smartwatch support?
6. **Backend Changes**: Does backend need any Android-specific endpoints?

---

## 11. Success Metrics

**Post-Launch KPIs**:
- [ ] Onboarding completion rate > 60%
- [ ] Call answer rate > 80%
- [ ] Day 7 retention > 40%
- [ ] Subscription conversion > 5%
- [ ] Average app rating > 4.2/5
- [ ] Crash-free sessions > 99.5%
- [ ] App startup time < 2 seconds

---

## 12. Next Steps

1. **Review this plan** with team
2. **Prioritize features** (MVP vs nice-to-have)
3. **Set up development environment** (Android Studio, Firebase, etc.)
4. **Create GitHub project board** with tasks from roadmap
5. **Begin Phase 1** (Project setup)

---

## Appendix A: Technology Justifications

### Why Jetpack Compose over XML Views?
- Modern declarative UI (matches SwiftUI paradigm)
- Less boilerplate code
- Better state management
- Google's recommended approach for new apps
- Easier to maintain and test

### Why Hilt over Koin?
- Official Google DI framework
- Better compile-time safety
- Annotation-based (less manual setup)
- Works seamlessly with Jetpack libraries

### Why Retrofit over Ktor Client?
- More mature ecosystem
- Better OkHttp integration
- More extensive documentation
- Easier debugging with interceptors

### Why Proto DataStore over SharedPreferences?
- Type-safe (uses Protocol Buffers)
- Async by default (no ANR risk)
- Built on Kotlin Coroutines
- Migration path provided by Google

### Why Clean Architecture?
- Clear separation of concerns
- Highly testable
- Framework-independent business logic
- Easy to scale and maintain
- Industry standard for complex apps

---

## Appendix B: File Structure Reference

```
youplus-android/
├── .github/
│   └── workflows/
│       └── android-ci.yml
├── app/
│   ├── build.gradle.kts
│   ├── proguard-rules.pro
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml
│       │   ├── java/com/youplus/
│       │   │   ├── YouPlusApplication.kt
│       │   │   ├── MainActivity.kt
│       │   │   ├── di/
│       │   │   │   ├── AppModule.kt
│       │   │   │   ├── NetworkModule.kt
│       │   │   │   └── DatabaseModule.kt
│       │   │   └── navigation/
│       │   │       └── NavGraph.kt
│       │   └── res/
│       │       ├── values/
│       │       │   ├── strings.xml
│       │       │   ├── colors.xml
│       │       │   └── themes.xml
│       │       └── drawable/
│       └── test/
├── core/
│   ├── common/
│   │   ├── src/main/java/com/youplus/core/common/
│   │   │   ├── Result.kt
│   │   │   ├── Constants.kt
│   │   │   └── Extensions.kt
│   ├── network/
│   │   ├── src/main/java/com/youplus/core/network/
│   │   │   ├── ApiService.kt
│   │   │   ├── NetworkModule.kt
│   │   │   └── interceptors/
│   ├── data/
│   │   ├── src/main/java/com/youplus/core/data/
│   │   │   ├── repository/
│   │   │   └── model/
│   └── ui/
│       ├── src/main/java/com/youplus/core/ui/
│       │   ├── components/
│       │   ├── theme/
│       │   └── utils/
├── feature/
│   ├── auth/
│   │   ├── build.gradle.kts
│   │   └── src/main/java/com/youplus/feature/auth/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   ├── onboarding/
│   ├── call/
│   ├── home/
│   ├── promises/
│   ├── settings/
│   └── paywall/
├── data/
│   ├── api/
│   ├── models/
│   └── repository/
├── buildSrc/
│   └── src/main/kotlin/
│       └── Dependencies.kt
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
└── README.md
```

---

**Document Version**: 1.0
**Last Updated**: 2025-11-17
**Author**: AI Planning Assistant
**Status**: Draft - Awaiting Review
