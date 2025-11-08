/**
 * AppDelegate LiveKit Extension
 * Routes incoming calls to LiveKit or ElevenLabs based on provider
 */

import Foundation
import PushKit

extension AppDelegate {
    /// Determine which call flow to use based on VoIP payload provider
    func routeIncomingCall(payload: PKPushPayload) {
        // Parse payload to detect provider
        guard let parsedPayload = VoIPPushManager.parsePayload(payload) else {
            Config.log("❌ Failed to parse VoIP payload", category: "AppDelegate+LiveKit")
            return
        }

        Config.log("📞 Routing call via \(parsedPayload.isLiveKit ? "LiveKit" : "ElevenLabs")", category: "AppDelegate+LiveKit")

        if parsedPayload.isLiveKit {
            // Route to LiveKit call flow
            routeToLiveKit(payload: parsedPayload)
        } else if parsedPayload.isElevenLabs {
            // Route to ElevenLabs call flow (legacy)
            routeToElevenLabs(payload: parsedPayload)
        } else {
            Config.log("❌ Unknown provider in VoIP payload", category: "AppDelegate+LiveKit")
        }
    }

    /// Route to LiveKit call flow
    private func routeToLiveKit(payload: VoIPPushPayload) {
        Config.log("🚀 Routing to LiveKit call", category: "AppDelegate+LiveKit")
        Config.log("   Room: \(payload.roomName ?? "unknown")", category: "AppDelegate+LiveKit")
        Config.log("   User: \(payload.userId)", category: "AppDelegate+LiveKit")

        // Store LiveKit-specific info in state
        callStateStore.state.provider = .livekit
        callStateStore.state.roomName = payload.roomName
        callStateStore.state.liveKitToken = payload.liveKitToken
        callStateStore.state.cartesiaVoiceId = payload.cartesiaVoiceId
        callStateStore.state.supermemoryUserId = payload.supermemoryUserId

        // Get LiveKit URL from config (should be set in environment/Config)
        let liveKitURL = Config.liveKitURL ?? "wss://livekit.example.com" // TODO: Set in Config

        // When user answers, start LiveKit connection
        // This will be triggered by CallScreen when user taps Answer button
        Config.log("✅ LiveKit call routed - ready for user to answer", category: "AppDelegate+LiveKit")
    }

    /// Route to ElevenLabs call flow (legacy)
    private func routeToElevenLabs(payload: VoIPPushPayload) {
        Config.log("📞 Routing to ElevenLabs call (legacy)", category: "AppDelegate+LiveKit")

        // Store ElevenLabs-specific info in state
        callStateStore.state.provider = .elevenlabs
        callStateStore.state.agentId = payload.agentId
        callStateStore.state.voiceId = payload.voiceId

        Config.log("✅ ElevenLabs call routed", category: "AppDelegate+LiveKit")
    }

    /// Start LiveKit call after user answers
    /// Called from CallScreen when user taps Answer
    func beginLiveKitCall() {
        guard callStateStore.state.provider == .livekit else {
            Config.log("❌ Not a LiveKit call", category: "AppDelegate+LiveKit")
            return
        }

        guard let roomName = callStateStore.state.roomName,
              let token = callStateStore.state.liveKitToken else {
            Config.log("❌ Missing LiveKit credentials", category: "AppDelegate+LiveKit")
            return
        }

        let liveKitURL = Config.liveKitURL ?? "wss://livekit.example.com"

        // Fetch prompts first
        Task {
            do {
                // Start streaming with LiveKit
                guard let callUUID = callStateStore.state.uuid?.uuidString else { return }

                // Update session controller to use LiveKit
                let deferredPromptResponse = DeferredPromptResponse(
                    prompts: .init(
                        systemPrompt: "You are a supportive AI assistant",
                        firstMessage: "Hi! How are you doing today?"
                    ),
                    cached: false,
                    agentId: "livekit-agent",
                    mood: callStateStore.state.mood ?? "supportive",
                    voiceId: callStateStore.state.cartesiaVoiceId
                )

                // Start LiveKit session
                sessionController.startLiveKitSession(
                    roomName: roomName,
                    token: token,
                    liveKitURL: liveKitURL,
                    prompts: deferredPromptResponse
                )

                Config.log("✅ LiveKit call started", category: "AppDelegate+LiveKit")
            } catch {
                Config.log("❌ Failed to start LiveKit call: \(error)", category: "AppDelegate+LiveKit")
            }
        }
    }

    /// End LiveKit call
    func endLiveKitCall() {
        if callStateStore.state.provider == .livekit {
            sessionController.endLiveKitSession()
            Config.log("✅ LiveKit call ended", category: "AppDelegate+LiveKit")
        }
    }
}

// MARK: - Config Extensions

extension Config {
    static var liveKitURL: String? {
        // TODO: Load from environment or config file
        // For now, can be set via environment variable
        return ProcessInfo.processInfo.environment["LIVEKIT_URL"]
    }
}
