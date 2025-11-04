# 🔍 Comprehensive Feature Analysis: What's Left to Implement

**Generated:** 2025-10-06
**Status:** Complete audit of nrn/ vs Swift app

---

## 📊 **Executive Summary**

### ✅ What We Have (COMPLETE):
1. ✅ Authentication (Apple Sign In + Supabase)
2. ✅ API Service with 15+ endpoints
3. ✅ Data models for all responses
4. ✅ Network monitoring
5. ✅ Data caching layer (5 different TTLs)
6. ✅ Home screen with real data
7. ✅ Evidence screen with call history
8. ✅ Pull-to-refresh everywhere
9. ✅ **Onboarding Data Push** (JUST COMPLETED)

### ⚠️ What's Missing (CRITICAL):
1. ❌ **Audio Recording & Conversion** (for onboarding)
2. ❌ **VOIP Push Notifications** (PushKit)
3. ❌ **CallKit Integration** (native call UI)
4. ❌ **11Labs Conversation** (actual AI calls)
5. ❌ **Background Audio** (calls continue in background)
6. ❌ **Brutal Reality System** (post-call shame screens)
7. ❌ **Onboarding Retry Service** (retry failed extractions)

### 📝 What's Missing (IMPORTANT):
8. ❌ Transcription Service
9. ❌ Background Conversation Manager
10. ❌ Analytics/PostHog integration
11. ❌ Settings screen functionality
12. ❌ Promise management UI
13. ❌ Celebration screens

---

## 🎤 **1. AUDIO HANDLING (CRITICAL - FOR ONBOARDING)**

### What RN App Does:

```typescript
// nrn/utils/fileUtils.ts
// 1. Record audio using expo-audio
const recorder = useAudioRecorder();
await recorder.record();

// 2. Stop and get file URI
const uri = recorder.uri; // "file:///path/to/recording.m4a"

// 3. Convert to base64 data URL
const base64 = await FileSystem.readAsStringAsync(uri, {
  encoding: FileSystem.EncodingType.Base64
});
const dataUrl = `data:audio/m4a;base64,${base64}`;

// 4. Store in onboarding response
response.value = dataUrl; // This gets sent to backend
```

### What We Have:
```swift
// ❌ NOTHING - No audio recording implemented
```

### What We Need:

**A. Audio Recording Service** (`AudioRecordingService.swift`)
```swift
class AudioRecordingService {
    func startRecording() async throws -> URL
    func stopRecording() async throws -> AudioRecording
    func requestPermissions() async throws -> Bool
}

struct AudioRecording {
    let fileURL: URL
    let duration: TimeInterval
    let format: String // "m4a"
}
```

**B. Base64 Conversion Utility** (`FileUtils.swift`)
```swift
func convertAudioToBase64DataURL(fileURL: URL) async throws -> String {
    // 1. Read file as Data
    let audioData = try Data(contentsOf: fileURL)

    // 2. Convert to base64
    let base64String = audioData.base64EncodedString()

    // 3. Create data URL
    return "data:audio/m4a;base64,\(base64String)"
}
```

**C. Integration in Onboarding**
```swift
// When voice step completes:
let recording = try await AudioRecordingService.shared.stopRecording()
let base64DataURL = try await convertAudioToBase64DataURL(fileURL: recording.fileURL)

let response = OnboardingResponseData(
    type: "voice",
    value: base64DataURL, // ← Send this to backend
    timestamp: ISO8601DateFormatter().string(from: Date()),
    voiceUri: recording.fileURL.absoluteString,
    duration: recording.duration,
    audioFileSize: recording.fileURL.fileSize,
    audioFormat: "m4a"
)

// Save to local storage
OnboardingDataPush.shared.saveProgress(data)
```

### Why Base64 Data URLs?
- ✅ Portable: Works across devices/restarts
- ✅ Self-contained: No broken file:// references
- ✅ Backend-ready: Can be directly processed
- ❌ Large: ~1.33x bigger than raw file
- But acceptable for onboarding (one-time upload)

**Priority:** 🔴 CRITICAL (blocks onboarding completion)

---

## 📞 **2. VOIP PUSH NOTIFICATIONS**

### What RN App Has:

**Custom Native Module** (`nrn/modules/expo-voip-push-token-v2/`)
```swift
// ios/ExpoVoipPushTokenModule.swift
import PushKit

@objc(ExpoVoipPushTokenModule)
class ExpoVoipPushTokenModule: Module {
    func requestVoipToken() {
        let voipRegistry = PKPushRegistry(queue: nil)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }

    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        let token = credentials.token.map { String(format: "%02x", $0) }.joined()
        // Send to JS layer
        sendEvent("voipToken", ["token": token])
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        // Show call UI
        sendEvent("voipPush", payload.dictionaryPayload)
    }
}
```

