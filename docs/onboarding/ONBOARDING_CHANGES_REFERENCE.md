# BigBruh Onboarding Revision - CHANGE REFERENCE DOCUMENT

## ⚠️ CRITICAL: What's Changing & Why

This document tracks EXACTLY what changes are being made to the 45-step onboarding so all dependent systems can be updated.

---

## 📋 CHANGE SUMMARY

### Steps Being REMOVED/REPLACED: **4 steps**
### Steps Being MODIFIED: **8 steps**
### Steps Being KEPT AS-IS: **33 steps**
### New DB Fields Added: **10 fields**
### DB Fields Removed: **4 fields**

---

## 🔴 STEPS BEING COMPLETELY REPLACED

### Step 16 - REPLACED
**OLD:**
- **Type:** Voice (6s)
- **DB Field:** `morning_failure`
- **Prompt:** "What time did you wake up today? What time did you PLAN to wake up?"
- **Problem:** Administrative, not psychological. Doesn't hit hard.

**NEW:**
- **Type:** Voice (8s)
- **DB Field:** `physical_disgust_trigger`
- **Prompt:** "Look in the MIRROR right now. What do you see that disgusts you?"
- **Why:** Forces physical confrontation. More visceral and shame-inducing.

---

### Step 18 - MODIFIED (Adding New Question)
**INSERTING NEW STEP 18A (becomes new step 19, everything shifts):**
- **Type:** Voice (10s)
- **DB Field:** `daily_time_audit`
- **Prompt:** "Describe YESTERDAY hour by hour. Where did your time actually go?"
- **Why:** Reality check on time waste. Forces accountability for actual behavior.

**Impact:** All steps 19-45 shift by +1 in numbering

---

### Step 22 - REPLACED
**OLD:**
- **Type:** Voice (6s)
- **DB Field:** `sabotage_pattern`
- **Prompt:** "How do you SABOTAGE yourself when things start going well?"
- **Problem:** Overlaps with Step 31 (biggest enemy/pattern)

**NEW:**
- **Type:** Voice (8s)
- **DB Field:** `financial_consequence`
- **Prompt:** "How much MONEY have you NOT MADE because of your excuses this year?"
- **Why:** Adds financial consequence angle. Missing from entire onboarding.

---

### Step 24 - MODIFIED (Adding New Question)
**INSERTING NEW STEP 24A (becomes new step 25, everything shifts):**
- **Type:** Voice (8s)
- **DB Field:** `parental_sacrifice`
- **Prompt:** "What did your PARENTS SACRIFICE for you that you're wasting?"
- **Why:** Guilt leverage. Parental investment angle missing.

**Impact:** All steps 25-45 shift by +1 in numbering

---

### Step 26 (becomes 28 after shifts) - ADDING AFTER
**INSERTING NEW STEP 28A (becomes new step 29):**
- **Type:** Voice (8s)
- **DB Field:** `breaking_point`
- **Prompt:** "What would have to HAPPEN for you to actually change? Not hope. What EVENT?"
- **Why:** Identifies breaking point. Critical for intervention strategy.

**Impact:** All steps 29-45 shift by +1 in numbering

---

### Step 30 (becomes 33 after shifts) - REPLACED
**OLD:**
- **Type:** Text
- **DB Field:** `transformation_date`
- **Prompt:** "By what date will you be UNRECOGNIZABLE?"
- **Problem:** Vague, no urgency, just asks for a date

**NEW:**
- **Type:** Voice (8s)
- **DB Field:** `urgency_mortality`
- **Prompt:** "You have 10 YEARS left to live. What changes TODAY?"
- **Why:** Creates real urgency. Death awareness forces immediate action thinking.

---

### Step 31 (becomes 34 after shifts) - ADDING AFTER
**INSERTING NEW STEP 34A (becomes new step 35):**
- **Type:** Choice
- **DB Field:** `emotional_quit_trigger`
- **Prompt:** "What EMOTION makes you quit?"
- **Options:**
  - Boredom
  - Frustration
  - Fear of success
  - Anxiety
  - Loneliness
  - Anger at myself
