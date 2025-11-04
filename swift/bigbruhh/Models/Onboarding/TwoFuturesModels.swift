//
//  TwoFuturesModels.swift
//  bigbruhh
//
//  Two Futures onboarding data models
//

import Foundation

enum FutureVoice {
    case hopeful  // You that wants you to win - gives hope
    case doubtful // You that has no hope in you - destroys it
    case both     // Rare moment of agreement
}

enum OnboardingStepType {
    case debate(messages: [DebateMessage])
    case input(config: InputConfig)
}

struct DebateMessage: Identifiable {
    let id = UUID()
    let speaker: FutureVoice
    let text: String
    let delay: TimeInterval  // Stagger for typewriter effect
}

struct InputConfig {
    let question: String
    let inputType: InputType
    let helperText: String?
    let skipAllowed: Bool
}

enum InputType {
    case text(placeholder: String?)
    case voice(minDuration: Int?, maxDuration: Int?)
    case choice(options: [String])
    case timePicker
    case datePicker
    case numberStepper(range: ClosedRange<Int>)
}

struct OnboardingStep {
    let id: Int
    let type: OnboardingStepType

    var isDebate: Bool {
        if case .debate = type { return true }
        return false
    }

    var isInput: Bool {
        if case .input = type { return true }
        return false
    }
}

struct TwoFuturesOnboardingResponse: Codable {
    // Identity
    let name: String
    let nonNegotiable: String
    let energyPeak: String
    let antiAccountability: String?

    // Commitment
    let dailyCommitment: String
    let commitmentTime: Date

    // Patterns
    let favoriteExcuse: String
    let changeTrigger: String
    let quitCount: Int

    // Accountability
    let failureStrikes: Int
    let witness: String

    // Voice recordings (3 total, ~70-105 sec)
    let voiceOriginURL: URL?      // ~30-45 sec
    let voiceCommitmentURL: URL   // ~20-30 sec
    let voiceCostURL: URL         // ~20-30 sec

    // Path choice
    let chosenPath: PathChoice

    enum PathChoice: String, Codable {
        case hopeful
        case doubtful
    }
}
