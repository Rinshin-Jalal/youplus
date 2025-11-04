//
//  UserResponse.swift
//  bigbruhh
//
//  Structure for storing user responses to onboarding steps
//  Migrated from: nrn/types/onboarding.ts - UserResponse interface
//

import Foundation

// MARK: - User Response

struct UserResponse: Codable, Identifiable {
    let id: UUID
    let stepId: Int
    let type: StepType
    let value: ResponseValue
    let timestamp: Date
    let voiceUri: String?                    // File path for voice recordings
    let duration: Double?                    // Duration in seconds (voice or long press)
    let dbField: [String]?                   // Database field mapping from step definition
    let analysis: VoiceAnalysis?             // Enhanced voice analysis data
    let evaluation: ResponseEvaluation?      // Response evaluation data
    let psychologicalMarkers: PsychologicalMarkers?  // Psychological metadata for backend
    let transcript: String?                  // Transcript if available (for voice)

    enum CodingKeys: String, CodingKey {
        case id
        case stepId
        case type
        case value
        case timestamp
        case voiceUri
        case duration
        case dbField = "db_field"
        case analysis
        case evaluation
        case psychologicalMarkers = "psychological_markers"
        case transcript
    }

    init(
        id: UUID = UUID(),
        stepId: Int,
        type: StepType,
        value: ResponseValue,
        timestamp: Date = Date(),
        voiceUri: String? = nil,
        duration: Double? = nil,
        dbField: [String]? = nil,
        analysis: VoiceAnalysis? = nil,
        evaluation: ResponseEvaluation? = nil,
        psychologicalMarkers: PsychologicalMarkers? = nil,
        transcript: String? = nil
    ) {
        self.id = id
        self.stepId = stepId
        self.type = type
        self.value = value
        self.timestamp = timestamp
        self.voiceUri = voiceUri
        self.duration = duration
        self.dbField = dbField
        self.analysis = analysis
        self.evaluation = evaluation
        self.psychologicalMarkers = psychologicalMarkers
        self.transcript = transcript
    }
}

// MARK: - Response Value Types

enum ResponseValue: Codable {
    case text(String)
    case number(Double)
    case bool(Bool)
    case sliders([Double])
    case choice(String)
    case voiceData(Data)
    case timeWindow(TimeWindow)
    case timezone(String)

    struct TimeWindow: Codable {
        let start: String  // HH:mm format
        let end: String    // HH:mm format
    }
}

// MARK: - Convenience Extensions

extension UserResponse {
    var isVoiceResponse: Bool {
        return type == .voice
    }

    var needsRetry: Bool {
        return evaluation?.action == .retry
    }

    var meetsStandards: Bool {
        return analysis?.meetsStandards ?? true
    }
}