- **Why:** Emotional trigger identification. Missing entire emotional angle.

**Impact:** All steps 32-45 shift by +1 in numbering

---

### Step 32 (becomes 36 after shifts) - ADDING AFTER
**INSERTING NEW STEP 36A (becomes new step 37):**
- **Type:** Text
- **DB Field:** `accountability_graveyard`
- **Prompt:** "How many accountability apps/coaches/systems have you ALREADY QUIT?"
- **Why:** Exposes pattern of abandoning help. Critical for BigBruh positioning.

**Impact:** All steps 33-45 shift by +1 in numbering

---

### Step 15 - MODIFIED (Deeper Question)
**OLD:**
- **Type:** Choice
- **DB Field:** `disappointment_check`
- **Prompt:** "Who's most disappointed in you?"
- **Options:** Myself, Parents, Partner, Everyone who believed in me, No one - they gave up

**NEW:**
- **Type:** Voice (8s)
- **DB Field:** `relationship_damage`
- **Prompt:** "Who STOPPED BELIEVING in you? When did you notice they gave up?"
- **Why:** More specific. Captures exact moment of relationship damage.

---

### Step 23 - SHARPENED
**OLD:**
- **Type:** Voice (7s)
- **DB Field:** `excuse_sophistication`
- **Prompt:** "What's your most SOPHISTICATED EXCUSE? The one that sounds legitimate."

**NEW:**
- **Type:** Voice (7s)
- **DB Field:** `intellectual_excuse`
- **Prompt:** "What excuse makes YOU sound smart but is still complete bullshit?"
- **Why:** More confrontational. Forces them to call out their own intellectual dishonesty.

---

## 📊 NEW STEP NUMBERING AFTER ALL SHIFTS

**Original → New Mapping:**

Steps 1-15: **No change**
Step 16: **REPLACED** (morning_failure → physical_disgust_trigger)
Step 17: **No change**
Step 18: **+NEW STEP AFTER** → becomes 19
Steps 19-21: **Shift to 20-22**
Step 22: **REPLACED** (sabotage_pattern → financial_consequence)
Step 23: **MODIFIED** (sharper wording)
Step 24: **+NEW STEP AFTER** → becomes 25
Steps 25-26: **Shift to 26-27**
Step 27: **Shifts to 28**
Step 28: **Shifts to 29**
Step 29: **Shifts to 30, +NEW STEP AFTER** → becomes 31
Step 30: **Shifts to 32, REPLACED** (transformation_date → urgency_mortality)
Step 31: **Shifts to 33, +NEW STEP AFTER** → becomes 34
Step 32: **Shifts to 34, +NEW STEP AFTER** → becomes 35
Steps 33-36: **Shift to 36-39**
Step 37: **Shifts to 40**
Step 38: **Shifts to 41**
Step 39: **Shifts to 42**
Step 40: **Shifts to 43**
Step 41: **Shifts to 44**
Step 42: **Shifts to 45**
Step 43: **Shifts to 46**
Step 44: **Shifts to 47**
Step 45: **Shifts to 48**

**WAIT - WE'RE ADDING 5 NEW STEPS → Total becomes 50 steps**

---

## 🔄 DECISION: Keep at 45 Steps or Expand to 50?

### Option A: Keep 45 Steps (Recommended)
**Action:** Replace 5 weak steps entirely instead of inserting
- Remove Step 20 (commitment time - redundant with Step 37)
- Keep total at 45 steps
- Cleaner, maintains rhythm

### Option B: Expand to 50 Steps
**Action:** Add all new questions
- More comprehensive extraction
- Longer onboarding (may lose users)
- Need to update all "45 steps" references in marketing

**RECOMMENDATION:** Option A - Replace 5 steps to keep 45 total

---

## 📝 FINAL 45-STEP STRUCTURE (Option A)

