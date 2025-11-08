/**
 * LiveKit Integration Extension for CallSessionController
 *
 * Adds support for:
 * - Real-time WebRTC audio via LiveKit
 * - Device tool commands via data channel
 * - Live conversation (replaces MP3 playback)
 *
 * Maintains backward compatibility with existing state machine
 */

import Foundation
import Combine
import AVFoundation

extension CallSessionController {
    /// Updated to support both ElevenLabs (legacy) and LiveKit (current)
    func startLiveKitSession(
        roomName: String,
        token: String,
        liveKitURL: String,
        prompts: DeferredPromptResponse
    ) {
        guard case .awaitingPrompts = state else { return }

        state = .preparing

        // Initialize LiveKit manager
        let liveKitManager = LiveKitManager()
        liveKitManager.delegate = self

        // Store reference for later
        self.liveKitManager = liveKitManager

        Task {
            do {
                try await liveKitManager.connect(
                    url: liveKitURL,
                    token: token,
                    roomName: roomName
                )

                // Connection successful - state updated via delegate
                print("✅ LiveKit session started")
            } catch {
                self.state = .failed(error)
                self.delegate?.callSessionController(self, didFailWith: error)
            }
        }
    }

    /// End LiveKit session properly
    func endLiveKitSession() {
        if let liveKitManager = liveKitManager {
            Task {
                await liveKitManager.disconnect()
            }
        }
        state = .completed
        delegate?.callSessionControllerDidFinish(self)
    }

    /// Toggle microphone during call
    func setMicrophoneEnabled(_ enabled: Bool) async throws {
        guard let liveKitManager = liveKitManager else {
            throw CallSessionError.invalidResponse
        }
        try await liveKitManager.setAudioEnabled(enabled)
    }

    /// Toggle speaker output
    func setSpeakerEnabled(_ enabled: Bool) throws {
        guard let liveKitManager = liveKitManager else {
            throw CallSessionError.invalidResponse
        }
        try liveKitManager.setSpeakerEnabled(enabled)
    }

    /// Execute a device tool command
    func executeDeviceTool(
        _ toolName: String,
        params: [String: Any] = [:]
    ) async throws -> [String: Any] {
        guard let liveKitManager = liveKitManager else {
            throw CallSessionError.invalidResponse
        }
        return try await liveKitManager.executeDeviceTool(toolName, params: params)
    }
}

// MARK: - LiveKit Manager Delegate

extension CallSessionController: LiveKitManagerDelegate {
    func liveKitManager(_ manager: LiveKitManager, didConnect to room: String) {
        // Connection successful - update state
        state = .streaming
        delegate?.callSessionControllerDidStart(self)
        print("📞 Call connected: \(room)")
    }

    func liveKitManager(_ manager: LiveKitManager, didDisconnect with error: Error?) {
        if let error = error {
            state = .failed(error)
            delegate?.callSessionController(self, didFailWith: error)
        } else {
            state = .completed
            delegate?.callSessionControllerDidFinish(self)
        }
    }

    func liveKitManager(_ manager: LiveKitManager, didReceiveDataChannelMessage message: Data) {
        // Parse incoming device tool response
        guard let json = try? JSONSerialization.jsonObject(with: message) as? [String: Any] else {
            return
        }

        print("📨 Device tool response: \(json)")
        // Handle response - could publish to @Published property for UI updates
    }

    func liveKitManager(_ manager: LiveKitManager, participantDidJoin participant: Participant) {
        let isAgent = participant.name?.contains("agent") ?? false
        if isAgent {
            print("🤖 Agent joined call")
        } else {
            print("👤 Participant joined: \(participant.identity)")
        }
    }

    func liveKitManager(_ manager: LiveKitManager, participantDidLeave participant: Participant) {
        let wasAgent = participant.name?.contains("agent") ?? false
        if wasAgent {
            print("🤖 Agent left - call ending")
            // Auto-end call if agent leaves
            endLiveKitSession()
        }
    }
}

// MARK: - Property for LiveKit Manager

extension CallSessionController {
    // Store LiveKit manager reference
    private static var liveKitManagerKey = "liveKitManager"

    var liveKitManager: LiveKitManager? {
        get {
            objc_getAssociatedObject(
                self,
                &CallSessionController.liveKitManagerKey
            ) as? LiveKitManager
        }
        set {
            objc_setAssociatedObject(
                self,
                &CallSessionController.liveKitManagerKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
