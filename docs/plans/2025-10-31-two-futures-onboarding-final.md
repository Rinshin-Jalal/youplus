# BigBruh Two Futures Onboarding - Final Design

**Date:** 2025-10-31
**Status:** Final Design - Ready for Implementation
**Duration:** 15-20 minutes
**Total Steps:** 30 (15 debates + 15 inputs)
**Style:** Minimal SwiftUI + Split-screen debates + Swipe navigation

---

## Core Concept

**Two Future Versions of You Fighting Over Your Timeline:**

- **TOP = WINNER FUTURE YOU**
  - Already succeeded, already won
  - Knows the path, lived through it
  - Wants to pull you forward
  - "I made it. Here's how."

- **BOTTOM = LOSER FUTURE YOU**
  - Tried and failed, lives with regret
  - Knows the pain of failure
  - Wants to keep you comfortable/safe
  - "I tried. It hurt. Stay safe."

**The Conflict:** Which future timeline do you choose?

---

## Character Voices

### Winner Future You (TOP - Blue text)

**Personality:**
- Confident but not arrogant
- Has scars from the journey
- Wants you to avoid their mistakes
- "I know it's hard. I lived it."

**Example Lines:**
```
"I wasted 2 years before I started. Don't be me."
"The pain of discipline is nothing compared to the pain of regret."
"I wish someone had pushed me harder. So I'm pushing you."
"You're stronger than you think. I know because I AM you."
```

**Tone:** Urgent, experienced, no bullshit

---

### Loser Future You (BOTTOM - Gray text)

**Personality:**
- Not weak, but protective
- Learned pain from trying and failing
- Genuinely cares about sparing you pain
- "I tried for you. It didn't work."

**Example Lines:**
```
"I tried this. It broke me. Don't make my mistake."
"Comfort isn't weakness. It's survival."
"I pushed too hard and lost everything. Be smarter."
"They say 'just try' - they don't know the cost."
```

**Tone:** Protective, defeated but caring, realistic

---

## Complete 30-Step Flow

### PHASE 1: INTRODUCTION (Steps 1-6, ~3 min)

**Step 1: DEBATE - Opening Encounter**
```
SPLIT SCREEN:

TOP (Winner Future):
"They're here."

BOTTOM (Loser Future):
"I know. I can feel it."

TOP:
"This is our chance. OUR chance to change it."

BOTTOM:
"Or our chance to save them from what happened to me."

TOP:
"We both want what's best."

BOTTOM:
"We just disagree on what that is."

[Swipe right to continue →]
```
**Purpose:** Establish that BOTH futures care, but have opposite advice

---

**Step 2: INPUT - Name (Simple text)**
```
"What should we call you?"

[Text input]
[Continue]
```
**Data:** `name`

---

**Step 3: DEBATE - First Direct Address**
```
TOP:
"{{name}}. Listen to me carefully."

BOTTOM:
"{{name}}. I need you to hear this."

TOP:
"I'm the version of you who made it."

BOTTOM:
"I'm the version who tried and failed."

TOP:
"I know the path forward."

BOTTOM:
"I know the cost of that path."

TOP:
"Choose wisely."

BOTTOM:
"Choose safely."

[Swipe →]
```
**Purpose:** Make the stakes crystal clear

---

**Step 4: INPUT - What You WON'T Give Up (Contrarian)**
```
"To win, what's the ONE thing you absolutely WON'T sacrifice?"

[Text input]
[Continue]
```
**Data:** `non_negotiable`

---

**Step 5: DEBATE - About Their Boundary**
```
[Dynamic based on answer]

If "Sleep" or "Health":
TOP: "{{answer}}. Smart. I protected that too."
BOTTOM: "{{answer}}. I sacrificed it. Don't be me."
TOP: "See? We agree on this one."
BOTTOM: "Rare moment."

If "Comfort" or "Social media":
BOTTOM: "{{answer}}. Good. That's what kept me sane."
TOP: "That's what kept you stuck."
BOTTOM: "Stuck but safe."
TOP: "Safe but stuck."

[Swipe →]
```

---

**Step 6: INPUT - When Are You Strongest? (Choice)**
```
"When does the best version of you show up?"

○ 5am (before the world wakes)
○ 10pm (after the world sleeps)
○ Midday (when energy peaks)

[Tap to select]
[Continue]
```
**Data:** `energy_peak`

---

### PHASE 2: TIMELINE DIVERGENCE (Steps 7-14, ~5 min)

**Step 7: DEBATE - Different Experiences**
```
[Based on their energy choice]

TOP:
"{{time_choice}}. That's when I trained."

BOTTOM:
"{{time_choice}}. That's when I told myself I'd train."

TOP:
"The difference? I actually got up."

BOTTOM:
"The difference? You didn't see what it cost me."

[Swipe →]
```

