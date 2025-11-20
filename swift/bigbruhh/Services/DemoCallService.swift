//
//  DemoCallService.swift
//  bigbruhh
//
//  Service to generate personalized demo call using OpenAI + Cartesia TTS
//  Uses cloned voice to create realistic accountability call preview
//

import Foundation
import AVFoundation
import os

enum DemoCallError: Error {
    case noVoiceCloneID
    case messageGenerationFailed(String)
    case ttsGenerationFailed(String)
    case networkError(Error)

    var localizedDescription: String {
        switch self {
        case .noVoiceCloneID:
            return "No voice clone ID available"
        case .messageGenerationFailed(let message):
            return "Message generation failed: \(message)"
        case .ttsGenerationFailed(let message):
            return "TTS generation failed: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

private let demoCallLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp.bundle", category: "DemoCall")

class DemoCallService {
    static let shared = DemoCallService()

    private let openAIAPIKey: String
    private let cartesiaAPIKey: String
    private let openAIBaseURL = "https://api.openai.com/v1"
    private let cartesiaBaseURL = "https://api.cartesia.ai"

    private init() {
        self.openAIAPIKey = Config.get("OPENAI_API_KEY") ?? ""
        self.cartesiaAPIKey = Config.get("CARTESIA_API_KEY") ?? ""
    }

    /// Generate demo call audio with personalized message
    /// - Parameters:
    ///   - voiceCloneID: Cartesia voice clone ID
    ///   - userName: User's name
    ///   - goal: User's goal from onboarding
    ///   - motivationLevel: User's motivation level (1-10)
    /// - Returns: Demo call audio with transcript
    func generateDemoCall(
        voiceCloneID: String,
        userName: String,
        goal: String,
        motivationLevel: Int
    ) async throws -> DemoCallAudio {
        demoCallLogger.log("🎬 Generating demo call for \(userName, privacy: .public)")

        // Step 1: Generate personalized message using OpenAI
        let message = try await generatePersonalizedMessage(
            userName: userName,
            goal: goal,
            motivationLevel: motivationLevel
        )

        demoCallLogger.log("✅ Generated message: \(message, privacy: .public)")

        // Step 2: Convert message to speech using Cartesia TTS
        let audioURL = try await generateSpeech(
            text: message,
            voiceID: voiceCloneID
        )

        demoCallLogger.log("✅ Generated TTS audio")

        // Get audio duration
        let asset = AVURLAsset(url: audioURL)
        let duration = try await asset.load(.duration)

        return DemoCallAudio(
            audioURL: audioURL,
            transcript: message,
            duration: CMTimeGetSeconds(duration)
        )
    }

    /// Generate personalized message using OpenAI
    private func generatePersonalizedMessage(
        userName: String,
        goal: String,
        motivationLevel: Int
    ) async throws -> String {
        let systemPrompt = """
        You are the user's Future Self - a version of them who has achieved their goal. You're calling them for their first accountability check-in.

        Your tone is:
        - Direct and no-nonsense
        - Uses "I" (you're their future self)
        - Short, punchy sentences
        - Confrontational but supportive
        - References their specific goal

        Keep the message under 100 words and make it feel like a real phone call opening.
        """

        let userPrompt = """
        Generate a 60-90 second accountability call opening for:
        - Name: \(userName)
        - Goal: \(goal)
        - Motivation Level: \(motivationLevel)/10

        Start with something like "Hey, it's me - you from the future" and reference their specific goal. Make it personal and confrontational.
        """

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "max_tokens": 200,
            "temperature": 0.8
        ]

        var request = URLRequest(url: URL(string: "\(openAIBaseURL)/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw DemoCallError.messageGenerationFailed("Invalid response")
            }

            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw DemoCallError.messageGenerationFailed(errorMessage)
            }

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let choices = json?["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw DemoCallError.messageGenerationFailed("Invalid response format")
            }

            return content.trimmingCharacters(in: .whitespacesAndNewlines)

        } catch let error as DemoCallError {
            throw error
        } catch {
            throw DemoCallError.networkError(error)
        }
    }

    /// Generate speech using Cartesia Sonic 3 TTS
    private func generateSpeech(text: String, voiceID: String) async throws -> URL {
        let requestBody: [String: Any] = [
            "model_id": "sonic-3",
            "transcript": text,
            "voice": [
                "mode": "id",
                "id": voiceID
            ],
            "language": "en",
            "generation_config": [
                "volume": 1.0,
                "speed": 1.0,
                "emotion": "neutral"
            ],
            "output_format": [
                "container": "wav",
                "encoding": "pcm_s16le",
                "sample_rate": 44100
            ]
        ]

        var request = URLRequest(url: URL(string: "\(cartesiaBaseURL)/tts/bytes")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(cartesiaAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("2024-06-10", forHTTPHeaderField: "Cartesia-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw DemoCallError.ttsGenerationFailed("Invalid response")
            }

            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw DemoCallError.ttsGenerationFailed(errorMessage)
            }

            // Save audio to temp file
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("demo_call_\(UUID().uuidString).wav")

            try data.write(to: tempURL)

            return tempURL

        } catch let error as DemoCallError {
            throw error
        } catch {
            throw DemoCallError.networkError(error)
        }
    }
}

