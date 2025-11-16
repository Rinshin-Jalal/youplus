//
//  VoiceCloneService.swift
//  bigbruhh
//
//  Service to clone user's voice using Cartesia AI
//  Combines voice recordings from onboarding and creates a cloned voice
//

import Foundation
import AVFoundation

struct VoiceCloneResponse: Codable {
    let id: String
    let userId: String
    let isPublic: Bool
    let name: String
    let description: String
    let createdAt: String
    let language: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case isPublic = "is_public"
        case name
        case description
        case createdAt = "created_at"
        case language
    }
}

enum VoiceCloneError: Error {
    case invalidAudioData
    case noVoiceRecordings
    case apiError(String)
    case networkError(Error)

    var localizedDescription: String {
        switch self {
        case .invalidAudioData:
            return "Invalid audio data"
        case .noVoiceRecordings:
            return "No voice recordings available"
        case .apiError(let message):
            return "API Error: \(message)"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        }
    }
}

class VoiceCloneService {
    static let shared = VoiceCloneService()

    private let cartesiaAPIKey: String
    private let baseURL = "https://api.cartesia.ai"

    private init() {
        // Get API key from Config or environment
        self.cartesiaAPIKey = Config.get("CARTESIA_API_KEY") ?? ""
    }

    /// Clone voice from multiple audio recordings
    /// - Parameters:
    ///   - audioURLs: Array of local audio file URLs (from steps 8, 20, and optionally 34)
    ///   - userName: User's name for the voice
    /// - Returns: Cloned voice ID
    func cloneVoice(from audioURLs: [URL], userName: String) async throws -> String {
        guard !audioURLs.isEmpty else {
            throw VoiceCloneError.noVoiceRecordings
        }

        Config.log("🎤 Starting voice clone for \(userName) with \(audioURLs.count) recordings", category: "VoiceClone")

        // Combine audio files into one
        let combinedAudioData = try await combineAudioFiles(audioURLs)

        // Create multipart form data
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "\(baseURL)/voices/clone")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(cartesiaAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("2024-06-10", forHTTPHeaderField: "Cartesia-Version")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Build multipart body
        var body = Data()

        // Add audio clip
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"clip\"; filename=\"voice.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(combinedAudioData)
        body.append("\r\n".data(using: .utf8)!)

        // Add name
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userName)'s Voice\r\n".data(using: .utf8)!)

        // Add description
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
        body.append("Cloned voice for daily accountability calls\r\n".data(using: .utf8)!)

        // Add language
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
        body.append("en\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw VoiceCloneError.apiError("Invalid response")
            }

            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                Config.log("❌ Voice clone failed: \(errorMessage)", category: "VoiceClone")
                throw VoiceCloneError.apiError(errorMessage)
            }

            let cloneResponse = try JSONDecoder().decode(VoiceCloneResponse.self, from: data)
            Config.log("✅ Voice cloned successfully: \(cloneResponse.id)", category: "VoiceClone")

            return cloneResponse.id

        } catch let error as VoiceCloneError {
            throw error
        } catch {
            throw VoiceCloneError.networkError(error)
        }
    }

    /// Combine multiple audio files into one
    private func combineAudioFiles(_ urls: [URL]) async throws -> Data {
        guard !urls.isEmpty else {
            throw VoiceCloneError.noVoiceRecordings
        }

        // If only one file, return its data
        if urls.count == 1 {
            return try Data(contentsOf: urls[0])
        }

        // Use AVMutableComposition to combine audio files
        let composition = AVMutableComposition()

        guard let audioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw VoiceCloneError.invalidAudioData
        }

        var currentTime = CMTime.zero

        for url in urls {
            let asset = AVURLAsset(url: url)

            guard let assetTrack = try? await asset.loadTracks(withMediaType: .audio).first else {
                Config.log("⚠️ Skipping invalid audio file: \(url.lastPathComponent)", category: "VoiceClone")
                continue
            }

            let duration = try await asset.load(.duration)
            let timeRange = CMTimeRange(start: .zero, duration: duration)

            try audioTrack.insertTimeRange(timeRange, of: assetTrack, at: currentTime)
            currentTime = CMTimeAdd(currentTime, duration)
        }

        // Export to data
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("combined_voice_\(UUID().uuidString).m4a")

        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) else {
            throw VoiceCloneError.invalidAudioData
        }

        exportSession.outputURL = tempURL
        exportSession.outputFileType = .m4a

        await exportSession.export()

        guard exportSession.status == .completed else {
            throw VoiceCloneError.invalidAudioData
        }

        let combinedData = try Data(contentsOf: tempURL)

        // Clean up temp file
        try? FileManager.default.removeItem(at: tempURL)

        Config.log("✅ Combined \(urls.count) audio files (\(combinedData.count) bytes)", category: "VoiceClone")

        return combinedData
    }
}
