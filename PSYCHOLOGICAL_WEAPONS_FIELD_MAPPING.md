# 🔥 Psychological Weapons Field Mapping - V3

## Overview
This document maps Swift `db_field` values (raw onboarding responses) to Identity table psychological weapons (AI-extracted actionable insights).

**KEY PRINCIPLE:**
- **Swift db_fields** = Raw data collected from user (stored in JSONB)
- **Identity weapons** = AI-synthesized actionable insights (stored in identity table columns)

---

## 🗺️ Complete Field Mapping

### WEAPON 1: `shame_trigger`
**What it is:** The most shameful/disgusting thing about themselves

**Synthesized from Swift db_fields:**
- `physical_disgust_trigger` (Step 16) - Mirror confrontation
- `relationship_damage` (Step 15) - Who stopped believing
- `fear_version` (Step 14) - Loser version they fear becoming

**AI synthesis example:**
```
Input fields:
- physical_disgust_trigger: "my gut hanging over my belt"
- relationship_damage: "my girlfriend stopped asking about my business"
- fear_version: "the 40 year old still living with parents"

Output weapon:
"being 30 with a beer gut, watching my girlfriend lose interest while I become the 40-year-old basement dweller I swore I'd never be"
```

---

### WEAPON 2: `financial_pain_point`
**What it is:** Specific money/career opportunity cost with emotional weight

**Synthesized from Swift db_fields:**
- `financial_consequence` (Step 22) - Money not made
- `parental_sacrifice` (Step 24) - What parents sacrificed
- `procrastination_now` (Step 10) - What they're avoiding (career impact)

**AI synthesis example:**
```
Input fields:
- financial_consequence: "$40K in lost income this year"
- parental_sacrifice: "took out loans for my college"
- procrastination_now: "applying to better jobs"

Output weapon:
"$40K lost this year while sitting in a dead-end job - enough to repay the loans my parents took out for my degree that I'm wasting"
```

---

### WEAPON 3: `relationship_damage_specific`
**What it is:** Exact person + exact moment they gave up

**Extracted from Swift db_fields:**
- `relationship_damage` (Step 15) - Who stopped believing
- `external_judge` (Step 42) - Who would be most disappointed
- `disappointment_check` (Step 15 old) - Deprecated but may exist

**AI synthesis example:**
```
Input fields:
- relationship_damage: "My dad stopped looking me in the eye after I quit my third job in 2023. He doesn't ask about work anymore."
- external_judge: "Dad"

Output weapon:
"Dad stopped looking me in the eye after I quit my third job in 2023. He doesn't ask about work anymore - gave up on me."
```

---

### WEAPON 4: `breaking_point_event`
**What it is:** The catastrophic event that would FORCE change

**Synthesized from Swift db_fields:**
- `breaking_point` (Step 31) - What event would force change
- `urgency_mortality` (Step 35) - 10 years left urgency
- `fear_version` (Step 14) - Who they fear becoming

**AI synthesis example:**
```
Input fields:
- breaking_point: "health scare or partner leaving me"
- urgency_mortality: "I'd finally start that business and stop making excuses"
- fear_version: "the guy who dies with regrets"

Output weapon:
"Partner leaving, preventable health crisis from sedentary lifestyle, or dying with regrets at 60 knowing I never tried"
```

---

### WEAPON 5: `self_sabotage_pattern`
**What it is:** Complete pattern: EMOTION → RATIONALIZATION → QUIT + frequency

**Synthesized from Swift db_fields:**
- `sabotage_method` (Step 22 old) - Deprecated but may exist
- `emotional_quit_trigger` (Step 36) - Which emotion causes quit
- `intellectual_excuse` (Step 23) - Smart-sounding BS excuse
- `quit_counter` (Step 19) - How many fresh starts this year

**AI synthesis example:**
```
Input fields:
- emotional_quit_trigger: "Boredom"
- intellectual_excuse: "This approach isn't optimal, I need to research better methods"
- quit_counter: "8 times"

Output weapon:
"Day 3-5: boredom hits when initial excitement fades → rationalizes with 'this method isn't optimal, need better research' → quits. Has done this 8 times this year."
```

---

### WEAPON 6: `accountability_history`
**What it is:** Pattern of abandoning help + what actually works

**Synthesized from Swift db_fields:**
- `accountability_graveyard` (Step 34) - Number of systems quit
- `accountability_style` (Step 25) - What makes them move
- `success_memory` (Step 27) - Past success story

