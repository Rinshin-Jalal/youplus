//
//  OnboardingDataPush.swift
//  bigbruhh
//
//  Service to push onboarding data to backend after payment completion
//  Matches NRN OnboardingDataPush.ts functionality
//

import Foundation
import SwiftUI

enum OnboardingDataPushError: Error {
    case userNotAuthenticated
    case invalidData
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .userNotAuthenticated:
            return "User not authenticated"
        case .invalidData:
            return "Invalid onboarding data"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

class OnboardingDataPushService {
    static let shared = OnboardingDataPushService()
    
    private init() {}
    
    func pushOnboardingData() async throws -> APIResponse<OnboardingCompleteResponse> {
        Config.log("Pushing onboarding data to backend", category: "OnboardingPush")

        // Get current user ID
        guard let userId = AuthService.shared.user?.id else {
            throw OnboardingDataPushError.userNotAuthenticated
        }

        // Get VOIP token if available
        let voipToken = UserDefaultsManager.get("voip_token") ?? ""

        // Get onboarding data
        let onboardingData = OnboardingDataManager.shared
        
        // Check if we have completed data
        guard let completedData = onboardingData.completedData else {
            throw OnboardingDataPushError.invalidData
        }
        
        // Convert onboarding state to API format
        let formatter = ISO8601DateFormatter()
        
        // Build responses dictionary
        var responsesDict: [String: OnboardingResponse] = [:]
        for (stepId, response) in completedData.responses {
            // Convert ResponseValue to String
            let valueString: String?
            switch response.value {
            case .text(let text):
                // Check if this is a file path (voice recording)
                if text.hasSuffix(".m4a") {
                    // Convert file path to base64 for backend
                    do {
                        let audioData = try Data(contentsOf: URL(fileURLWithPath: text))
                        let base64Audio = audioData.base64EncodedString()
                        valueString = "data:audio/m4a;base64,\(base64Audio)"
                        print("✅ Converted audio file to base64: \(text)")
                    } catch {
                        print("❌ Failed to convert audio file to base64: \(error)")
                        valueString = text // Fallback to original text
                    }
                } else {
                    valueString = text
                }
            case .number(let number):
                valueString = String(number)
            case .bool(let bool):
                valueString = String(bool)
            case .sliders(let sliders):
                valueString = sliders.map { String($0) }.joined(separator: ",")
            case .choice(let choice):
                valueString = choice
            case .voiceData(let data):
                valueString = data.base64EncodedString()
            case .timeWindow(let window):
                valueString = "\(window.start)-\(window.end)"
            case .timezone(let tz):
                valueString = tz
            }
            
            responsesDict[String(stepId)] = OnboardingResponse(
                type: response.type.rawValue,
                value: valueString,
                timestamp: formatter.string(from: response.timestamp),
                voiceUri: response.voiceUri,
                duration: response.duration,
                audioFileSize: nil,
                audioFormat: nil,
                dbField: response.dbField
            )
        }
        
        // Calculate progress percentage (total steps is 45)
        let progressPercentage = Int((Double(completedData.currentStep) / 45.0) * 100)
        
        // Format dates
        let startedAtString = formatter.string(from: completedData.startedAt)
        let lastSavedAtString = formatter.string(from: Date())
        let completedAtString = completedData.completedAt.map { formatter.string(from: $0) }
        
        let onboardingState = OnboardingStateData(
            currentStep: completedData.currentStep,
            responses: responsesDict,
            totalResponses: completedData.responses.count,
            progressPercentage: progressPercentage,
            startedAt: startedAtString,
            lastSavedAt: lastSavedAtString,
            isCompleted: completedData.isCompleted,
            completedAt: completedAtString,
            userName: completedData.userName,
            callTime: completedData.callTime,
            userTimezone: completedData.userTimezone
        )

        let request = OnboardingCompleteRequest(
            userId: userId,
            state: onboardingState,
            voipToken: voipToken.isEmpty ? nil : voipToken
        )

        // Make API call using existing APIService method
        let identityResponse: APIResponse<IdentityExtraction> = try await APIService.shared.pushOnboardingData(request: request)
        
        // Convert to OnboardingCompleteResponse format
        let response = APIResponse<OnboardingCompleteResponse>(
            success: identityResponse.success,
            data: OnboardingCompleteResponse(
                success: identityResponse.success,
                message: identityResponse.success ? "Onboarding data processed successfully" : nil,
                completedAt: ISO8601DateFormatter().string(from: Date()),
                totalSteps: completedData.responses.count,
                filesProcessed: completedData.responses.values.filter { $0.type == .voice }.count,
                processingWarnings: nil,
                identityExtraction: identityResponse.data,
                error: identityResponse.error
            ),
            error: identityResponse.error
        )

        if response.success {
            Config.log("✅ Onboarding data pushed successfully", category: "OnboardingPush")
        } else {
            Config.log("❌ Failed to push onboarding data: \(response.error ?? "Unknown error")", category: "OnboardingPush")
        }

        return response
    }

    func testBackendConnectivity() async -> Bool {
        do {
            let response: APIResponse<[String: String]> = try await APIService.shared.get("/api/health")
            return response.success
        } catch {
            Config.log("❌ Backend connectivity test failed: \(error)", category: "OnboardingPush")
            return false
        }
    }
}