### Steps Being REMOVED Completely:
1. **Step 16** (morning_failure) → REPLACED with physical_disgust_trigger
2. **Step 20** (commitment_time) → REMOVED (redundant with Step 37)
3. **Step 22** (sabotage_pattern) → REPLACED with financial_consequence
4. **Step 30** (transformation_date) → REPLACED with urgency_mortality

### New Steps Being ADDED:
1. **New Step 18** (daily_time_audit) - Replaces removed Step 20
2. **New Step 24** (parental_sacrifice) - Replaces removed redundancy
3. **New Step 26** (breaking_point) - New psychological angle
4. **New Step 31** (emotional_quit_trigger) - New emotional angle
5. **New Step 32** (accountability_graveyard) - New pattern recognition

---

## 🗄️ DATABASE FIELD CHANGES

### DB Fields REMOVED (4):
1. `morning_failure` (Step 16 old)
2. `commitment_time` (Step 20 old)
3. `sabotage_pattern` (Step 22 old)
4. `transformation_date` (Step 30 old)

### DB Fields ADDED (5):
1. `physical_disgust_trigger` (Step 16 new) - Voice
2. `daily_time_audit` (Step 18 new) - Voice
3. `financial_consequence` (Step 22 new) - Voice
4. `parental_sacrifice` (Step 24 new) - Voice
5. `breaking_point` (Step 26 new) - Voice
6. `urgency_mortality` (Step 30 new) - Voice
7. `emotional_quit_trigger` (Step 31 new) - Choice
8. `accountability_graveyard` (Step 32 new) - Text

### DB Fields MODIFIED (2):
1. `disappointment_check` (Step 15) → `relationship_damage` (type changed Text to Voice)
2. `excuse_sophistication` (Step 23) → `intellectual_excuse` (same type, sharper question)

---

## 🔧 SYSTEMS THAT NEED UPDATES

### 1. **Swift App - StepDefinitions.swift**
**File:** `/Users/rinshin/Code/bigbruh/swift/bigbruhh/Models/Onboarding/StepDefinitions.swift`
- Update all 45 step definitions
- Modify DB field names in step configs
- Update phase assignments if needed

### 2. **Database Schema**
**Files:** Backend database types/migrations
- Remove 4 old DB fields from schema
- Add 8 new DB fields to schema
- Update any queries that reference old field names
- Migration script needed

### 3. **Backend API - Onboarding Processing**
**Files:** 
- `/Users/rinshin/Code/bigbruh/be/src/features/onboarding/`
- Any services that process onboarding data
- Update field validators
- Update data extraction logic

### 4. **AI Prompt Engine**
**Files:**
- `/Users/rinshin/Code/bigbruh/be/src/services/prompt-engine/`
- Update prompt templates that reference old fields
- Add new fields to behavioral analysis
- Update tone engine to use new psychological data

### 5. **Daily Call System**
**Files:**
- Call generation logic
- Confrontation templates
- Update references to use new field names:
  - `physical_disgust_trigger` instead of `morning_failure`
  - `financial_consequence` instead of `sabotage_pattern`
  - `relationship_damage` instead of `disappointment_check`
  - etc.

### 6. **Analytics/Tracking**
- Update any analytics that track onboarding completion
- Update step-specific tracking
- Update field-specific analysis

### 7. **Documentation**
- Update README references to "45 steps"
- Update brand documentation
- Update API documentation
- Update onboarding flow documentation

### 8. **Testing**
- Update test data with new fields
- Update test cases for onboarding validation
- Update integration tests

---

## 📋 IMPLEMENTATION CHECKLIST

### Phase 1: Documentation & Planning
- [x] Create change reference document
- [ ] Create complete new 45-step onboarding markdown
- [ ] Review with team
- [ ] Get approval on DB field changes

### Phase 2: Database
- [ ] Create migration script to rename/remove old fields
- [ ] Add new fields to schema
- [ ] Test migration on staging DB
- [ ] Update database types files

