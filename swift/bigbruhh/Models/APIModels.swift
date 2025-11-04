//
//  APIModels.swift
//  bigbruhh
//
//  Codable models matching backend API responses
//  Reference: be/src/routes/* for API structure
//

import Foundation

// MARK: - Identity Models

struct IdentityResponse: Codable {
    let success: Bool
    let data: IdentityData?
    let error: String?
}

struct IdentityData: Codable {
    let id: String
    let userId: String?
    let name: String?
    let identitySummary: String?
    let summary: String?
    let createdAt: Date?
    let updatedAt: Date?

    // STATUS FIELDS (from identity_status table)
    let trustPercentage: Int?
    let currentStreakDays: Int?
    let promisesMadeCount: Int?
    let promisesBrokenCount: Int?
    let nextCallTimestamp: TimeInterval?
    let statusSummary: StatusSummary?

    // OPERATIONAL FIELDS
    let dailyNonNegotiable: String?
    let transformationTargetDate: String?

    // IDENTITY FIELDS (AI-extracted psychological profile)
    let currentIdentity: String?
    let aspiratedIdentity: String?
    let fearIdentity: String?
    let coreStruggle: String?
    let biggestEnemy: String?
    let primaryExcuse: String?
    let sabotageMethod: String?

    // BEHAVIORAL FIELDS (AI-extracted action patterns)
    let weaknessTimeWindow: String?
    let procrastinationFocus: String?
    let lastMajorFailure: String?
    let pastSuccessStory: String?
    let accountabilityTrigger: String?
    let warCry: String?

    // Note: Backend sends camelCase but decoder converts from snake_case
    // So camelCase keys from backend become snake_case during decoding
    // Example: trustPercentage (backend) -> trust_percentage (decoder) -> trustPercentage (Swift property)
}

struct IdentityStats: Codable {
    let totalCalls: Int
    let answeredCalls: Int
    let successRate: Int
    let longestStreak: Int
}

struct StatusSummary: Codable {
    let disciplineLevel: String?
    let disciplineMessage: String?
    let notificationTitle: String?
    let notificationMessage: String?
    let generatedAt: String?
}

// MARK: - Call Config Models

struct CallConfigResponse: Codable {
    let success: Bool
    let agentId: String?
    let mood: String?
    let callUUID: String?
    let prompts: CallPrompts?
    let voiceId: String?
    let metadata: CallMetadata?
    let error: String?
}

struct CallPrompts: Codable {
    let systemPrompt: String
    let firstMessage: String
}

struct CallMetadata: Codable {
    let userId: String
    let callType: String
    let toneUsed: String
    let userStreak: Int?
    let hasOnboardingData: Bool
    let recentExcuseCount: Int?
    let behavioralIntelligenceActive: Bool
    let optimizedEngine: Bool?
    let promptGenerationTimeMs: Int?
    let estimatedTokens: Int?
    let tokenReductionAchieved: String?
}

// MARK: - Call Log Models

struct CallLogResponse: Codable {
    let success: Bool
    let data: [CallLogEntry]?
    let error: String?
}

struct CallLogEntry: Codable, Identifiable {
    let id: String
    let userId: String
    let callType: String // "morning", "evening", "apology_call", "first_call", "emergency", "daily_reckoning"
    let createdAt: Date
    let audioUrl: String?
    let durationSec: Int?
    let confidenceScores: [String: AnyCodableValue]?
    let conversationId: String?
    let status: String?
    let transcriptJson: [String: AnyCodableValue]?
    let transcriptSummary: String?
    let costCents: Int?
    let startTime: Date?
    let endTime: Date?
    let callSuccessful: String? // "success", "failure", "unknown"
    let source: String? // "vapi", "elevenlabs"
    let isRetry: Bool?
    let retryAttemptNumber: Int?
    let originalCallUuid: String?
    let retryReason: String? // "missed", "declined", "failed"
    let urgency: String? // "high", "critical", "emergency"
    let acknowledged: Bool?
    let acknowledgedAt: Date?
    let timeoutAt: Date?
    
