# BigBruh Split-Screen Debate Onboarding

**Date:** 2025-10-31
**Status:** Final Design v2 - Split Screen Live Feed
**Duration:** 15-20 minutes
**Steps:** 30-40 steps (dynamic)
**Style:** Split screen, typewriter feed, minimal design

## Core Visual Design

### Screen Layout

```
┌─────────────────────────────┐
│                             │
│      FUTURE SELF            │
│      (Blue text)            │
│      [Typing live...]       │
│                             │
├─────────────────────────────┤ ← Divider line
│                             │
│      WEAK SELF              │
│      (Gray text)            │
│      [Typing live...]       │
│                             │
└─────────────────────────────┘
```

**50/50 Split:**
- Top half = Future Self territory
- Bottom half = Weak Self territory
- Thin divider line in middle
- Each side types in real-time with typewriter effect
- Text scrolls up as conversation continues

**When User Needs to Input:**
- One side (or both) clears out
- Input field appears in center
- After input, debate resumes

---

## The Experience

### Live Conversation Feed

**Both voices type simultaneously** like a real-time argument:

```
TOP HALF (Future Self typing...):
"They're here because they're tired of being weak."

BOTTOM HALF (Weak Self typing...):
"They're here because they download apps when desperate."

TOP HALF:
"Same thing. Desperation can fuel change."

BOTTOM HALF:
"Or it fizzles in 72 hours like always."

TOP HALF:
"Let's find out."

[Screen clears for input]
```

**Key Difference:** Feels like you're watching a LIVE conversation about you, not reading scripted text.

---

## Complete Flow (35 Steps)

### PHASE 1: OPENING HOOK (5 steps, 2 min)

**Step 1: DEBATE - They Don't Know You're Watching**
```
TOP: "Someone's here."
BOTTOM: "Probably another quitter."
TOP: "Or the one who finally makes it."
BOTTOM: "1 in 100. Those are terrible odds."
TOP: "Better than 0 in 100."
BOTTOM: "Fair point."

[Tap anywhere to continue]
```

**Step 2: DEBATE - About You Specifically**
```
TOP: "They opened the app at {{current_time}}."
BOTTOM: "So? Everyone has midnight motivation."
TOP: "Or morning clarity. Or lunch break desperation."
BOTTOM: "Time doesn't matter. They all quit."
TOP: "What if this one doesn't?"
BOTTOM: "Then I'll be the first to celebrate."
TOP: "Liar. You'll find a new excuse."

[Continue]
```

**Step 3: INPUT - Name**
```
[Both sides clear]
[Center of screen:]
"What should we call you?"
[TextField]
```

**Step 4: DEBATE - React to Name**
```
TOP: "{{name}}. Strong name."
BOTTOM: "It's just a name. Doesn't mean anything."
TOP: "Names are identity. Identity drives action."
BOTTOM: "Or it's just what their parents called them."
TOP: "Today they choose what it means."
BOTTOM: "If they don't quit by Friday."

[Continue]
```

**Step 5: DEBATE - Set Expectations**
```
TOP: "{{name}}, here's the deal:"
TOP: "We're going to ask you questions."
TOP: "You answer honestly, we hold you accountable."
BOTTOM: "Or you lie, we catch you, you quit."
TOP: "That's the defeatist version."
BOTTOM: "That's the realistic version."
TOP: "Either way, let's begin."

[Continue]
```

---

### PHASE 2: IDENTITY EXPLORATION (10 steps, 5 min)

**Step 6: INPUT - Current Identity**
```
[Screen splits, question appears in middle:]
"Who are you RIGHT NOW?"
[Not who you want to be. Who you ARE today.]
[TextField]
```

**Step 7: DEBATE - About Current Self**
```
[Dynamic based on their answer]

TOP: "{{their_answer}}. That's honest."
BOTTOM: "Or that's who they THINK they are."
TOP: "What's the difference?"
BOTTOM: "Perception vs reality. Huge gap."
TOP: "Then let's close the gap."

[Continue]
```

**Step 8: INPUT - Future Identity**
```
"Who do you want to become?"
[TextField - multiline]
```

