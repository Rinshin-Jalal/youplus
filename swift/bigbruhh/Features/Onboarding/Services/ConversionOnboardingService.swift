//
//  ConversionOnboardingService.swift
//  bigbruhh
//
//  Service to upload conversion onboarding data to backend
//  Handles 3 voice recordings upload with progress tracking
//

import Foundation
import SwiftUI
import UIKit

enum ConversionOnboardingError: Error {
    case userNotAuthenticated
    case invalidData
    case networkError(Error)
    case voiceRecordingMissing
    case voiceConversionFailed(String)

    var localizedDescription: String {
        switch self {
        case .userNotAuthenticated:
            return "User not authenticated"
        case .invalidData:
            return "Invalid onboarding data"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .voiceRecordingMissing:
            return "Voice recording missing"
        case .voiceConversionFailed(let file):
            return "Failed to convert voice recording: \(file)"
        }
    }
}

struct ConversionCompleteResponse: Codable {
    let success: Bool
    let message: String
    let completedAt: String
    let voiceUploads: VoiceUploads
    let identityCreated: Bool

    struct VoiceUploads: Codable {
        let whyItMatters: String?
        let costOfQuitting: String?
        let commitment: String?
    }
}

// Progress callback for UI updates
typealias UploadProgressCallback = (String, Double) -> Void

class ConversionOnboardingService {
    static let shared = ConversionOnboardingService()

    private init() {}

    /// Authenticate as guest if needed
    func ensureAuthenticated() async throws {
        if AuthService.shared.isAuthenticated { return }
        try await AuthService.shared.authenticateGuest()
    }

    /// Clone voice using backend
    func cloneVoice(audioURLs: [URL], userName: String) async throws -> String {
        try await ensureAuthenticated()
        
        Config.log("🎤 Cloning voice for \(userName) via backend")
        
        // Create multipart request manually since APIService doesn't support it yet
        // Or better, implement multipart in APIService. 
        // For now, let's use a helper here or assume APIService has upload support.
        // APIService doesn't seem to have multipart support in the viewed file.
        // I'll implement a simple multipart upload here or add it to APIService.
        // Given the complexity, I'll add a helper method here.
        
        let boundary = UUID().uuidString
        let url = URL(string: "\(Config.backendURL ?? "")/voice/clone")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = AuthService.shared.guestToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        
        // Add audio files
        // Backend expects "audio" or "clip"
        // Let's combine them first using AVFoundation if needed, or send the first one.
        // The backend handles multiple files or single "clip".
        // Let's send the first file as "clip" for now, or better, combine them.
        // Since VoiceCloneService (local) combined them, we should probably do that too.
        // But for now, let's just send the first valid recording (step 8 usually).
        
        if let firstURL = audioURLs.first, let audioData = try? Data(contentsOf: firstURL) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"clip\"; filename=\"voice.m4a\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
            body.append(audioData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Add voiceName
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"voiceName\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userName)'s Voice\r\n".data(using: .utf8)!)
        
        // Add provider
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"provider\"\r\n\r\n".data(using: .utf8)!)
        body.append("cartesia\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ConversionOnboardingError.voiceConversionFailed(errorMsg)
        }
        
        struct CloneResponse: Codable {
            let success: Bool
            let voice_id: String
        }
        
