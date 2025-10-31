# BigBruh MVP - VoIP CallKit Setup Guide

## 🎯 Overview

This guide covers setting up **VoIP calls with CallKit and ElevenLabs** for the BigBruh MVP. The app will receive calls in background, play AI-generated audio, and handle user responses.

## 📋 Prerequisites

- Apple Developer Account ($99/year)
- Xcode 15+
- Physical iOS device (VoIP doesn't work in simulator)
- ElevenLabs API key
- Backend deployed (Cloudflare Workers)

## 🔧 iOS Setup

### 1. Enable Background Modes

In Xcode, go to your app target → **Signing & Capabilities** → **+ Capability** → add:

- **Background Modes**
  - ✅ **Audio, AirPlay, and Picture in Picture**
  - ✅ **Voice over IP**
  - ✅ **Background app refresh**
  - ✅ **Remote notifications**

- **Push Notifications**
  - ✅ Enable push notifications

### 2. Info.plist Configuration

Add these keys to your `Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>voip</string>
    <string>audio</string>
    <string>background-processing</string>
    <string>remote-notification</string>
</array>

<key>NSMicrophoneUsageDescription</key>
<string>BigBruh needs microphone access for voice recording during onboarding and calls.</string>

<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>armv7</string>
</array>
```

### 3. Entitlements File

Create `BigBruhMVP.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>aps-environment</key>
    <string>development</string>
    <key>com.apple.developer.voip-background-mode</key>
    <true/>
    <key>com.apple.developer.networking.wifi-info</key>
    <true/>
</dict>
</plist>
```

## 📱 Push Notifications Setup

### 1. Apple Push Notification Service (APNs)

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. **Certificates, Identifiers & Profiles** → **Identifiers**
3. Select your app bundle ID
4. Enable **Push Notifications**
5. Create **VoIP Services Certificate**
6. Download and install in Keychain

### 2. VoIP Push Token Registration

The app automatically registers for VoIP pushes on launch:

```swift
// In VoIPService.swift
func registerForVoIPPushes() {
    voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
    voipRegistry?.delegate = self
    voipRegistry?.desiredPushTypes = [.voIP]
}
```

### 3. Backend Push Configuration

Update your backend to send VoIP pushes:

```typescript
// In voip.ts route
const apnsPayload = {
    aps: {
        'content-available': 1,
        'push-type': 'voip',
        'sound-1': 'default'
    },
    'call-id': callId,
    'handle': 'BigBruh',
    'script': script
};
```

## 🎙️ CallKit Integration

### 1. Call Provider Configuration

```swift
// In VoIPService.swift
static var providerConfiguration: CXProviderConfiguration {
    let configuration = CXProviderConfiguration(localizedName: "BigBruh")
    configuration.maximumCallGroups = 1
    configuration.maximumCallsPerCallGroup = 1
    configuration.supportsVideo = false
    configuration.supportedHandleTypes = [.generic]
    configuration.iconTemplateImageData = UIImage(named: "call_icon")?.pngData()
    return configuration
}
```

### 2. Incoming Call Handling

```swift
func reportIncomingCall(uuid: UUID, handle: String) {
    let callHandle = CXHandle(type: .generic, value: handle)
    let callUpdate = CXCallUpdate()
    
    callUpdate.remoteHandle = callHandle
    callUpdate.supportsHolding = false
    callUpdate.supportsGrouping = false
    callUpdate.supportsUngrouping = false
    callUpdate.supportsDTMF = false
    callUpdate.hasVideo = false
    
    provider.reportNewIncomingCall(with: uuid, update: callUpdate)
}
```

### 3. Call State Management

```swift
func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    // Configure audio for call
    configureAudioSessionForCall()
    
    // Update call state
    activeCall?.state = .active
    
    // Start playing ElevenLabs audio
    playCallAudio()
    
    action.fulfill()
}
```

## 🔊 ElevenLabs Audio Integration

### 1. Audio Session Configuration

```swift
private func configureAudioSessionForCall() {
    do {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .voiceChat, options: [
            .defaultToSpeaker,
            .allowBluetooth,
            .allowAirPlay
        ])
        try session.setActive(true)
    } catch {
        Config.logError(error, category: "VoIP")
    }
}
```

### 2. Audio Playback with CallKit

```swift
func playElevenLabsAudio(audioData: Data, uuid: UUID) {
    do {
        audioPlayer = try AVAudioPlayer(data: audioData)
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
        
        // Configure audio session for call
        configureAudioSessionForCall()
        
        // Start playing
        audioPlayer?.play()
        
        // Update call state
        activeCall?.state = .active
        
    } catch {
        Config.logError(error, category: "VoIP")
    }
}
```

### 3. Streaming Audio (Optional)

For real-time audio streaming:

```swift
func generateStreamingSpeech(
    text: String,
    onAudioChunk: @escaping (Data) -> Void
) {
    // Use ElevenLabs streaming endpoint
    // Handle audio chunks as they arrive
    // Feed chunks to AVAudioEngine for playback
}
```

## 🚀 Testing VoIP Calls

### 1. On Physical Device

VoIP calls **only work on physical devices**, not simulators.

### 2. Test Call Flow

```swift
// Test call in CallView.swift
private func testCall() {
    let uuid = UUID()
    let testScript = "This is a test call from BigBruh. Are you ready?"
    
    let call = voipService.createCall(
        uuid: uuid,
        handle: "BigBruh Test",
        script: testScript
    )
    
    voipService.startCall(uuid: uuid, handle: "BigBruh Test") { success in
        if success {
            // Simulate audio after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.simulateTestAudio(uuid: uuid)
            }
        }
    }
}
```

### 3. Background Testing

1. Start a test call
2. Put app in background (home button)
3. Verify call continues via CallKit UI
4. Verify audio plays in background
5. Test answering/ending from lock screen

## 📊 Call Flow Diagram

```
Backend (Cloudflare Workers)
    ↓ (VoIP Push)
APNs (Apple Push Service)
    ↓ (VoIP Push)
iOS App (Background)
    ↓ (CallKit)
Call UI (System)
    ↓ (User answers)
App (Foreground)
    ↓ (ElevenLabs API)
ElevenLabs (TTS)
    ↓ (Audio stream)
App (Audio playback)
    ↓ (User response)
Backend (Save response)
```

## 🔧 Troubleshooting

### Common Issues

1. **VoIP pushes not received**
   - Check APNs certificate is valid
   - Verify device token is registered
   - Ensure background modes are enabled

2. **Audio not playing in background**
   - Check audio session category
   - Verify background audio mode
   - Test with physical device

3. **CallKit UI not showing**
   - Verify provider configuration
   - Check incoming call reporting
   - Test with physical device

4. **ElevenLabs audio issues**
   - Verify API key is valid
   - Check audio format compatibility
   - Test with shorter scripts

### Debug Logging

Enable detailed logging:

```swift
// In Config.swift
static let enableDebugLogs = true
static let enableVoIPLogs = true

// In VoIPService.swift
Config.log("VoIP event: \(event)", category: "VoIP")
```

## 📋 Production Checklist

- [ ] Apple Developer account configured
- [ ] APNs VoIP certificate created
- [ ] Background modes enabled in Xcode
- [ ] Entitlements file configured
- [ ] Physical device testing completed
- [ ] Background call testing completed
- [ ] Lock screen call testing completed
- [ ] ElevenLabs audio integration working
- [ ] Push notification token registration working
- [ ] CallKit integration working
- [ ] Error handling implemented
- [ ] Production logging configured

## 🎯 Success Metrics

- **Call connection rate**: >95%
- **Background call success**: >90%
- **Audio playback quality**: Clear, no stuttering
- **CallKit UI responsiveness**: <1 second delay
- **Battery usage**: <5% per hour of calls

## 💡 Advanced Features

After basic VoIP setup:

1. **Custom call sounds**
2. **Call recording**
3. **Video calls (future)**
4. **SIP integration (future)**
5. **Multi-user conference calls (future)**

---

**VoIP calls are CRITICAL for BigBruh's core value proposition.** Users must receive calls they can't ignore, even when the app is closed. This setup ensures daily accountability calls work reliably in background.
