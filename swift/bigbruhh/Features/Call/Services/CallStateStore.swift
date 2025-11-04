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

    var uuid: UUID?
    var userId: String?
    var callType: String?
    var mood: String?
    var startedAt: Date?
    var phase: Phase
    var sessionToken: String?
    var promptsReady: Bool
    var metadata: [String: AnyHashable]
}

final class CallStateStore: ObservableObject {
    @Published private(set) var state: CallSessionState

    private var cancellables = Set<AnyCancellable>()

    init(initialState: CallSessionState = CallSessionState(uuid: nil, userId: nil, callType: nil, mood: nil, startedAt: nil, phase: .idle, sessionToken: nil, promptsReady: false, metadata: [:])) {
        state = initialState
    }

    func reset() {
        state = CallSessionState(uuid: nil, userId: nil, callType: nil, mood: nil, startedAt: nil, phase: .idle, sessionToken: nil, promptsReady: false, metadata: [:])
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
    }
}
