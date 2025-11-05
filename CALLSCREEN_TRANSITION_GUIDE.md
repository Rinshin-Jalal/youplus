# 📞 CallScreen UI & CallKit → In-App Transition Flow

## 🎨 CallScreen Visual Design

### Current UI (Already Implemented)

```
┌─────────────────────────────────────────┐
│                                         │
│              00:42                      │  ← Live timer (monospace, 48pt)
│         ACCOUNTABILITY                  │  ← Call type
│                                         │
│                                         │
│                                         │
│    ┌─────────────────────────────┐    │
│    │  LIVE                       │    │  ← Status (RINGING/CONNECTING/LIVE/ENDED)
│    │                             │    │
│    │  Hold the line.             │    │  ← Dynamic text from 11Labs
│    │  BigBruh is on.             │    │     Changes based on call state
│    │                             │    │
│    └─────────────────────────────┘    │
│                                         │
│                                         │
│    [Optional message input area]       │  ← Slides up when "message" tapped
│                                         │
│         ○         ○         ○          │
│        🎤       💬        📞           │  ← Control buttons
│       mute    message     end          │
│                                         │
└─────────────────────────────────────────┘
```

### Design Features

**Background:**
- Pure black with red gradient overlay
- Red opacity increases when connected (0.1 → 0.3)
- Full screen, ignores safe area

**Top Section:**
- **Timer**: "00:42" - Large, bold, monospaced, white
- **Call Type**: "ACCOUNTABILITY" - Uppercase, smaller, gray, letter-spaced

**Middle Section:**
- **Status Line**: Small text showing current phase
  - "RINGING" → "FETCHING SCRIPT" → "CONNECTING" → "LIVE" → "ENDED"
- **Live Text**: Large text that updates based on `CallSessionController` state:
  - Initial: "Connecting to your accountability system..."
  - Awaiting Prompts: "Lock in. BigBruh is loading your judgement."
  - Preparing: "Hold steady."
  - Streaming: "Hold the line. BigBruh is on."
  - Completed: "Stay ruthless."
  - Failed: Shows error