---

**Step 8: INPUT - Who Would You WANT to Disappoint? (Contrarian)**
```
"Whose opinion matters so little you'd be HAPPY to disappoint them?"

[Text input or skip]
[Continue]
```
**Data:** `anti_accountability`

---

**Step 9: DEBATE - About External Pressure**
```
BOTTOM:
"{{answer}}. Good. Their opinion is toxic."

TOP:
"Agreed. I wasted years caring what {{answer}} thought."

BOTTOM:
"Finally something we agree on."

TOP:
"Doesn't mean you should care what NOBODY thinks."

BOTTOM:
"Doesn't mean you should break yourself for approval."

[Swipe →]
```
**Purpose:** Rare agreement moment showing both futures have wisdom

---

**Step 10: INPUT - VOICE - Your Origin Story (30-45 sec)**
```
"Tell both of us:"

"Why are you here? What happened that brought you to this moment?"

[Voice recorder - 30-60 seconds]
[Can skip if not ready]

[Continue]
```
**Data:** `voice_origin` (~30-45 sec)

---

**Step 11: DEBATE - React to Voice**
```
IF RECORDED:
TOP: "{{timestamp}} - hear that? That's desperation."
BOTTOM: "Desperation I remember."
TOP: "Desperation that fueled my success."
BOTTOM: "Desperation that broke me."
TOP: "We heard the same recording. Saw different futures."
BOTTOM: "That's the point."

IF SKIPPED:
BOTTOM: "They skipped it. Smart."
TOP: "Or scared."
BOTTOM: "Scared is smart sometimes."
TOP: "Not when scared keeps you stuck."

[Swipe →]
```

---

**Step 12: INPUT - Best Excuse (Contrarian)**
```
"What's your BEST excuse? The one that always works?"

[Text input]
[Continue]
```
**Data:** `favorite_excuse`

---

**Step 13: DEBATE - Excuse as Tool**
```
TOP:
"{{excuse}}. I used that one for 3 years."

BOTTOM:
"{{excuse}}. That one saved me countless times."

TOP:
"Saved you FROM success."

BOTTOM:
"Saved me FROM burnout."

TOP:
"Burnout heals. Regret doesn't."

BOTTOM:
"Easy for you to say. You won."

[Swipe →]
```

---

**Step 14: INPUT - "I'll change when..." (Contrarian)**
```
"Complete honestly:"

"I'll actually change when _______"

[Text input]
[Continue]
```
**Data:** `change_trigger`

---

### PHASE 3: COMMITMENT CROSSROADS (Steps 15-22, ~6 min)

**Step 15: DEBATE - About Waiting**
```
[Dynamic based on their answer]

If external condition:
BOTTOM: "Waiting for {{condition}}. I waited too."
TOP: "Still waiting? Or did you start?"
BOTTOM: "...I started. It destroyed me."
TOP: "Or built you. Depending on the timeline."

If internal state:
TOP: "Waiting to feel ready. You never will."
BOTTOM: "I never felt ready either. Pushed anyway. Regret it."
TOP: "I pushed too. Don't regret it."
BOTTOM: "Different outcomes. Same choice."

[Swipe →]
```

---

**Step 16: INPUT - The ONE Thing (Text)**
```
"What will you do every single day?"

[Be specific: '30min run at 6am' not 'exercise']

[Text input]
[Continue]
```
**Data:** `daily_commitment`

---

**Step 17: DEBATE - Specificity Matters**
```
TOP:
"{{commitment}}. I did that exact thing."

BOTTOM:
"{{commitment}}. I tried that exact thing."

TOP:
"Day 1: Hard. Day 100: Automatic."

BOTTOM:
"Day 1: Hard. Day 7: Quit."

TOP:
"What was different?"

BOTTOM:
"You tell me. You're the one who won."

TOP:
"I didn't quit on Day 7."

[Swipe →]
```

---

**Step 18: INPUT - What Time? (Time picker)**
```
"What time will you do {{commitment}}?"

[Time picker]
[Continue]
```
**Data:** `commitment_time`

---

**Step 19: DEBATE - Time Strategy**
```
[Check if aligned with energy peak]

IF ALIGNED:
TOP: "{{time}}. That's when I did it. Smart."
BOTTOM: "{{time}}. That's when I planned to. Never did."

IF NOT ALIGNED:
BOTTOM: "{{time}}. Fighting your natural rhythm?"
TOP: "Or expanding it. I did {{commitment}} at {{time}} even when tired."
BOTTOM: "And it worked?"
TOP: "...eventually."

[Swipe →]
```

---

