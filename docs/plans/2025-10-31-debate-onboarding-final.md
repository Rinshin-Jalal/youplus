# BigBruh Debate Onboarding - Final Design

**Date:** 2025-10-31
**Status:** Final Design - Ready for Implementation
**Duration:** 15-20 minutes
**Style:** Minimal SwiftUI + Debate Entertainment

## Core Concept

Replace 60-step interrogation with **debate-driven journey** where two internal voices argue about your potential:

- **WEAK SELF** (bottom, gray text) - Your current self defending comfort, making excuses
- **FUTURE SELF** (top, blue text) - Your potential calling out patterns, pushing forward

**Key Innovation:** Instead of explanation steps telling you things, you WITNESS debates about your own answers. Way more engaging than being lectured.

---

## Design Principles

1. **Minimal Visual Design** - Standard SwiftUI components, no color phase switching, clean white background
2. **Three Step Types** - Input (you answer) → Debate (they argue) → Choice (you pick winner)
3. **Entertainment Value** - Debates are engaging, sometimes funny, always real
4. **Variety of Interactions** - Different choice mechanisms keep it fresh
5. **Essential Data Only** - Still captures identity, commitment, patterns

---

## Complete Onboarding Flow (20 Steps, 15-20 min)

### PHASE 1: INTRODUCTION (3 steps, 2 min)

**Step 1: DEBATE - Opening Hook**
```
[Screen opens to:]

BOTTOM: "They're not going to finish this."

TOP: "They opened the app. That's something."

BOTTOM: "Everyone opens apps. Then they delete them day 3."

TOP: "Maybe. But today isn't day 3. Today is day ZERO."

BOTTOM: "Exactly. Zero. Nothing."

TOP: "Or everything. Depends on what they choose next."

[Both fade]
[Button appears: "Continue"]
```
**Purpose:** Hook them immediately. "Who are these voices talking about me?"

---

**Step 2: INPUT - Name**
```
[Clean screen]
"What should we call you?"
[TextField]
```

---

**Step 3: DEBATE - About Their Name**
```
BOTTOM: "{{name}}. Fresh start name. New app, new you?"

TOP: "They've had fresh starts. Remember January? March? Last Monday?"

BOTTOM: "This is DIFFERENT though."

TOP: "Different how? Different app? Or different {{name}}?"

BOTTOM: "Come on, they showed up. Give them credit."

TOP: "Showing up is 1%. Following through is 99%."

BOTTOM: "Jesus, let them breathe for one second."

TOP: "They've been breathing for YEARS. Time to move."

[Fade out]
[Continue automatically to next step]
```
**Purpose:** Establish character dynamics, make it entertaining

---

### PHASE 2: IDENTITY DISCOVERY (5 steps, 5 min)

**Step 4: INPUT - Who You Want to Become**
```
"Who do you want to become?"
[Not goals. Not achievements. WHO as a person.]
[TextField - multiline]
```

---

**Step 5: DEBATE + CHOICE - About Their Answer**
```
BOTTOM: "That's... actually pretty specific."

TOP: "Or rehearsed. How many times have they written this in journals?"

BOTTOM: "So what if they have? Repetition means it matters."

TOP: "Or it means they're stuck in fantasy. Writing isn't becoming."

BOTTOM: "They have to START somewhere!"

TOP: "They have to start DOING somewhere. Not writing. DOING."

[SWIPE DOWN = Agree with TOP (need action, not words)]
[SWIPE UP = Agree with BOTTOM (writing is a valid start)]
```
**Data Captured:** `identity_goal` + `action_vs_planning_bias`

---

**Step 6: INPUT - The ONE Thing**
```
"What's the ONE thing you'll do every single day?"
[TextField]
[Helper text: "Be specific. 'Work out' isn't enough. '30 min run at 6am' is."]
```

---

**Step 7: DEBATE + DRAG CHOICE - About Their Commitment**
```
[After they enter something]

TOP (small): "{{their_answer}}. Is that specific enough?"

BOTTOM (small): "It's fine. Perfect is the enemy of good."

TOP (growing): "No. Vague is the enemy of accountability. WHEN? HOW LONG?"

BOTTOM (shrinking): "Let them refine it later..."

[DRAG TOP to center = Must make it more specific now]
[DRAG BOTTOM to center = Accept as-is, move forward]
```
**Data Captured:** `daily_commitment` + `specificity_preference`