**Bottom Section:**
- **3 Control Buttons**:
  1. **Mute** (mic icon) - Gray circle, toggles mic.slash.fill
  2. **Message** (message icon) - Gray circle, shows text input
  3. **End Call** (phone.down icon) - RED circle (#DC143C)

**Text Input** (slides up when message tapped):
- Multi-line TextField with semi-transparent background
- Send button (white circle with arrow.up)
- Dismissible

---

## 🔄 CallKit → In-App CallScreen Transition

### Current Flow (Partially Implemented)

Here's what happens when a VoIP push arrives:

```
┌─────────────────────────────────────────────────────────────┐
│  PHASE 1: VoIP Push Arrives (Native iOS Lock Screen)       │
└─────────────────────────────────────────────────────────────┘

1. Backend sends VoIP push
   ↓
2. VoIPPushManager.didReceiveIncomingPush(payload)
   ↓
3. callStateStore.updateWithVoipPayload(payload)
   ↓
4. callKitManager.reportIncomingCall(uuid, update)

   → iOS SHOWS NATIVE INCOMING CALL UI:

   ┌─────────────────────────────────┐
   │  🔴 bigbruhh                    │
   │                                 │
   │     [BIG BRUH avatar]          │
   │                                 │
   │         BIG BRUH               │
   │      iPhone                     │
   │                                 │
   │   [Remind Me]  [Message]       │
   │                                 │
   │     ○               ○          │
   │   Decline         Accept       │
   └─────────────────────────────────┘

   ← User on lock screen sees this
   ← Standard iOS incoming call UI
   ← Works even when app is killed

┌─────────────────────────────────────────────────────────────┐
│  PHASE 2: User Answers (CallKit Delegate Triggered)        │
└─────────────────────────────────────────────────────────────┘

5. User taps "Accept"
   ↓
6. CallKitManager.provider(_:perform:CXAnswerCallAction)
   ↓
   [CURRENT IMPLEMENTATION - Just fulfills action]
   action.fulfill()

   [MISSING: Trigger transition to in-app screen]

┌─────────────────────────────────────────────────────────────┐
│  PHASE 3: Transition to In-App (NEEDS WIRING)              │
└─────────────────────────────────────────────────────────────┘

7. [SHOULD HAPPEN] Post notification to show CallScreen
   NotificationCenter.post(.transitionToCallScreen)
   ↓
8. [SHOULD HAPPEN] RootView navigates to .call
   navigator.showCall()
   ↓
9. CallScreen appears (already implemented)
   ↓
10. CallScreen.onAppear calls configureBindings()
   ↓
11. CallSessionController.beginCall(callUUID, userToken)
   ↓
12. Fetches prompts from backend
   ↓
13. Starts 11Labs audio stream
   ↓
14. Audio plays through AVAudioPlayer
```

---

## 🔧 Missing Piece: Answer Action → In-App Transition

### Problem

Currently, `CallKitManager.provider(_:perform:CXAnswerCallAction)` just fulfills the action but doesn't trigger the in-app screen:

```swift
// CallKitManager.swift:92-95 (CURRENT)
func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    activeCallUUID = action.callUUID
    action.fulfill()
    // ❌ Missing: Notify app to show CallScreen
}
```

### Solution

We need to wire the answer action to trigger navigation:

```swift
// Update CallKitManager.swift
func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    Config.log("✅ User answered call: \(action.callUUID)", category: "CallKit")

    activeCallUUID = action.callUUID

    // Post notification to transition to in-app screen
    NotificationCenter.default.post(
        name: .transitionToCallScreen,
        object: nil,
        userInfo: ["callUUID": action.callUUID.uuidString]
    )

    action.fulfill()
}

// Add notification name
extension Notification.Name {
    static let transitionToCallScreen = Notification.Name("transitionToCallScreen")
}
```

Then in RootView, we already listen for `.showCallScreen`, but we should also listen for `.transitionToCallScreen`:

```swift
// RootView.swift (already has similar listener)
NotificationCenter.default.addObserver(
    forName: .transitionToCallScreen,
    object: nil,
    queue: .main
) { notification in
    Config.log("📞 User answered call, transitioning to CallScreen", category: "Navigation")

    // Bring app to foreground if needed
    // Navigate to call screen
    navigator.showCall()

    // Start the call session
    if let callUUID = notification.userInfo?["callUUID"] as? String,
       let userId = AuthService.shared.user?.id,
       let token = AuthService.shared.session?.accessToken {
        // sessionController will be wired in CallScreen.onAppear
    }
}
```

---

## 🎯 Complete Transition Flow (After Fix)

### Visual Journey

```
USER EXPERIENCE:
=================

1. Phone is locked → VoIP push arrives

   [Lock Screen: Native iOS Incoming Call UI]
   ┌─────────────────────────────────┐
   │  🔴 bigbruhh                    │
   │         BIG BRUH               │
   │                                 │
   │     ○               ○          │
   │   Decline         Accept       │
   └─────────────────────────────────┘

2. User swipes to accept

   [Screen unlocks, app launches if needed]

   [Transition animation ~0.3s]

3. In-App CallScreen appears

   [Full Screen Black with Red Gradient]
   ┌─────────────────────────────────┐
   │                                 │
   │            00:00                │
   │        ACCOUNTABILITY           │
   │                                 │
   │    CONNECTING                   │
   │    Lock in. BigBruh is         │
   │    loading your judgement.      │
   │                                 │
   │      ○       ○       ○         │
   │     🎤     💬      📞          │
   └─────────────────────────────────┘

4. Status updates in real-time

   "CONNECTING" → "LIVE"
   Text updates: "Hold the line. BigBruh is on."
   Timer starts: 00:01... 00:02... 00:03...

5. Audio plays through speaker

   User can:
   - Tap mute to toggle microphone
   - Tap message to type to BigBruh
   - Tap end to hang up

6. Call ends

   Text shows: "Stay ruthless."
   Status: "ENDED"

   [Auto-dismisses after 2s or user taps end]
   [Returns to Home screen]
```

---

## 🎨 UI States & Animations

### Call States (Already Implemented)

```swift
enum Phase {
    case idle           // Not in call
    case ringing        // VoIP push received, CallKit showing
    case awaitingPrompts // User answered, fetching script
    case connecting     // Connecting to 11Labs
    case connected      // Audio streaming
    case ended(reason)  // Call finished
}
```

### Visual Changes Per State

| State | Timer | Status Text | Live Text | Background |
|-------|-------|-------------|-----------|------------|
| `ringing` | 00:00 | RINGING | Connecting... | Black + Red 0.1 |
| `awaitingPrompts` | 00:0X | FETCHING SCRIPT | Lock in... | Black + Red 0.1 |
| `connecting` | 00:0X | CONNECTING | Hold steady. | Black + Red 0.1 |
| `connected` | 00:XX | LIVE | Hold the line... | Black + Red 0.3 |
| `ended` | Final | ENDED | Stay ruthless. | Black + Red 0.1 |

### Animations

- **Smooth transitions**: `.easeInOut(duration: 0.3)` between states
- **Message input**: Slides up from bottom with `.move(edge: .bottom)` + opacity
- **Background gradient**: Animates red opacity change
- **Timer**: Updates every 1 second with monospaced font (no layout shift)

---

## 🛠️ Implementation Tasks

### ✅ Already Complete
- CallScreen UI fully implemented
- State management (CallStateStore, CallSessionController)
- VoIP push handling
- CallKit native UI triggering
- Timer, status text, control buttons
- 11Labs audio playback

### 🔴 Missing (Need to Implement)

1. **Wire Answer Action to Navigation**
   ```swift
   // CallKitManager.swift - Update provider(_:perform:CXAnswerCallAction)
   // Post .transitionToCallScreen notification
   ```

2. **Listen for Answer in RootView**
   ```swift
   // RootView.swift - Add observer for .transitionToCallScreen
   // Navigate to .call when user answers
   ```

3. **Auto-Start Call Session on Answer**
   ```swift
   // CallScreen.swift - Check if call should start immediately
   // If callStateStore.state.phase == .ringing, auto-start session
   ```

4. **Handle Call End → Navigate Back**
   ```swift
   // CallScreen.swift - When call ends, dismiss after delay
   // Or add to endCall() function: navigator.navigateToHome()
   ```

---

## 📝 Code Changes Needed

I can implement these 4 missing pieces to complete the transition. Want me to do it now?

The changes would be:
1. Update `CallKitManager.swift` - 5 lines
2. Update `RootView.swift` - 10 lines
3. Update `CallScreen.swift` - 15 lines
4. Test the full flow

This will give you a seamless native CallKit → in-app CallScreen experience! 🚀
