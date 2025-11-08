import Foundation
import Combine
import AVFoundation

struct DeferredPromptResponse: Decodable {
    let prompts: PromptBody
    let cached: Bool
    let mood: String
    
    // ElevenLabs (Legacy - optional for backward compatibility)
    let agentId: String?
    let voiceId: String?
    
    // LiveKit (Current)
    let cartesiaVoiceId: String?
    let supermemoryUserId: String?
    let roomName: String?

    struct PromptBody: Decodable {
        let systemPrompt: String
        let firstMessage: String
    }
}

protocol CallSessionControllerDelegate: AnyObject {
    func callSessionController(_ controller: CallSessionController, didFailWith error: Error)
    func callSessionControllerDidStart(_ controller: CallSessionController)
    func callSessionControllerDidFinish(_ controller: CallSessionController)
}

final class CallSessionController: NSObject, ObservableObject {
    enum State {
        case idle
        case awaitingPrompts
        case preparing
        case streaming
        case completed
        case failed(Error)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var promptResponse: DeferredPromptResponse?

    weak var delegate: CallSessionControllerDelegate?
    private weak var conversationReference: AnyObject?

    private var cancellables = Set<AnyCancellable>()

    func beginCall(with callUUID: String, userToken: String) {
        guard case .idle = state else { return }
        state = .awaitingPrompts
        fetchPrompts(callUUID: callUUID, token: userToken)
    }

    func startStreaming(callUUID: String, sessionToken: String) {
        guard let promptResponse else { return }
        state = .preparing
        delegate?.callSessionControllerDidStart(self)
        // LiveKit connection is handled by LiveKitManager
        // This method is kept for compatibility but actual streaming happens via WebRTC
        state = .streaming
    }

    func endSession() {
        // LiveKit connection cleanup is handled by LiveKitManager
        state = .completed
        delegate?.callSessionControllerDidFinish(self)
    }

    func registerClientTools(on conversation: AnyObject, tools: [String: (Any?) -> Any?]) {
        guard let registrar = conversation as? ClientToolRegistrable else { return }
        tools.forEach { registrar.registerClientTool($0.key, fn: $0.value) }
    }

    func setupDefaultTools(for conversation: AnyObject) {
        conversationReference = conversation
        registerClientTools(
            on: conversation,
            tools: [
                "get_battery_level": DeviceTools.getBatteryLevel,
                "change_brightness": DeviceTools.changeBrightness,
                "flash_screen": DeviceTools.flashScreen,
            ]
        )
    }

    private func fetchPrompts(callUUID: String, token: String) {
        guard let baseURL = Config.backendURL else {
            self.state = .failed(CallSessionError.invalidResponse)
            return
        }
        var request = URLRequest(url: URL(string: "\(baseURL)/voip/session/prompts")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["callUUID": callUUID])

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> DeferredPromptResponse in
                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    throw CallSessionError.invalidResponse
                }
                return try JSONDecoder().decode(DeferredPromptResponse.self, from: data)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case let .failure(error) = completion {
                    self.state = .failed(error)
                    self.delegate?.callSessionController(self, didFailWith: error)
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }
                self.promptResponse = response
            }
            .store(in: &cancellables)
    }

    private func prepareAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker])
        try? session.setActive(true, options: .notifyOthersOnDeactivation)
    }
}

protocol ClientToolRegistrable {
    func registerClientTool(_ name: String, fn: @escaping (Any?) -> Any?)
}

enum CallSessionError: Error {
    case invalidResponse
}
