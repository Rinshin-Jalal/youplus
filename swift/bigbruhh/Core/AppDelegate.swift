//
//  AppDelegate.swift
//  bigbruhh
//
//  VoIP Push and CallKit lifecycle management
//

import UIKit
import PushKit

class AppDelegate: NSObject, UIApplicationDelegate {
    // Instantiate all call managers
    let voipManager = VoIPPushManager()
    let callKitManager = CallKitManager()
    let callStateStore = CallStateStore()
    let sessionController = CallSessionController()

    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Config.log("🚀 AppDelegate: App launching", category: "AppDelegate")

        // Wire VoIP delegate
        voipManager.delegate = self

        // Wire CallStateStore to CallKit
        callStateStore.bindCallKitManager(callKitManager)

        Config.log("✅ AppDelegate: VoIP and CallKit managers initialized", category: "AppDelegate")

        return true
    }
}

// MARK: - VoIP Push Handling
extension AppDelegate: VoIPPushManagerDelegate {
    func voipPushManager(_ manager: VoIPPushManager, didUpdatePushToken token: Data) {
        let tokenString = token.map { String(format: "%02x", $0) }.joined()
        Config.log("✅ VoIP Token Received: \(tokenString.prefix(20))...", category: "VoIP")

        // Save token locally
        UserDefaultsManager.set(tokenString, forKey: "voip_token")

        // Send to backend
        Task {
            guard let userId = AuthService.shared.user?.id else {
                Config.log("⚠️ Cannot register VoIP token: User not authenticated", category: "VoIP")
                return
            }

            do {
                _ = try await APIService.shared.registerVOIPToken(
                    request: VOIPTokenRequest(
                        userId: userId,
                        voipToken: tokenString,
                        platform: "ios"
                    )
                )
                Config.log("✅ VoIP token registered with backend", category: "VoIP")
            } catch {
                Config.log("❌ Failed to register VoIP token: \(error)", category: "VoIP")
            }
        }
    }

    func voipPushManager(_ manager: VoIPPushManager,
                        didReceiveIncomingPush payload: PKPushPayload,
                        type: PKPushType) {
        Config.log("📞 Incoming VoIP push received!", category: "VoIP")
        Config.log("📦 Payload: \(payload.dictionaryPayload)", category: "VoIP")

        // Update call state with payload
        callStateStore.updateWithVoipPayload(payload)

        // Show CallKit UI
        guard let uuid = callStateStore.state.uuid else {
            Config.log("❌ Cannot show CallKit: No UUID in payload", category: "VoIP")
            return
        }

        let update = callKitManager.configureDefaultUpdate(
            displayName: "BIG BRUH",
            hasVideo: false
        )
        callKitManager.reportIncomingCall(uuid: uuid, update: update)
        Config.log("✅ CallKit UI triggered for call: \(uuid)", category: "VoIP")
    }

    func voipPushManager(_ manager: VoIPPushManager, didInvalidateWithError error: Error?) {
        if let error = error {
            Config.log("❌ VoIP token invalidated: \(error.localizedDescription)", category: "VoIP")
        } else {
            Config.log("⚠️ VoIP token invalidated (no error)", category: "VoIP")
        }
    }
}
