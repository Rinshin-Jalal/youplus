import Foundation
import PushKit
import Combine

protocol VoIPPushManagerDelegate: AnyObject {
    func voipPushManager(_ manager: VoIPPushManager, didReceiveIncomingPush payload: PKPushPayload, type: PKPushType)
    func voipPushManager(_ manager: VoIPPushManager, didUpdatePushToken token: Data)
    func voipPushManager(_ manager: VoIPPushManager, didInvalidateWithError error: Error?)
}

final class VoIPPushManager: NSObject, ObservableObject {
    @Published private(set) var currentToken: Data?

    weak var delegate: VoIPPushManagerDelegate?

    private let pushRegistry: PKPushRegistry

    override init() {
        self.pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        super.init()
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
    }

    func invalidateRegistration() {
        pushRegistry.desiredPushTypes = []
        currentToken = nil
    }
}

extension VoIPPushManager: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard type == .voIP else { return }
        currentToken = pushCredentials.token
        delegate?.voipPushManager(self, didUpdatePushToken: pushCredentials.token)
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard type == .voIP else { return }
        currentToken = nil
        delegate?.voipPushManager(self, didInvalidateWithError: nil)
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        guard type == .voIP else {
            completion()
            return
        }
        delegate?.voipPushManager(self, didReceiveIncomingPush: payload, type: type)
        completion()
    }

    func pushRegistry(_ registry: PKPushRegistry, didFailToRegisterForVoIPPushesWithError error: Error) {
        delegate?.voipPushManager(self, didInvalidateWithError: error)
    }
}
