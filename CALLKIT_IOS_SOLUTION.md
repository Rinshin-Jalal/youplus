# 🔔 CallKit → In-App Transition (iOS-Compatible Solution)

## 🚫 iOS Limitation

**You CANNOT automatically transition from CallKit to in-app UI on iOS.**

Even major apps like WhatsApp, Telegram, FaceTime cannot do this. When user answers a CallKit call, iOS keeps them in the native CallKit interface.

---

## ✅ iOS-Compatible Solution

### Two Approaches:

#### **Approach 1: Local Notification (Recommended)**

When user answers the CallKit call, show a notification they can tap to open the app:

```
┌─────────────────────────────────────┐
│  🔴 BIG BRUH                        │
│  Your accountability call is live   │
│                                     │
│  [Tap to view in app]               │
└─────────────────────────────────────┘
```

User taps → App opens → Shows CallScreen

#### **Approach 2: Auto-Detect When App Opens**

When user manually opens app during active call, automatically show CallScreen.

---

## 🛠️ Implementation: Local Notification

### Step 1: Request Notification Permission

```swift
// AppDelegate.swift - Add to application(didFinishLaunchingWithOptions:)

func application(_ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // Request notification permission
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            Config.log("✅ Notification permission granted", category: "Notifications")
        } else {
            Config.log("❌ Notification permission denied: \(error?.localizedDescription ?? "unknown")", category: "Notifications")
        }
    }

    // Set notification delegate
    UNUserNotificationCenter.current().delegate = self

    // ... rest of existing code
    voipManager.delegate = self
    callStateStore.bindCallKitManager(callKitManager)

    return true
}
```

### Step 2: Show Notification When Call Answered

```swift
// AppDelegate.swift - Add to VoIPPushManagerDelegate

extension AppDelegate: VoIPPushManagerDelegate {
    // ... existing didUpdatePushToken and didInvalidateWithError ...

    func voipPushManager(_ manager: VoIPPushManager,
                        didReceiveIncomingPush payload: PKPushPayload,
                        type: PKPushType) {
        Config.log("📞 Incoming VoIP push received!", category: "VoIP")

        // Update call state
        callStateStore.updateWithVoipPayload(payload)

        guard let uuid = callStateStore.state.uuid else { return }

        // Show CallKit UI
        let update = callKitManager.configureDefaultUpdate(
            displayName: "BIG BRUH",
            hasVideo: false
        )
        callKitManager.reportIncomingCall(uuid: uuid, update: update)

        // ✅ NEW: Schedule notification for when user answers
        scheduleCallActiveNotification(callUUID: uuid)
    }
}

// MARK: - Local Notification
extension AppDelegate {
    func scheduleCallActiveNotification(callUUID: UUID) {
        let content = UNMutableNotificationContent()
        content.title = "BIG BRUH"
        content.body = "Your accountability call is live. Tap to view in app."
        content.sound = nil // No sound, call is already active
        content.categoryIdentifier = "ACTIVE_CALL"
        content.userInfo = ["callUUID": callUUID.uuidString]

        // Trigger after 2 seconds (gives user time to answer)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

        let request = UNNotificationRequest(
            identifier: "active_call_\(callUUID.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Config.log("❌ Failed to schedule notification: \(error)", category: "Notifications")
            } else {
                Config.log("✅ Scheduled active call notification", category: "Notifications")
            }
        }
    }
}

// MARK: - Notification Delegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {

        if response.notification.request.content.categoryIdentifier == "ACTIVE_CALL" {
            Config.log("📲 User tapped active call notification", category: "Notifications")

            // Navigate to call screen
            NotificationCenter.default.post(
                name: .showCallScreen,
                object: nil,
                userInfo: response.notification.request.content.userInfo
            )
        }

        completionHandler()
    }

    // Show notification even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        if notification.request.content.categoryIdentifier == "ACTIVE_CALL" {
            // Show banner even when app is open
            completionHandler([.banner, .list])
        } else {
            completionHandler([.banner, .list, .sound])
        }
    }
}
```

### Step 3: Import UserNotifications

```swift
// AppDelegate.swift - Add import at top

import UIKit
import PushKit
import UserNotifications  // ← Add this
```

---

## 🎯 User Flow (After Implementation)

### Scenario 1: App in Background/Killed

