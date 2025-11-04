//
//  ConversionStepDefinitions.swift
//  bigbruhh
//
//  42-step conversion-focused onboarding flow
//

import Foundation
import SwiftUI

// MARK: - 42-Step Conversion Flow

let CONVERSION_ONBOARDING_STEPS: [ConversionOnboardingStep] = [

    // ==========================================
    // PHASE 1: THE HOOK (Steps 1-4)
    // ==========================================

    ConversionOnboardingStep(
        id: 1,
        type: .explanatory(config: ExplanatoryConfig(
            iconName: "calendar.badge.exclamationmark",
            title: "You've Been Here Before",
            subtitle: "Started strong. Lasted a week. Then... nothing.",
            backgroundColor: .black,
            accentColor: Color(hex: "#FF6B6B")
        ))
    ),

    ConversionOnboardingStep(
        id: 2,
        type: .explanatory(config: ExplanatoryConfig(
            iconName: "brain.head.profile",
            title: "The Real Problem",
            subtitle: "It's not motivation. It's not discipline. It's that no one actually holds you accountable.",
            backgroundColor: .black,
            accentColor: Color(hex: "#4ECDC4")
        ))
    ),

    ConversionOnboardingStep(
        id: 3,
        type: .explanatory(config: ExplanatoryConfig(
            iconName: "phone.badge.checkmark",
            title: "What If Someone Did?",
            subtitle: "Every day. Real consequences. No escape.",
            backgroundColor: .black,
            accentColor: Color(hex: "#FFE66D")
        ))
    ),

    ConversionOnboardingStep(
        id: 4,
        type: .explanatory(config: ExplanatoryConfig(
            iconName: "magnifyingglass.circle.fill",
            title: "Let's Start",
            subtitle: "First, let's understand your pattern.",
            backgroundColor: .black,
            accentColor: Color(hex: "#A8DADC")
        ))
    ),

    // ==========================================
    // PHASE 2: FIRST CONTACT (Steps 5-10)
    // ==========================================

    ConversionOnboardingStep(
        id: 5,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "I'm you from the future. Here to make sure you don't quit. Again.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: true
        ))
    ),

    ConversionOnboardingStep(
        id: 6,
        type: .input(config: InputConfig(
            question: "What do you actually want to achieve?",
            inputType: .text(placeholder: "e.g., Build my startup, Get fit, Learn to code"),
            helperText: "Be specific. What's the real goal?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 7,
        type: .input(config: InputConfig(
            question: "When do you want this by?",
            inputType: .datePicker,
            helperText: "Pick a real deadline",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 8,
        type: .input(config: InputConfig(
            question: "On a scale of 1-10, how badly?",
            inputType: .numberStepper(range: 1...10),
            helperText: "How much do you actually want this?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 9,
        type: .input(config: InputConfig(
            question: "Why does this goal haunt you?",
            inputType: .voice(minDuration: 10, maxDuration: 30),
            helperText: "Take 10 seconds. What deeper truth makes this goal undeniable? Be explicit. Be honest.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 10,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Okay. Now let's look at your pattern.",
            persona: .accountability,
            showAvatar: true,
            emphasize: false
        ))
    ),

    // ==========================================
    // PHASE 3: PATTERN REVELATION (Steps 11-18)
    // ==========================================

    ConversionOnboardingStep(
        id: 11,
        type: .input(config: InputConfig(
            question: "How many times have you tried before?",
            inputType: .numberStepper(range: 0...20),
            helperText: "Be honest. How many attempts?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 12,
        type: .input(config: InputConfig(
            question: "What happened last time?",
            inputType: .text(placeholder: "Describe what happened"),
            helperText: nil,
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 13,
        type: .input(config: InputConfig(
            question: "And the time before that?",
            inputType: .text(placeholder: "What about before?"),
            helperText: "See the pattern?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 14,
        type: .debate(messages: [
            DebateMessage(speaker: .hopeful, text: "Maybe this time is different.", delay: 0.5),
            DebateMessage(speaker: .doubtful, text: "That's what you said last time.", delay: 1.5),
            DebateMessage(speaker: .hopeful, text: "People change.", delay: 2.5),
            DebateMessage(speaker: .doubtful, text: "You haven't.", delay: 3.5)
        ])
    ),

    ConversionOnboardingStep(
        id: 15,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "See? Even your futures know your pattern. Let's dig deeper.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: false
        ))
    ),

    ConversionOnboardingStep(
        id: 16,
        type: .input(config: InputConfig(
            question: "What's your favorite excuse?",
            inputType: .choice(options: [
                "No time",
                "Too tired",
                "Not ready yet",
                "I'll start tomorrow"
            ]),
            helperText: "Which one do you use most?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 17,
        type: .input(config: InputConfig(
            question: "Who have you disappointed by quitting?",
            inputType: .text(placeholder: "Name someone"),
            helperText: "This gets personal. Who's counting on you?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 18,
        type: .input(config: InputConfig(
            question: "When do you usually give up?",
            inputType: .text(placeholder: "tuesday night??"),
            helperText: "What time of day? Day of week?",
            skipAllowed: false
        ))
    ),

    // ==========================================
    // PHASE 4: THE COST (Steps 19-24)
    // ==========================================

    ConversionOnboardingStep(
        id: 19,
        type: .debate(messages: [
            // Dynamic based on excuse - placeholder for "No time"
            DebateMessage(speaker: .doubtful, text: "You had time for Netflix though.", delay: 0.5),
            DebateMessage(speaker: .hopeful, text: "You'll make time if it matters.", delay: 1.5)
        ])
    ),

    ConversionOnboardingStep(
        id: 20,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Here's what you need to hear. The cost of quitting again.",
            persona: .accountability,
            showAvatar: true,
            emphasize: true
        ))
    ),

    ConversionOnboardingStep(
        id: 21,
        type: .input(config: InputConfig(
            question: "What are you really afraid to lose?",
            inputType: .voice(minDuration: 10, maxDuration: 30),
            helperText: "Use 10 seconds. What exactly dies when you quit again? Be raw.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 22,
        type: .input(config: InputConfig(
            question: "Where will you be in 6 months if nothing changes?",
            inputType: .text(placeholder: "Describe your future"),
            helperText: "Be brutally honest.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 23,
        type: .debate(messages: [
            DebateMessage(speaker: .doubtful, text: "That's your future. Same pattern, same result.", delay: 0.5),
            DebateMessage(speaker: .hopeful, text: "Unless something changes.", delay: 2.0)
        ])
    ),

    ConversionOnboardingStep(
        id: 24,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Something needs to change. Let me show you what accountability looks like.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: false
        ))
    ),

    // ==========================================
    // PHASE 5: DEMO CALL (Steps 25-27)
    // ==========================================

    ConversionOnboardingStep(
        id: 25,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Starting tomorrow, I call you. Every day. This is what it looks like.",
            persona: .accountability,
            showAvatar: true,
            emphasize: true
        ))
    ),

    ConversionOnboardingStep(
        id: 26,
        type: .demoCall
    ),

    ConversionOnboardingStep(
        id: 27,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Every day. Same time. No excuses. No escape. Think you can handle that?",
            persona: .accountability,
            showAvatar: true,
            emphasize: true
        ))
    ),

    // ==========================================
    // PHASE 6: PERMISSION GATES (Steps 28-30)
    // ==========================================

    ConversionOnboardingStep(
        id: 28,
        type: .permissionRequest(type: .notifications)
    ),

    ConversionOnboardingStep(
        id: 29,
        type: .permissionRequest(type: .calls)
    ),

    ConversionOnboardingStep(
        id: 30,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Good. Now let's set this up for real.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: false
        ))
    ),

    // ==========================================
    // PHASE 7: COMMITMENT SETUP (Steps 31-37)
    // ==========================================

    ConversionOnboardingStep(
        id: 31,
        type: .debate(messages: [
            DebateMessage(speaker: .hopeful, text: "Are you actually ready this time?", delay: 0.5),
            DebateMessage(speaker: .doubtful, text: "Or are we wasting our time?", delay: 1.5)
        ])
    ),

    ConversionOnboardingStep(
        id: 32,
        type: .input(config: InputConfig(
            question: "What's your daily commitment?",
            inputType: .text(placeholder: "e.g., 30 min coding, 1 hour gym, 5 sales calls"),
            helperText: "Be specific. What will you do every day?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 33,
        type: .input(config: InputConfig(
            question: "What time should I call you?",
            inputType: .timePicker,
            helperText: "Pick your best energy time",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 34,
        type: .input(config: InputConfig(
            question: "How many strikes before you're out?",
            inputType: .numberStepper(range: 1...5),
            helperText: "Miss this many days = you're done",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 35,
        type: .input(config: InputConfig(
            question: "Will you actually follow through?",
            inputType: .voice(minDuration: 15, maxDuration: 30),
            helperText: "Be brutally honest for 15 seconds. What happens if you fail? Make it real.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 36,
        type: .input(config: InputConfig(
            question: "Who should know if you fail?",
            inputType: .text(placeholder: "Name your witness"),
            helperText: "We'll notify them if you quit",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 37,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "I've heard your commitment. Now choose your path.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: true
        ))
    ),

    // ==========================================
    // PHASE 8: FINAL DECISION (Steps 38-41)
    // ==========================================

    ConversionOnboardingStep(
        id: 38,
        type: .input(config: InputConfig(
            question: "Will you actually do this?",
            inputType: .choice(options: [
                "Yes, I'm ready",
                "Honestly, probably not"
            ]),
            helperText: "Last chance to be honest",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 39,
        type: .debate(messages: [
            DebateMessage(speaker: .hopeful, text: "Then prove it.", delay: 0.5),
            DebateMessage(speaker: .doubtful, text: "We'll see.", delay: 1.5)
        ])
    ),

    ConversionOnboardingStep(
        id: 40,
        type: .input(config: InputConfig(
            question: "Which future do you choose?",
            inputType: .choice(options: [
                "→ HOPEFUL PATH",
                "→ DOUBTFUL PATH"
            ]),
            helperText: nil,
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 41,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Here's what happens next. The real system. Are you ready to commit?",
            persona: .accountability,
            showAvatar: true,
            emphasize: true
        ))
    ),

    // ==========================================
    // PHASE 9: PAYWALL (Step 42)
    // ==========================================
    // Note: Paywall is handled in the container, not as a step

]

// MARK: - Helper to get step by ID

func getConversionStep(id: Int) -> ConversionOnboardingStep? {
    return CONVERSION_ONBOARDING_STEPS.first { $0.id == id }
}

// MARK: - Dynamic debate messages based on excuse

func getDebateMessagesForExcuse(_ excuse: String) -> [DebateMessage] {
    switch excuse {
    case "No time":
        return [
            DebateMessage(speaker: .doubtful, text: "You had time for Netflix though.", delay: 0.5),
            DebateMessage(speaker: .hopeful, text: "You'll make time if it matters.", delay: 1.5)
        ]
    case "Too tired":
        return [
            DebateMessage(speaker: .doubtful, text: "Always too tired for what matters.", delay: 0.5),
            DebateMessage(speaker: .hopeful, text: "Energy follows commitment.", delay: 1.5)
        ]
    case "Not ready yet":
        return [
            DebateMessage(speaker: .doubtful, text: "You'll never be ready.", delay: 0.5),
            DebateMessage(speaker: .hopeful, text: "You start before you're ready.", delay: 1.5)
        ]
    case "I'll start tomorrow":
        return [
            DebateMessage(speaker: .doubtful, text: "Tomorrow never comes.", delay: 0.5),
            DebateMessage(speaker: .hopeful, text: "Today is the tomorrow you promised.", delay: 1.5)
        ]
    default:
        return [
            DebateMessage(speaker: .doubtful, text: "Same excuses, same results.", delay: 0.5),
            DebateMessage(speaker: .hopeful, text: "Different choice, different outcome.", delay: 1.5)
        ]
    }
}