        let result = try JSONDecoder().decode(CloneResponse.self, from: data)
        return result.voice_id
    }

    /// Generate demo call using backend
    func generateDemoCall(voiceId: String, userName: String, goal: String, motivationLevel: Int) async throws -> (URL, String) {
        try await ensureAuthenticated()
        
        let body: [String: Any] = [
            "voiceId": voiceId,
            "userName": userName,
            "goal": goal,
            "motivationLevel": motivationLevel
        ]
        
        struct DemoResponse: Codable {
            let success: Bool
            let audioUrl: String
            let transcript: String
        }
        
        let response: APIResponse<DemoResponse> = try await APIService.shared.post("/voice/demo", body: body)
        
        guard let data = response.data, let url = URL(string: data.audioUrl) else {
            throw ConversionOnboardingError.voiceConversionFailed("Invalid demo response")
        }
        
        return (url, data.transcript)
    }

    /// Generate commitment audio using backend
    func generateCommitmentAudio(voiceId: String, text: String) async throws -> URL {
        try await ensureAuthenticated()
        
        let body: [String: Any] = [
            "voiceId": voiceId,
            "text": text
        ]
        
        struct CommitmentResponse: Codable {
            let success: Bool
            let audioUrl: String
        }
        
        let response: APIResponse<CommitmentResponse> = try await APIService.shared.post("/voice/commitment", body: body)
        
        guard let data = response.data, let url = URL(string: data.audioUrl) else {
            throw ConversionOnboardingError.voiceConversionFailed("Invalid commitment response")
        }
        
        return url
    }

    /// Upload conversion onboarding data to backend
    /// - Parameters:
    ///   - response: The completed conversion onboarding response
    ///   - progressCallback: Optional callback for upload progress updates
    /// - Returns: API response with success status and upload details
    func uploadOnboardingData(
        response: ConversionOnboardingResponse,
        progressCallback: UploadProgressCallback? = nil
    ) async throws -> APIResponse<ConversionCompleteResponse> {
        Config.log("🚀 Starting conversion onboarding upload")

        // Verify user is authenticated
        guard let userId = AuthService.shared.user?.id else {
            throw ConversionOnboardingError.userNotAuthenticated
        }

        Config.log("👤 User ID: \(userId)")

        // ==================================================
        // PHASE 1: Convert Voice Recordings to Base64
        // ==================================================
        progressCallback?("Converting voice recordings...", 0.1)

        // Helper function to convert voice file URL to base64
        func convertVoiceToBase64(fileURL: URL, name: String) throws -> String {
            Config.log("🎙️  Converting \(name) to base64...")

            do {
                let audioData = try Data(contentsOf: fileURL)
                let base64Audio = audioData.base64EncodedString()
                let dataURI = "data:audio/m4a;base64,\(base64Audio)"

                Config.log("✅ \(name) converted: \(audioData.count) bytes")

                return dataURI
            } catch {
                Config.log("❌ Failed to convert \(name): \(error)")
                throw ConversionOnboardingError.voiceConversionFailed(name)
            }
        }

        let whyItMattersAudio = try convertVoiceToBase64(
            fileURL: response.whyItMatters,
            name: "whyItMatters"
        )
        progressCallback?("Converting voice recordings...", 0.3)

        let costOfQuittingAudio = try convertVoiceToBase64(
            fileURL: response.costOfQuitting,
            name: "costOfQuitting"
        )
        progressCallback?("Converting voice recordings...", 0.5)

        let commitmentAudio = try convertVoiceToBase64(
            fileURL: response.commitmentVoice,
            name: "commitment"
        )
        progressCallback?("Preparing data...", 0.6)

        // ==================================================
        // PHASE 2: Build Request Body
        // ==================================================
        Config.log("📦 Building request body...")

        let formatter = ISO8601DateFormatter()

        // Get device metadata for push notifications
        let deviceMetadata: [String: Any] = [
            "type": "apns",
            "device_model": UIDevice.current.model,
            "os_version": "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
            "locale": Locale.current.identifier,
            "timezone": TimeZone.current.identifier
        ]

        // Get push token if available
        let pushToken = UserDefaultsManager.get("voip_token") as String?

        let requestBody: [String: Any] = [
            // Identity & Aspiration
            "goal": response.goal,
            "goalDeadline": formatter.string(from: response.goalDeadline),
            "motivationLevel": response.motivationLevel,
            "whyItMattersAudio": whyItMattersAudio,

            // Pattern Recognition
            "attemptCount": response.attemptCount,
            "lastAttemptOutcome": response.lastAttemptOutcome,
            "previousAttemptOutcome": response.previousAttemptOutcome,
            "favoriteExcuse": response.favoriteExcuse,
            "whoDisappointed": response.whoDisappointed,
            "quitTime": formatter.string(from: response.quitTime),

            // The Cost
            "costOfQuittingAudio": costOfQuittingAudio,
            "futureIfNoChange": response.futureIfNoChange,

            // Commitment Setup
            "dailyCommitment": response.dailyCommitment,
            "callTime": formatter.string(from: response.callTime),
            "strikeLimit": response.strikeLimit,
            "commitmentAudio": commitmentAudio,
            "witness": response.witness,

            // Decision
            "willDoThis": response.willDoThis,
            "chosenPath": response.chosenPath.rawValue,

            // Permissions
            "notificationsGranted": response.notificationsGranted,
            "callsGranted": response.callsGranted,

            // Metadata
            "completedAt": formatter.string(from: response.completedAt),
            "totalTimeSpent": Int(response.totalTimeSpent),

            // Optional: Push notifications
            "deviceMetadata": deviceMetadata
        ]

        // Add push token if available
        var finalBody = requestBody
        if let token = pushToken {
            finalBody["pushToken"] = token
        }

        Config.log("📊 Request body prepared with \(finalBody.keys.count) fields")

        // ==================================================
        // PHASE 3: Upload to Backend
        // ==================================================
        progressCallback?("Uploading to backend...", 0.7)

        do {
            let apiResponse: APIResponse<ConversionCompleteResponse> = try await APIService.shared.post("/api/onboarding/conversion/complete", body: finalBody)

            progressCallback?("Upload complete!", 1.0)

            if apiResponse.success {
                Config.log("✅ Conversion onboarding uploaded successfully")
                if let uploads = apiResponse.data?.voiceUploads {
                    let why = uploads.whyItMatters != nil ? "✅" : "❌"
                    let cost = uploads.costOfQuitting != nil ? "✅" : "❌"
                    let commit = uploads.commitment != nil ? "✅" : "❌"
                    Config.log("📊 Voice uploads: \(why) whyItMatters, \(cost) costOfQuitting, \(commit) commitment")
                } else {
                    Config.log("📊 Voice uploads: (no data)")
                }
            } else {
                Config.log("❌ Upload failed: \(apiResponse.error ?? "Unknown error")")
            }

            return apiResponse

        } catch {
            Config.log("💥 Network error during upload: \(error)")
            throw ConversionOnboardingError.networkError(error)
        }
    }

    /// Test connectivity to backend
    func testBackendConnectivity() async -> Bool {
        do {
            let response: APIResponse<[String: String]> = try await APIService.shared.get("/api/health")
            return response.success
        } catch {
            Config.log("❌ Backend connectivity test failed: \(error)")
            return false
        }
    }
}