```
1. VoIP push arrives
   ↓
2. CallKit native UI shows on lock screen
   ┌─────────────────────┐
   │  🔴 bigbruhh        │
   │    BIG BRUH         │
   │   ○         ○       │
   │ Decline   Accept    │
   └─────────────────────┘
   ↓
3. User taps "Accept"
   ↓
4. Call connects via CallKit (audio works)
   User stays in CallKit interface
   ↓
5. [2 seconds later] Notification appears
   ┌─────────────────────────────────┐
   │  🔴 BIG BRUH                    │
   │  Your accountability call is    │
   │  live. Tap to view in app.      │
   └─────────────────────────────────┘
   ↓
6. User taps notification
   ↓
7. App opens → RootView receives notification
   ↓
8. navigator.showCall()
   ↓
9. CallScreen appears with live call UI
   Timer running, audio playing, controls active
```

### Scenario 2: User Opens App Manually During Call

```
1. Call is active (CallKit handling audio)
   ↓
2. User swipes up, opens BigBruh app manually
   ↓
3. App detects active call
   ↓
4. Auto-navigate to CallScreen
```

**Need to implement:** Auto-detection in RootView

```swift
// RootView.swift - Add to onAppear

.onAppear {
    determineInitialScreen()

    // Listen for notification taps
    NotificationCenter.default.addObserver(
        forName: .showCallScreen,
        object: nil,
        queue: .main
    ) { notification in
        navigator.showCall()
    }

    // ✅ NEW: Auto-detect active call when app opens
    checkForActiveCall()
}

private func checkForActiveCall() {
    // Check if CallKit has an active call
    if let activeUUID = (UIApplication.shared.delegate as? AppDelegate)?.callKitManager.activeCallUUID {
        Config.log("📞 Active call detected, showing CallScreen", category: "Navigation")
        navigator.showCall()
    }
}
```

---

## 🎨 Alternative: Custom Notification Action

You can add a custom action button to the notification:

```swift
// AppDelegate.swift - Add to application(didFinishLaunchingWithOptions:)

func setupNotificationCategories() {
    let openAction = UNNotificationAction(
        identifier: "OPEN_CALL",
        title: "View Call",
        options: [.foreground]
    )

    let category = UNNotificationCategory(
        identifier: "ACTIVE_CALL",
        actions: [openAction],
        intentIdentifiers: [],
        options: []
    )

    UNUserNotificationCenter.current().setNotificationCategories([category])
}

// Call in didFinishLaunchingWithOptions:
setupNotificationCategories()
```

This gives:
```
┌─────────────────────────────────┐
│  🔴 BIG BRUH                    │
│  Your accountability call is    │
│  live. Tap to view in app.      │
│                                 │
│  [View Call]                    │
└─────────────────────────────────┘
```

---

## 📊 Comparison of Approaches

| Approach | Pros | Cons |
|----------|------|------|
| **Local Notification** | - Works from any state<br>- Clear call-to-action<br>- iOS native pattern | - Requires tap from user<br>- 2-second delay |
| **Auto-detect on App Open** | - Seamless if user opens app<br>- No notification needed | - User must manually open app<br>- May not open app |
| **Both Combined** | - Best UX<br>- Covers all scenarios | - Slightly more code |

**Recommendation:** Implement both! Notification for proactive prompt, auto-detect as fallback.

---

## ✅ What This Achieves

1. **CallKit handles the call** - Native iOS experience, works on lock screen
2. **Audio works** - CallSessionController plays through CallKit
3. **User gets prompted** - Notification suggests opening app
4. **In-app experience** - When they tap, shows your beautiful CallScreen UI
5. **Fallback** - If they open app manually, auto-detects and shows CallScreen

---

## 🚀 Implementation Checklist

- [ ] Add `import UserNotifications` to AppDelegate
- [ ] Request notification permission in `didFinishLaunchingWithOptions`
- [ ] Implement `UNUserNotificationCenterDelegate`
- [ ] Create `scheduleCallActiveNotification()` method
- [ ] Handle notification tap → navigate to CallScreen
- [ ] Add `checkForActiveCall()` to RootView
- [ ] Test: Answer call → See notification → Tap → Opens CallScreen
- [ ] Test: Answer call → Open app manually → Auto-shows CallScreen

---

## 📝 Technical Notes

**Why 2-second delay?**
- Gives user time to answer the call
- Ensures CallKit audio is established
- Avoids notification appearing before answer

**Why show notification in foreground?**
- User might already have app open when call arrives
- Banner notification is less intrusive than full-screen navigation
- User maintains control

**CallKit audio vs AVAudioPlayer:**
- CallKit handles the actual VoIP call connection
- Your AVAudioPlayer plays the 11Labs generated audio through the call
- Both work together seamlessly

---

**This is the iOS-correct way!** Even Apple's own apps work this way. 🎯
