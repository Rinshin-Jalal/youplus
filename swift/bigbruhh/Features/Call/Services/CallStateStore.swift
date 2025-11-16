import Foundation
import Combine
import PushKit
import CallKit

struct CallSessionState: Equatable {
    enum Phase: Equatable {
        case idle
        case ringing
        case awaitingPrompts
        case connecting
        case connected
        case ended(reason: String?)
    }

    enum Provider: String, Equatable {
        case livekit
        case elevenlabs
        case unknown
    }

    var uuid: UUID?
    var userId: String?
    var callType: String?
    var mood: String?
    var startedAt: Date?
    var phase: Phase
    var sessionToken: String?
    var promptsReady: Bool
    var provider: Provider = .unknown

    // ElevenLabs (Legacy)
    var agentId: String?
    var voiceId: String?

    // LiveKit (Current)
    var roomName: String?
    var liveKitToken: String?
    var liveKitURL: String?
    var cartesiaVoiceId: String?
    var supermemoryUserId: String?

    var metadata: [String: AnyHashable]
}

final class CallStateStore: ObservableObject {
    @Published private(set) var state: CallSessionState

    private var cancellables = Set<AnyCancellable>()

    init(initialState: CallSessionState? = nil) {
        state = initialState ?? CallSessionState(
            uuid: nil,
            userId: nil,
            callType: nil,
            mood: nil,
            startedAt: nil,
            phase: .idle,
            sessionToken: nil,
            promptsReady: false,
            provider: .unknown,
            metadata: [:]
        )
    }

    func reset() {
        state = CallSessionState(
            uuid: nil,
            userId: nil,
            callType: nil,
            mood: nil,
            startedAt: nil,
            phase: .idle,
            sessionToken: nil,
            promptsReady: false,
            provider: .unknown,
            metadata: [:]
        )
    }

    func updateWithVoipPayload(_ payload: PKPushPayload) {
        guard
            let dictionary = payload.dictionaryPayload as? [String: AnyHashable],
            let callUUIDString = dictionary["callUUID"] as? String,
            let uuid = UUID(uuidString: callUUIDString)
        else { return }

        state.uuid = uuid
        state.userId = dictionary["userId"] as? String
        state.callType = dictionary["callType"] as? String
        state.mood = dictionary["mood"] as? String
        state.metadata.merge(dictionary) { _, new in new }
        state.phase = .ringing
        state.startedAt = Date()
        state.promptsReady = false

        // Detect provider (LiveKit or ElevenLabs)
        if let roomName = dictionary["roomName"] as? String,
           let liveKitToken = dictionary["liveKitToken"] as? String {
            // LiveKit call
            state.provider = .livekit
            state.roomName = roomName
            state.liveKitToken = liveKitToken
            state.cartesiaVoiceId = dictionary["cartesiaVoiceId"] as? String
            state.supermemoryUserId = dictionary["supermemoryUserId"] as? String
        } else if let agentId = dictionary["agentId"] as? String {
            // ElevenLabs call (legacy)
            state.provider = .elevenlabs
            state.agentId = agentId
            state.voiceId = dictionary["voiceId"] as? String
        }
        
        // Track call started
        AnalyticsService.shared.track(event: "call_started", properties: [
            "call_type": state.callType ?? "unknown",
            "call_id": uuid.uuidString,
            "provider": state.provider.rawValue
        ])
    }

    func bindCallKitManager(_ manager: CallKitManager) {
        manager.$callState
            .receive(on: RunLoop.main)
            .sink { [weak self] call in
                guard let self else { return }
                guard let call else {
                    if case .ended = self.state.phase { return }
                    self.state.phase = .ended(reason: "CallKit ended")
                    return
                }

                if call.hasConnected && !call.hasEnded {
                    self.state.phase = self.state.promptsReady ? .connected : .awaitingPrompts
                } else if call.isOutgoing && !call.hasConnected {
                    self.state.phase = .connecting
                } else if call.hasEnded {
                    self.state.phase = .ended(reason: "CallKit reported end")
                }
            }
            .store(in: &cancellables)
    }

    func applySessionToken(_ token: String) {
        state.sessionToken = token
    }

    func applyBackendMetadata(_ metadata: [String: AnyHashable]) {
        state.metadata.merge(metadata) { _, new in new }
    }

    func markPromptsReady() {
        state.promptsReady = true
        if case .awaitingPrompts = state.phase {
            state.phase = .connected
        }
    }

    func markEnded(reason: String?) {
        state.phase = .ended(reason: reason)
        
        // Track call completed or declined
        if let startedAt = state.startedAt {
            let duration = Date().timeIntervalSince(startedAt)
            AnalyticsService.shared.track(event: "call_completed", properties: [
                "call_type": state.callType ?? "unknown",
                "call_id": state.uuid?.uuidString ?? "unknown",
                "call_duration": duration,
                "provider": state.provider.rawValue,
                "reason": reason ?? "completed"
            ])
        } else {
            // Call was declined before starting
            AnalyticsService.shared.track(event: "call_declined", properties: [
                "call_type": state.callType ?? "unknown",
                "call_id": state.uuid?.uuidString ?? "unknown",
                "provider": state.provider.rawValue
            ])
        }
    }
    
    // MARK: - Internal State Management
    // Allow external updates to state properties while maintaining encapsulation
    
    func updateProvider(_ provider: CallSessionState.Provider) {
        state.provider = provider
    }
    
    func updateRoomName(_ roomName: String?) {
        state.roomName = roomName
    }
    
    func updateLiveKitToken(_ token: String?) {
        state.liveKitToken = token
    }
    
    func updateCartesiaVoiceId(_ voiceId: String?) {
        state.cartesiaVoiceId = voiceId
    }
    
    func updateSupermemoryUserId(_ userId: String?) {
        state.supermemoryUserId = userId
    }
    
    func updateAgentId(_ agentId: String?) {
        state.agentId = agentId
    }
    
    func updateVoiceId(_ voiceId: String?) {
        state.voiceId = voiceId
    }
}
