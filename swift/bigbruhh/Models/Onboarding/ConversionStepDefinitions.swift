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

    // VOICE RECORDING REFRAME 1
    ConversionOnboardingStep(
        id: 10,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Most people skip voice recordings. You didn't. That matters.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: false
        ))
    ),

    ConversionOnboardingStep(
        id: 11,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Okay. Now let's look at your pattern.",
            persona: .accountability,
            showAvatar: true,
            emphasize: false
        ))
    ),

    // ==========================================
    // PHASE 3: PATTERN REVELATION (Steps 12-20)
    // ==========================================

    ConversionOnboardingStep(
        id: 12,
        type: .input(config: InputConfig(
            question: "How many times have you tried before?",
            inputType: .numberStepper(range: 0...20),
            helperText: "Be honest. How many attempts?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 13,
        type: .input(config: InputConfig(
            question: "What happened last time?",
            inputType: .text(placeholder: "Describe what happened"),
            helperText: nil,
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 14,
        type: .input(config: InputConfig(
            question: "And the time before that?",
            inputType: .text(placeholder: "What about before?"),
            helperText: "See the pattern?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 15,
        type: .debate(messages: [
            DebateMessage(speaker: .hopeful, text: "Maybe this time is different.", delay: 0.5),
            DebateMessage(speaker: .doubtful, text: "That's what you said last time.", delay: 1.5),
            DebateMessage(speaker: .hopeful, text: "People change.", delay: 2.5),
            DebateMessage(speaker: .doubtful, text: "You haven't.", delay: 3.5)
        ])
    ),

    ConversionOnboardingStep(
        id: 16,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "See? Even your futures know your pattern. Let's dig deeper.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: false
        ))
    ),

    ConversionOnboardingStep(
        id: 17,
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
        id: 18,
        type: .input(config: InputConfig(
            question: "Who have you disappointed by quitting?",
            inputType: .text(placeholder: "Name someone"),
            helperText: "This gets personal. Who's counting on you?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 19,
        type: .input(config: InputConfig(
            question: "When do you usually give up?",
            inputType: .text(placeholder: "tuesday night??"),
            helperText: "What time of day? Day of week?",
            skipAllowed: false
        ))
    ),

    // CELEBRATION + PHASE BRIDGE 1
    ConversionOnboardingStep(
        id: 20,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "You just mapped your entire failure pattern. Most people spend their whole lives avoiding what you just faced.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: false
        ))
    ),

    // ==========================================
    // PHASE 4: THE COST (Steps 21-28)
    // ==========================================

    ConversionOnboardingStep(
        id: 21,
        type: .debate(messages: [
            // Dynamic based on excuse - placeholder for "No time"
            DebateMessage(speaker: .doubtful, text: "You had time for Netflix though.", delay: 0.5),
            DebateMessage(speaker: .hopeful, text: "You'll make time if it matters.", delay: 1.5)
        ])
    ),

    ConversionOnboardingStep(
        id: 22,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Here's what you need to hear. The cost of quitting again.",
            persona: .accountability,
            showAvatar: true,
            emphasize: true
        ))
    ),

    // VOICE RECORDING PREP 2
    ConversionOnboardingStep(
        id: 23,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Your voice. On a server. I know how that sounds. These recordings stay encrypted, tied only to your account, used only for your calls. Not training data. Not shared. Yours. But you have to trust the system. If you can't, this won't work. Are you ready?",
            persona: .accountability,
            showAvatar: true,
            emphasize: false
        ))
    ),

    ConversionOnboardingStep(
        id: 24,
        type: .input(config: InputConfig(
            question: "What are you really afraid to lose?",
            inputType: .voice(minDuration: 10, maxDuration: 30),
            helperText: "Use 10 seconds. What exactly dies when you quit again? Be raw.",
            skipAllowed: false
        ))
    ),

    // CELEBRATION 2
    ConversionOnboardingStep(
        id: 25,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Twice now. You've spoken your truth twice.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: false
        ))
    ),

    ConversionOnboardingStep(
        id: 26,
        type: .input(config: InputConfig(
            question: "Where will you be in 6 months if nothing changes?",
            inputType: .text(placeholder: "Describe your future"),
            helperText: "Be brutally honest.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 27,
        type: .debate(messages: [
            DebateMessage(speaker: .doubtful, text: "That's your future. Same pattern, same result.", delay: 0.5),
            DebateMessage(speaker: .hopeful, text: "Unless something changes.", delay: 2.0)
        ])
    ),

    // PHASE BRIDGE 2
    ConversionOnboardingStep(
        id: 28,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "You know the cost. Now let me show you what accountability looks like. Not reminders. Not quotes. Real calls. Daily. Starting tomorrow.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: false
        ))
    ),

    // ==========================================
    // PHASE 5: DEMO CALL (Steps 29-32)
    // ==========================================

    ConversionOnboardingStep(
        id: 29,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Starting tomorrow, I call you. Every day. This is what it looks like.",
            persona: .accountability,
            showAvatar: true,
            emphasize: true
        ))
    ),

    ConversionOnboardingStep(
        id: 30,
        type: .demoCall
    ),

    ConversionOnboardingStep(
        id: 31,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Every day. Same time. No excuses. No escape.",
            persona: .accountability,
            showAvatar: true,
            emphasize: true
        ))
    ),

    // CELEBRATION 3
    ConversionOnboardingStep(
        id: 32,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "You saw what's coming. Daily calls. Real consequences. Most people close the app here. You're still here.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: false
        ))
    ),

    // ==========================================
    // PHASE 6: PERMISSION GATES (Steps 33-36)
    // ==========================================

    ConversionOnboardingStep(
        id: 33,
        type: .permissionRequest(type: .notifications)
    ),

    ConversionOnboardingStep(
        id: 34,
        type: .permissionRequest(type: .calls)
    ),

    // PHASE BRIDGE 3
    ConversionOnboardingStep(
        id: 35,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Permissions granted. Now we set up the system for real. Your daily commitment. Call time. Consequences. This becomes binding.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: false
        ))
    ),

    ConversionOnboardingStep(
        id: 36,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Last voice commitment. You're not talking to me. Talk to the version of you who'll want to quit in 3 days. What does THAT person need to hear from THIS person—the one who still believes?",
            persona: .accountability,
            showAvatar: true,
            emphasize: false
        ))
    ),

    // ==========================================
    // PHASE 7: COMMITMENT SETUP (Steps 37-46)
    // ==========================================

    ConversionOnboardingStep(
        id: 37,
        type: .debate(messages: [
            DebateMessage(speaker: .hopeful, text: "Are you actually ready this time?", delay: 0.5),
            DebateMessage(speaker: .doubtful, text: "Or are we wasting our time?", delay: 1.5)
        ])
    ),

    ConversionOnboardingStep(
        id: 38,
        type: .input(config: InputConfig(
            question: "What's your daily commitment?",
            inputType: .text(placeholder: "e.g., 30 min coding, 1 hour gym, 5 sales calls"),
            helperText: "Be specific. What will you do every day?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 39,
        type: .input(config: InputConfig(
            question: "What time should I call you?",
            inputType: .timePicker,
            helperText: "Pick your best energy time",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 40,
        type: .input(config: InputConfig(
            question: "How many strikes before you're out?",
            inputType: .numberStepper(range: 1...5),
            helperText: "Miss this many days = you're done",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 41,
        type: .input(config: InputConfig(
            question: "Will you actually follow through?",
            inputType: .voice(minDuration: 15, maxDuration: 30),
            helperText: "Be brutally honest for 15 seconds. What happens if you fail? Make it real.",
            skipAllowed: false
        ))
    ),

    // CELEBRATION 4
    ConversionOnboardingStep(
        id: 42,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Three voice commitments. 90% quit before this point. You're not them.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: false
        ))
    ),

    ConversionOnboardingStep(
        id: 43,
        type: .input(config: InputConfig(
            question: "Who should know if you fail?",
            inputType: .text(placeholder: "Name your witness"),
            helperText: "We'll notify them if you quit",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 44,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "I've heard your commitment. Now choose your path.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: true
        ))
    ),

    // ==========================================
    // PHASE 8: FINAL DECISION (Steps 45-51)
    // ==========================================

    ConversionOnboardingStep(
        id: 45,
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
        id: 46,
        type: .debate(messages: [
            DebateMessage(speaker: .hopeful, text: "Then prove it.", delay: 0.5),
            DebateMessage(speaker: .doubtful, text: "We'll see.", delay: 1.5)
        ])
    ),

    ConversionOnboardingStep(
        id: 47,
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
        id: 48,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "Here's what happens next. The real system. Are you ready to commit?",
            persona: .accountability,
            showAvatar: true,
            emphasize: true
        ))
    ),

    // FINAL CELEBRATION
    ConversionOnboardingStep(
        id: 49,
        type: .aiCommentary(config: AICommentaryConfig(
            message: "42 complete. You did what most people won't. You answered questions you've never been asked. You recorded your voice three times. You saw the system. You made your choice. One thing left: investment.",
            persona: .futureYou,
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