**Step 20: INPUT - VOICE - Say Your Commitment (20-30 sec)**
```
"Both of us need to hear you say it:"

"I will {{commitment}} at {{time}} every single day."

[Voice recorder - 20-45 seconds]

[Continue]
```
**Data:** `voice_commitment` (~20-30 sec)
**Total voice:** ~50-75 sec

---

**Step 21: DEBATE - RARE FULL AGREEMENT**
```
TOP:
"They said it."

BOTTOM:
"Out loud."

TOP:
"That's what I sounded like Day 1."

BOTTOM:
"That's what I sounded like Day 1."

TOP:
"Difference is, I said it Day 100 too."

BOTTOM:
"I wish I had."

TOP:
"You can. Through them."

BOTTOM:
"...maybe."

TOP:
"Maybe is enough to start."

[Swipe →]
```
**Purpose:** Powerful - both futures see themselves in current you

---

**Step 22: INPUT - Quit Count (Number)**
```
"How many times have you 'started fresh' this year?"

[Number stepper: 0-50+]
[Continue]
```
**Data:** `quit_count`

---

### PHASE 4: DIVERGENT COUNSEL (Steps 23-28, ~4 min)

**Step 23: DEBATE - Different Lessons from Same Data**
```
[Based on quit_count]

IF 5+:
TOP: "{{count}} times. I quit {{count + 2}} times before I won."
BOTTOM: "{{count}} times. I quit {{count + 1}} times before I gave up."
TOP: "See? One more try."
BOTTOM: "Or one more failure."

IF 0-2:
BOTTOM: "{{count}} times. Lucky. I was at 15 before my first year."
TOP: "Not luck. Discipline starting early."

[Swipe →]
```

---

**Step 24: INPUT - Failure Tolerance (Choice)**
```
"How many misses before you're officially done?"

○ 1 miss = Zero tolerance
○ 3 misses = Human grace
○ 5 misses = Life happens
○ No limit = Never quit

[Tap to select]
[Continue]
```
**Data:** `failure_strikes`

---

**Step 25: DEBATE - Opposite Advice**
```
[Based on choice]

IF 1 strike:
TOP: "1 strike. That's what I did. Binary commitment."
BOTTOM: "1 strike. That's why I failed. Too rigid."

IF 3-5 strikes:
BOTTOM: "{{strikes}} strikes. Compassion. I wish I had that."
TOP: "{{strikes}} strikes. Enough rope to hang yourself."
BOTTOM: "Or enough grace to be human."
TOP: "Grace becomes excuse."
BOTTOM: "Rigidity becomes breakdown."

IF No limit:
BOTTOM: "No limit. Smart. Infinite chances."
TOP: "No limit. No accountability. Recipe for nothing."

[Swipe →]
```
**Purpose:** Neither is wrong - both have valid experience

---

**Step 26: INPUT - VOICE - Cost of Quitting (20-30 sec)**
```
"Tell us both:"

"If you quit this time, what does it cost you?"

[Voice recorder - 20-45 seconds]

[Continue]
```
**Data:** `voice_cost` (~20-30 sec)
**Total voice:** ~70-105 sec ✅

---

**Step 27: DEBATE - Both Futures Hear the Cost**
```
TOP:
"That cost... I know it."

BOTTOM:
"I live it. Every day."

TOP:
"That's why we're both here."

BOTTOM:
"Different methods. Same desperation."

TOP:
"I don't want them to become me through pain."

BOTTOM:
"I don't want them to become me through regret."

TOP:
"Then let's give them both perspectives."

BOTTOM:
"And let them choose."

[Swipe →]
```

---

**Step 28: INPUT - Who Notices? (Text)**
```
"Name one person who will notice if you actually do this:"

[First name]

[Text input]
[Continue]
```
**Data:** `witness`

---

### PHASE 5: THE CHOICE (Steps 29-30, ~2 min)

**Step 29: DEBATE - Final Divergent Appeals**
```
TOP:
"{{name}}, here's what I know:"
"{{commitment}} at {{time}} every day changed everything."
"Was it hard? Yes. Worth it? Absolutely."
"I can't promise it won't hurt."
"But I can promise the alternative hurts more."

BOTTOM:
"{{name}}, here's what I know:"
"{{commitment}} at {{time}} sounded perfect."
"But I broke myself trying."
"Was it hard? Unbearable. Worth it? I'll never know."
"I can't promise comfort is right."
"But I can promise pushing too hard breaks you."

TOP:
"Choose forward."

BOTTOM:
"Choose safety."

TOP:
"Choose growth."

BOTTOM:
"Choose sanity."

BOTH (centered):
"We can't choose for you."

[Swipe →]
```
**Purpose:** Final clear presentation of both philosophies

