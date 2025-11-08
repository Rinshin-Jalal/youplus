import CallKit
import Combine
import LiveKit

struct CallKitConfiguration {
    let appName: String
    let supportsVideo: Bool
    let maximumCallsPerCallGroup: Int
}

final class CallKitManager: NSObject, ObservableObject {
    @Published private(set) var activeCallUUID: UUID?
    @Published private(set) var isMuted: Bool = false
    @Published private(set) var isOnHold: Bool = false
    @Published private(set) var callState: CXCall?

    private let provider: CXProvider
    private let callController = CXCallController()
    private let observer = CXCallObserver()
    private var cancellables = Set<AnyCancellable>()

    init(configuration: CallKitConfiguration = CallKitConfiguration(appName: "BIG BRUH", supportsVideo: false, maximumCallsPerCallGroup: 1)) {
        let providerConfiguration = CXProviderConfiguration()
        providerConfiguration.maximumCallsPerCallGroup = configuration.maximumCallsPerCallGroup
        providerConfiguration.supportsVideo = configuration.supportsVideo
        providerConfiguration.iconTemplateImageData = nil
        providerConfiguration.supportedHandleTypes = [.phoneNumber]

        self.provider = CXProvider(configuration: providerConfiguration)

        super.init()

        self.provider.setDelegate(self, queue: nil)
        self.observer.setDelegate(self, queue: nil)
    }

    func reportIncomingCall(uuid: UUID, update: CXCallUpdate) {
        provider.reportNewIncomingCall(with: uuid, update: update) { [weak self] error in
            if let error { print("CallKit incoming call error: \(error.localizedDescription)") }
            if error == nil { self?.activeCallUUID = uuid }
        }
    }

    func reportOutgoingCall(uuid: UUID, update: CXCallUpdate) {
        provider.reportOutgoingCall(with: uuid, startedConnectingAt: Date())
        provider.reportCall(with: uuid, updated: update)
        activeCallUUID = uuid
    }

    func endCall(uuid: UUID) {
        let endTransaction = CXEndCallAction(call: uuid)
        requestTransaction(actions: [endTransaction])
    }

    func setMuted(_ muted: Bool, uuid: UUID) {
        let action = CXSetMutedCallAction(call: uuid, muted: muted)
        requestTransaction(actions: [action])
    }

    func setOnHold(_ onHold: Bool, uuid: UUID) {
        let action = CXSetHeldCallAction(call: uuid, onHold: onHold)
        requestTransaction(actions: [action])
    }

    func configureDefaultUpdate(displayName: String, hasVideo: Bool = false) -> CXCallUpdate {
        let update = CXCallUpdate()
        update.hasVideo = hasVideo
        update.remoteHandle = CXHandle(type: .generic, value: displayName)
        update.localizedCallerName = displayName
        update.supportsHolding = true
        update.supportsUngrouping = false
        update.supportsGrouping = false
        update.supportsDTMF = false
        return update
    }

    private func requestTransaction(actions: [CXCallAction]) {
        let transaction = CXTransaction(actions: actions)
        callController.request(transaction) { error in
            if let error { print("CallKit transaction error: \(error.localizedDescription)") }
        }
    }
}

extension CallKitManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        activeCallUUID = nil
        isMuted = false
        isOnHold = false
        callState = nil
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        activeCallUUID = action.callUUID
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        if activeCallUUID == action.callUUID { activeCallUUID = nil }
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        isMuted = action.isMuted
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        isOnHold = action.isOnHold
        action.fulfill()
    }

    // MARK: - Audio Session Management for LiveKit

    /// Called when CallKit activates the audio session
    /// Syncs with LiveKit's RTC audio session
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("📱 CallKit audio session activated, syncing with LiveKit")

        // Notify LiveKit that the audio session is active
        // This allows LiveKit to properly configure audio routing
        do {
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ Failed to activate audio session: \(error.localizedDescription)")
        }
    }

    /// Called when CallKit deactivates the audio session
    /// Cleanly disconnect from LiveKit audio
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("📱 CallKit audio session deactivated")

        // Deactivate the audio session
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}

extension CallKitManager: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        callState = call
    }
}
