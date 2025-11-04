//
//  ConversionOnboardingModels.swift
//  bigbruhh
//
//  Conversion-focused onboarding models for 42-step psychological journey
//

import Foundation
import SwiftUI

// MARK: - Extended Step Types

enum ConversionStepType {
    case explanatory(config: ExplanatoryConfig)
    case aiCommentary(config: AICommentaryConfig)
    case debate(messages: [DebateMessage])
    case input(config: InputConfig)
    case demoCall
    case permissionRequest(type: PermissionType)
}

// MARK: - Explanatory Step

struct ExplanatoryConfig {
    let iconName: String          // SF Symbol name
    let title: String             // Main message
    let subtitle: String?         // Optional secondary text
    let backgroundColor: Color    // Background color
    let accentColor: Color        // Icon/text accent
}

// MARK: - AI Commentary

struct AICommentaryConfig {
    let message: String           // What the AI says
    let persona: AIPersona        // Voice/tone
    let showAvatar: Bool          // Show AI avatar/icon
    let emphasize: Bool           // Highlight this message
}

enum AIPersona {
    case futureYou                // "I'm you from the future"
    case accountability           // "No BS accountability coach"
    case neutral                  // Standard delivery

    var avatarIcon: String {
        switch self {
        case .futureYou: return "person.fill.viewfinder"
        case .accountability: return "exclamationmark.shield.fill"
        case .neutral: return "message.fill"
        }
    }

    var tone: String {
        switch self {
        case .futureYou: return "I'm you from the future."
        case .accountability: return "Let's cut the BS."
        case .neutral: return "Here's what you need to know."
        }
    }
}

// MARK: - Permission Types

enum PermissionType {
    case notifications
    case calls
    case microphone

    var title: String {
        switch self {
        case .notifications: return "I need to be able to reach you"
        case .calls: return "I need to be able to call you"
        case .microphone: return "I need to hear your commitment"
        }
    }

    var explanation: String {
        switch self {
        case .notifications: return "Daily reminders and accountability check-ins"
        case .calls: return "Your daily accountability call. No hiding."
        case .microphone: return "Voice recordings make your commitment real"
        }
    }

    var iconName: String {
        switch self {
        case .notifications: return "bell.fill"
        case .calls: return "phone.fill"
        case .microphone: return "mic.fill"
        }
    }
}

// MARK: - Conversion Onboarding Step

struct ConversionOnboardingStep {
    let id: Int
    let type: ConversionStepType

    // Computed properties for type checking
    var isExplanatory: Bool {
        if case .explanatory = type { return true }
        return false
    }

    var isAICommentary: Bool {
        if case .aiCommentary = type { return true }
        return false
    }

    var isDebate: Bool {
        if case .debate = type { return true }
        return false
    }

    var isInput: Bool {
        if case .input = type { return true }
        return false
    }

    var isDemoCall: Bool {
        if case .demoCall = type { return true }
        return false
    }

    var isPermissionRequest: Bool {
        if case .permissionRequest = type { return true }
        return false
    }
}

// MARK: - Conversion Response Model

struct ConversionOnboardingResponse: Codable {
    // Identity & Aspiration
    let goal: String
    let goalDeadline: Date
    let motivationLevel: Int           // 1-10
    let whyItMatters: URL              // Voice recording

    // Pattern Recognition
    let attemptCount: Int              // How many times tried
    let lastAttemptOutcome: String     // What happened
    let previousAttemptOutcome: String // Pattern emerges
    let favoriteExcuse: String         // Choice
    let whoDisappointed: String        // Gets personal
    let quitTime: Date                 // When they usually give up

    // The Cost
    let costOfQuitting: URL            // Voice recording
    let futureIfNoChange: String       // Where they'll be

    // Commitment Setup
    let dailyCommitment: String
    let callTime: Date
    let strikeLimit: Int               // 1-5
    let commitmentVoice: URL           // Voice recording
    let witness: String

    // Decision
    let willDoThis: Bool               // Yes or No
    let chosenPath: PathChoice

    enum PathChoice: String, Codable {
        case hopeful
        case doubtful
    }

    // Permissions
    var notificationsGranted: Bool = false
    var callsGranted: Bool = false

    // Metadata
    let completedAt: Date
    let totalTimeSpent: TimeInterval   // Track engagement
}