// MARK: - Preview & Testing Support

#if DEBUG
extension ConversionOnboardingService {
    /// Create mock response for preview testing
    static func mockResponse() -> ConversionOnboardingResponse {
        ConversionOnboardingResponse(
            goal: "Get fit and build discipline",
            goalDeadline: Date().addingTimeInterval(180 * 86400), // 6 months
            motivationLevel: 8,
            whyItMatters: URL(fileURLWithPath: "/tmp/mock_why_it_matters.m4a"),
            attemptCount: 3,
            lastAttemptOutcome: "Gave up after 2 weeks",
            previousAttemptOutcome: "Stopped after injury",
            favoriteExcuse: "Too busy with work",
            whoDisappointed: "My family and myself",
            quitTime: Date().addingTimeInterval(-14 * 86400), // 2 weeks ago
            costOfQuitting: URL(fileURLWithPath: "/tmp/mock_cost_of_quitting.m4a"),
            futureIfNoChange: "Overweight, unhealthy, watching life pass by",
            dailyCommitment: "30 min gym session",
            callTime: Calendar.current.date(bySettingHour: 20, minute: 30, second: 0, of: Date())!,
            strikeLimit: 3,
            commitmentVoice: URL(fileURLWithPath: "/tmp/mock_commitment.m4a"),
            witness: "My spouse",
            willDoThis: true,
            chosenPath: .hopeful,
            notificationsGranted: true,
            callsGranted: true,
            completedAt: Date(),
            totalTimeSpent: 1200 // 20 minutes
        )
    }
}
#endif