**AI synthesis example:**
```
Input fields:
- accountability_graveyard: "6 apps, 2 coaches, 1 gym membership"
- accountability_style: "Public shame"
- success_memory: "Only followed through when competing with my brother"

Output weapon:
"Quit 6 apps, 2 coaches, 1 gym membership in 18 months. Only moves when publicly shamed or in direct competition."
```

---

### WEAPON 7: `current_self_summary`
**What it is:** Brutal 2-3 sentence assessment of NOW

**Synthesized from Swift db_fields:**
- `voice_commitment` (Step 2) - Why really here
- `biggest_lie` (Step 5) - Biggest lie they tell themselves
- `daily_time_audit` (Step 18) - Where time actually goes
- `procrastination_now` (Step 10) - What avoiding right now

**AI synthesis example:**
```
Input fields:
- voice_commitment: "I'm here because I keep letting myself down"
- biggest_lie: "I'll start tomorrow"
- daily_time_audit: "6 hours on YouTube, 2 hours gaming, 1 hour scrolling"
- procrastination_now: "building my side business"

Output weapon:
"A 28-year-old who wastes 9 hours daily on entertainment instead of building the side business he talks about. Tells himself 'I'll start tomorrow' every night. Knows what to do, too weak to do it."
```

---

### WEAPON 8: `aspirational_identity_gap`
**What it is:** The PAINFUL GAP between want and reality

**Synthesized from Swift db_fields:**
- `identity_goal` (Step 28) - Who they want to become
- `success_metric` (Step 30) - Measurable number
- Current reality from `current_self_summary` synthesis

**AI synthesis example:**
```
Input fields:
- identity_goal: "Disciplined entrepreneur who builds wealth and freedom"
- success_metric: "Launch product by June 1st, $10K MRR by December"

Output weapon:
"Wants to be disciplined entrepreneur with $10K MRR product by December. Currently hasn't even started building, wakes at 11am, scrolls until 2pm. The gap grows daily."
```

---

### WEAPON 9: `non_negotiable_commitment`
**What it is:** ONE action + stakes + consequences

**Synthesized from Swift db_fields:**
- `daily_non_negotiable` (Step 20) - One thing every day
- `failure_threshold` (Step 43) - How many failures tolerated
- `sacrifice_list` (Step 38) - What willing to sacrifice

**AI synthesis example:**
```
Input fields:
- daily_non_negotiable: "100 pushups before 8am"
- failure_threshold: "1 strike - no mercy"
- sacrifice_list: "Comfort, Entertainment"

Output weapon:
"100 pushups before 8am daily, no excuses. 1 strike = accountability fail. Willing to sacrifice comfort and entertainment."
```

---

### WEAPON 10: `war_cry_or_death_vision`
**What it is:** Either motivational phrase OR nightmare future

**Extracted/Synthesized from Swift db_fields:**
- `war_cry` (Step 39) - War cry recording
- `oath_recording` (Step 45) - Oath recording
- `fear_version` (Step 14) - Nightmare self
- `urgency_mortality` (Step 35) - 10 years left vision

**AI synthesis example:**
```
Input fields:
- war_cry: "NO MORE WEAK SHIT"
- fear_version: "the guy who dies with regrets"

Output weapon:
"NO MORE WEAK SHIT or die at 60 as the guy who almost made it but was too comfortable"
```

---

## 🔄 Data Flow Architecture

### Frontend (Swift) → Backend Flow:

```
1. USER COMPLETES ONBOARDING (45 steps)
   └─ Swift sends all responses with db_field names

2. JSONB STORAGE (onboarding.responses)
   └─ All raw responses stored as-is
   └─ Example: { "physical_disgust_trigger": "...", "financial_consequence": "..." }

3. AI EXTRACTION (ai-psychological-analyzer.ts)
   └─ Reads JSONB responses
   └─ AI synthesizes 10 psychological weapons
   └─ Example: shame_trigger = synthesize(physical_disgust_trigger + relationship_damage + fear_version)

4. IDENTITY TABLE STORAGE
   └─ 10 weapons stored in identity table columns
   └─ identity_summary auto-generated from weapons

5. CALL GENERATION (onboarding-intel.ts)
   └─ Reads identity table weapons
   └─ Formats for brutal accountability calls
   └─ Example: "SHAME TRIGGER: [weapon] - Deploy when making excuses"
```

---

## 📊 Complete Swift db_field Reference

### All db_fields from StepDefinitions.swift:

