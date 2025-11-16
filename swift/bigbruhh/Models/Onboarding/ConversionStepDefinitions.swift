//
//  ConversionStepDefinitions.swift
//  bigbruhh
//
//  36-step conversion-focused onboarding flow
//  Focus: Value proposition, Future You character data, Feature showcases
//

import Foundation
import SwiftUI

// MARK: - 36-Step Conversion Flow

let CONVERSION_ONBOARDING_STEPS: [ConversionOnboardingStep] = [

    // ==========================================
    // PHASE 1: THE HOOK (Steps 1-3)
    // ==========================================

    ConversionOnboardingStep(
        id: 1,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "hey", delay: 0.5),
                ChatMessage(text: "it's me. you. from later.", delay: 1.0),
                ChatMessage(text: "remember that thing you started last month?", delay: 1.2),
                ChatMessage(text: "yeah. that one.", delay: 0.8),
                ChatMessage(text: "stsrted strong. lasted a week. then... nothing.", delay: 1.0)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

    ConversionOnboardingStep(
        id: 2,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "here's what you don't want to hear", delay: 0.5),
                ChatMessage(text: "it's not motivation", delay: 0.8),
                ChatMessage(text: "it's not discipline", delay: 0.8),
                ChatMessage(text: "it's that no one actually holds you accountable", delay: 1.2),
                ChatMessage(text: "and you know it", delay: 0.6)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

    ConversionOnboardingStep(
        id: 3,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "what if someone did?", delay: 0.5),
                ChatMessage(text: "every day", delay: 0.8),
                ChatMessage(text: "real consequences", delay: 0.8),
                ChatMessage(text: "no escape", delay: 0.8),
                ChatMessage(text: "that's what this is", delay: 1.0)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

    // ==========================================
    // PHASE 2: GOAL COLLECTION (Steps 4-8)
    // ==========================================

    ConversionOnboardingStep(
        id: 4,
        type: .input(config: InputConfig(
            question: "What's your name?",
            inputType: .text(placeholder: "What should I call you?"),
            helperText: "I'm you from the future. What do you want me to call you?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 5,
        type: .input(config: InputConfig(
            question: "What's the goal you keep failing to achieve?",
            inputType: .text(placeholder: "e.g., Build my startup, Get fit, Learn to code, Start my business"),
            helperText: "Not a habit. A specific goal or achievement you've started and quit multiple times.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 6,
        type: .input(config: InputConfig(
            question: "When do you want to achieve this by?",
            inputType: .datePicker,
            helperText: "Pick a real deadline. If it's ongoing, pick when you want to see results.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 7,
        type: .input(config: InputConfig(
            question: "How badly do you want this?",
            inputType: .numberStepper(range: 1...10),
            helperText: "1 = not really, 10 = I'll die if I don't get this",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 8,
        type: .input(config: InputConfig(
            question: "Why can't you let this go?",
            inputType: .voice(minDuration: 10, maxDuration: 30),
            helperText: "10 seconds. What's the real reason this keeps coming back? What happens if you never do it?",
            skipAllowed: false
        ))
    ),

    // ==========================================
    // PHASE 3: PATTERN RECOGNITION (Steps 9-13)
    // ==========================================

    ConversionOnboardingStep(
        id: 9,
        type: .input(config: InputConfig(
            question: "Who have you disappointed by quitting?",
            inputType: .text(placeholder: "Name someone"),
            helperText: "This gets personal. Who's counting on you? Who did you let down?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 10,
        type: .input(config: InputConfig(
            question: "What's the biggest obstacle stopping you?",
            inputType: .text(placeholder: "What's really in your way?"),
            helperText: "Be honest. What's the real barrier?",
            skipAllowed: false
        ))
    ),

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
            question: "How did you quit?",
            inputType: .text(placeholder: "What was the excuse? What was the moment you gave up?"),
            helperText: "Be specific. What actually happened?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 13,
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
        id: 14,
        type: .input(config: InputConfig(
            question: "When exactly do you quit?",
            inputType: .text(placeholder: "Tuesday night? Sunday morning? After 3 days?"),
            helperText: "What's the pattern? Day of week? Time of day? How many days in?",
            skipAllowed: false
        ))
    ),

    // ==========================================
    // PHASE 4: THE COST (Steps 15-18)
    // ==========================================

    ConversionOnboardingStep(
        id: 15,
        type: .input(config: InputConfig(
            question: "What would success look like?",
            inputType: .text(placeholder: "Describe your ideal outcome"),
            helperText: "If you actually did this, what would change?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 16,
        type: .input(config: InputConfig(
            question: "What dies if you quit again?",
            inputType: .voice(minDuration: 10, maxDuration: 30),
            helperText: "10 seconds. What exactly are you losing? Your future? Self-respect? Someone's trust?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 17,
        type: .input(config: InputConfig(
            question: "Where will you be in 6 months if you quit again?",
            inputType: .text(placeholder: "Same place? Worse? What's the reality?"),
            helperText: "Be brutally honest. Same goal, same failure, same excuses.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 18,
        type: .input(config: InputConfig(
            question: "What have you already spent trying to achieve this?",
            inputType: .text(placeholder: "Time? Money? Opportunities?"),
            helperText: "What's the cost of all your failed attempts?",
            skipAllowed: false
        ))
    ),

    // ==========================================
    // PHASE 5: FEATURE DEMO & VALUE (Steps 19-25)
    // ==========================================

    ConversionOnboardingStep(
        id: 19,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "starting tomorrow, i call you", delay: 0.5),
                ChatMessage(text: "every day", delay: 0.8),
                ChatMessage(text: "same time", delay: 0.8),
                ChatMessage(text: "this is what it looks like", delay: 0.8, emphasize: true)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

    ConversionOnboardingStep(
        id: 20,
        type: .demoCall
    ),

    ConversionOnboardingStep(
        id: 21,
        type: .input(config: InputConfig(
            question: "Why will this time be different?",
            inputType: .text(placeholder: "What's changed? What's different now?"),
            helperText: "Be honest. What makes this attempt different from the others?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 22,
        type: .input(config: InputConfig(
            question: "What's your biggest fear about this goal?",
            inputType: .text(placeholder: "What scares you most?"),
            helperText: "What are you really afraid of? Failure? Success? Judgment?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 23,
        type: .input(config: InputConfig(
            question: "How much is this goal worth to you?",
            inputType: .text(placeholder: "In dollars, time, or what you'd give up"),
            helperText: "What would you pay? What would you sacrifice?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 24,
        type: .input(config: InputConfig(
            question: "What's the worst that happens if you fail again?",
            inputType: .text(placeholder: "Be specific. What's the real cost?"),
            helperText: "What exactly happens? What do you lose?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 25,
        type: .input(config: InputConfig(
            question: "What's your backup plan if you want to quit?",
            inputType: .text(placeholder: "What will you do when it gets hard?"),
            helperText: "What's your escape route? What's your excuse ready?",
            skipAllowed: false
        ))
    ),

    // ==========================================
    // PHASE 6: PERMISSIONS & COMMITMENT SETUP (Steps 26-33)
    // ==========================================

    ConversionOnboardingStep(
        id: 26,
        type: .permissionRequest(type: .notifications)
    ),

    ConversionOnboardingStep(
        id: 27,
        type: .permissionRequest(type: .calls)
    ),

    ConversionOnboardingStep(
        id: 28,
        type: .input(config: InputConfig(
            question: "What's your biggest motivation right now?",
            inputType: .text(placeholder: "What's driving you today?"),
            helperText: "Why are you here? What's pushing you forward?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 29,
        type: .input(config: InputConfig(
            question: "What will you do every single day?",
            inputType: .text(placeholder: "Be specific: 30 min coding, 1 hour gym, 5 sales calls"),
            helperText: "The exact action. No vague goals. What measurable thing?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 30,
        type: .input(config: InputConfig(
            question: "What time should I call you?",
            inputType: .timePicker,
            helperText: "Pick your best energy time",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 31,
        type: .input(config: InputConfig(
            question: "How many days can you miss before you're done?",
            inputType: .numberStepper(range: 1...5),
            helperText: "Miss this many days = you failed. Game over.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 32,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "last voice commitment", delay: 0.5),
                ChatMessage(text: "you're not talking to me", delay: 0.8),
                ChatMessage(text: "talk to the version of you who'll want to quit in 3 days", delay: 1.2),
                ChatMessage(text: "what does THAT person need to hear from THIS person", delay: 1.0),
                ChatMessage(text: "the one who still believes?", delay: 0.8)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

    ConversionOnboardingStep(
        id: 33,
        type: .input(config: InputConfig(
            question: "What happens if you fail this time?",
            inputType: .voice(minDuration: 15, maxDuration: 30),
            helperText: "15 seconds. Talk to the version of you who will want to quit. What's the cost?",
            skipAllowed: false
        ))
    ),

    // ==========================================
    // PHASE 7: FINAL COMMITMENT (Steps 34-35)
    // ==========================================

    ConversionOnboardingStep(
        id: 34,
        type: .input(config: InputConfig(
            question: "What will you tell yourself when you want to quit?",
            inputType: .text(placeholder: "What's your reminder? Your reason?"),
            helperText: "What do you need to hear? What will keep you going?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 35,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "i've heard your commitment", delay: 0.5),
                ChatMessage(text: "i know your goal. your pattern. your excuses.", delay: 1.0),
                ChatMessage(text: "i know what dies if you quit", delay: 0.8),
                ChatMessage(text: "starting tomorrow, i call you", delay: 0.8),
                ChatMessage(text: "every day", delay: 0.6),
                ChatMessage(text: "no escape", delay: 0.6),
                ChatMessage(text: "now invest in yourself", delay: 0.8, emphasize: true),
                ChatMessage(text: "because you've already invested this much", delay: 0.8),
                ChatMessage(text: "don't let it be for nothing", delay: 0.8)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

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
