import Foundation
import Combine
import AVFoundation

struct DeferredPromptResponse: Decodable {
    let prompts: PromptBody
    let cached: Bool
    let agentId: String
    let mood: String
    let voiceId: String?

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

    private var audioPlayer: AVAudioPlayer?
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
        authenticateAndStream(callUUID: callUUID, sessionToken: sessionToken, prompts: promptResponse)
    }

    func endSession() {
        audioPlayer?.stop()
        audioPlayer = nil
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
        var request = URLRequest(url: URL(string: "https://api.bigbruh.app/voip/session/prompts")!)
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

    private func authenticateAndStream(callUUID: String, sessionToken: String, prompts: DeferredPromptResponse) {
        var request = URLRequest(url: URL(string: "https://api.bigbruh.app/calls/\(callUUID)/stream")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(sessionToken, forHTTPHeaderField: "X-Call-Session")

        let body: [String: Any] = [
            "agentId": prompts.agentId,
            "mood": prompts.mood,
            "prompts": [
                "systemPrompt": prompts.prompts.systemPrompt,
                "firstMessage": prompts.prompts.firstMessage
            ],
            "voiceId": prompts.voiceId as Any
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> URL in
                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    throw CallSessionError.invalidResponse
                }

                let temporaryFile = FileManager.default.temporaryDirectory.appendingPathComponent("call-\(callUUID).mp3")
                do {
                    try data.write(to: temporaryFile, options: .atomic)
                    return temporaryFile
                } catch {
                    throw CallSessionError.writeFailed(error)
                }
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case let .failure(error) = completion {
                    self.state = .failed(error)
                    self.delegate?.callSessionController(self, didFailWith: error)
                } else {
                    self.state = .streaming
                }
            } receiveValue: { [weak self] fileURL in
                guard let self else { return }
                self.prepareAudioSession()
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                    self.audioPlayer?.prepareToPlay()
                    self.audioPlayer?.play()
                    self.audioPlayer?.delegate = self
                } catch {
                    self.state = .failed(error)
                    self.delegate?.callSessionController(self, didFailWith: error)
                }
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
    case writeFailed(Error)
    case playbackFailed
}

extension CallSessionController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        state = flag ? .completed : .failed(CallSessionError.playbackFailed)
        flag
            ? delegate?.callSessionControllerDidFinish(self)
            : delegate?.callSessionController(self, didFailWith: CallSessionError.playbackFailed)
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        state = .failed(error ?? CallSessionError.playbackFailed)
        delegate?.callSessionController(self, didFailWith: error ?? CallSessionError.playbackFailed)
    }
}
