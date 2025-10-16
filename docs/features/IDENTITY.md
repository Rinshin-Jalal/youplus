# Identity System Feature

**Complete guide to how user identity works in BIG BRUH - from creation to usage.**

---

## 🎯 What is Identity?

Identity is the **psychological profile** of the user - a collection of 15 AI-extracted fields that describe who they are, who they want to become, and what holds them back. It's the foundation that makes every accountability call deeply personal and effective.

Think of it as the AI's understanding of the user's psychology, packaged into clean, actionable data points.

---

## 📊 Database: `identity` Table

**Fields stored**:
- 2 operational fields (name, target date)
- 7 identity fields (current self, desired self, feared self, struggles, enemy, excuse, sabotage)
- 6 behavioral fields (weakness window, procrastination focus, failures, successes, triggers, war cry)

**References**:
- Schema definition: [be/src/types/database.ts:48-77](../be/src/types/database.ts#L48)
- Detailed breakdown: [DATABASE.md - Table 2](../DATABASE.md#table-2-identity)

---

## 🏗️ How Identity is Created

### Frontend (iOS): Onboarding Collection

**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Onboarding/](../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Onboarding/)

**What happens**:
1. User goes through 45 onboarding steps
2. 15+ voice recordings captured (goals, fears, struggles)
3. Text responses collected (daily habits, target dates)
4. Choice selections (accountability style, enforcement tone)
5. All responses stored locally as user progresses
6. After payment + authentication, ALL 45 responses sent to backend in single request

**Why voice recordings**:
- Captures emotional tone and energy
- More authentic than typed responses
- Used for voice cloning AND psychological analysis
- AI can extract personality from voice patterns

**Key steps that feed identity**:
- **Step 3**: Identity name (who they want to be called)
- **Step 5-7**: Current situation, desired outcome, nightmare scenario
- **Step 8-10**: Past failures, enemy identification, procrastination patterns
- **Step 12-15**: Daily habits, struggles, success stories
- **Step 19**: Daily non-negotiable commitment
- **Step 30**: Transformation target date

### Backend: AI-Powered Extraction

**Endpoint**: `POST /onboarding/v3/complete`
**Handler**: [be/src/routes/onboarding.ts:76-371](../be/src/routes/onboarding.ts#L76)

**Step-by-step process**:

#### Step 1: Receive & Process Files
- Backend receives 45 responses in JSONB format
- Voice recordings come as base64 data URLs
- Audio files uploaded to Cloudflare R2 cloud storage
- Response values updated with cloud URLs

**Service**: [be/src/utils/onboardingFileProcessor.ts](../be/src/utils/onboardingFileProcessor.ts)

#### Step 2: Auto-Trigger Extraction
- System automatically calls `extractAndSaveIdentityUnified()`
- Happens immediately after onboarding completion
- User doesn't need to wait or trigger manually

**Orchestrator**: [be/src/services/unified-identity-extractor.ts](../be/src/services/unified-identity-extractor.ts)

#### Step 3: Voice Transcription
- All voice recording URLs fetched from R2
- Audio sent to Deepgram API (Nova-2 model)
- Transcripts returned with smart formatting and punctuation
- Failed transcriptions logged but don't block extraction

**Service**: [be/src/services/ai-psychological-analyzer.ts:40-98](../be/src/services/ai-psychological-analyzer.ts#L40)

#### Step 4: Content Extraction
- System loops through all 45 responses
- Voice responses: Uses transcribed text
- Text responses: Uses raw text
- Choice responses: Uses selected option
- All content organized by `db_field` name

#### Step 5: AI Analysis
- All psychological content sent to GitHub Models (GPT-4o-mini)
- Prompt asks AI to extract 13 specific psychological fields
- AI analyzes patterns, extracts core insights
- Response returned as structured JSON

**Prompt includes**:
```
"Analyze these responses and extract:
- current_identity: Who they are now (2-3 sentences)
- aspirated_identity: Who they want to become
- fear_identity: Who they fear becoming
- core_struggle: Their main struggle
- biggest_enemy: What defeats them
- primary_excuse: Go-to excuse for giving up
- sabotage_method: How they ruin success
- weakness_time_window: When they break
- procrastination_focus: What they're avoiding
- last_major_failure: Recent complete failure
- past_success_story: Time they succeeded
- accountability_trigger: What makes them move
- war_cry: Their motivational phrase"
```

**Service**: [be/src/services/ai-psychological-analyzer.ts:242-325](../be/src/services/ai-psychological-analyzer.ts#L242)

#### Step 6: Direct Field Extraction
- 2 operational fields extracted directly (no AI needed)
- `name`: From response with db_field="identity_name"
- `daily_non_negotiable`: From response with db_field="daily_non_negotiable"

#### Step 7: Combine & Save
- AI-extracted fields (13) + direct fields (2) = 15 total
- Identity summary auto-generated from key fields
- Record saved/updated in `identity` table using upsert
- Success confirmed back to frontend

**Result**: User's identity is ready for use in calls within seconds of completing onboarding.

---

## 🎯 Where Identity is Used

### Backend Usage

#### 1. **Call Prompt Generation**
**Location**: [be/src/services/prompt-engine/](../be/src/services/prompt-engine/)

When 11labs AI requests call configuration, the prompt engine:
- Fetches complete identity from database
- Injects identity fields into system prompt
- AI uses this to personalize every interaction

**Example prompt injection**:
```
"You're speaking to Mike.
IDENTITY: Currently struggling with consistency, wants to become disciplined.
FEARS: Becoming like his lazy uncle who gave up.
ENEMY: His phone - wastes hours scrolling.
PRIMARY EXCUSE: 'I'm too tired' - he uses this constantly.
WEAKNESS: Late nights after 10pm, loses all discipline.
WAR CRY: 'I'm not my father, I make different choices.'"
```

**Why it matters**: AI can reference specific fears, enemies, excuses during conversation. Makes calls feel deeply personal rather than generic.

#### 2. **Tool Functions During Calls**
**Location**: [be/src/routes/tool-handlers/getUserContext.ts](../be/src/routes/tool-handlers/getUserContext.ts)

When AI needs more context during call, it calls `getUserContext` which returns:
- Complete identity profile
- Recent promises
- Call history
- Statistics

AI can then say things like:
- "Remember, you said your biggest enemy is your phone..."
- "You told me your war cry is 'I'm not my father'..."
- "This is your weakness time window, isn't it?"

#### 3. **Brutal Reality Reviews**
**Location**: [be/src/services/brutal-reality-engine.ts](../be/src/services/brutal-reality-engine.ts)

Daily performance reviews reference identity:
- "Mike, your 'too tired' excuse doesn't fly anymore"
- "Your biggest enemy (phone) is winning"
- "Remember your war cry? Prove it."
- "You're becoming exactly who you feared: [fear_identity]"

#### 4. **Identity Status Messages**
**Location**: [be/src/utils/identity-status-sync.ts:179-308](../be/src/utils/identity-status-sync.ts#L179)

When generating discipline messages, system uses:
- `primary_excuse` - "Every excuse (I'm too tired) drags you deeper"
- `fear_identity` - "You're sliding toward [fear_identity]"
- `core_struggle` - "Your struggle with [core_struggle] is winning"

#### 5. **Behavioral Pattern Analysis**
**Location**: [be/src/routes/tool-handlers/analyzeBehavioralPatterns.ts](../be/src/routes/tool-handlers/analyzeBehavioralPatterns.ts)

Pattern detection tools reference:
- `weakness_time_window` - "You always break between 10pm-midnight"
- `sabotage_method` - "You sabotage by [method]"
- `procrastination_focus` - "You're avoiding [specific thing]"

### Frontend (iOS) Usage

#### 1. **Identity Profile Screen**
**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/](../swift-ios-rewrite/bigbruhh/bigbruhh/Features/)

User can:
- View their complete psychological profile
- See all 15 identity fields
- Understand how AI sees them
- Edit fields if insights change

**Displays**:
- Current identity section
- Aspirated identity (goals)
- Fear identity (what to avoid)
- Behavioral patterns
- Operational data (daily commitment, target date)

**Why shown**: Transparency - user should know what AI knows about them.

#### 2. **Pre-Call Preparation**
When user is about to receive accountability call:
- Quick identity reminder shown
- "Remember: You want to become [aspirated_identity]"
- "You're fighting [biggest_enemy]"
- "Your war cry: [war_cry]"

**Purpose**: Psychological prep before intense conversation. Reminds user of their commitments and goals.

#### 3. **Progress Tracking**
Shows how identity is evolving:
- Days since identity creation
- Progress toward transformation_target_date
- Identity updates over time

#### 4. **Settings Integration**
- Display identity name in settings
- Edit daily non-negotiable
- Update transformation target date
- Request identity re-extraction if needed

---

## 🔄 Identity Updates

### When Identity Can Change

1. **Manual Update**: User edits fields via Identity Profile screen
   - Frontend calls `PUT /api/identity/:userId`
   - Only updates specified fields
   - Preserves AI-extracted fields unless explicitly changed

2. **Re-extraction**: User requests fresh AI analysis
   - Admin/debug feature: `POST /onboarding/extract-data`
   - Re-runs AI analysis on original onboarding responses
   - Useful if AI models improve or user wants refresh

3. **Gradual Evolution**: (Future feature)
   - AI could update fields based on call patterns
   - Example: If user consistently breaks promises, update `primary_excuse`
   - Not currently implemented

### What Doesn't Change

- Original onboarding responses (in `onboarding` table)
- Voice recordings (in R2 storage)
- Identity creation timestamp

---

## 🤔 Why This Design?

### Problem Solved

**Before identity extraction**:
- AI would need to read all 45 onboarding responses on every call
- Slow, expensive, inconsistent interpretations
- No way to reference specific psychological insights quickly

**With identity extraction**:
- One-time AI analysis during onboarding
- Clean, structured data ready for instant use
- Consistent psychological understanding across all calls
- Fast prompt generation (milliseconds vs seconds)

### Design Decisions

#### Why 15 Fields?
- Enough detail for deep personalization
- Not too many to overwhelm AI or slow down calls
- Covers identity (who they are), behavior (what they do), and operations (system needs)

#### Why AI Extraction?
- Human-written extraction rules would be rigid and limited
- AI can understand nuance, emotion, context from voice recordings
- Can synthesize across multiple responses to find patterns
- Improves as AI models improve

#### Why Store in Database?
- Fast access during calls (no API delays)
- Enables querying (find users with specific struggles)
- Allows updates without re-analyzing entire onboarding
- Powers analytics and pattern detection

#### Why Voice Recordings?
- Captures emotional authenticity
- Tone reveals more than words
- Used for both identity AND voice cloning
- Makes onboarding feel more human

---

## 🔍 Technical Flow Summary

```
iOS App: User completes 45 steps
  ↓
iOS App: Submit to POST /onboarding/v3/complete
  ↓
Backend: Upload audio files to R2
  ↓
Backend: Save responses to 'onboarding' table
  ↓
Backend: Auto-trigger extractAndSaveIdentityUnified()
  ↓
Backend: Transcribe all voice recordings (Deepgram)
  ↓
Backend: Extract psychological content from responses
  ↓
Backend: Send content to GitHub Models AI
  ↓
AI: Analyze and extract 13 psychological fields
  ↓
Backend: Extract 2 operational fields directly
  ↓
Backend: Combine 15 fields + generate summary
  ↓
Backend: Save to 'identity' table (upsert)
  ↓
Backend: Return success to iOS
  ↓
iOS: Show success, user ready for calls
  ↓
Later: Prompt Engine fetches identity for personalized calls
```

---

## 📁 Key File References

### Backend
- Identity routes: [be/src/routes/identity.ts](../be/src/routes/identity.ts)
- Extraction orchestrator: [be/src/services/unified-identity-extractor.ts](../be/src/services/unified-identity-extractor.ts)
- AI analyzer: [be/src/services/ai-psychological-analyzer.ts](../be/src/services/ai-psychological-analyzer.ts)
- Type definitions: [be/src/types/database.ts:48-77](../be/src/types/database.ts#L48)

### Frontend (iOS)
- Onboarding flow: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Onboarding/](../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Onboarding/)
- Authentication: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/](../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/)

### Related Documentation
- Complete identity technical guide: [IDENTITY.md](../IDENTITY.md)
- Database schema: [DATABASE.md](../DATABASE.md)
- API routes: [ROUTES.md](../ROUTES.md)

---

## 🎓 Common Questions

**Q: Can users see their identity data?**
A: Yes, in the Identity Profile screen. Transparency is important.

**Q: What if AI extraction fails?**
A: System falls back to extracting just 2 operational fields (name, daily commitment). User can still use app, but calls won't be as personalized until re-extraction succeeds.

**Q: Can identity be updated?**
A: Yes, manually via PUT endpoint or by requesting re-extraction. But original onboarding responses are preserved.

**Q: Why not ask users to fill out identity fields directly?**
A: Users don't know how to describe themselves objectively. AI can extract deeper insights from natural conversation and voice recordings than structured forms.

**Q: How long does extraction take?**
A: Usually 10-30 seconds total. Deepgram transcription (5-15s) + AI analysis (5-15s). Fast enough for onboarding flow.

---

*Last updated: 2025-01-11*