**Step 9: DEBATE - Gap Analysis**
```
TOP: "Current: {{current_identity}}"
TOP: "Future: {{future_identity}}"
TOP: "That's a BIG gap."
BOTTOM: "Too big. Unrealistic."
TOP: "Or achievable with the right system."
BOTTOM: "Systems fail. People fail."
TOP: "Not if they don't quit."

[Continue]
```

**Step 10: DEBATE - Why People Quit**
```
BOTTOM: "Want to know why they'll quit?"
TOP: "I'd rather focus on why they'll win."
BOTTOM: "That's naive. Patterns don't lie."
TOP: "Patterns can change. That's literally why we're here."
BOTTOM: "Hope isn't a strategy."
TOP: "Neither is cynicism."
BOTTOM: "Touché."

[Continue]
```

**Step 11: INPUT - Success Memory**
```
"Tell us about ONE time you actually followed through."
[What was different that time?]
[TextField - multiline]
```

**Step 12: DEBATE - Success Pattern**
```
TOP: "{{their_success_story}}. See? They CAN do it."
BOTTOM: "Once. They did it ONCE."
TOP: "Once proves it's possible. Once is the data point."
BOTTOM: "Once is an outlier. Not a pattern."
TOP: "Not yet. But it could be."
BOTTOM: "Could be. Will be. Wanna be. All the same."
TOP: "Until they're not."

[Continue]
```

**Step 13: INPUT - Why That Success Happened**
```
"Why did you succeed that one time?"
[What made it different?]
[TextField]
```

**Step 14: DEBATE - Extract the Pattern**
```
TOP: "{{their_reason}}. That's the key."
BOTTOM: "Or that's what they THINK was the key."
TOP: "Either way, it's a clue. A variable we can control."
BOTTOM: "You can't control external circumstances."
TOP: "No, but you can control response to circumstances."
BOTTOM: "Philosophy major over here."
TOP: "No. Engineer. And we're engineering success."

[Continue]
```

**Step 15: VOICE INPUT - Why You're Here**
```
[Both sides clear]
[Center:]
"Record in your own voice:"
"Why am I really here?"

[Voice recorder - 20-60 seconds]
[After recording, continue]
```

**Step 16: DEBATE - React to Voice**
```
TOP: "Did you hear that?"
BOTTOM: "Yeah. I heard it."
TOP: "The part where their voice cracked?"
BOTTOM: "At {{timestamp}}. Yeah."
TOP: "That's the real reason. Not the words. The crack."
BOTTOM: "People can fake words. Can't fake voice cracks."
TOP: "Exactly. That's our foundation."

[Continue]
```

---

### PHASE 3: EXCUSE CONFRONTATION (8 steps, 4 min)

**Step 17: DEBATE - Transition to Excuses**
```
BOTTOM: "Okay so they want to change. Great."
BOTTOM: "But here's what actually happens:"
BOTTOM: "Day 1: Motivated"
BOTTOM: "Day 2: Tired"
BOTTOM: "Day 3: Life happens"
BOTTOM: "Day 4: Quit"
TOP: "Unless we identify the excuse BEFORE it arrives."
TOP: "Then we can kill it."

[Continue]
```

**Step 18: INPUT - Favorite Excuse (Multiple Choice)**
```
"Pick your favorite excuse:"

• I don't have time
• I'm too tired
• I'll start tomorrow
• It's not the right moment
• Other people have it easier
• [Custom]

[Tap to select]
```

**Step 19: DEBATE - About Their Excuse**
```
[Dynamic per excuse. Example: "I don't have time"]

BOTTOM: "Time is real though. They ARE busy."
TOP: "Everyone's busy. Winners find time."
BOTTOM: "So people who don't have time are losers?"
TOP: "No. People who SAY they don't have time are liars."
BOTTOM: "Harsh."
TOP: "True. They found time to answer these questions."
BOTTOM: "...okay fair."

[Continue]
```

**Step 20: INPUT - Time Audit**
```
"Yesterday. Where did your time ACTUALLY go?"
[Be honest. We already know the answer.]
[TextField - multiline]
```