---

**Step 8: VOICE INPUT - Why You're Really Here**
```
"Record this in your own voice:"

"Why am I really here?"

[Voice recorder - 15-45 seconds]
[Visual: Simple waveform animation]
[Minimal buttons: Record / Stop / Re-record / Continue]
```
**Data Captured:** `voice_commitment_1` (~30 sec)

---

**Step 9: DEBATE - React to Their Voice**
```
BOTTOM: "That sounded... rehearsed."

TOP: "Maybe. But did you hear the crack at the end?"

BOTTOM: "What crack?"

TOP: "Listen again. {{timestamp}}. That's where the real reason lives."

BOTTOM: "Oh. Yeah. I heard it."

TOP: "That's what we work with. Not the script. The crack."

[Fade out automatically]
```
**Purpose:** Show the voices are "listening" - creates connection

---

### PHASE 3: EXCUSE CONFRONTATION (4 steps, 4 min)

**Step 10: INPUT - Favorite Excuse (Multiple Choice)**
```
"Pick your favorite excuse:"

○ I don't have time
○ I'm too tired
○ I'll start tomorrow
○ It's not the right moment
○ Other people have it easier
○ [Text input: Other]

[Tap to select]
```

---

**Step 11: DEBATE - About Their Excuse**
```
[Dynamic based on choice. Example for "I don't have time":]

BOTTOM: "Time is real though. They ARE busy."

TOP: "Everyone's busy. Winners find time. Losers find excuses."

BOTTOM: "That's harsh. They have actual responsibilities."

TOP: "So does everyone. But everyone finds time for what matters."

BOTTOM: "So they don't matter to themselves?"

TOP: "Their words say they matter. Their time says they don't."

BOTTOM: "...damn."

TOP: "Yeah. Damn."

[Fade out]
```

---

**Step 12: INPUT - Weakness Window**
```
"When are you most likely to quit?"

[Time + Situation]
[Example: "9pm after work when I'm tired"]
[TextField]
```

---

**Step 13: DEBATE + TAP CHOICE - About Their Pattern**
```
BOTTOM: "{{weakness_window}}. That's specific. That's real."

TOP: "So if they KNOW their weakness window... why walk into it?"

BOTTOM: "Because life happens? They can't control everything."

TOP: "They can control {{their_commitment}} timing. Do it BEFORE the window."

BOTTOM: "Or build discipline to push through the window."

TOP: "Which sounds more likely for someone who's quit {{N}} times?"

[Card 1: "Do it before weakness window" - TAP to choose]
[Card 2: "Build discipline to push through" - TAP to choose]
```
**Data Captured:** `weakness_window` + `strategy_preference`

---

### PHASE 4: COMMITMENT BUILDING (5 steps, 5 min)

**Step 14: INPUT - Time Picker**
```
"What time will you do {{their_commitment}} every day?"

[SwiftUI WheelDatePicker - time only]
```

---

**Step 15: DEBATE - Validate Their Time Choice**
```
[Dynamic based on if time is in their weakness window]

IF IN WEAKNESS WINDOW:
BOTTOM: "{{chosen_time}}. Perfect."
TOP: "That's literally IN your weakness window."
BOTTOM: "So what? Face it head-on!"
TOP: "Noble. Stupid. But noble."
[Automatic: Continue]

IF BEFORE WEAKNESS WINDOW:
BOTTOM: "{{chosen_time}}. That's early/smart timing."
TOP: "Exactly. Strike before the weakness hits."
BOTTOM: "Okay we actually agree on something?"
TOP: "Don't get used to it."
[Automatic: Continue]
```

---

**Step 16: INPUT - Quit Counter**
```
"How many times have you 'started fresh' this year?"

[Number picker: 0-50+]
```

---

