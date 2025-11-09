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
    func liveKitManager(_ manager: LiveKitManager, didConnectTo room: String)
    func liveKitManager(_ manager: LiveKitManager, didDisconnectWith error: Error?)
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
    @Published private(set) var participants: [String: Participant] = [:]
    @Published private(set) var agentJoined = false

    weak var delegate: LiveKitManagerDelegate?

    private weak var room: Room?
    private var audioTrack: LocalAudioTrack?
    private var cancellables = Set<AnyCancellable>()
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 3
    private var agentJoinTask: Task<Void, Never>?
    private var audioSessionConfigured = false

    // Computed property for array access if needed elsewhere
    var participantList: [Participant] {
        Array(participants.values)
    }

    // MARK: - Connection

    /// Connect to a LiveKit room with timeout
    func connect(
        url: String,
        token: String,
        roomName: String,
        timeout: TimeInterval = 15.0
    ) async throws {
        guard connectionState == .disconnected else {
            throw LiveKitError.alreadyConnected
        }

        connectionState = .connecting

        do {
            // Wrap connection in timeout
            try await withTimeout(seconds: timeout) {
                // Create room instance
                let room = Room()
                try await room.connect(url: url, token: token)

                self.room = room

                // Setup room observers
                self.setupRoomObservers(room)

                // Setup local audio
                try await self.setupLocalAudio()

                self.connectionState = .connected
                self.delegate?.liveKitManager(self, didConnectTo: roomName)

                #if DEBUG
                print("✅ Connected to LiveKit room: \(roomName)")
                #endif

                // Start agent join verification
                self.startAgentJoinVerification()
            }
        } catch is TimeoutError {
            connectionState = .failed("Connection timeout")
            let error = LiveKitError.connectionTimeout
            delegate?.liveKitManager(self, didDisconnectWith: error)
            throw error
        } catch {
            connectionState = .failed(error.localizedDescription)
            delegate?.liveKitManager(self, didDisconnectWith: error)
            throw error
        }
    }

    /// Start monitoring for agent join within timeout period
    private func startAgentJoinVerification(timeout: TimeInterval = 10.0) {
        agentJoinTask?.cancel()

        agentJoinTask = Task { [weak self] in
            guard let self = self else { return }

            // Wait for agent join timeout
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))

            // Check if task was cancelled (agent joined)
            if !Task.isCancelled {
                await MainActor.run {
                    if !self.agentJoined {
                        #if DEBUG
                        print("⚠️ Agent did not join within \(timeout) seconds")
                        #endif
                        self.connectionState = .failed("Agent failed to join call")
                        self.delegate?.liveKitManager(self, didDisconnectWith: LiveKitError.agentJoinTimeout)
                    }
                }
            }
        }
    }

    /// Disconnect from the room
    func disconnect() async {
        guard let room = room else { return }

        connectionState = .disconnecting

        do {
            try await room.disconnect()
            audioTrack = nil
            self.room = nil
            connectionState = .disconnected
            delegate?.liveKitManager(self, didDisconnectWith: nil)

            #if DEBUG
            print("✅ Disconnected from LiveKit room")
            #endif
        } catch {
            connectionState = .failed(error.localizedDescription)
            delegate?.liveKitManager(self, didDisconnectWith: error)
        }
    }

    // MARK: - Audio Controls

    /// Toggle microphone audio
    func setAudioEnabled(_ enabled: Bool) async throws {
        guard let audioTrack = audioTrack else {
            throw LiveKitError.audioTrackNotFound
        }

        // Enable/disable the audio track - use reportStatistics parameter
        await audioTrack.set(reportStatistics: enabled)
        isAudioEnabled = enabled

        #if DEBUG
        print("🎤 Audio \(enabled ? "enabled" : "disabled")")
        #endif
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
            #if DEBUG
            print("🔊 Speaker \(enabled ? "enabled" : "disabled")")
            #endif
        } catch {
            throw LiveKitError.audioSessionFailed(error)
        }
    }

    // MARK: - Data Channel (Device Tools)
    // NOTE: Data channel functionality temporarily disabled
    // LiveKit Swift SDK data channel API may differ from expected implementation
    
    /// Send a device tool command via data channel
    func sendDeviceToolCommand(_ command: [String: Any]) async throws {
        // TODO: Implement data channel sending when LiveKit Swift SDK API is confirmed
        // For now, this is a placeholder
        throw LiveKitError.dataChannelNotFound
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
        guard let room = room else {
            throw LiveKitError.audioTrackNotFound
        }
        
        // Create and publish local audio track
        // LiveKit Swift SDK: Create audio track with microphone source
        let audioTrack = try await LocalAudioTrack.createTrack(name: "microphone")
        
        try await room.localParticipant.publish(audioTrack: audioTrack)
        self.audioTrack = audioTrack

        #if DEBUG
        print("🎤 Local audio track published")
        #endif

        // NOTE: Data channel setup commented out - LiveKit Swift SDK API needs verification
        // TODO: Implement data channel when API is confirmed
        // Data channels for device tools can be added later if needed

        // Only configure audio session once
        if !audioSessionConfigured {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.defaultToSpeaker, .duckOthers]
            )
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            audioSessionConfigured = true

            #if DEBUG
            print("🔊 Audio session configured")
            #endif
        }
    }

    private func setupRoomObservers(_ room: Room) {
        // Add self as room delegate to observe events
        room.add(delegate: self)
    }

    /// Execute async operation with timeout
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    // Handle reconnection
    private func attemptReconnection(url: String, token: String) async throws {
        guard reconnectAttempts < maxReconnectAttempts else {
            throw LiveKitError.maxReconnectAttemptsExceeded
        }

        reconnectAttempts += 1
        let delaySeconds = pow(2.0, Double(reconnectAttempts)) // Exponential backoff

        #if DEBUG
        print("🔄 Reconnecting attempt \(reconnectAttempts)... (waiting \(Int(delaySeconds))s)")
        #endif

        try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))

        connectionState = .reconnecting

        try await connect(url: url, token: token, roomName: "unknown")
        reconnectAttempts = 0 // Reset on successful reconnection
    }
}