**Step 21: DEBATE - Time Reality Check**
```
TOP: "{{their_time_audit}}. There it is."
BOTTOM: "See? They didn't have time!"
TOP: "They had time. They chose other things."
BOTTOM: "Choosing rest isn't a crime."
TOP: "No. But saying 'I don't have time' while scrolling 2 hours is."
BOTTOM: "Ouch."
TOP: "Truth hurts. But lies hurt more."

[Continue]
```

**Step 22: INPUT - Weakness Window**
```
"When are you weakest?"
[Time of day + situation]
[Example: "9pm on couch after work"]
[TextField]
```

**Step 23: DEBATE - Weakness Strategy**
```
TOP: "{{weakness_window}}. Classic ambush point."
BOTTOM: "So what? Everyone has weak moments."
TOP: "Yes. But smart people don't walk into them."
BOTTOM: "How do you avoid life?"
TOP: "You don't avoid life. You schedule BEFORE the ambush."
BOTTOM: "Or build discipline to push through."
TOP: "Which is more likely for someone who's quit {{N}} times?"

[Continue]
```

**Step 24: INPUT - Quit Counter**
```
"How many times have you 'started fresh' this year?"
[Number slider: 0-50+]
```

**Step 25: DEBATE - Pattern Recognition**
```
[Dynamic based on count]

IF 5+:
BOTTOM: "{{count}} times. That's... a lot."
TOP: "That's not a lot. That's a PATTERN."
BOTTOM: "Can patterns be broken?"
TOP: "Only if you see them first."
BOTTOM: "They're seeing it now."
TOP: "Seeing isn't changing. But it's step one."

[Continue]
```

---

### PHASE 4: COMMITMENT BUILDING (8 steps, 5 min)

**Step 26: DEBATE - Transition to Action**
```
TOP: "Enough analysis. Time to build the system."
BOTTOM: "Here we go. The 'life-changing commitment.'"
TOP: "Mock all you want. Systems work."
BOTTOM: "Systems work until they don't."
TOP: "They work until YOU quit them."
BOTTOM: "Exactly. So let's see how long this lasts."
TOP: "Let's."

[Continue]
```

**Step 27: INPUT - The ONE Thing**
```
"What's the ONE thing you'll do every single day?"
[Be specific. 'Work out' isn't enough.]
[TextField]
```

**Step 28: DEBATE - Specificity Check**
```
TOP: "{{their_commitment}}. Is that specific enough?"
BOTTOM: "It's fine. Perfect is enemy of good."
TOP: "Vague is enemy of accountability."

[SWIPE DOWN = Make it more specific (agree with TOP)]
[SWIPE UP = Accept as-is (agree with BOTTOM)]
```

**Step 29: INPUT - Time Selection**
```
"What time will you do {{their_commitment}}?"
[Time picker]
```

**Step 30: DEBATE - Time Strategy**
```
[Check if time is in weakness window]

IF IN WEAKNESS WINDOW:
TOP: "{{time}}. That's IN your weakness window."
BOTTOM: "Face the dragon head-on!"
TOP: "Noble. Stupid. But noble."
BOTTOM: "Sometimes stupid is brave."
TOP: "And sometimes brave is just stupid."
[Continue - accept their choice]

IF STRATEGIC TIME:
TOP: "{{time}}. Before the weakness hits. Smart."
BOTTOM: "Or early enough that they'll snooze it."
TOP: "We'll see."
BOTTOM: "Yes. We will."
[Continue]
```

**Step 31: INPUT - Backup Plan**
```
"When will you do it if {{time}} doesn't work?"
[Backup time picker]
[Or: 'No backup - {{time}} or nothing']
```

**Step 32: DEBATE - Flexibility vs Discipline**
```
[If they chose backup time:]
TOP: "Backup plan. Flexible."
BOTTOM: "Or pre-planned excuse."
TOP: "Life happens. Flexibility isn't failure."
BOTTOM: "Flexibility becomes 'eventually' becomes 'never.'"

[If they chose no backup:]
TOP: "No backup. Bold."
BOTTOM: "Or setting themselves up for guilt."
TOP: "Binary commitment. {{time}} or failure."
BOTTOM: "Harsh. But clear."

[Continue]
```