**Step 17: DEBATE - About Their Quit History**
```
[Dynamic based on number]

IF 0-2:
BOTTOM: "{{count}} times. That's not bad."
TOP: "Not bad? Every quit is data. Every restart is a pattern."

IF 3-5:
BOTTOM: "{{count}} times. So what? Everyone struggles."
TOP: "Struggling is human. But {{count}} times is a system failure."

IF 6+:
BOTTOM: "{{count}} times. Okay that's... a lot."
TOP: "That's not a lot. That's a PATTERN. This is their software."
BOTTOM: "Can software be rewritten?"
TOP: "That's what we're here to find out."

[Fade out automatically]
```

---

**Step 18: VOICE INPUT - Record Your Commitment**
```
"Record your commitment in your own words:"

"I will {{their_commitment}} every day at {{their_time}}"

[Voice recorder - 20-60 seconds]
[Can expand beyond the prompt if they want]
```
**Data Captured:** `voice_commitment_2` (~45 sec)

---

**Step 19: DEBATE - React to Voice Commitment (Rare Agreement)**
```
BOTTOM: "That was... different."

TOP: "Yeah. I heard it too."

BOTTOM: "They didn't sound fake this time."

TOP: "No. They sounded scared."

BOTTOM: "Scared?"

TOP: "Scared of failing again. But more scared of never trying."

BOTTOM: "That's... actually beautiful?"

TOP: "Don't ruin it. But yeah. They're ready."

BOTTOM: "So what now?"

TOP: "Now we hold them to it. No mercy."

BOTTOM: "...I'm in."

[Fade out automatically]
```
**Purpose:** Powerful moment. Both sides align. User feels the weight.

---

### PHASE 5: LOCK-IN (2 steps, 2 min)

**Step 20: CHOICE - Final Confirmation**
```
[Clean summary card]

YOU ARE: {{name}}
BECOMING: {{identity_goal}}
BY DOING: {{daily_commitment}}
EVERY DAY AT: {{time}}

WEAK SELF: "You can still back out..."

FUTURE SELF: "Or lock it in and prove you're different."

[TAP TOP = Lock in, continue to app]
[TAP BOTTOM = Go back and change something]
```
**Data Captured:** `final_confirmation`

---

**If they LOCK IN:**
```
[Both voices together, centered:]

"Welcome to BigBruh.
We'll call tonight at {{time}}.
Don't make us come find you."

[Fade to main app]
```

---

## Technical Implementation

### Data Models

```swift
// Step Types
enum OnboardingStepType {
    case debate(lines: [DebateLine])
    case input(InputType)
    case debateWithChoice(debate: [DebateLine], choice: ChoiceType)
}

struct DebateLine {
    let speaker: Speaker // weakSelf, futureSelf
    let text: String
    let delay: TimeInterval // stagger appearance
}

enum Speaker {
    case weakSelf  // bottom, gray
    case futureSelf // top, blue
}

enum InputType {
    case text(prompt: String, placeholder: String?)
    case voice(prompt: String, minDuration: Int, maxDuration: Int)
    case multipleChoice(prompt: String, options: [String])
    case timePicker(prompt: String)
    case numberPicker(prompt: String, range: ClosedRange<Int>)
}

enum ChoiceType {
    case swipeDismiss // swipe down = choose top, swipe up = choose bottom
    case dragToCenter // drag one side to center
    case tapCards // tap card to select
}

// Response Storage
struct OnboardingResponse {
    let userName: String
    let identityGoal: String
    let dailyCommitment: String
    let commitmentTime: Date
    let weaknessWindow: String
    let favoriteExcuse: String
    let quitCount: Int
    let voiceCommitments: [URL] // 2 recordings
    let choices: [String: String] // stepId: choice
}
```

### UI Components (Minimal SwiftUI)

**Base Layout:**
```swift
VStack {
    // Progress dots (top)
    ProgressDotsView(current: step, total: 20)

    Spacer()

    // Main content area
    ZStack {
        // Input views (clean, center)
        currentInputView

        // Debate voices (positioned)
        if showingDebate {
            VStack {
                // Future Self (top)
                Text(futureSelfLine)
                    .font(.body)
                    .foregroundColor(.blue)
                    .padding()

                Spacer()

                // Weak Self (bottom)
                Text(weakSelfLine)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }

    Spacer()
}
```

