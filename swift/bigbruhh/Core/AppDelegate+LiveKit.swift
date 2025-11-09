/**
 * AppDelegate LiveKit Extension
 * Routes incoming calls to LiveKit or ElevenLabs based on provider
 */

import Foundation
import PushKit
import Supabase
import Auth

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
        callStateStore.updateProvider(.livekit)
        callStateStore.updateRoomName(payload.roomName)
        callStateStore.updateLiveKitToken(payload.liveKitToken)
        callStateStore.updateCartesiaVoiceId(payload.cartesiaVoiceId)
        callStateStore.updateSupermemoryUserId(payload.supermemoryUserId)

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
        callStateStore.updateProvider(.elevenlabs)
        callStateStore.updateAgentId(payload.agentId)
        callStateStore.updateVoiceId(payload.voiceId)

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

        // Fetch prompts from backend (same as ElevenLabs flow)
        Task {
            do {
                guard let callUUID = callStateStore.state.uuid?.uuidString,
                      let session = SupabaseManager.shared.currentSession,
                      let baseURL = Config.backendURL else {
                    Config.log("❌ Missing call UUID, user session, or backend URL", category: "AppDelegate+LiveKit")
                    return
                }
                
                let userToken = session.accessToken

                // Fetch prompts from backend
                var request = URLRequest(url: URL(string: "\(baseURL)/voip/session/prompts")!)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
                request.httpBody = try JSONSerialization.data(withJSONObject: ["callUUID": callUUID])

                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "AppDelegate", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch prompts"])
                }

                let promptResponse = try JSONDecoder().decode(DeferredPromptResponse.self, from: data)

                // Start LiveKit session with fetched prompts
                sessionController.startLiveKitSession(
                    roomName: roomName,
                    token: token,
                    liveKitURL: liveKitURL,
                    prompts: promptResponse
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
