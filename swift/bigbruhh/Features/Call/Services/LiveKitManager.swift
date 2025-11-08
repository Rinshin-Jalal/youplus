/**
 * LiveKit Manager Service
 * Handles real-time WebRTC connection to LiveKit rooms
 *
 * Replaces:
 * - AVAudioPlayer MP3 playback (old)
 * - Single-direction audio streaming (old)
 *
 * New capabilities:
 * - Bidirectional audio/video via WebRTC
 * - Real-time agent communication
 * - Device tool execution via data channel
 * - Connection state management
 */

import Foundation
import LiveKit
import AVFoundation
import Combine

protocol LiveKitManagerDelegate: AnyObject {
    func liveKitManager(_ manager: LiveKitManager, didConnect to room: String)
    func liveKitManager(_ manager: LiveKitManager, didDisconnect with error: Error?)
    func liveKitManager(_ manager: LiveKitManager, didReceiveDataChannelMessage message: Data)
    func liveKitManager(_ manager: LiveKitManager, participantDidJoin participant: Participant)
    func liveKitManager(_ manager: LiveKitManager, participantDidLeave participant: Participant)
}

final class LiveKitManager: NSObject, ObservableObject {
    enum ConnectionState: Equatable {
        case disconnected
        case connecting
        case connected
        case reconnecting
        case disconnecting
        case failed(String)
    }

    @Published private(set) var connectionState: ConnectionState = .disconnected
    @Published private(set) var isAudioEnabled = true
    @Published private(set) var isVideoEnabled = false
    @Published private(set) var participants: [Participant] = []

    weak var delegate: LiveKitManagerDelegate?

    private var room: Room?
    private var audioTrack: LocalAudioTrack?
    private var dataChannelPublisher: LocalDataPublisher?
    private var cancellables = Set<AnyCancellable>()
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 3

    // MARK: - Connection

    /// Connect to a LiveKit room
    func connect(
        url: String,
        token: String,
        roomName: String
    ) async throws {
        guard connectionState == .disconnected else {
            throw LiveKitError.alreadyConnected
        }

        connectionState = .connecting

        do {
            // Create room configuration
            let roomOptions = RoomOptions(
                autoSubscribe: true,
                dynacast: false,
                adaptiveStream: true
            )

            // Create room instance
            let room = try await Room().connect(
                url: url,
                token: token,
                options: roomOptions
            )

            self.room = room

            // Setup room observers
            setupRoomObservers(room)

            // Setup local audio
            try await setupLocalAudio()

            connectionState = .connected
            delegate?.liveKitManager(self, didConnect: roomName)

            print("✅ Connected to LiveKit room: \(roomName)")
        } catch {
            connectionState = .failed(error.localizedDescription)
            delegate?.liveKitManager(self, didDisconnect: error)
            throw error
        }
    }

    /// Disconnect from the room
    func disconnect() async {
        guard let room = room else { return }

        connectionState = .disconnecting

        do {
            try await room.disconnect()
            audioTrack = nil
            dataChannelPublisher = nil
            self.room = nil
            connectionState = .disconnected
            delegate?.liveKitManager(self, didDisconnect: nil)

            print("✅ Disconnected from LiveKit room")
        } catch {
            connectionState = .failed(error.localizedDescription)
            delegate?.liveKitManager(self, didDisconnect: error)
        }
    }

    // MARK: - Audio Controls

    /// Toggle microphone audio
    func setAudioEnabled(_ enabled: Bool) async throws {
        guard let audioTrack = audioTrack else {
            throw LiveKitError.audioTrackNotFound
        }

        try await audioTrack.set(enabled: enabled)
        isAudioEnabled = enabled

        print("🎤 Audio \(enabled ? "enabled" : "disabled")")
    }

