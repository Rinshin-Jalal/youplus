//
//  StepDefinition.swift
//  bigbruhh
//
//  Defines the structure of each onboarding step
//  Migrated from: nrn/types/onboarding.ts - StepDefinition interface
//

import Foundation

// MARK: - Step Definition

struct StepDefinition: Codable, Identifiable {
    let id: Int                              // 1-45 BigBruh steps
    let phase: OnboardingPhase               // Phase of onboarding
    let type: StepType                       // Type of input required
    let prompt: String                       // Main prompt text for all step types
    let dbField: [String]?                   // Database field name(s)
    let options: [String]?                   // For choice steps
    let helperText: String?                  // Helper text to guide user
    let sliders: [SliderConfig]?             // For dual_sliders steps
    let minDuration: Int?                    // For long_press_activate (milliseconds)
    let requiredPhrase: String?              // For voice steps to enforce phrase
    let displayType: String?                 // Special rendering hints for explanation steps

    enum CodingKeys: String, CodingKey {
        case id
        case phase
        case type
        case prompt
        case dbField = "db_field"
        case options
        case helperText
        case sliders
        case minDuration
        case requiredPhrase
        case displayType
    }
}

protocol PromptResolving {
    func resolve(prompt: String) -> String
}

struct StaticPromptResolver: PromptResolving {
    func resolve(prompt: String) -> String {
        return prompt
    }
}

extension StepDefinition {
    func resolvedPrompt(using resolver: any PromptResolving) -> String {
        return resolver.resolve(prompt: prompt)
    }
}

// MARK: - Convenience Extensions

extension StepDefinition {
    /// Whether this step requires user input
    var requiresInput: Bool {
        switch type {
        case .explanation:
            return false
        default:
            return true
        }
    }

    /// Whether this step records audio
    var isVoiceStep: Bool {
        return type == .voice
    }

    /// Whether this step has choices
    var hasChoices: Bool {
        return type == .choice && options != nil
    }

    /// Whether this step has sliders
    var hasSliders: Bool {
        return type == .dualSliders && sliders != nil
    }
}