**JS Hook** (`nrn/hooks/voip/useVoipListener.ts`)
```typescript
export function useVoipListener() {
    const [voipToken, setVoipToken] = useState<string | null>(null);

    useEffect(() => {
        // Listen for token
        const tokenSub = ExpoVoipPushToken.addListener('voipToken', (event) => {
            setVoipToken(event.token);
            // Send to backend
            api.post('/token-init-push', { voipToken: event.token });
        });

        // Listen for incoming calls
        const pushSub = ExpoVoipPushToken.addListener('voipPush', (payload) => {
            // Show call screen
            handleIncomingCall(payload);
        });

        // Request token on mount
        ExpoVoipPushToken.requestVoipToken();

        return () => {
            tokenSub.remove();
            pushSub.remove();
        };
    }, []);

    return { voipToken, isListening: true };
}
```

### What We Need:

**A. PushKit Integration** (`VOIPManager.swift`)
```swift
import PushKit

class VOIPManager: NSObject, PKPushRegistryDelegate, ObservableObject {
    static let shared = VOIPManager()

    @Published var voipToken: String?
    private let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)

    func registerForVOIP() {
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
    }

    // Token received
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        let token = credentials.token.map { String(format: "%02x", $0) }.joined()
        voipToken = token

        // Send to backend
        Task {
            try? await APIService.shared.registerVOIPToken(request: VOIPTokenRequest(
                userId: AuthService.shared.user?.id ?? "",
                voipToken: token,
                platform: "ios"
            ))
        }
    }

    // Incoming call received
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        handleIncomingVOIPCall(payload: payload.dictionaryPayload)
        completion()
    }

    private func handleIncomingVOIPCall(payload: [AnyHashable: Any]) {
        // Show CallKit UI
        CallKitManager.shared.reportIncomingCall(
            uuid: UUID(),
            handle: "Big Bruh",
            hasVideo: false
        )
    }
}
```

**B. Integration in AppDelegate**
```swift
// In bigbruhhApp.swift or AppDelegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Register for VOIP
    VOIPManager.shared.registerForVOIP()
    return true
}
```

**Priority:** 🔴 CRITICAL (required for calls)

---

## 📱 **3. CALLKIT INTEGRATION**

### What RN App Doesn't Have:
- ❌ No CallKit (just shows in-app call screen)
- Uses basic notification-like UI

### What Swift Should Have (Native iOS Experience):

**CallKitManager.swift**
```swift
import CallKit

class CallKitManager: NSObject, ObservableObject {
    static let shared = CallKitManager()

    private let callController = CXCallController()
    private let provider: CXProvider

    override init() {
        let config = CXProviderConfiguration(localizedName: "Big Bruh")
        config.supportsVideo = false
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.generic]

        provider = CXProvider(configuration: config)
        super.init()
        provider.setDelegate(self, queue: nil)
    }

    // Report incoming call
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        update.hasVideo = hasVideo
        update.localizedCallerName = "Big Bruh Accountability"

        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                print("❌ CallKit error: \(error)")
            }
        }
    }

    // Start outgoing call
    func startCall(handle: String, videoEnabled: Bool = false) {
        let uuid = UUID()
        let handle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        startCallAction.isVideo = videoEnabled

        let transaction = CXTransaction(action: startCallAction)
        callController.request(transaction) { error in
            if let error = error {
                print("❌ Start call error: \(error)")
            }
        }
    }

    // End call
    func endCall(uuid: UUID) {
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)

        callController.request(transaction) { error in
            if let error = error {
                print("❌ End call error: \(error)")
            }
        }
    }
}

extension CallKitManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // Handle reset
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // User answered call
        // → Connect to 11Labs
        // → Show call screen
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Call ended
        action.fulfill()
    }
}
```

**Priority:** 🟡 IMPORTANT (better UX than RN app)

---

## 🤖 **4. 11LABS CONVERSATION API**

### What RN App Has:

**11Labs React Native SDK** (`nrn/components/11labs/ConvAIAgent.tsx`)
```typescript
import { useConversation } from "@elevenlabs/react-native";

const ConvAIAgent = ({ agentId, onTranscript }) => {
    const conversation = useConversation();

    // Start conversation
    const startCall = async () => {
        // Configure audio session for background
        await configureIOSAudioSession();

        // Get call config from backend
        const config = await api.post(`/call/${userId}/morning`);

        // Start 11Labs conversation
        await conversation.startSession({
            agentId: config.agentId,
            // ... other config
        });

        // Register client tools
        registerClientTools();
    };

    // Listen for events
    useEffect(() => {
        conversation.on('message', (msg) => {
            console.log('AI:', msg);
        });

        conversation.on('transcript', (text) => {
            onTranscript(text);
        });

        return () => conversation.endSession();
    }, []);

    return <CallUI />;
};
```

