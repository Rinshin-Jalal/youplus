Step 1. Brand Aesthetic Core

Essence:
BigBruh = confrontational accountability + brotherly authority.
Not corporate, not wellness, not “self-improvement cozy vibes.”

Keywords:

Raw

Direct

Aggressive but caring

Bold

Street / Gen Z digital culture

No neutrality

Feel:
Like your older brother in your face, but you know he wants you to win.

Step 2. Design Language
Typography

Primary Font Stack:
Impact → Maximum impact headers, burning text, authority statements.
Inter-Bold → Modern body text, explanations, UI labels.
Inter-Black → Heavy buttons, emphasis, destructive actions.
Inter-Regular → Clean reading text, secondary information.

Secondary Fonts:
Menlo → Monospace terminal aesthetic, debug information.
System → Fallback default font.

Removed Fonts:
Arial Black → Replaced with Impact for authority, Inter-Black for emphasis.
Courier New → Replaced with Inter-Bold for technical info, Inter-Regular for general text.

Font Weight Hierarchy:
900 → Emergency headers, burning effects, critical warnings.
800 → Primary headers, main statements.
700 → Body text, buttons, emphasis.
600 → Secondary text, labels.
400 → Supporting text, muted information.

Rules:

- Always uppercase for headers and impact statements.
- High-contrast text only (black/white, no grays for main content).
- Maximum 4 fonts per screen, 2 fonts preferred.
- Never use round/friendly fonts.
- Letter spacing: 2-6px for headers, 1-2px for body.
- Line height: 1.2-1.4 for headers, 1.4-1.6 for body.

Color Palette

Base Binary System:
Pure Black (#000000) - Mystery, authority, judgment phases.
Pure White (#FFFFFF) - Clinical examination, clean phases.

Text: Harsh contrast - White on black, Black on white.

Primary Accent Colors:
Neon Red (#FF0033 / #FF0000) → urgency, blood, aggression, errors.
Neon Green (#90FD0E / #39FF14) → success, recording, "go" energy.
Orange-Red (#FF6B4A) → secondary red family, warnings.
Bright Yellow (#FFFF00) → countdown timers, urgent alerts.
Apple Red (#FF3B30) → error states, destructive actions.
Burn Orange (#FF4500) → fire effects, destruction.

Secondary Color Family:
#4AFF6B → Growth energy, secondary green.
#4A6BFF → Digital blue, secondary blue.
#FFD94A → Warning yellow, secondary yellow.

Gray Scale:
#666666 → Secondary text, muted elements.
#333333 → Background variants, disabled states.
#111111 → Subtle borders, dark accents.

RGBA Overlay System:
rgba(255,255,255,0.06) → Subtle glitch overlays.
rgba(255,255,255,0.10) → Medium white overlays.
rgba(255,255,255,0.15) → Strong white overlays.
rgba(255, 59, 48, 0.95) → Red error state overlays.
rgba(57, 255, 20, 0.06) → Subtle green recording states.
rgba(57, 255, 20, 0.12) → Medium green recording states.
rgba(255, 0, 0, 0.1) → Red stamp/document overlays.

Avoid: Pastels, corporate blues, soft gradients, rainbow colors.

UI Elements

Rectangular buttons. No rounded corners.

Solid fills, no gradients except glitch/neon glow.

Minimal iconography. When used, must be bold/line-based, no cartoonishness.

Single dominant action per screen.

Motion & Effects

Core Animation Principles:
Snappy, hard cuts - no easing, instant state changes.
Aggressive transitions - 200-400ms duration, no bounce.
Glitch effects for phase changes and critical moments.

Viral Effect Library:
BurnTransition → Text-to-ash particle effects for contracts/signatures.
GlitchTransition → Chromatic aberration, horizontal bands, screen shake.
FilmGrainOverlay → Subtle 2-4% opacity procedural grain texture.
PulseButton → 2-second pulse cycle with 0.98 press depth scaling.

Phase-Based Visual System:
Black Phase (Steps 1-15) → Mystery, authority, dark backgrounds.
White Phase (Steps 16-35) → Clinical examination, harsh contrast.
Black Phase (Steps 36+) → Judgment, sealing, authority.

UI Pattern Library:
Rectangular buttons with 3px borders, no rounded corners.
High-contrast text only - white/black, no gray main content.
Single dominant action per screen.
Left-aligned text for authority (not centered).
Letter spacing 2-6px for headers, 1-2px for body.

Technical Implementation:
react-native-reanimated for all animations.
Expo Audio for sound integration.
Binary background system (black/white phases).
RGBA overlay system for subtle effects.
Light mode enforcement in paywall flows.
No gradients except neon glow effects.

Step 3. Tone of Voice

Direct, brotherly, slang-infused but not meme-y parody.

Short sentences. Commands, not suggestions.

Daily Call Examples:
"TIME FOR YOUR CHECK-IN. DID YOU KEEP YOUR WORD?"
"NO HIDING. NO EXCUSES. WHAT'S THE TRUTH?"
"STACK WINS. NOT EXCUSES."

Call Response Examples:
Success: "THAT'S THE VERSION OF YOU I F\*\*\* WITH."
Failure: "NAH. SAME WEAK EXCUSE FROM ONBOARDING. I DIDN'T FORGET."

Step 4. Brand Aesthetic Position

If BIG BRUH = austere, philosophical, serious.
BigBruh = raw, street, Gen Z-coded but strict.

Visual reference points:

Gym brands (Gorilla Mind, YoungLA) but more digital-glitch than fitness.

Hacker / underground design (black + neon).

Gen Z social apps (BeReal, NGL, GAS) but stripped of soft UI.

Step 5. Component Architecture Patterns

Core App Structure:

- Intensive 54-step onboarding → Psychological profile extraction
- Single daily accountability call → Binary success/failure tracking
- App screens → Home, Call Interface, History, Settings

Key Components:
OnboardingFlow → 54-step psychological transformation journey
CallInterface → VoIP call handling with BigBruh confrontation
HomeScreen → Daily status, win streaks, accountability tracking
HistoryScreen → Past calls, excuse patterns, failure/success record
SettingsScreen → Call preferences, intensity levels

Call System Components:
VoiceCallUI → Real-time conversation interface with BigBruh
CallResponse → Binary success/failure input (✅ Did it / ❌ Failed)
ExcuseCounter → Tracks and replays user's recurring excuses
StreakTracker → Win/loss counter without gamification

Visual Effect Hierarchy:
Phase flashes → White screen flash on critical moments
Call transitions → Aggressive cuts, no easing
Confrontation text → Typewriter reveals with authority
Failure feedback → Screen shake, harsh contrast
Success feedback → Brief neon pulse, minimal celebration

Step 6. Gen Z Fit Test

Gen Z aesthetic loves: high contrast, neon, glitch, irony, bluntness.

Gen Z hates: corporate minimalism, over-polished motivational apps, "dad vibes."

BigBruh passes because:

Feels like an app you’d hate but need.

Feels like part of Gen Z "edgy internet" not mainstream productivity.

Tone is strict but not cringe-dad—closer to locker room older brother.

Risk: if overdone, could drift into parody. Must stay authentic, not meme-only.

Step 7. Brand Tagline Directions

“BIGBRUH SEES ALL.”

“STACK WINS. NOT EXCUSES.”

“THE BROTHER YOU CAN’T GHOST.”

“NO HIDING. NO QUITTING.”