---

**Step 30: LOCK-IN - Your Timeline Decision**
```
SCREEN: Clean summary (both voices silent, your choice)

━━━━━━━━━━━━━━━━━━━━━━━
YOUR COMMITMENT
━━━━━━━━━━━━━━━━━━━━━━━

{{name.uppercase()}}

I will {{commitment}}
at {{time}}
every single day.

{{strikes}} strikes limit.
{{witness}} is watching.

━━━━━━━━━━━━━━━━━━━━━━━

Which future am I choosing?

[→ WINNER'S PATH] ← Blue, bold
[→ LOSER'S PATH] ← Gray, subtle

━━━━━━━━━━━━━━━━━━━━━━━

IF WINNER'S PATH:
TOP (solo, centered):
"Welcome to the winning timeline.
I'll be here with you.
Every. Single. Day.
Let's prove Loser Future wrong."

IF LOSER'S PATH:
BOTTOM (solo, centered):
"I understand. Safety makes sense.
But... what if Winner Future is right?
Last chance to change timelines."

[Still want safety?]
[Actually, show me the winning path]

FINAL LOCK-IN:
BOTH (together):
"We'll call at {{time}}.
The path is set.
Now we see which future wins."

[Fade to main app]
```

---

## Technical Implementation

### Character Colors

```swift
enum FutureVoice {
    case winner  // Top, blue (#4A90E2)
    case loser   // Bottom, gray (#8E8E93)
    case both    // Centered, white
}
```

### Data Model

```swift
struct OnboardingResponse {
    let name: String
    let nonNegotiable: String
    let energyPeak: String
    let antiAccountability: String?

    let dailyCommitment: String
    let commitmentTime: Date

    let favoriteExcuse: String
    let changeTrigger: String
    let quitCount: Int

    let failureStrikes: Int
    let witness: String

    // Voice recordings (70-105 sec total)
    let voiceOrigin: URL?       // ~30-45 sec
    let voiceCommitment: URL    // ~20-30 sec
    let voiceCost: URL          // ~20-30 sec

    // Which timeline chosen
    let chosenPath: PathChoice
}

enum PathChoice {
    case winner
    case loser  // Redirected to winner with softer approach
}
```

### Debate Message System

```swift
struct DebateExchange {
    let winnerSays: String
    let loserSays: String
    let context: DebateContext
}

enum DebateContext {
    case agreement      // Both say similar things
    case opposition     // Direct disagreement
    case nuanced        // Both right from different angles
}

// Dynamic debate generation
func generateDebate(
    for step: Int,
    with userAnswer: String?,
    previousAnswers: [String: Any]
) -> DebateExchange {
    // Context-aware debate creation
    // Winner perspective: "This worked for me"
    // Loser perspective: "This failed for me"
}
```

---

## Contrarian Questions with Two Futures Context

| Question | Winner Response | Loser Response |
|----------|----------------|----------------|
| "What won't you give up?" | "I kept {{answer}}. It sustained me." | "I couldn't give up {{answer}}. It held me back." |
| "Who would you disappoint?" | "I stopped caring about {{person}}. Freedom." | "I stopped caring about {{person}}. Isolation." |
| "Best excuse?" | "{{excuse}} worked until it didn't." | "{{excuse}} protected me from pain." |
| "I'll change when..." | "Stop waiting. I did. It worked." | "I stopped waiting. It broke me." |

---

## Key Features

✅ **Two futures fighting** - NOT current vs future, but winner vs loser futures
✅ **Both care** - Neither is villain, both want best for current you
✅ **Opposite advice** - Same data, different conclusions
✅ **30 steps** - 15 debates + 15 inputs
✅ **Contrarian questions** - Flip typical onboarding
✅ **Voice strategy** - 3 moments, ~70-105 sec total
✅ **Swipe navigation** - Forward/back through steps
✅ **Choice matters** - Final decision between timelines
✅ **Minimal design** - Clean split screen, no color phases
✅ **Rare agreement** - Powerful moments when both futures align

---

## Why This Works

**Psychological Power:**
- Not external authority vs you
- Not idealized future vs broken present
- **TWO VERSIONS OF YOUR FUTURE SELF** with lived experience
- One succeeded, one failed - both are YOU
- Makes the stakes visceral and real

**Emotional Impact:**
- Winner: "I made it. You can too."
- Loser: "I tried and failed. Spare yourself."
- You decide: Which story do I want to live?

**Data Collection:**
- Same essential data as before
- But collected through lived future testimony
- More authentic responses
- Deeper emotional investment

---

**Status:** Final design complete
**Character Dynamic:** CORRECTED - Two futures, not current vs future
**Next:** Prototype implementation
