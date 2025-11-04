//
//  OnboardingModels.swift
//  bigbruhh
//
//  Core enums and types for the 45-step psychological onboarding system
//  Migrated from: nrn/types/onboarding.ts
//

import Foundation

// MARK: - User Path Types

enum UserPath: String, Codable {
    case broken = "BROKEN"
    case hungry = "HUNGRY"
    case frozen = "FROZEN"
}

// MARK: - Step Types

enum StepType: String, Codable {
    case text = "text"
    case voice = "voice"
    case dualSliders = "dual_sliders"
    case choice = "choice"
    case timezoneSelection = "timezone_selection"
    case explanation = "explanation"
    case longPressActivate = "long_press_activate"
    case timeWindowPicker = "time_window_picker"
    case visualCommitmentSummary = "visual_commitment_summary"
}

// MARK: - Onboarding Phases

enum OnboardingPhase: String, Codable {
    case warningInitiation = "WARNING_INITIATION"
    case excuseDiscovery = "EXCUSE_DISCOVERY"
    case excuseConfrontation = "EXCUSE_CONFRONTATION"
    case patternAwareness = "PATTERN_AWARENESS"
    case patternAnalysis = "PATTERN_ANALYSIS"
    case identityRebuild = "IDENTITY_REBUILD"
    case commitmentSystem = "COMMITMENT_SYSTEM"
    case externalAnchors = "EXTERNAL_ANCHORS"
    case finalOath = "FINAL_OATH"
}

// MARK: - Voice Analysis

struct VoiceAnalysis: Codable {
    let strength: StrengthLevel
    let confidence: Double
    let authenticity: Double
    let commitment: Double
    let hesitation: Double
    let overallScore: Double
    let meetsStandards: Bool
    let emotionalTone: [String]
    let authenticityMarkers: [String]
    let weaknessFlags: [String]

    enum StrengthLevel: String, Codable {
        case weak
        case neutral
        case strong
    }
}

// MARK: - Response Evaluation

struct ResponseEvaluation: Codable {
    let level: StrengthLevel
    let score: Double
    let reasoning: String
    let action: EvaluationAction
    let attempts: Int

    enum StrengthLevel: String, Codable {
        case weak
        case neutral
        case strong
    }

    enum EvaluationAction: String, Codable {
        case retry
        case escalate
        case advance
    }
}

// MARK: - Psychological Markers

struct PsychologicalMarkers: Codable {
    let strengthLevel: String
    let authenticityScore: Double
    let commitmentLevel: Double
    let emotionalIndicators: [String]
    let vulnerabilityExpressed: Bool
    let excusePatterns: [String]
}

// MARK: - Slider Configuration

struct SliderConfig: Codable {
    let label: String
    let range: SliderRange

    struct SliderRange: Codable {
        let min: Int
        let max: Int
    }
}