// MARK: - Room Observer

extension LiveKitManager: RoomDelegate {
    nonisolated func room(_ room: Room, participantDidJoin participant: Participant) {
        Task { @MainActor in
            guard let sid = participant.sid else { return }
            participants[sid.stringValue] = participant
            delegate?.liveKitManager(self, participantDidJoin: participant)

            let identityString = participant.identity?.description ?? ""
            let isAgent = participant.name?.contains("agent") ?? false ||
                          identityString.contains("agent") ||
                          participant.kind == .agent

            if isAgent {
                agentJoined = true
                agentJoinTask?.cancel() // Cancel timeout since agent joined
                #if DEBUG
                print("🤖 Agent joined: \(participant.identity) (\(participant.name ?? "Unknown"))")
                #endif
            } else {
                #if DEBUG
                print("👤 Participant joined: \(participant.identity) (\(participant.name ?? "Unknown"))")
                #endif
            }
        }
    }

    nonisolated func room(_ room: Room, participantDidLeave participant: Participant) {
        Task { @MainActor in
            guard let sid = participant.sid else { return }
            participants.removeValue(forKey: sid.stringValue)
            delegate?.liveKitManager(self, participantDidLeave: participant)

            #if DEBUG
            print("👋 Participant left: \(participant.identity)")
            #endif

            // If agent leaves, call is effectively over
            let wasAgent = participant.name?.contains("agent") ?? false
            if wasAgent {
                #if DEBUG
                print("🤖 Agent disconnected - call ending")
                #endif
            }
        }
    }

    nonisolated func room(_ room: Room, didFailWithError error: Error) {
        Task { @MainActor in
            #if DEBUG
            print("❌ Room error: \(error.localizedDescription)")
            #endif
            let errorMessage = (error as? LiveKitError)?.localizedDescription ?? error.localizedDescription
            connectionState = .failed(errorMessage)
            delegate?.liveKitManager(self, didDisconnectWith: error)
        }
    }

    nonisolated func roomDidDisconnect(_ room: Room, error: Error?) {
        Task { @MainActor in
            #if DEBUG
            print("❌ Disconnected: \(error?.localizedDescription ?? "No error")")
            #endif
            audioTrack = nil
            connectionState = .disconnected
            delegate?.liveKitManager(self, didDisconnectWith: error)
        }
    }

    nonisolated func roomDidReconnect(_ room: Room) {
        Task { @MainActor in
            #if DEBUG
            print("✅ Reconnected to room")
            #endif
            connectionState = .connected
        }
    }

    // MARK: - Track Subscription

    nonisolated func room(_ room: Room, participant: RemoteParticipant, didPublishTrack publication: RemoteTrackPublication) {
        #if DEBUG
        print("📢 Track published by \(participant.identity): \(publication.kind) - \(publication.source)")
        #endif

        // Auto-subscribe to audio tracks from agent
        if publication.kind == .audio {
            Task {
                do {
                    try await publication.set(subscribed: true)
                    #if DEBUG
                    print("🔊 Subscribed to audio track from \(participant.identity)")
                    #endif
                } catch {
                    #if DEBUG
                    print("❌ Failed to subscribe to track: \(error.localizedDescription)")
                    #endif
                }
            }
        }
    }

    nonisolated func room(_ room: Room, participant: RemoteParticipant, didSubscribeTrack track: Track, publication: RemoteTrackPublication) {
        if let audioTrack = track as? RemoteAudioTrack {
            #if DEBUG
            print("✅ Successfully subscribed to audio track from \(participant.identity)")
            print("🔊 Audio track is now playing (LiveKit manages playback automatically)")
            #endif
        }
    }

    nonisolated func room(_ room: Room, participant: RemoteParticipant, didUnpublishTrack publication: RemoteTrackPublication) {
        #if DEBUG
        print("📉 Track unpublished by \(participant.identity): \(publication.kind)")
        #endif
    }

    // MARK: - Data Channel

    nonisolated func room(_ room: Room, didReceive data: Data, from participant: RemoteParticipant?) {
        Task { @MainActor in
            delegate?.liveKitManager(self, didReceiveDataChannelMessage: data)
        }

        // Parse device tool response
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            #if DEBUG
            print("📥 Received data channel message: \(json)")
            #endif
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
    case agentJoinTimeout
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
        case .agentJoinTimeout:
            return "Agent failed to join the call"
        case .invalidToken:
            return "Invalid LiveKit token"
        }
    }
}

struct TimeoutError: Error {}