### What We Need:

**Option 1: Swift SDK (if exists)**
```swift
import ElevenLabs // Check if iOS SDK exists

class ElevenLabsService {
    func startConversation(agentId: String, config: CallConfig) async throws {
        // Use official SDK
    }
}
```

**Option 2: REST API + WebSocket (if no SDK)**
```swift
class ElevenLabsService {
    private var webSocket: URLSessionWebSocketTask?

    func startConversation(agentId: String) async throws {
        // 1. Get signed URL from 11Labs
        let url = URL(string: "https://api.elevenlabs.io/v1/convai/conversation")!

        // 2. Connect WebSocket
        webSocket = URLSession.shared.webSocketTask(with: url)
        webSocket?.resume()

        // 3. Send audio chunks
        // 4. Receive AI responses
    }

    func sendAudioChunk(_ data: Data) async throws {
        let message = URLSessionWebSocketTask.Message.data(data)
        try await webSocket?.send(message)
    }

    func listenForResponses() async throws {
        guard let webSocket = webSocket else { return }

        while true {
            let message = try await webSocket.receive()
            // Handle AI response
        }
    }
}
```

**Priority:** 🔴 CRITICAL (core feature)

---

## 🎧 **5. BACKGROUND AUDIO HANDLING**

### What RN App Has:

```typescript
// nrn/components/11labs/ConvAIAgent.tsx
async function configureIOSAudioSession() {
    const ExpoAudio = require("expo-audio");
    await ExpoAudio.AudioMode.setAudioModeAsync({
        allowsRecordingIOS: true,
        staysActiveInBackground: true, // ← KEY!
        interruptionModeIOS: ExpoAudio.AudioMode.INTERRUPTION_MODE_IOS_DO_NOT_MIX,
        playsInSilentModeIOS: true,
    });
}
```

### What We Need:

**AudioSessionManager.swift**
```swift
import AVFoundation

class AudioSessionManager {
    static func configureForVOIPCall() throws {
        let session = AVAudioSession.sharedInstance()

        try session.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.allowBluetooth, .defaultToSpeaker]
        )

        try session.setActive(true)
    }

    static func enableBackgroundAudio() {
        // Requires: Info.plist → UIBackgroundModes → audio
        // Already configured if you have VoIP background mode
    }
}
```

**Info.plist**
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
</array>
```

**Priority:** 🟡 IMPORTANT (calls must work in background)

---

## 💀 **6. BRUTAL REALITY SYSTEM**

### What RN App Has:

**BrutalRealityProvider** (`nrn/contexts/BrutalRealityProvider.tsx`)
```typescript
// Checks AsyncStorage flags:
// - "expecting_fake_call" → User declined call, expecting shame
// - "trigger_brutal_reality" → Show brutal review on next open

const BrutalRealityProvider = ({ children }) => {
    const [showBrutalReality, setShowBrutalReality] = useState(false);
    const [todayReview, setTodayReview] = useState(null);

    useEffect(() => {
        // Check if brutal reality should trigger
        const flag = await AsyncStorage.getItem("trigger_brutal_reality");
        if (flag) {
            // Load brutal review from API
            const review = await api.get("/api/brutal-reality/today");
            setTodayReview(review);
            setShowBrutalReality(true);
        }
    }, []);

    return (
        <>
            {children}
            {showBrutalReality && <BrutalRealityOverlay review={todayReview} />}
        </>
    );
};
```

**Backend Sets Flags When:**
- User declines call
- User misses call
- User breaks promise

### What We Need:

**BrutalRealityService.swift**
```swift
class BrutalRealityService: ObservableObject {
    @Published var showBrutalReality: Bool = false
    @Published var todayReview: BrutalReview?

    func checkForBrutalRealityTrigger() async {
        // Check UserDefaults for flag
        if let flag = UserDefaults.standard.string(forKey: "trigger_brutal_reality") {
            // Load review from API
            let response = try? await APIService.shared.get("/api/brutal-reality/today")
            if let review = response?.data {
                todayReview = review
                showBrutalReality = true
                UserDefaults.standard.removeObject(forKey: "trigger_brutal_reality")
            }
        }
    }
}