    // Enriched fields for Evidence screen
    let promisesAnalyzed: Int?
    let promisesBroken: Int?
    let promisesKept: Int?
    let worstExcuse: String?
    // brutalReview removed (bloat elimination)

    enum CodingKeys: String, CodingKey {
        case id, userId = "user_id", callType = "call_type"
        case createdAt = "created_at"
        case audioUrl = "audio_url"
        case durationSec = "duration_sec"
        case confidenceScores = "confidence_scores"
        case conversationId = "conversation_id"
        case status
        case transcriptJson = "transcript_json"
        case transcriptSummary = "transcript_summary"
        case costCents = "cost_cents"
        case startTime = "start_time"
        case endTime = "end_time"
        case callSuccessful = "call_successful"
        case source
        case isRetry = "is_retry"
        case retryAttemptNumber = "retry_attempt_number"
        case originalCallUuid = "original_call_uuid"
        case retryReason = "retry_reason"
        case urgency
        case acknowledged
        case acknowledgedAt = "acknowledged_at"
        case timeoutAt = "timeout_at"
        case promisesAnalyzed = "promises_analyzed"
        case promisesBroken = "promises_broken"
        case promisesKept = "promises_kept"
        case worstExcuse = "worst_excuse"
        // brutalReview removed
    }

    var displayCallType: String {
        switch callType {
        case "morning": return "Morning Check-in"
        case "evening": return "Evening Review"
        case "apology_call": return "Apology Call"
        case "first_call": return "First Call"
        case "emergency": return "Emergency Call"
        case "daily_reckoning": return "Daily Reckoning"
        default: return callType.capitalized
        }
    }

    var duration: String {
        guard let sec = durationSec, sec > 0 else { return "Not answered" }
        let minutes = sec / 60
        let seconds = sec % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Promise Models

struct PromisesResponse: Codable {
    let success: Bool
    let data: [Promise]?
    let error: String?
}

struct Promise: Codable, Identifiable {
    let id: String
    let userId: String
    let createdAt: Date
    let promiseDate: String
    let promiseText: String
    let status: String // "pending", "kept", "broken"
    let excuseText: String?
    let promiseOrder: Int
    let priorityLevel: String // "low", "medium", "high", "critical"
    let category: String
    let timeSpecific: Bool
    let targetTime: String?
    let createdDuringCall: Bool
    let parentPromiseId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case createdAt = "created_at"
        case promiseDate = "promise_date"
        case promiseText = "promise_text"
        case status
        case excuseText = "excuse_text"
        case promiseOrder = "promise_order"
        case priorityLevel = "priority_level"
        case category
        case timeSpecific = "time_specific"
        case targetTime = "target_time"
        case createdDuringCall = "created_during_call"
        case parentPromiseId = "parent_promise_id"
    }

    var isCompleted: Bool {
        return status == "kept"
    }

    var isBroken: Bool {
        return status == "broken"
    }
}

struct CreatePromiseRequest: Codable {
    let userId: String
    let promiseDate: String
    let promiseText: String
    let excuseText: String?
    let promiseOrder: Int
    let priorityLevel: String // "low", "medium", "high", "critical"
    let category: String
    let timeSpecific: Bool
    let targetTime: String?
    let createdDuringCall: Bool
    let parentPromiseId: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case promiseDate = "promise_date"
        case promiseText = "promise_text"
        case excuseText = "excuse_text"
        case promiseOrder = "promise_order"
        case priorityLevel = "priority_level"
        case category
        case timeSpecific = "time_specific"
        case targetTime = "target_time"
        case createdDuringCall = "created_during_call"
        case parentPromiseId = "parent_promise_id"
    }
}

struct CompletePromiseRequest: Codable {
    let promiseId: String
    let status: String // "kept" or "broken"
    let excuseText: String?

    enum CodingKeys: String, CodingKey {
        case promiseId = "promise_id"
        case status
        case excuseText = "excuse_text"
    }
}