| Step | db_field                      | Type   | Maps to Weapon                    |
|------|-------------------------------|--------|-----------------------------------|
| 2    | voice_commitment              | Voice  | current_self_summary              |
| 3    | identity_name                 | Text   | name (operational)                |
| 5    | biggest_lie                   | Voice  | current_self_summary              |
| 6    | favorite_excuse               | Choice | current_self_summary              |
| 7    | last_failure                  | Voice  | self_sabotage_pattern             |
| 9    | weakness_window               | Text   | self_sabotage_pattern             |
| 10   | procrastination_now           | Voice  | current_self_summary              |
| 11   | motivation_fear_intensity     | Slider | (not used in weapons)             |
| 11   | motivation_desire_intensity   | Slider | (not used in weapons)             |
| 12   | time_waster                   | Choice | current_self_summary              |
| 14   | fear_version                  | Voice  | shame_trigger, breaking_point     |
| 15   | relationship_damage           | Voice  | shame_trigger, relationship_dmg   |
| 16   | physical_disgust_trigger      | Voice  | shame_trigger                     |
| 18   | daily_time_audit              | Voice  | current_self_summary              |
| 19   | quit_counter                  | Text   | self_sabotage_pattern             |
| 20   | daily_non_negotiable          | Text   | non_negotiable_commitment         |
| 22   | financial_consequence         | Voice  | financial_pain_point              |
| 23   | intellectual_excuse           | Voice  | self_sabotage_pattern             |
| 24   | parental_sacrifice            | Voice  | financial_pain_point              |
| 25   | accountability_style          | Choice | accountability_history            |
| 27   | success_memory                | Voice  | accountability_history            |
| 28   | identity_goal                 | Voice  | aspirational_identity_gap         |
| 30   | success_metric                | Text   | aspirational_identity_gap         |
| 31   | breaking_point                | Voice  | breaking_point_event              |
| 32   | biggest_enemy                 | Voice  | self_sabotage_pattern             |
| 34   | accountability_graveyard      | Text   | accountability_history            |
| 35   | urgency_mortality             | Voice  | breaking_point_event, war_cry     |
| 36   | emotional_quit_trigger        | Choice | self_sabotage_pattern             |
| 37   | streak_target                 | Text   | (operational tracking)            |
| 38   | sacrifice_list                | Choice | non_negotiable_commitment         |
| 39   | war_cry                       | Voice  | war_cry_or_death_vision           |
| 41   | evening_call_time             | Time   | (operational - users table)       |
| 42   | external_judge                | Text   | relationship_damage_specific      |
| 43   | failure_threshold             | Choice | non_negotiable_commitment         |
| 45   | oath_recording                | Voice  | war_cry_or_death_vision           |

---

## 🎯 Usage in Calls

### Example Intelligence Output for Calls:

```markdown
# 🎯 PSYCHOLOGICAL WEAPONS PROFILE

**User Name**: John

## WHO THEY ARE NOW (Reality Mirror)
"A 28-year-old who wastes 6 hours daily on YouTube instead of building the business he talks about. Smart enough to know better, too weak to act different."
*Use this: Call them out on reality vs promises*

## THE GAP (Cognitive Dissonance Weapon)
"Wants to be disciplined entrepreneur who wakes at 5am and builds empire. Currently wakes at 11am, scrolls TikTok, makes excuses. The gap grows daily."
*Use this: Highlight the painful distance between want and reality*

## 🔪 PRIMARY WEAPONS

### SHAME TRIGGER
"being 30, living in parents basement, watching friends buy houses while I play video games"
*Deploy when: They're making excuses or avoiding the mirror*
*Hit: "Remember what you said disgusts you? Still true today?"*

### FINANCIAL PAIN
"$50K lost this year - could have bought parents a house with the money they sacrificed"
*Deploy when: They say money doesn't matter or they'll start tomorrow*
*Hit: "That's $50K you'll never see again. How much more?"*

[... more weapons ...]
```

---

## 🚀 Implementation Notes

### For Backend Engineers:
1. **Raw responses** live in `onboarding.responses` JSONB - never deleted
2. **Psychological weapons** live in `identity` table columns - AI-extracted
3. AI extraction happens automatically after onboarding completion
4. Existing users can be re-extracted with: `POST /onboarding/extract-data`

### For Frontend Engineers:
1. **No changes needed** to Swift StepDefinitions
2. Continue sending `db_field` names exactly as before
3. Backend handles all synthesis and extraction

### For AI Prompt Engineers:
1. AI prompt lives in `ai-psychological-analyzer.ts` `buildAnalysisPrompt()`
2. Update prompt to improve weapon extraction quality
3. Test with real user data to refine synthesis logic

---

**Version:** V3
**Last Updated:** 2025-01-15
**Status:** Active