struct BrutalReview: Codable {
    let id: String
    let brutalParagraph: String
    let psychologicalImpactScore: Int
    let dominantEmotion: String
    let patternIdentified: String
}
```

**BrutalRealityOverlay.swift** (full-screen shame modal)
```swift
struct BrutalRealityOverlay: View {
    let review: BrutalReview
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("THE BRUTAL TRUTH")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.red)

                Text(review.brutalParagraph)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Impact Score: \(review.psychologicalImpactScore)/10")
                    .foregroundColor(.red)

                Button("I UNDERSTAND") {
                    isPresented = false
                }
            }
        }
    }
}
```

**Priority:** 🟡 IMPORTANT (core psychological feature)

---

## 🔄 **7. ONBOARDING RETRY SERVICE**

### What RN App Has:

**OnboardingRetryService** (`nrn/services/OnboardingRetryService.ts`)
- Retries failed voice transcriptions
- Retries identity extraction if incomplete
- Uses debug endpoints: `/debug/onboarding/retry-transcription/:userId`

### What We Need:
- Can implement later as admin tool
- Not critical for user flow

**Priority:** 🟢 NICE-TO-HAVE

---

## 📊 **8. OTHER MISSING FEATURES**

### Analytics (PostHog)
**RN:** Full event tracking with PostHog
**Swift:** ❌ Not implemented
**Priority:** 🟢 NICE-TO-HAVE

### Settings Screen Full Functionality
**RN:** Complete settings with schedule editing, rules, etc.
**Swift:** ✅ ControlView exists, needs API connection
**Priority:** 🟡 IMPORTANT

### Promise Management UI
**RN:** Create, complete, reorder promises
**Swift:** ❌ No UI for promises
**Priority:** 🟡 IMPORTANT

### Celebration Screens
**RN:** Post-purchase celebration, secret plan reveal
**Swift:** ❌ Not implemented
**Priority:** 🟢 NICE-TO-HAVE

### Transcription Service
**RN:** Real-time transcription display during calls
**Swift:** ❌ Not implemented
**Priority:** 🟡 IMPORTANT

---

## 🎯 **IMPLEMENTATION PRIORITY ORDER**

### Phase 1: Make Onboarding Work (Week 1)
1. ✅ Onboarding Data Push (DONE)
2. ❌ **Audio Recording Service** (CRITICAL)
3. ❌ **Base64 Audio Conversion** (CRITICAL)
4. ❌ Test full onboarding → payment → push flow

### Phase 2: Enable Calls (Week 2)
5. ❌ **VOIP Push Notifications** (PushKit)
6. ❌ **CallKit Integration**
7. ❌ **11Labs Conversation API**
8. ❌ **Background Audio Handling**

### Phase 3: Complete Experience (Week 3)
9. ❌ Brutal Reality System
10. ❌ Settings Screen API Integration
11. ❌ Promise Management UI
12. ❌ Transcription Display

### Phase 4: Polish (Week 4)
13. ❌ Analytics Integration
14. ❌ Celebration Screens
15. ❌ Onboarding Retry Service

---

## 📝 **AUDIO HANDLING - DETAILED EXPLANATION**

### The Question: "How are we handling audios for pushing?"

**Answer:** We store them as base64 data URLs in local storage, then send to backend.

**WHY Base64 Data URLs?**

1. **Portability:** File paths (`file:///`) become invalid after app restart
2. **Self-contained:** Everything in one string, no external files
3. **Backend-ready:** Backend can immediately process without fetching files
4. **One-time upload:** Onboarding is uploaded once, size doesn't matter much

**WHY NOT just file paths?**

```swift
// ❌ BAD: Store file path
response.value = "file:///var/mobile/.../recording.m4a"

// Problem 1: Path might be invalid after restart
// Problem 2: File might be deleted by OS
// Problem 3: Backend can't access this file
// Problem 4: When pushing to backend, we'd need to upload file separately
```

**The Complete Audio Flow:**

```
1. User records voice in onboarding step
   ↓
2. Audio saved to temp file: file:///tmp/recording.m4a
   ↓
3. Read file as Data
   ↓
4. Convert to base64 string
   ↓
5. Create data URL: "data:audio/m4a;base64,AAA..."
   ↓
6. Store in UserDefaults as part of onboarding data
   ↓
7. When payment completes → push to backend
   ↓
8. Backend receives base64, extracts audio
   ↓
9. Backend uploads to R2 cloud storage
   ↓
10. Backend transcribes with Whisper API
   ↓
11. Backend uses for voice cloning
```

---

## ✅ **FINAL CHECKLIST**

### To Make App Fully Functional:

- [x] API Models
- [x] API Service
- [x] Auth Service
- [x] Network Monitor
- [x] Data Cache
- [x] Home Screen Data
- [x] Evidence Screen Data
- [x] Pull-to-Refresh
- [x] Onboarding Data Push
- [ ] **Audio Recording** ← START HERE
- [ ] **Base64 Conversion** ← THEN THIS
- [ ] **VOIP Push**
- [ ] **CallKit**
- [ ] **11Labs Integration**
- [ ] **Background Audio**
- [ ] Brutal Reality
- [ ] Settings Functionality
- [ ] Promise UI

**Current Completion:** ~60% of core features ✅
**To MVP:** Need items marked ❌ above

---

**Last Updated:** 2025-10-06
**Next Step:** Implement Audio Recording Service