// MARK: - Settings Models

struct SettingsScheduleResponse: Codable {
    let success: Bool
    let data: ScheduleSettings?
    let error: String?
}

struct ScheduleSettings: Codable {
    let userId: String
    let morningTime: String // "07:00"
    let eveningTime: String // "21:00"
    let timezone: String // "America/New_York"
    let morningEnabled: Bool
    let eveningEnabled: Bool
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case morningTime = "morning_time"
        case eveningTime = "evening_time"
        case timezone
        case morningEnabled = "morning_enabled"
        case eveningEnabled = "evening_enabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UpdateScheduleRequest: Codable {
    let userId: String
    let morningTime: String?
    let eveningTime: String?
    let timezone: String?
    let morningEnabled: Bool?
    let eveningEnabled: Bool?
}

// MARK: - Countdown Models

struct CountdownResponse: Codable {
    let success: Bool
    let data: CountdownData?
    let error: String?
}

struct CountdownData: Codable {
    let nextCallTime: Date?
    let timeRemaining: TimeInterval?
    let callType: String? // "morning" or "evening"
    let isCallDue: Bool

    enum CodingKeys: String, CodingKey {
        case nextCallTime, timeRemaining, callType, isCallDue
    }
}

// MARK: - Voice Clip Models

struct VoiceClipsResponse: Codable {
    let success: Bool
    let data: [VoiceClip]?
    let error: String?
}

struct VoiceClip: Codable, Identifiable {
    let id: String
    let userId: String
    let stepId: Int
    let audioUrl: String
    let transcription: String?
    let duration: Double?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, userId = "user_id", stepId = "step_id"
        case audioUrl = "audio_url", transcription, duration
        case createdAt = "created_at"
    }
}

// MARK: - Onboarding Models

struct OnboardingCompleteRequest: Codable {
    let userId: String
    let state: OnboardingStateData
    let voipToken: String?
}

struct OnboardingStateData: Codable {
    let currentStep: Int
    let responses: [String: OnboardingResponse]
    let totalResponses: Int
    let progressPercentage: Int
    let startedAt: String
    let lastSavedAt: String
    let isCompleted: Bool?
    let completedAt: String?
    let userName: String?
    let callTime: String?
    let userTimezone: String?
}

struct OnboardingResponse: Codable {
    let type: String // "voice", "text", "choice", "dual_sliders", etc.
    let value: String? // Can be text, base64 audio, or JSON-encoded value
    let timestamp: String
    let voiceUri: String?
    let duration: Double?
    let audioFileSize: Int?
    let audioFormat: String?
    let dbField: [String]? // Database field mapping (e.g., ["identity_name"])

    enum CodingKeys: String, CodingKey {
        case type, value, timestamp, voiceUri, duration, audioFileSize, audioFormat
        case dbField = "db_field"
    }
}

struct OnboardingCompleteResponse: Codable {
    let success: Bool
    let message: String?
    let completedAt: String?
    let totalSteps: Int?
    let filesProcessed: Int?
    let processingWarnings: String?
    let identityExtraction: IdentityExtraction?
    let error: String?
}

struct IdentityExtraction: Codable {
    let success: Bool
    let fieldsExtracted: Int
    let voiceTranscribed: Int
    let error: String?
}

// MARK: - VOIP Token Models

struct VOIPTokenRequest: Codable {
    let userId: String
    let voipToken: String
    let platform: String // "ios"
    let deviceModel: String?
    let osVersion: String?
}

struct VOIPTokenResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
}

// MARK: - Brutal Reality Models (REMOVED - bloat elimination)
// Stub types kept for backward compatibility during transition

// MARK: - Generic API Response

struct GenericAPIResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
    let data: [String: AnyCodableValue]?
}

// Helper for dynamic JSON values
enum AnyCodableValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([AnyCodableValue])
    case dictionary([String: AnyCodableValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([AnyCodableValue].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: AnyCodableValue].self) {
            self = .dictionary(value)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode AnyCodableValue"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}