**Step 33: VOICE INPUT - Record Commitment**
```
[Screen clears]
"Record your commitment:"

"I will {{commitment}} every day at {{time}}"

[Voice recorder - 30-90 seconds]
[Can expand beyond prompt]
```

**Step 34: DEBATE - React to Voice (RARE AGREEMENT)**
```
BOTTOM: "That was... different."
TOP: "Yeah. I heard it."
BOTTOM: "They didn't sound fake."
TOP: "No. They sounded scared."
BOTTOM: "Scared of failing?"
TOP: "Scared of failing. More scared of never trying."
BOTTOM: "That's real."
TOP: "That's everything."
BOTTOM: "So what now?"
TOP: "Now we hold them accountable. No mercy."
BOTTOM: "I'm in."
TOP: "We're BOTH in."

[Continue - powerful moment]
```

---

### PHASE 5: LOCK-IN & ACCOUNTABILITY SETUP (5 steps, 3 min)

**Step 35: INPUT - Failure Tolerance**
```
"How many missed days before you're officially a quitter?"

• 1 strike - no mercy
• 3 strikes - human tolerance
• 5 strikes - realistic buffer
```

**Step 36: DEBATE - Failure Philosophy**
```
[Dynamic based on choice]

IF 1 STRIKE:
BOTTOM: "1 strike? That's insane."
TOP: "That's commitment. One miss = pattern starts."
BOTTOM: "What about emergencies?"
TOP: "Real emergencies are rare. Excuses are common."

IF 3 STRIKES:
TOP: "3 strikes. Reasonable."
BOTTOM: "Or just enough rope to hang themselves."
TOP: "Glass half empty much?"
BOTTOM: "Realism isn't pessimism."

IF 5 STRIKES:
BOTTOM: "5 strikes. That's a lot of grace."
TOP: "Or a lot of chances to establish the quit pattern."
BOTTOM: "Or space to be human."
TOP: "We'll see which one it is."

[Continue]
```

**Step 37: INPUT - Accountability Partner Name**
```
"Who would be most disappointed if you quit?"
[First name only]
[TextField]
```

**Step 38: DEBATE - External Accountability**
```
TOP: "{{partner_name}}. They know you."
BOTTOM: "But will they actually hold you accountable?"
TOP: "Doesn't matter. The NAME creates the pressure."
BOTTOM: "Internal guilt as motivation. Classic."
TOP: "If it works, it works."
BOTTOM: "Fair."

[Continue]
```

**Step 39: SUMMARY - Commitment Card**
```
[Both sides show same text, centered:]

━━━━━━━━━━━━━━━━━━━━━━━
YOUR COMMITMENT
━━━━━━━━━━━━━━━━━━━━━━━

WHO: {{name}}
BECOMING: {{future_identity}}
BY DOING: {{commitment}}
EVERY DAY AT: {{time}}

FAILURE LIMIT: {{strikes}}
ACCOUNTABILITY: {{partner_name}}

━━━━━━━━━━━━━━━━━━━━━━━

[Button: LOCK IT IN]
[Button: Change Something]
```

**Step 40: FINAL DEBATE - If Locked In**
```
TOP: "Welcome to BigBruh, {{name}}."
BOTTOM: "Hope you're ready."
TOP: "We'll call at {{time}}."
BOTTOM: "Every. Single. Day."
TOP: "Miss the call..."
BOTTOM: "...and we mark the strike."
TOP: "{{strikes}} strikes and you're out."
BOTTOM: "But we don't think you'll quit."
TOP: "We KNOW you won't quit."
BOTH (centered): "Because you heard yourself say it."

[Fade to main app]
```

---

## Technical Implementation

### Split Screen Layout