    /// Toggle speaker output
    func setSpeakerEnabled(_ enabled: Bool) throws {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            let category: AVAudioSession.Category = enabled ? .playAndRecord : .playback
            try audioSession.setCategory(
                category,
                mode: .voiceChat,
                options: [.defaultToSpeaker, .duckOthers]
            )
            print("🔊 Speaker \(enabled ? "enabled" : "disabled")")
        } catch {
            throw LiveKitError.audioSessionFailed(error)
        }
    }

    // MARK: - Data Channel (Device Tools)

    /// Send a device tool command via data channel
    func sendDeviceToolCommand(_ command: [String: Any]) async throws {
        guard let dataChannelPublisher = dataChannelPublisher else {
            throw LiveKitError.dataChannelNotFound
        }

        guard let data = try? JSONSerialization.data(withJSONObject: command) else {
            throw LiveKitError.encodingFailed
        }

        try await dataChannelPublisher.publish(
            data,
            reliability: .reliable
        )

        print("📤 Sent device tool command: \(command)")
    }

    /// Execute a device tool (battery, flash screen, etc)
    func executeDeviceTool(_ toolName: String, params: [String: Any] = [:]) async throws -> [String: Any] {
        let command: [String: Any] = [
            "tool": toolName,
            "params": params,
        ]

        try await sendDeviceToolCommand(command)

        // Return acknowledgment (in production, would wait for response via data channel)
        return ["status": "sent", "tool": toolName]
    }

    // MARK: - Private Helpers

    private func setupLocalAudio() async throws {
        // Create and publish local audio track
        let audioTrack = LocalAudioTrack()
        try await room?.localParticipant.publishAudioTrack(audioTrack)
        self.audioTrack = audioTrack

        print("🎤 Local audio track published")

        // Setup audio session for voice chat
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .duckOthers]
        )
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        print("🔊 Audio session configured")
    }

    private func setupRoomObservers(_ room: Room) {
        // Participant joined
        room.add(
            subscriber: self,
            options: RoomObserverOptions(
                participants: true
            )
        )
    }

    // Handle reconnection
    private func attemptReconnection(url: String, token: String) async throws {
        guard reconnectAttempts < maxReconnectAttempts else {
            throw LiveKitError.maxReconnectAttemptsExceeded
        }

        reconnectAttempts += 1
        let delaySeconds = pow(2.0, Double(reconnectAttempts)) // Exponential backoff

        print("🔄 Reconnecting attempt \(reconnectAttempts)... (waiting \(Int(delaySeconds))s)")

        try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))

        connectionState = .reconnecting

        try await connect(url: url, token: token, roomName: "unknown")
        reconnectAttempts = 0 // Reset on successful reconnection
    }
}

// MARK: - Room Observer

extension LiveKitManager: RoomDelegate {
    nonisolated func room(_ room: Room, participantDidJoin participant: Participant) {
        DispatchQueue.main.async {
            self.participants.append(participant)
            self.delegate?.liveKitManager(self, participantDidJoin: participant)

            let isAgent = participant.name?.contains("agent") ?? false
            print("\(isAgent ? "🤖" : "👤") Participant joined: \(participant.identity) (\(participant.name ?? "Unknown"))")
        }
    }

    nonisolated func room(_ room: Room, participantDidLeave participant: Participant) {
        DispatchQueue.main.async {
            self.participants.removeAll { $0.sid == participant.sid }
            self.delegate?.liveKitManager(self, participantDidLeave: participant)

            print("👋 Participant left: \(participant.identity)")

            // If agent leaves, call is effectively over
            let wasAgent = participant.name?.contains("agent") ?? false
            if wasAgent {
                print("🤖 Agent disconnected - call ending")
            }
        }
    }

    nonisolated func room(_ room: Room, didFailWithError error: LiveKitError) {
        DispatchQueue.main.async {
            print("❌ Room error: \(error.localizedDescription)")
            self.connectionState = .failed(error.localizedDescription)
            self.delegate?.liveKitManager(self, didDisconnect: error)
        }
    }

    nonisolated func roomDidDisconnect(_ room: Room, error: Error?) {
        DispatchQueue.main.async {
            print("❌ Disconnected: \(error?.localizedDescription ?? "No error")")
            self.audioTrack = nil
            self.connectionState = .disconnected
            self.delegate?.liveKitManager(self, didDisconnect: error)
        }
    }

    nonisolated func roomDidReconnect(_ room: Room) {
        DispatchQueue.main.async {
            print("✅ Reconnected to room")
            self.connectionState = .connected
        }
    }
}

// MARK: - Error Types

enum LiveKitError: LocalizedError {
    case alreadyConnected
    case audioTrackNotFound
    case dataChannelNotFound
    case audioSessionFailed(Error)
    case encodingFailed
    case maxReconnectAttemptsExceeded
    case connectionTimeout
    case invalidToken

    var errorDescription: String? {
        switch self {
        case .alreadyConnected:
            return "Already connected to a room"
        case .audioTrackNotFound:
            return "Audio track not found"
        case .dataChannelNotFound:
            return "Data channel not available"
        case .audioSessionFailed(let error):
            return "Audio session setup failed: \(error.localizedDescription)"
        case .encodingFailed:
            return "Failed to encode message"
        case .maxReconnectAttemptsExceeded:
            return "Max reconnection attempts exceeded"
        case .connectionTimeout:
            return "Connection timeout"
        case .invalidToken:
            return "Invalid LiveKit token"
        }
    }
}