**Debate Animation:**
```swift
// Lines appear one at a time with typing effect
ForEach(visibleLines) { line in
    Text(line.text)
        .typewriterEffect(duration: line.text.count * 0.03)
        .transition(.opacity)
}
```

**Choice Interactions:**
```swift
// Swipe dismiss
.gesture(
    DragGesture()
        .onEnded { value in
            if value.translation.height < -50 {
                // Swiped up - dismiss top (choose bottom)
            } else if value.translation.height > 50 {
                // Swiped down - dismiss bottom (choose top)
            }
        }
)

// Drag to center
.gesture(
    DragGesture()
        .onChanged { value in
            // Scale up the one being dragged
        }
        .onEnded { value in
            // If dragged far enough, select it
        }
)
```

### Debate Content System

**Dynamic Debates:**
```swift
struct DebateGenerator {
    func generateDebate(
        for step: OnboardingStep,
        with userAnswer: String,
        context: OnboardingContext
    ) -> [DebateLine] {
        // Dynamic debates based on:
        // - User's answer
        // - Previous patterns
        // - Quit count
        // - Time of day
        // - Specificity of commitment
    }
}
```

**Personality Configs:**
```swift
let weakSelfPersonality = [
    "defeatist": ["They'll quit", "This won't work", "Why bother"],
    "relatable": ["Everyone struggles", "Be realistic", "Cut them slack"],
    "funny": ["At least they tried?", "New year new me vibes", "Classic"]
]

let futureSelfPersonality = [
    "direct": ["Here's the truth", "No more excuses", "You know better"],
    "tough_love": ["I believe in you but not your excuses", "Your potential is trapped"],
    "strategic": ["Let's be smart about this", "Data says...", "Pattern shows..."]
]
```

---

## Key Differences from Current Design

| Current (60 steps) | New Debate Design (20 steps) |
|-------------------|------------------------------|
| Explanation → Question → Explanation | Input → Debate → Choice |
| Solo interrogation | Two voices arguing about you |
| 60 linear steps | 20 varied interactions |
| Phase color switching | Minimal white background |
| Heavy psychological extraction | Entertainment + essential data |
| Serious throughout | Playful but accountable |
| 9 rigid phases | 5 fluid sections |
| Voice everywhere | 2 strategic voice moments |

---

## Voice Recording Moments (2 total, ~75 sec)

1. **Step 8:** "Why am I really here?" (15-45 sec)
2. **Step 18:** "I will {{commitment}} at {{time}}" (20-60 sec)

**Purpose:**
- Capture authentic commitment in their own voice
- Play back during weakness moments
- Create accountability through self-confrontation

---

## Essential Data Captured

✅ **Identity:**
- Name
- Who they want to become
- Voice: Why they're here

✅ **Commitment:**
- The ONE daily thing
- Exact time
- Voice: Their commitment statement

✅ **Patterns:**
- Favorite excuse
- Weakness window
- Quit count
- Action vs planning bias
- Strategy preference

✅ **Choices:**
- Every debate choice they made
- Pattern of which voice they choose
- Shows if they're future-focused or comfort-focused

---

## Success Metrics

**Completion Rate:** Target 70%+ (vs current 45%)
**Engagement:** Debates keep attention vs explanations
**Time:** 15-20 min (vs 25-30 min current)
**Data Quality:** Same essential data, less friction
**User Sentiment:** "That was actually fun" vs "That was intense"

---

## Implementation Phases

**Phase 1:** Build debate engine + minimal UI
**Phase 2:** Create 20 step flows with debates
**Phase 3:** Implement 3 choice interaction types
**Phase 4:** Add voice recording (2 moments)
**Phase 5:** Test and refine debate personalities
**Phase 6:** Polish animations and timing

---

## Open Questions for Implementation

1. **Debate timing:** How long should each debate line stay on screen? (2 sec per line?)
2. **Skip option:** Should there be a way to skip debates for returning users?
3. **Replay:** Can users replay debates they've already seen?
4. **Accessibility:** How do debates work for screen readers?
5. **Localization:** How do we maintain personality in other languages?

---

**Status:** Design complete, ready for prototype implementation
**Next Step:** Build step engine + first 5 steps as proof of concept
