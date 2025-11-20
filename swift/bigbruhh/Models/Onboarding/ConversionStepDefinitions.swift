//
//  ConversionStepDefinitions.swift
//  bigbruhh
//
//  38-step conversion-optimized onboarding flow
//  Focus: Reduce typing, increase engagement, add demographics, personalized demo call
//

import Foundation
import SwiftUI

// MARK: - 38-Step Conversion Flow

let CONVERSION_ONBOARDING_STEPS: [ConversionOnboardingStep] = [

    // 🚨 TESTING ONLY: Move Loading Screen to First Step
    // TO REVERT: Delete this entire block (down to the next comment)
    ConversionOnboardingStep(
        id: 999,
        type: .loading(config: LoadingConfig(
            title: "Creating Future You",
            statusMessages: [
                "Analyzing your voice...",
                "Building your accountability partner...",
                "Preparing your first call...",
                "Almost ready..."
            ],
            duration: 12.0
        ))
    ),
    ConversionOnboardingStep(
        id: 9999,
        type: .commitmentCard
    ),
    // ==========================================
    // PHASE 1: THE HOOK (Steps 1-3) ✅ Keep as-is
    // ==========================================

    ConversionOnboardingStep(
        id: 1,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "hey", delay: 0.5),
                ChatMessage(text: "it's me. you. from later.", delay: 1.0),
                ChatMessage(text: "remember that thing you started last month?", delay: 1.2),
                ChatMessage(text: "yeah. that one.", delay: 0.8),
                ChatMessage(text: "started strong. lasted a week. then... nothing.", delay: 1.0)
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
    // PHASE 2: CORE IDENTITY + VOICE #1 (Steps 4-8)
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
            question: "What's the ONE thing you NEED to accomplish to feel whole again?",
            inputType: .text(placeholder: "e.g., Build my startup, Get fit, Learn to code"),
            helperText: "Not a habit. The specific goal that's been eating at you.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 6,
        type: .input(config: InputConfig(
            question: "When do you NEED this by?",
            inputType: .datePicker,
            helperText: "Pick a real deadline. When do you need to see results?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 7,
        type: .input(config: InputConfig(
            question: "How badly do you CRAVE this change?",
            inputType: .slider(range: 1...10),
            helperText: "Slide to show your hunger. 1 = meh, 10 = I'll die without this",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 8,
        type: .input(config: InputConfig(
            question: "Tell me why you NEED this. What's the cost of staying stuck?",
            inputType: .voice(minDuration: 15, maxDuration: 30),
            helperText: "15 seconds. Speak from your gut. Let me hear the hunger.",
            skipAllowed: false
        ))
    ),

    // NEW: AI Break
    ConversionOnboardingStep(
        id: 9,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "i heard that.", delay: 0.5),
                ChatMessage(text: "the hunger is there.", delay: 0.8),
                ChatMessage(text: "but hunger isn't enough.", delay: 0.8),
                ChatMessage(text: "let's see what's been blocking it.", delay: 1.0)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

    // ==========================================
    // PHASE 3: PATTERN RECOGNITION (Steps 9-14) - REDUCE TYPING
    // ==========================================

    ConversionOnboardingStep(
        id: 10,
        type: .input(config: InputConfig(
            question: "Who have you disappointed by quitting?",
            inputType: .choice(options: [
                "Myself",
                "Family",
                "Partner",
                "Friends",
                "No one yet",
                "Everyone"
            ]),
            helperText: "This gets personal. Who's counting on you?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 11,
        type: .input(config: InputConfig(
            question: "What's been stopping you from becoming who you're meant to be?",
            inputType: .choice(options: [
                "No time",
                "No energy",
                "Fear of failure",
                "Procrastination",
                "Lack of support",
                "Don't know how"
            ]),
            helperText: "Be honest. What's the real barrier?",
            skipAllowed: false
        ))
    ),

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
            question: "How did you quit last time?",
            inputType: .choice(options: [
                "Gradually stopped",
                "Life got busy",
                "Lost motivation",
                "Got discouraged",
                "Never really started"
            ]),
            helperText: "What actually happened? Be specific.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 14,
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
        id: 15,
        type: .input(config: InputConfig(
            question: "When do you usually quit?",
            inputType: .choice(options: [
                "First week",
                "After 2-3 weeks",
                "Around 1 month",
                "After 2-3 months",
                "Never make it past day 1"
            ]),
            helperText: "What's the pattern? When does it fall apart?",
            skipAllowed: false
        ))
    ),

    // NEW: AI Break
    ConversionOnboardingStep(
        id: 16,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "i see the pattern now.", delay: 0.5),
                ChatMessage(text: "it's clearer than you think.", delay: 0.8),
                ChatMessage(text: "and it's not your fault.", delay: 0.8),
                ChatMessage(text: "but it is your responsibility.", delay: 1.0)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

    // ==========================================
    // PHASE 4: DEMOGRAPHICS (Steps 15-18) - NEW
    // ==========================================

    ConversionOnboardingStep(
        id: 17,
        type: .input(config: InputConfig(
            question: "How old are you?",
            inputType: .numberStepper(range: 13...100),
            helperText: "Just so I know who I'm talking to",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 18,
        type: .input(config: InputConfig(
            question: "What's your gender?",
            inputType: .choice(options: [
                "Male",
                "Female",
                "Non-binary",
                "Prefer not to say"
            ]),
            helperText: "Optional but helps me understand you better",
            skipAllowed: true
        ))
    ),

    ConversionOnboardingStep(
        id: 19,
        type: .input(config: InputConfig(
            question: "Where are you from?",
            inputType: .text(placeholder: "City, Country (optional)"),
            helperText: "Just curious. You can skip this.",
            skipAllowed: true
        ))
    ),

    ConversionOnboardingStep(
        id: 20,
        type: .input(config: InputConfig(
            question: "How did you hear about us?",
            inputType: .choice(options: [
                "App Store",
                "Friend",
                "Social Media",
                "Search",
                "Ad",
                "Other"
            ]),
            helperText: "Helps us reach more people like you",
            skipAllowed: false
        ))
    ),

    // NEW: AI Break
    ConversionOnboardingStep(
        id: 21,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "okay.", delay: 0.5),
                ChatMessage(text: "i have a better picture now.", delay: 0.8),
                ChatMessage(text: "now let's look at the stakes.", delay: 0.8),
                ChatMessage(text: "the real cost of staying the same.", delay: 1.0)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

    // ==========================================
    // PHASE 5: THE COST + VOICE #2 (Steps 19-23)
    // ==========================================

    ConversionOnboardingStep(
        id: 22,
        type: .input(config: InputConfig(
            question: "Paint the picture: What does your life look like when you FINALLY have this?",
            inputType: .text(placeholder: "Describe your ideal outcome"),
            helperText: "If you actually did this, what would change?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 23,
        type: .input(config: InputConfig(
            question: "What dies inside you if you quit again? Say it out loud.",
            inputType: .voice(minDuration: 15, maxDuration: 30),
            helperText: "15 seconds. Let Future You hear it. What exactly are you losing?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 24,
        type: .input(config: InputConfig(
            question: "Where will you be in 6 months if you quit again?",
            inputType: .choice(options: [
                "Same place, no progress",
                "Even worse off",
                "Full of regret",
                "Given up completely"
            ]),
            helperText: "Be brutally honest. Same goal, same failure, same excuses.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 25,
        type: .input(config: InputConfig(
            question: "What have you already spent trying to achieve this?",
            inputType: .multiSelect(options: [
                "Time (months/years)",
                "Money ($100+)",
                "Opportunities",
                "Relationships",
                "Self-respect"
            ]),
            helperText: "Select all that apply. What's the cost of all your failed attempts?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 26,
        type: .input(config: InputConfig(
            question: "What's your biggest fear about this goal?",
            inputType: .choice(options: [
                "Failing again",
                "Succeeding and the pressure",
                "Judgment from others",
                "Wasting more time",
                "Finding out I can't do it"
            ]),
            helperText: "What are you really afraid of?",
            skipAllowed: false
        ))
    ),

    // NEW: AI Break
    ConversionOnboardingStep(
        id: 27,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "that is a heavy cost.", delay: 0.5),
                ChatMessage(text: "too heavy to carry alone.", delay: 0.8),
                ChatMessage(text: "it stops now.", delay: 0.8),
                ChatMessage(text: "let me show you your future.", delay: 1.0)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

    // ==========================================
    // PHASE 6: CREATING FUTURE YOU (Step 24) - NEW
    // ==========================================

    ConversionOnboardingStep(
        id: 28,
        type: .loading(config: LoadingConfig(
            title: "Creating Future You",
            statusMessages: [
                "Analyzing your voice...",
                "Building your accountability partner...",
                "Preparing your first call...",
                "Almost ready..."
            ],
            duration: 12.0
        ))
    ),

    // ==========================================
    // PHASE 7: DEMO CALL EXPERIENCE (Step 25)
    // ==========================================

    ConversionOnboardingStep(
        id: 29,
        type: .demoCall
    ),

    // ==========================================
    // PHASE 8: SOCIAL PROOF (Steps 26-27) - NEW
    // ==========================================

    ConversionOnboardingStep(
        id: 30,
        type: .input(config: InputConfig(
            question: "How was that experience?",
            inputType: .ratingStars,
            helperText: "Rate your demo call from 1-5 stars",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 31,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "glad you liked it", delay: 0.5),
                ChatMessage(text: "imagine that every single day", delay: 0.8),
                ChatMessage(text: "no escape", delay: 0.6),
                ChatMessage(text: "no excuses", delay: 0.6),
                ChatMessage(text: "just you and your commitment", delay: 0.8)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

    // ==========================================
    // PHASE 9: FINAL COMMITMENT + VOICE #3 (Steps 28-34)
    // ==========================================

    ConversionOnboardingStep(
        id: 32,
        type: .permissionRequest(type: .notifications)
    ),

    ConversionOnboardingStep(
        id: 33,
        type: .permissionRequest(type: .calls)
    ),

    ConversionOnboardingStep(
        id: 34,
        type: .input(config: InputConfig(
            question: "What will you do every single day?",
            inputType: .text(placeholder: "Be specific: 30 min gym, 1 hour coding, 5 sales calls"),
            helperText: "The exact action. No vague goals. What measurable thing?",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 35,
        type: .input(config: InputConfig(
            question: "What time should I call you?",
            inputType: .timePicker,
            helperText: "Pick your best energy time. This is when I'll hold you accountable.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 36,
        type: .input(config: InputConfig(
            question: "How many days can you miss before you're done?",
            inputType: .numberStepper(range: 1...5),
            helperText: "Miss this many days = you failed. Game over.",
            skipAllowed: false
        ))
    ),

    ConversionOnboardingStep(
        id: 37,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "last voice commitment", delay: 0.5),
                ChatMessage(text: "you're not talking to me", delay: 0.8),
                ChatMessage(text: "talk to the version of you who'll want to quit in 3 days", delay: 1.2),
                ChatMessage(text: "what does THAT person need to hear from THIS person?", delay: 1.0),
                ChatMessage(text: "the one who still believes?", delay: 0.8)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    ),

    ConversionOnboardingStep(
        id: 38,
        type: .input(config: InputConfig(
            question: "This is it. Tell Future You why THIS time is different. Why you NEED this to work.",
            inputType: .voice(minDuration: 20, maxDuration: 30),
            helperText: "20 seconds. Make it real. This is your final oath.",
            skipAllowed: false
        ))
    ),

    // ==========================================
    // PHASE 10: COMMITMENT CARD (Step 39)
    // ==========================================

    ConversionOnboardingStep(
        id: 39,
        type: .commitmentCard
    ),

    // ==========================================
    // PHASE 11: PAYWALL (Steps 40)
    // ==========================================

    ConversionOnboardingStep(
        id: 40,
        type: .aiCommentary(config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "i've heard your commitment", delay: 0.5),
                ChatMessage(text: "i know your goal. your pattern. your excuses.", delay: 1.0),
                ChatMessage(text: "i know what dies if you quit", delay: 0.8),
                ChatMessage(text: "starting tomorrow, i call you", delay: 0.8),
                ChatMessage(text: "every day", delay: 0.6),
                ChatMessage(text: "no escape", delay: 0.6),
                ChatMessage(text: "now invest in yourself", delay: 0.8, emphasize: true),
                ChatMessage(text: "don't let it be for nothing", delay: 0.8)
            ],
            persona: .futureYou,
            showAvatar: false
        ))
    )

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