### Phase 3: Backend
- [ ] Update onboarding router/handlers
- [ ] Update validation logic for new fields
- [ ] Update prompt engine to use new fields
- [ ] Update call generation logic
- [ ] Test API endpoints

### Phase 4: Frontend (Swift App)
- [ ] Update StepDefinitions.swift with all changes
- [ ] Update any UI components that reference specific steps
- [ ] Update data models
- [ ] Test onboarding flow end-to-end

### Phase 5: Testing
- [ ] Full onboarding flow test
- [ ] Database field persistence test
- [ ] Daily call generation test with new fields
- [ ] Edge case testing

### Phase 6: Deployment
- [ ] Deploy backend changes
- [ ] Run database migration
- [ ] Deploy app updates
- [ ] Monitor for errors

---

## ⚠️ BREAKING CHANGES WARNING

### User Data Impact:
- **Existing users:** Their old field data remains valid
- **New users:** Will have new field structure
- **Migration needed:** For any logic that expects old fields

### API Breaking Changes:
- Onboarding submission endpoint expects new field names
- Any external integrations querying onboarding data affected

### Backward Compatibility:
**Recommended approach:**
1. Add new fields alongside old fields initially
2. Keep old fields for 1-2 versions for backward compatibility
3. Migrate old data to new fields gradually
4. Deprecate and remove old fields in future version

---

## 🎯 WHY THESE SPECIFIC CHANGES

### Psychological Coverage Gaps Filled:

**OLD GAPS:**
- No financial/career consequence
- No physical self-confrontation  
- No relationship damage depth
- No parental guilt leverage
- No daily reality time audit
- No breaking point identification
- No emotional trigger mapping
- No accountability history pattern

**NEW COVERAGE:**
- ✅ Financial: How much money NOT made
- ✅ Physical: Mirror disgust trigger
- ✅ Relationships: Who stopped believing
- ✅ Family: Parental sacrifice wasted
- ✅ Time: Hour-by-hour reality check
- ✅ Breaking Point: What event would force change
- ✅ Emotional: Which emotion causes quit
- ✅ Pattern: How many systems already abandoned

### Strategic Value:

1. **Better Daily Call Material:** New fields provide more confrontation angles
2. **Deeper Psychological Profile:** More precise user weakness mapping
3. **Reduced Redundancy:** Remove overlapping failure questions
4. **Increased Shame/Guilt Leverage:** Adds family/relationship angles
5. **Financial Stakes:** Money angle missing entirely before
6. **Urgency Creation:** Death awareness creates immediate action
7. **Emotional Intelligence:** Maps specific emotional quit triggers
8. **Pattern Recognition:** Exposes history of abandoning help

---

## 📞 IMPACT ON DAILY CALLS

### Before Changes - Example Call Script:
```
"You said your sabotage pattern is [sabotage_pattern]. 
You woke up at [morning_failure]. 
[disappointment_check] is disappointed in you."
```

### After Changes - Example Call Script:
```
"You've wasted [financial_consequence] this year with excuses.
You looked in the mirror and saw [physical_disgust_trigger].
[relationship_damage] stopped believing in you.
Your parents sacrificed [parental_sacrifice] and you're pissing it away.
When [emotional_quit_trigger] hits, you quit.
This is the [accountability_graveyard]th system you've tried.
You said it would take [breaking_point] to change.
Well? Has it happened yet?"
```

**Impact:** Much more specific, harder-hitting, multi-angle confrontation.

---

## 🚀 NEXT STEPS

1. **Review this change document** with team
2. **Approve the 45-step structure** (Option A recommended)
3. **Create the complete new onboarding markdown** with all changes
4. **Plan database migration** strategy
5. **Estimate implementation timeline** across all systems
6. **Begin Phase 1:** Update documentation and get approval

---

*This reference document should be used by all engineers implementing changes across frontend, backend, database, and AI systems.*
