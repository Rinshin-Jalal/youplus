import Foundation
import PushKit
import Combine

protocol VoIPPushManagerDelegate: AnyObject {
    func voipPushManager(_ manager: VoIPPushManager, didReceiveIncomingPush payload: PKPushPayload, type: PKPushType)
    func voipPushManager(_ manager: VoIPPushManager, didUpdatePushToken token: Data)
    func voipPushManager(_ manager: VoIPPushManager, didInvalidateWithError error: Error?)
}

/// Represents a VoIP push payload
/// Supports both ElevenLabs (legacy) and LiveKit (current) providers
struct VoIPPushPayload: Decodable {
    let callUUID: String
    let userId: String
    let callType: String
    let mood: String
    let prompts: PromptPayload?

    // ElevenLabs (Legacy)
    let agentId: String?
    let voiceId: String?

    // LiveKit (Current)
    let roomName: String?
    let liveKitToken: String?
    let cartesiaVoiceId: String?
    let supermemoryUserId: String?

    struct PromptPayload: Decodable {
        let systemPrompt: String
        let firstMessage: String
    }

    enum CodingKeys: String, CodingKey {
        case callUUID
        case userId
        case callType
        case mood
        case prompts
        case agentId
        case voiceId
        case roomName
        case liveKitToken
        case cartesiaVoiceId
        case supermemoryUserId
    }

    /// Check if this is a LiveKit call
    var isLiveKit: Bool {
        roomName != nil && liveKitToken != nil
    }

    /// Check if this is a legacy ElevenLabs call
    var isElevenLabs: Bool {
        agentId != nil
    }
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

// MARK: - Payload Parsing

extension VoIPPushManager {
    /// Parse VoIP push payload from PKPushPayload
    static func parsePayload(_ pushPayload: PKPushPayload) -> VoIPPushPayload? {
        guard let dictionaryPayload = pushPayload.dictionaryPayload as? [String: Any] else {
            return nil
        }

        // Convert dictionary to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionaryPayload) else {
            return nil
        }

        // Decode to VoIPPushPayload
        do {
            let payload = try JSONDecoder().decode(VoIPPushPayload.self, from: jsonData)
            return payload
        } catch {
            print("❌ Failed to decode VoIP push payload: \(error)")
            return nil
        }
    }

    /// Determine call provider from push payload
    static func getCallProvider(_ pushPayload: PKPushPayload) -> String? {
        guard let payload = parsePayload(pushPayload) else { return nil }
        return payload.isLiveKit ? "livekit" : (payload.isElevenLabs ? "elevenlabs" : nil)
    }
}

// MARK: - PKPushRegistry Delegate

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

        // Parse and log the call provider
        if let provider = VoIPPushManager.getCallProvider(payload) {
            print("📞 Incoming call via \(provider)")
        }

        delegate?.voipPushManager(self, didReceiveIncomingPush: payload, type: type)
        completion()
    }

    func pushRegistry(_ registry: PKPushRegistry, didFailToRegisterForVoIPPushesWithError error: Error) {
        delegate?.voipPushManager(self, didInvalidateWithError: error)
    }
}