```swift
VStack(spacing: 0) {
    // TOP HALF - Future Self
    VStack {
        ScrollView {
            ForEach(futureSelfMessages) { message in
                HStack {
                    Text(message.text)
                        .typewriterEffect()
                        .foregroundColor(.blue)
                        .font(.body)
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
    }
    .frame(maxHeight: .infinity)
    .background(Color.white)

    // DIVIDER
    Rectangle()
        .fill(Color.gray.opacity(0.3))
        .frame(height: 1)

    // BOTTOM HALF - Weak Self
    VStack {
        ScrollView {
            ForEach(weakSelfMessages) { message in
                HStack {
                    Text(message.text)
                        .typewriterEffect()
                        .foregroundColor(.gray)
                        .font(.body)
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
    }
    .frame(maxHeight: .infinity)
    .background(Color.white)
}
```

### Typewriter Effect

```swift
struct TypewriterTextView: View {
    let text: String
    let speed: Double = 0.03 // seconds per character

    @State private var displayedText = ""

    var body: some View {
        Text(displayedText)
            .onAppear {
                animateText()
            }
    }

    private func animateText() {
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * speed) {
                displayedText.append(character)
            }
        }
    }
}
```

### Live Feed Animation

```swift
// When new message arrives
withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
    if message.speaker == .futureSelf {
        futureSelfMessages.append(message)
    } else {
        weakSelfMessages.append(message)
    }
}

// Auto-scroll to bottom
ScrollViewReader { proxy in
    // ... messages ...
    .onChange(of: messages) { _ in
        proxy.scrollTo(messages.last?.id, anchor: .bottom)
    }
}
```

### Input Transitions

```swift
// When input needed
withAnimation(.easeInOut(duration: 0.3)) {
    futureSelfMessages.removeAll() // Clear top
    weakSelfMessages.removeAll() // Clear bottom
    showInput = true
}

// Input appears in center (over divider)
ZStack {
    // Split screen debate
    splitScreenView

    // Input overlay (when needed)
    if showInput {
        VStack {
            Spacer()
            TextField("Your answer...", text: $userInput)
                .textFieldStyle(.roundedBorder)
                .padding()
            Spacer()
        }
        .background(Color.white.opacity(0.95))
        .transition(.opacity)
    }
}
```

---

## Data Models

```swift
struct DebateMessage: Identifiable {
    let id = UUID()
    let speaker: Speaker
    let text: String
    let timestamp: Date
}

enum Speaker {
    case futureSelf  // Top half, blue
    case weakSelf    // Bottom half, gray
    case both        // Rare - appears in both halves
}

struct OnboardingStep {
    let id: Int
    let type: StepType
    let content: StepContent
}

enum StepType {
    case debate(messages: [DebateMessage])
    case input(InputConfig)
    case debateWithChoice(messages: [DebateMessage], choice: ChoiceConfig)
}

struct OnboardingResponse {
    // Identity
    let userName: String
    let currentIdentity: String
    let futureIdentity: String

    // Commitment
    let dailyCommitment: String
    let commitmentTime: Date
    let backupTime: Date?

    // Patterns
    let successMemory: String
    let successReason: String
    let favoriteExcuse: String
    let timeAudit: String
    let weaknessWindow: String
    let quitCount: Int

    // Accountability
    let failureStrikes: Int
    let accountabilityPartner: String

    // Voice
    let voiceWhy: URL
    let voiceCommitment: URL

    // Choices
    let debateChoices: [Int: String] // stepId: choice
}
```

---

## Key Features

1. **35+ steps** - More content, better engagement
2. **50/50 split screen** - Visual drama, always showing both perspectives
3. **Live typewriter feed** - Feels like real-time conversation
4. **Scrolling history** - Can scroll back to see what was said
5. **Minimal design** - White background, clean text, no fancy colors
6. **Variety of inputs** - Text, voice, time pickers, swipes, taps
7. **Dynamic debates** - React to user's specific answers
8. **Rare agreement moment** - Powerful when both sides align

---

## Success Metrics

- **Engagement:** Split screen + typewriter = can't look away
- **Time:** 15-20 min despite 35+ steps (fast-paced)
- **Completion:** Target 75%+ (entertaining enough to finish)
- **Data:** All essential accountability data captured
- **Memorability:** "That was like watching a movie about myself"

---

**Status:** Ready for prototype implementation
**Next:** Build split-screen engine + first 10 steps proof of concept
