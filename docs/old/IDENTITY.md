# BIG BRUH Identity System - Complete Technical Documentation

**How user identity is created, what creates it, and how it all works in plain English with complete references.**

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [The 45-Step Onboarding Journey](#the-45-step-onboarding-journey)
3. [Identity Creation Flow](#identity-creation-flow)
4. [The Unified Identity Extractor](#the-unified-identity-extractor)
5. [AI Psychological Analyzer](#ai-psychological-analyzer)
6. [Identity Database Schema](#identity-database-schema)
7. [Identity Status System](#identity-status-system)
8. [How Identity is Used](#how-identity-is-used)
9. [Code References](#code-references)

---

## 🎯 Overview

The BIG BRUH identity system transforms raw user responses into a powerful psychological profile that drives personalized accountability. It uses **AI-powered analysis** to extract actionable insights from 45+ onboarding responses, creating an identity that the AI can use to deliver brutal, effective accountability calls.

### Core Philosophy
**"Extract intelligence, not just data"**

Instead of storing raw onboarding responses and letting the AI figure them out during every call, BIG BRUH uses OpenAI to analyze responses ONCE during onboarding and extract 13 clean, actionable identity fields. This makes the AI calls faster, more consistent, and more psychologically effective.

### Key Components

1. **Onboarding Responses** → Raw user data (voice recordings, text, choices)
2. **Unified Identity Extractor** → Orchestrates the extraction process
3. **AI Psychological Analyzer** → Analyzes responses with OpenAI/GitHub Models
4. **Identity Table** → Stores 13 psychological + 2 operational fields
5. **Identity Status** → Tracks performance, trust, streaks
6. **Prompt Engine** → Uses identity to personalize accountability calls

---

## 🚶 The 45-Step Onboarding Journey

Before identity creation happens, users complete a comprehensive 45-step onboarding flow that captures their psychological profile, goals, fears, and behavioral patterns.

### Onboarding Flow Stages

#### Stage 1: Anonymous Onboarding (Steps 1-45)
User completes onboarding **without creating an account**:
- **Voice recordings**: User speaks their goals, fears, struggles (15+ audio responses)
- **Text responses**: Written commitments, daily routines, excuses
- **Choice responses**: Preferences, accountability style, time windows
- **Data storage**: All responses stored temporarily with `sessionId` (no user account yet)

**Key Files**:
- Frontend: Swift iOS app handles 45-step flow
- Response Format: Each step has `type`, `value`, `db_field`, `timestamp`

#### Stage 2: Payment
User pays via RevenueCat before creating account (ensures commitment).

#### Stage 3: Authentication
User signs up via Supabase Auth (Google/Apple Sign-in), creating their account.

#### Stage 4: Data Migration & Processing
This is where the magic happens! 🪄

**Triggered by**: POST `/onboarding/v3/complete`
**Handler**: [onboarding.ts:postOnboardingV3Complete](be/src/routes/onboarding.ts#L76)

The frontend sends all 45 responses to the backend in a single request:

```json
{
  "state": {
    "currentStep": 45,
    "responses": {
      "step_1": {
        "type": "voice",
        "value": "data:audio/m4a;base64,...",
        "db_field": ["identity_name"],
        "timestamp": "2024-01-15T10:30:00Z"
      },
      "step_2": {
        "type": "text",
        "value": "I want to become a disciplined person",
        "db_field": ["aspirated_identity"],
        "timestamp": "2024-01-15T10:31:00Z"
      },
      "step_19": {
        "type": "voice",
        "value": "data:audio/m4a;base64,...",
        "db_field": ["daily_non_negotiable"],
        "timestamp": "2024-01-15T10:45:00Z"
      }
      // ... 42 more steps
    },
    "userName": "John",
    "brotherName": "Executor",
    "userTimezone": "America/New_York"
  }
}
```

---

## 🔄 Identity Creation Flow

Here's the complete step-by-step process of how identity is created:

### Step 1: Receive Onboarding Completion Request

**Location**: [onboarding.ts:76-98](be/src/routes/onboarding.ts#L76)

```typescript
export const postOnboardingV3Complete = async (c: Context) => {
  const userId = getAuthenticatedUserId(c);
  const body = await c.req.json();
  const { state } = body;

  if (!state || !state.responses) {
    return c.json({ error: "Missing onboarding state" }, 400);
  }
```

The backend receives the complete onboarding state with 45+ responses.

### Step 2: Process Files (Audio/Images → Cloud Storage)

**Location**: [onboarding.ts:199-236](be/src/routes/onboarding.ts#L199)
**Function**: `processOnboardingFiles()`
**File**: [onboardingFileProcessor.ts](be/src/utils/onboardingFileProcessor.ts)

The system processes all embedded files:

1. **Detects base64 audio data**: Files like `data:audio/m4a;base64,...`
2. **Converts to binary**: Decodes base64 to ArrayBuffer
3. **Uploads to R2**: Stores in Cloudflare R2 bucket
4. **Replaces URLs**: Updates response values with cloud URLs (`https://pub-xxx.r2.dev/audio/...`)

```typescript
const fileProcessingResult = await processOnboardingFiles(
  env,
  state.responses,
  userId
);
```

**Result**: All voice recordings are now accessible via HTTPS URLs for transcription.

### Step 3: Save Responses to Database

**Location**: [onboarding.ts:284-296](be/src/routes/onboarding.ts#L284)

The processed responses are saved to the `onboarding` table in JSONB format:

```typescript
await supabase.from("onboarding").upsert({
  user_id: userId,
  responses: processedResponses, // JSONB with cloud URLs
  updated_at: new Date().toISOString(),
}, { onConflict: "user_id" });
```

**Database Table**: `onboarding`
- `id`: UUID primary key
- `user_id`: Foreign key to users table
- `responses`: JSONB column containing all 45 responses
- `created_at`: Timestamp
- `updated_at`: Timestamp

### Step 4: Update User Record

**Location**: [onboarding.ts:270-281](be/src/routes/onboarding.ts#L270)

Mark onboarding as completed and extract operational data:

```typescript
await supabase.from("users").update({
  onboarding_completed: true,
  onboarding_completed_at: new Date().toISOString(),
  name: state.userName || "User",
  timezone: state.userTimezone || "UTC",
  call_window_start: callTime, // e.g., "20:30"
  call_window_timezone: state.userTimezone || "UTC",
  updated_at: new Date().toISOString(),
}).eq("id", userId);
```

**Extracted Operational Data**:
- `name`: User's preferred name (from responses)
- `timezone`: User's timezone for call scheduling
- `call_window_start`: When evening calls should start (e.g., "20:30")
- `call_window_timezone`: Timezone for call window

### Step 5: Auto-Trigger Identity Extraction 🧠

**Location**: [onboarding.ts:300-324](be/src/routes/onboarding.ts#L300)

This is where the AI magic happens!

```typescript
// ✨ SIMPLE FIX: Auto-trigger identity extraction after onboarding
let identityExtractionResult = null;
try {
  console.log(`🧠 Starting automatic identity extraction for user ${userId}...`);
  identityExtractionResult = await extractAndSaveIdentityUnified(userId, env);
  console.log(`✅ Identity extraction: ${identityExtractionResult.success ? "SUCCESS" : "FAILED"}`);
} catch (error) {
  console.warn(`⚠️ Identity extraction failed, user can continue without it:`, error);
}
```

**Function**: `extractAndSaveIdentityUnified()`
**File**: [unified-identity-extractor.ts](be/src/services/unified-identity-extractor.ts)

This function orchestrates the entire identity extraction process (detailed below).

### Step 6: Initialize Identity Status

**Location**: [onboarding.ts:326-348](be/src/routes/onboarding.ts#L326)

Initialize performance tracking with AI-generated messages:

```typescript
const { syncIdentityStatus } = await import("@/utils/identity-status-sync");
identityStatusResult = await syncIdentityStatus(userId, env);
```

**Function**: `syncIdentityStatus()`
**File**: [identity-status-sync.ts](be/src/utils/identity-status-sync.ts#L33)

This creates the initial `identity_status` record with:
- `trust_percentage`: 100 (starts at full trust)
- `current_streak_days`: 0 (no streak yet)
- `promises_made_count`: 0
- `promises_broken_count`: 0
- `status_summary`: AI-generated discipline message

### Step 7: Return Success Response

**Location**: [onboarding.ts:350-359](be/src/routes/onboarding.ts#L350)

```typescript
return c.json({
  success: true,
  message: "Onboarding completed successfully",
  completedAt: new Date().toISOString(),
  totalSteps: Object.keys(processedResponses).length,
  filesProcessed: fileProcessingResult.uploadedFiles?.length || 0,
  identityExtraction: identityExtractionResult,
  identityStatusSync: identityStatusResult,
});
```

The frontend receives confirmation that identity extraction succeeded!

---

## 🧬 The Unified Identity Extractor

The **Unified Identity Extractor** is the orchestrator that manages the entire identity extraction process. It's called "unified" because it combines multiple extraction strategies into one cohesive system.

### Main Class: `IntelligentIdentityExtractor`

**File**: [unified-identity-extractor.ts](be/src/services/unified-identity-extractor.ts#L16)

This class handles:
1. Fetching onboarding responses from database
2. Orchestrating AI psychological analysis
3. Extracting operational fields directly
4. Combining AI + operational data
5. Saving to identity table

### Key Methods

#### 1. `extractIdentityData(userId: string)`

**Location**: [unified-identity-extractor.ts:32-78](be/src/services/unified-identity-extractor.ts#L32)

**Purpose**: Main extraction method that coordinates everything.

**Process**:
```typescript
async extractIdentityData(userId: string): Promise<Partial<Identity>> {
  // 📊 Get JSONB onboarding responses from database
  const { data: onboardingRecord, error } = await this.supabase
    .from("onboarding")
    .select("responses")
    .eq("user_id", userId)
    .single();

  if (error || !onboardingRecord) {
    console.error("Error fetching onboarding record:", error);
    return {};
  }

  const responses = onboardingRecord.responses;

  // 🤖 Use AI to analyze responses and extract intelligent insights
  const aiAnalysisResult = await analyzeOnboardingWithAI(responses, this.env);

  if (!aiAnalysisResult.success) {
    console.error("AI analysis failed:", aiAnalysisResult.error);
    return {};
  }

  console.log(`✅ INTELLIGENT extraction completed: ${aiAnalysisResult.fieldsExtracted} intelligent fields extracted`);

  return aiAnalysisResult.identity || {};
}
```

**What it does**:
1. Fetches the JSONB responses from `onboarding` table
2. Sends responses to AI Psychological Analyzer
3. Returns extracted identity fields (13 psychological fields)

#### 2. `extractAndSaveIdentity(userId: string)`

**Location**: [unified-identity-extractor.ts:156-237](be/src/services/unified-identity-extractor.ts#L156)

**Purpose**: Extract identity and save to database.

**Process**:
```typescript
async extractAndSaveIdentity(userId: string): Promise<{
  success: boolean;
  identity?: Partial<Identity>;
  fieldsExtracted?: number;
  aiAnalyzed?: boolean;
  error?: string;
}> {
  // Extract identity using AI
  let identity = await this.extractIdentityData(userId);

  if (Object.keys(identity).length === 0) {
    // Try to extract at least operational fields as fallback
    const operationalFields = await this.extractOperationalFieldsDirectly(userId);
    if (Object.keys(operationalFields).length > 0) {
      identity = operationalFields;
    } else {
      return { success: false, error: "No intelligent identity data could be extracted" };
    }
  }

  // 🏗️ Prepare intelligent identity record for database
  const identityRecord = {
    user_id: userId,
    name: identity.name || "Unknown",
    identity_summary: this.generateIntelligentSummary(identity),
    ...identity, // Spread all AI-extracted intelligent fields
    updated_at: new Date().toISOString(),
  };

  // 💾 Save to identity table using upsert pattern
  const { data: existingRecord } = await this.supabase
    .from("identity")
    .select("id")
    .eq("user_id", userId)
    .maybeSingle();

  if (existingRecord) {
    // Update existing record
    await this.supabase.from("identity").update(identityRecord).eq("user_id", userId);
  } else {
    // Insert new record
    await this.supabase.from("identity").insert(identityRecord);
  }

  return {
    success: true,
    identity,
    fieldsExtracted: Object.keys(identity).length,
    aiAnalyzed: true,
  };
}
```

**What it does**:
1. Calls `extractIdentityData()` to get AI-extracted fields
2. Falls back to operational fields if AI fails
3. Generates identity summary
4. Saves to `identity` table (upsert - update if exists, insert if new)
5. Returns success with metadata

#### 3. `extractOperationalFieldsDirectly(userId: string)`

**Location**: [unified-identity-extractor.ts:86-135](be/src/services/unified-identity-extractor.ts#L86)

**Purpose**: Extract basic operational fields without AI (fallback).

**Operational Fields Extracted**:
1. `name` - Identity name (from step with db_field: "identity_name")
2. `daily_non_negotiable` - Daily commitment (from step with db_field: "daily_non_negotiable")
3. `transformation_target_date` - Target date (from step with db_field: "transformation_date")

**Process**:
```typescript
private async extractOperationalFieldsDirectly(userId: string): Promise<Partial<Identity>> {
  const { data: onboardingRecord } = await this.supabase
    .from("onboarding")
    .select("responses")
    .eq("user_id", userId)
    .single();

  const responses = onboardingRecord.responses;
  const operational: Partial<Identity> = {};

  // Extract name using db_field: "identity_name"
  const nameResponse = this.findResponseByDbField(responses, 'identity_name');
  if (nameResponse?.value) {
    operational.name = String(nameResponse.value);
  }

  // Extract daily_non_negotiable using db_field: "daily_non_negotiable"
  const dailyResponse = this.findResponseByDbField(responses, 'daily_non_negotiable');
  if (dailyResponse?.value) {
    operational.daily_non_negotiable = String(dailyResponse.value);
  }

  // Extract transformation_target_date using db_field: "transformation_date"
  const dateResponse = this.findResponseByDbField(responses, 'transformation_date');
  if (dateResponse?.value) {
    operational.transformation_target_date = String(dateResponse.value);
  }

  return operational;
}
```

**Why these are "operational"**: These fields are needed for system functionality (scheduling, naming) and don't require AI analysis - they're straightforward data mappings.

#### 4. `findResponseByDbField(responses, dbField)`

**Location**: [unified-identity-extractor.ts:140-148](be/src/services/unified-identity-extractor.ts#L140)

**Purpose**: Find a response by its database field name.

Each onboarding response has a `db_field` property that indicates what database field it maps to. This function searches through all responses to find the one with the matching `db_field`.

```typescript
private findResponseByDbField(responses: Record<string, any>, dbField: string): any {
  for (const [, responseData] of Object.entries(responses)) {
    const stepResponse = responseData as any;
    if (stepResponse.db_field && stepResponse.db_field.includes(dbField)) {
      return stepResponse;
    }
  }
  return null;
}
```

---

## 🤖 AI Psychological Analyzer

The **AI Psychological Analyzer** is the brain of the identity system. It uses OpenAI/GitHub Models to analyze raw onboarding responses and extract 13 psychological fields.

### Main Class: `AIPsychologicalAnalyzer`

**File**: [ai-psychological-analyzer.ts](be/src/services/ai-psychological-analyzer.ts#L22)

This class handles:
1. Voice transcription (Deepgram API)
2. Extracting psychological content from responses
3. Generating AI analysis with OpenAI/GitHub Models
4. Parsing AI response into structured identity fields
5. Extracting operational fields directly

### Key Methods

#### 1. `analyzeOnboardingResponses(responses)`

**Location**: [ai-psychological-analyzer.ts:109-157](be/src/services/ai-psychological-analyzer.ts#L109)

**Purpose**: Main analysis method that processes all onboarding responses.

**Process**:
```typescript
async analyzeOnboardingResponses(
  responses: Record<string, any>
): Promise<PsychologicalAnalysisResult> {
  console.log(`🧠 AI ANALYZER: Processing ${Object.keys(responses).length} onboarding responses`);

  // 📊 Extract relevant psychological content from responses (includes transcription)
  const psychologicalContent = await this.extractPsychologicalContent(responses);

  if (Object.keys(psychologicalContent).length === 0) {
    return { success: false, error: "No psychological content found in responses" };
  }

  // 🤖 Generate AI analysis using OpenAI
  const aiAnalysis = await this.generateAIAnalysis(psychologicalContent);

  // 🏗️ Extract operational fields directly from responses
  const operationalFields = this.extractOperationalFields(responses);

  // 🎯 Combine AI analysis with operational data
  const intelligentIdentity = {
    ...operationalFields,
    ...aiAnalysis
  };

  console.log(`✅ AI ANALYZER: Extracted ${Object.keys(intelligentIdentity).length} intelligent fields`);

  return {
    success: true,
    identity: intelligentIdentity,
    fieldsExtracted: Object.keys(intelligentIdentity).length
  };
}
```

**What it does**:
1. Extracts psychological content (transcribes voice, gets text/choices)
2. Sends content to AI for analysis
3. Extracts operational fields directly
4. Combines AI + operational fields
5. Returns complete identity

#### 2. `extractPsychologicalContent(responses)`

**Location**: [ai-psychological-analyzer.ts:165-206](be/src/services/ai-psychological-analyzer.ts#L165)

**Purpose**: Extract and prepare content for AI analysis (including voice transcription).

**Process**:
```typescript
private async extractPsychologicalContent(responses: Record<string, any>): Promise<Record<string, any>> {
  const content: Record<string, any> = {};

  // 🔄 Extract responses using db_field values
  for (const [stepId, responseData] of Object.entries(responses)) {
    const response = responseData as any;

    // Use db_field if available
    const fieldName = response.db_field && response.db_field[0]
      ? response.db_field[0]
      : `step_${stepId}`;

    // Handle VOICE responses
    if (response.type === 'voice' && response.value && typeof response.value === 'string') {
      if (response.value.startsWith('https://')) {
        // Voice URL - needs transcription via Deepgram
        console.log(`🎤 AI ANALYZER: Transcribing voice URL for ${fieldName}...`);
        const transcript = await this.transcribeVoiceUrl(response.value);
        if (transcript.trim()) {
          content[fieldName] = transcript;
        }
      } else if (response.value.trim().length > 0) {
        // Already transcribed text
        content[fieldName] = response.value;
      }
    }

    // Handle TEXT and CHOICE responses
    if ((response.type === 'text' || response.type === 'choice') && response.value) {
      content[fieldName] = String(response.value);
    }
  }

  console.log(`🧠 AI ANALYZER: Extracted ${Object.keys(content).length} content fields`);
  return content;
}
```

**What it does**:
1. Loops through all onboarding responses
2. For **voice responses**: Transcribes audio via Deepgram API
3. For **text/choice responses**: Extracts text directly
4. Uses `db_field` to name each field properly
5. Returns dictionary of psychological content ready for AI

**Voice Transcription Process**:
```typescript
private async transcribeVoiceUrl(audioUrl: string): Promise<string> {
  // Download audio from R2
  const audioResponse = await fetch(audioUrl);
  const audioBuffer = await audioResponse.arrayBuffer();

  // Transcribe with Deepgram
  const response = await fetch(
    "https://api.deepgram.com/v1/listen?model=nova-2&smart_format=true&punctuate=true",
    {
      method: "POST",
      headers: {
        Authorization: `Token ${this.env.DEEPGRAM_API_KEY}`,
        "Content-Type": "audio/wav",
      },
      body: audioBuffer,
    }
  );

  const result = await response.json();
  return result.results?.channels?.[0]?.alternatives?.[0]?.transcript || "";
}
```

#### 3. `generateAIAnalysis(content)`

**Location**: [ai-psychological-analyzer.ts:242-325](be/src/services/ai-psychological-analyzer.ts#L242)

**Purpose**: Send psychological content to AI and get structured analysis.

**Process**:
```typescript
private async generateAIAnalysis(content: Record<string, any>): Promise<Partial<Identity>> {
  const prompt = this.buildAnalysisPrompt(content);

  // GitHub Models API (OpenAI GPT-4o-mini)
  const response = await this.openai.chat.completions.create({
    model: "openai/gpt-4o-mini",
    messages: [
      {
        role: "system",
        content: "You are a psychological analyst extracting actionable insights from accountability app onboarding responses."
      },
      {
        role: "user",
        content: prompt
      }
    ],
    temperature: 0.1,
    max_tokens: 1500
  });

  const analysisText = response.choices[0]?.message?.content;

  // 🔧 Parse structured analysis from AI response
  return this.parseAIAnalysis(analysisText);
}
```

**What it does**:
1. Builds prompt with all psychological content
2. Calls GitHub Models (OpenAI GPT-4o-mini) via OpenAI SDK
3. Uses low temperature (0.1) for consistent, factual extraction
4. Parses JSON response into identity fields
5. Returns 13 psychological fields

**Note**: Uses GitHub Models instead of direct OpenAI API (same models, different endpoint).

#### 4. `buildAnalysisPrompt(content)`

**Location**: [ai-psychological-analyzer.ts:333-362](be/src/services/ai-psychological-analyzer.ts#L333)

**Purpose**: Create structured prompt for AI analysis.

**Prompt Structure**:
```typescript
private buildAnalysisPrompt(content: Record<string, any>): string {
  let prompt = `Analyze these psychological responses from an accountability app user and extract specific insights:\n\n`;

  // Add all content
  Object.entries(content).forEach(([field, value]) => {
    prompt += `${field}: "${value}"\n`;
  });

  prompt += `\nExtract these specific insights in JSON format:

{
  "current_identity": "Who they are now (2-3 sentences)",
  "aspirated_identity": "Who they want to become (2-3 sentences)",
  "fear_identity": "Who they fear becoming (2-3 sentences)",
  "core_struggle": "Their main struggle (1-2 sentences)",
  "biggest_enemy": "What defeats them (1-2 sentences)",
  "primary_excuse": "Their go-to excuse (1 sentence)",
  "sabotage_method": "How they sabotage themselves (1-2 sentences)",
  "weakness_time_window": "When they typically break (time/situation)",
  "procrastination_focus": "What they're avoiding right now (specific)",
  "last_major_failure": "Recent failure summary (1-2 sentences)",
  "past_success_story": "Success they achieved (1-2 sentences)",
  "accountability_trigger": "What makes them move (shame/confrontation/competition/financial)",
  "war_cry": "Their motivational phrase (extract or create from their energy)"
}

Be direct, specific, and actionable. Use their exact words when possible.`;

  return prompt;
}
```

**What it does**:
1. Lists all psychological content (transcripts, text responses)
2. Asks AI to extract 13 specific fields
3. Provides clear format and length guidelines
4. Instructs AI to use user's exact words when possible

**Example Prompt** (simplified):
```
Analyze these psychological responses:

identity_name: "I want to be called Mike"
aspirated_identity: "I spoke about wanting to become a disciplined person who wakes up early"
fear_identity: "I said I'm terrified of becoming like my lazy uncle who gave up on life"
core_struggle: "I struggle with consistency, I start strong but quit after a few days"
biggest_enemy: "My phone, I waste hours scrolling at night"
primary_excuse: "I always say I'm too tired or I'll start tomorrow"

Extract these specific insights in JSON format:
{
  "current_identity": "Who they are now (2-3 sentences)",
  "aspirated_identity": "Who they want to become (2-3 sentences)",
  ...
}
```

#### 5. `parseAIAnalysis(analysisText)`

**Location**: [ai-psychological-analyzer.ts:370-403](be/src/services/ai-psychological-analyzer.ts#L370)

**Purpose**: Parse AI's JSON response into identity fields.

**Process**:
```typescript
private parseAIAnalysis(analysisText: string): Partial<Identity> {
  try {
    // Try to extract JSON from the response
    const jsonMatch = analysisText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      console.warn("⚠️ No JSON found in AI analysis response");
      return {};
    }

    const parsed = JSON.parse(jsonMatch[0]);

    // 🧹 Clean and validate extracted fields
    const cleanedAnalysis: Partial<Identity> = {};

    const expectedFields = [
      'current_identity', 'aspirated_identity', 'fear_identity', 'core_struggle',
      'biggest_enemy', 'primary_excuse', 'sabotage_method', 'weakness_time_window',
      'procrastination_focus', 'last_major_failure', 'past_success_story',
      'accountability_trigger', 'war_cry'
    ];

    expectedFields.forEach(field => {
      if (parsed[field] && typeof parsed[field] === 'string' && parsed[field].trim()) {
        (cleanedAnalysis as any)[field] = parsed[field].trim();
      }
    });

    return cleanedAnalysis;
  } catch (error) {
    console.error("💥 Failed to parse AI analysis:", error);
    return {};
  }
}
```

**What it does**:
1. Extracts JSON from AI response (handles markdown code blocks)
2. Validates that response is valid JSON
3. Filters to only expected fields (13 psychological fields)
4. Cleans each field (trims whitespace, validates non-empty)
5. Returns clean identity object

#### 6. `extractOperationalFields(responses)`

**Location**: [ai-psychological-analyzer.ts:411-447](be/src/services/ai-psychological-analyzer.ts#L411)

**Purpose**: Extract operational fields directly (no AI needed).

Same as `extractOperationalFieldsDirectly` in the Unified Extractor - extracts:
- `name`
- `daily_non_negotiable`
- `transformation_target_date`

---

## 📊 Identity Database Schema

The identity system uses two main database tables:

### 1. `identity` Table

**Purpose**: Stores complete psychological profile and identity data.

**Schema**:
```sql
CREATE TABLE identity (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  identity_summary TEXT NOT NULL,

  -- OPERATIONAL FIELDS (2 fields)
  daily_non_negotiable TEXT,
  transformation_target_date TEXT,

  -- IDENTITY FIELDS (7 fields)
  current_identity TEXT,
  aspirated_identity TEXT,
  fear_identity TEXT,
  core_struggle TEXT,
  biggest_enemy TEXT,
  primary_excuse TEXT,
  sabotage_method TEXT,

  -- BEHAVIORAL FIELDS (6 fields)
  weakness_time_window TEXT,
  procrastination_focus TEXT,
  last_major_failure TEXT,
  past_success_story TEXT,
  accountability_trigger TEXT,
  war_cry TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Total Fields**: 15 (13 psychological + 2 operational)

**Type Definition**: [database.ts:48-77](be/src/types/database.ts#L48)

```typescript
export interface Identity {
  id: string;
  user_id: string;
  name: string;
  identity_summary: string;

  // OPERATIONAL FIELDS (2 essential system fields)
  daily_non_negotiable?: string;
  transformation_target_date?: string;

  // IDENTITY FIELDS (7 core psychological profile fields)
  current_identity?: string;
  aspirated_identity?: string;
  fear_identity?: string;
  core_struggle?: string;
  biggest_enemy?: string;
  primary_excuse?: string;
  sabotage_method?: string;

  // BEHAVIORAL FIELDS (6 action pattern fields)
  weakness_time_window?: string;
  procrastination_focus?: string;
  last_major_failure?: string;
  past_success_story?: string;
  accountability_trigger?: string;
  war_cry?: string;

  created_at: string;
  updated_at: string;
}
```

### 2. `identity_status` Table

**Purpose**: Tracks performance metrics and AI-generated status messages.

**Schema**:
```sql
CREATE TABLE identity_status (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  trust_percentage INTEGER DEFAULT 100,
  next_call_timestamp BIGINT,
  promises_made_count INTEGER DEFAULT 0,
  promises_broken_count INTEGER DEFAULT 0,
  current_streak_days INTEGER DEFAULT 0,
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  status_summary JSONB
);
```

**Type Definition**: [database.ts:80-91](be/src/types/database.ts#L80)

```typescript
export interface IdentityStatus {
  id: string;
  user_id: string;
  trust_percentage?: number;
  next_call_timestamp?: string;
  promises_made_count?: number;
  promises_broken_count?: number;
  current_streak_days?: number;
  last_updated?: string;
  status_summary?: IdentityStatusSummary;
}

export interface IdentityStatusSummary {
  disciplineLevel: "CRISIS" | "GROWTH" | "STUCK" | "STABLE" | "UNKNOWN";
  disciplineMessage: string;
  notificationTitle: string;
  notificationMessage: string;
  generatedAt: string;
}
```

### 3. `onboarding` Table

**Purpose**: Stores raw onboarding responses in JSONB format.

**Schema**:
```sql
CREATE TABLE onboarding (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  responses JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Type Definition**: [database.ts:102-108](be/src/types/database.ts#L102)

```typescript
export interface Onboarding {
  id: string;
  user_id?: string;
  responses: Record<string, any>; // JSONB
  created_at: string;
  updated_at: string;
}
```

---

## 🔄 Identity Status System

The identity status system tracks user performance and generates AI-powered discipline messages.

### Status Sync Process

**Function**: `syncIdentityStatus(userId, env)`
**File**: [identity-status-sync.ts:33-139](be/src/utils/identity-status-sync.ts#L33)

**Process**:
```typescript
export async function syncIdentityStatus(userId: string, env: Env) {
  // Fetch all promises for this user
  const { data: allPromises } = await supabase
    .from("promises")
    .select("*")
    .eq("user_id", userId)
    .order("promise_date", { ascending: false });

  // Calculate metrics
  const promisesMade = allPromises.filter(p => p.status === "kept" || p.status === "broken").length;
  const promisesBroken = allPromises.filter(p => p.status === "broken").length;
  const currentStreak = calculateStreak(allPromises);

  // Trust calculation based on last 7 days
  const sevenDaysAgo = format(subDays(new Date(), 7), "yyyy-MM-dd");
  const recentPromises = allPromises.filter(p => p.promise_date >= sevenDaysAgo);
  const recentBroken = recentPromises.filter(p => p.status === "broken").length;
  const trustPercentage = Math.max(0, 100 - recentBroken * 10);

  // Generate AI-powered status summary
  const statusSummary = await generateStatusSummary({
    userId, env, supabase, metrics, allPromises
  });

  // Upsert to identity_status table
  await supabase.from("identity_status").upsert({
    user_id: userId,
    promises_made_count: promisesMade,
    promises_broken_count: promisesBroken,
    current_streak_days: currentStreak,
    trust_percentage: trustPercentage,
    status_summary: statusSummary,
    last_updated: new Date().toISOString(),
  }, { onConflict: "user_id" });
}
```

**What it calculates**:
1. **Promises Made**: Total promises with definitive status (kept or broken)
2. **Promises Broken**: Total broken promises
3. **Current Streak**: Consecutive days with all promises kept
4. **Trust Percentage**: 100 - (recent broken * 10), based on last 7 days
5. **Status Summary**: AI-generated discipline message

### Streak Calculation

**Function**: `calculateStreak(promises)`
**Location**: [identity-status-sync.ts:141-177](be/src/utils/identity-status-sync.ts#L141)

**Algorithm**:
```typescript
function calculateStreak(promises: any[]): number {
  // Group promises by date
  const promisesByDate = new Map<string, any[]>();
  for (const promise of promises) {
    const date = promise.promise_date;
    if (!promisesByDate.has(date)) {
      promisesByDate.set(date, []);
    }
    promisesByDate.get(date)!.push(promise);
  }

  // Sort dates descending (most recent first)
  const sortedDates = Array.from(promisesByDate.keys()).sort().reverse();

  let streak = 0;

  // Count consecutive days where ALL promises were kept
  for (const date of sortedDates) {
    const dayPromises = promisesByDate.get(date)!;
    const completedPromises = dayPromises.filter(
      p => p.status === "kept" || p.status === "broken"
    );

    if (completedPromises.length === 0) continue;

    const allKept = completedPromises.every(p => p.status === "kept");

    if (allKept) {
      streak++;
    } else {
      break; // Streak broken
    }
  }

  return streak;
}
```

**Streak Rules**:
- Only counts days where ALL promises were kept
- Breaks immediately on first day with ANY broken promise
- Ignores days with no completed promises

### AI Status Summary Generation

**Function**: `generateStatusSummary(params)`
**Location**: [identity-status-sync.ts:179-308](be/src/utils/identity-status-sync.ts#L179)

**Process**:
```typescript
async function generateStatusSummary(params: GenerateSummaryParams): Promise<IdentityStatusSummary> {
  const { userId, env, metrics } = params;

  // Fetch user context (identity, latest call)
  const userContext = await getUserContext(env, userId);
  const identity = userContext.identity;
  const { data: latestCall } = await supabase
    .from("calls")
    .select("transcript_summary")
    .eq("user_id", userId)
    .order("end_time", { ascending: false })
    .limit(1)
    .maybeSingle();

  const latestCallSummary = latestCall?.transcript_summary || null;

  // Build prompt for OpenAI
  const prompt = `# USER PERFORMANCE SNAPSHOT
Success rate: ${metrics.successRate}%
Trust percentage: ${metrics.trustPercentage}%
Current streak: ${metrics.currentStreak} days
Promises made: ${metrics.promisesMade}
Promises broken: ${metrics.promisesBroken}
Primary excuse: ${identity?.primary_excuse || "unknown"}
Latest evening call summary: ${latestCallSummary || "No call summary yet."}

Identity data:
- Daily non-negotiable: ${identity?.daily_non_negotiable || "unknown"}
- Fear identity: ${identity?.fear_identity || "unknown"}
- Core struggle: ${identity?.core_struggle || "unknown"}

You are BigBruh. Classify their discipline state and craft a brutal but motivating notification.
Return JSON with keys: disciplineLevel (CRISIS|GROWTH|STUCK|STABLE|UNKNOWN), disciplineMessage, notificationTitle, notificationMessage.`;

  // Call OpenAI
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${env.OPENAI_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      temperature: 0.6,
      max_tokens: 400,
      response_format: { type: "json_object" },
      messages: [
        {
          role: "system",
          content: "You are BigBruh, an intense accountability enforcer. Output STRICT JSON."
        },
        { role: "user", content: prompt }
      ],
    }),
  });

  const result = await response.json();
  const content = result?.choices?.[0]?.message?.content;
  const parsed = JSON.parse(content);

  return {
    disciplineLevel: normalizeDisciplineLevel(parsed.disciplineLevel),
    disciplineMessage: parsed.disciplineMessage,
    notificationTitle: parsed.notificationTitle,
    notificationMessage: parsed.notificationMessage,
    generatedAt: new Date().toISOString(),
  };
}
```

**What it generates**:
```typescript
{
  disciplineLevel: "CRISIS" | "GROWTH" | "STUCK" | "STABLE" | "UNKNOWN",
  disciplineMessage: "Brutal but motivating message about current state",
  notificationTitle: "Short notification title",
  notificationMessage: "Brief notification message",
  generatedAt: "2024-01-15T10:30:00Z"
}
```

**Example Output**:
```json
{
  "disciplineLevel": "CRISIS",
  "disciplineMessage": "You're sliding hard, Mike. Every excuse (I'm too tired) puts you deeper in the pit. Decide if you're done being weak.",
  "notificationTitle": "EMERGENCY INTERVENTION",
  "notificationMessage": "Your excuses are stacking (5 broken). Stop pretending tomorrow saves you.",
  "generatedAt": "2024-01-15T10:30:00Z"
}
```

---

## 🎯 How Identity is Used

The extracted identity is used throughout the app to personalize accountability:

### 1. Call Prompt Generation

**Function**: Prompt Engine
**File**: [prompt-engine/](be/src/services/prompt-engine/)

The prompt engine uses identity fields to create personalized AI call instructions:

```typescript
// Fetches identity
const userContext = await getUserContext(env, userId);
const identity = userContext.identity;

// Uses identity to personalize prompt
const prompt = `
You are speaking to ${identity.name}.

THEIR PSYCHOLOGICAL PROFILE:
- Current Identity: ${identity.current_identity}
- Who They Want to Become: ${identity.aspirated_identity}
- Who They Fear Becoming: ${identity.fear_identity}
- Core Struggle: ${identity.core_struggle}
- Biggest Enemy: ${identity.biggest_enemy}
- Primary Excuse: ${identity.primary_excuse}

BEHAVIORAL PATTERNS:
- Weakness Window: ${identity.weakness_time_window}
- Sabotage Method: ${identity.sabotage_method}
- Accountability Trigger: ${identity.accountability_trigger}

Use this knowledge to deliver brutal, personalized accountability.
`;
```

**Result**: AI calls are deeply personalized based on user's psychological profile.

### 2. Brutal Reality Reviews

**File**: [brutal-reality-engine.ts](be/src/services/brutal-reality-engine.ts)

Uses identity to generate daily performance reviews:

```typescript
const identity = await getUserIdentity(userId);

const brutalReview = `
${identity.name}, your ${identity.primary_excuse} excuse doesn't fly anymore.
Your biggest enemy (${identity.biggest_enemy}) is winning.
Remember what you said? "${identity.war_cry}"
Time to prove it or admit you're becoming ${identity.fear_identity}.
`;
```

### 3. Push Notifications

**File**: [identity-status-sync.ts](be/src/utils/identity-status-sync.ts)

Status summary messages are used for push notifications:

```typescript
const statusSummary = identityStatus.status_summary;

sendPushNotification({
  title: statusSummary.notificationTitle,
  message: statusSummary.notificationMessage,
  userId: userId
});
```

### 4. Tool Functions (AI Intelligence)

**Files**: [tool-handlers/](be/src/routes/tool-handlers/)

During calls, AI uses tool functions to access identity:

```typescript
// getUserContext tool
const context = await getUserContext(env, userId);
return {
  identity: context.identity,
  recentPromises: context.promises,
  excuseHistory: context.excuses,
  // ... more context
};
```

**AI can then reference**: "Remember, you said your biggest enemy is your phone..."

---

## 📚 Code References

### Main Files

| File | Purpose | Key Functions |
|------|---------|---------------|
| [onboarding.ts](be/src/routes/onboarding.ts) | Onboarding completion endpoint | `postOnboardingV3Complete()`, `postExtractOnboardingData()` |
| [unified-identity-extractor.ts](be/src/services/unified-identity-extractor.ts) | Orchestrates identity extraction | `extractAndSaveIdentity()`, `extractIdentityData()` |
| [ai-psychological-analyzer.ts](be/src/services/ai-psychological-analyzer.ts) | AI-powered analysis | `analyzeOnboardingResponses()`, `generateAIAnalysis()` |
| [identity-status-sync.ts](be/src/utils/identity-status-sync.ts) | Status tracking and AI messages | `syncIdentityStatus()`, `generateStatusSummary()` |
| [identity.ts](be/src/routes/identity.ts) | Identity API routes | `getCurrentIdentity()`, `updateIdentity()`, `getIdentityStats()` |
| [database.ts](be/src/types/database.ts) | Type definitions | `Identity`, `IdentityStatus`, `Onboarding` |
| [onboardingFileProcessor.ts](be/src/utils/onboardingFileProcessor.ts) | File upload to R2 | `processOnboardingFiles()` |

### Key Functions Call Tree

```
POST /onboarding/v3/complete
├── processOnboardingFiles() - Upload audio/images to R2
├── supabase.from("onboarding").upsert() - Save responses
├── supabase.from("users").update() - Mark onboarding complete
├── extractAndSaveIdentityUnified()
│   └── IntelligentIdentityExtractor.extractAndSaveIdentity()
│       ├── extractIdentityData()
│       │   └── analyzeOnboardingWithAI()
│       │       └── AIPsychologicalAnalyzer.analyzeOnboardingResponses()
│       │           ├── extractPsychologicalContent()
│       │           │   └── transcribeVoiceUrl() - Deepgram API
│       │           ├── generateAIAnalysis()
│       │           │   ├── buildAnalysisPrompt()
│       │           │   ├── OpenAI API call (GitHub Models)
│       │           │   └── parseAIAnalysis()
│       │           └── extractOperationalFields()
│       ├── generateIntelligentSummary()
│       └── supabase.from("identity").upsert() - Save identity
└── syncIdentityStatus()
    ├── calculateStreak()
    ├── generateStatusSummary()
    │   └── OpenAI API call (gpt-4o-mini)
    └── supabase.from("identity_status").upsert() - Save status
```

### Database Tables

```
users
├── id (FK to other tables)
├── onboarding_completed
├── name (extracted from onboarding)
├── timezone (extracted from onboarding)
└── call_window_start (extracted from onboarding)

onboarding
├── id
├── user_id (FK to users)
└── responses (JSONB - raw 45 responses)

identity
├── id
├── user_id (FK to users)
├── name (extracted)
├── identity_summary (generated)
├── [13 psychological fields] (AI-extracted)
└── [2 operational fields] (direct extraction)

identity_status
├── id
├── user_id (FK to users)
├── trust_percentage (calculated)
├── current_streak_days (calculated)
├── promises_made_count (calculated)
├── promises_broken_count (calculated)
└── status_summary (AI-generated)

promises
├── id
├── user_id (FK to users)
├── promise_text
├── status (kept/broken)
└── promise_date

calls
├── id
├── user_id (FK to users)
├── call_type
├── transcript_summary
└── end_time
```

---

## 🔍 Summary

### The Complete Identity Flow

1. **User Completes Onboarding** (45 steps)
   - Voice recordings, text responses, choices
   - Stored temporarily, then sent to backend after payment + signup

2. **Backend Receives Data** (`POST /onboarding/v3/complete`)
   - Processes files (audio/images → R2 cloud)
   - Saves to `onboarding` table (JSONB)
   - Updates `users` table (name, timezone, call window)

3. **Identity Extraction Triggered**
   - **Unified Identity Extractor** orchestrates the process
   - **AI Psychological Analyzer** analyzes responses
   - **Deepgram** transcribes voice recordings
   - **GitHub Models (GPT-4o-mini)** extracts 13 psychological fields
   - Operational fields extracted directly (name, daily_non_negotiable, date)

4. **Identity Saved to Database**
   - 15 total fields saved to `identity` table
   - Identity summary generated
   - Upsert pattern (update if exists, insert if new)

5. **Identity Status Initialized**
   - Performance metrics calculated
   - **OpenAI (GPT-4o-mini)** generates discipline message
   - Saved to `identity_status` table

6. **Identity Ready for Use**
   - Prompt engine creates personalized AI call instructions
   - Brutal reality engine generates daily reviews
   - Status messages used for push notifications
   - Tool functions provide intelligence to AI during calls

### Key Technologies

- **Hono** - Web framework (Cloudflare Workers)
- **Supabase** - PostgreSQL database + Auth
- **Cloudflare R2** - Object storage (audio/images)
- **Deepgram Nova-2** - Voice transcription
- **GitHub Models (GPT-4o-mini)** - Identity extraction
- **OpenAI GPT-4o-mini** - Status messages
- **11labs** - Conversational AI + voice cloning

### Why This Architecture?

**Problem**: Sending 45 raw responses to AI during every call is slow, expensive, and inconsistent.

**Solution**: Extract identity ONCE during onboarding using AI, store clean actionable fields, use them throughout the app.

**Benefits**:
- ⚡ **Faster calls**: Pre-extracted identity = instant personalization
- 💰 **Lower costs**: One-time AI analysis vs. repeated analysis
- 🎯 **More consistent**: Same identity interpretation across all calls
- 🧹 **Cleaner data**: 15 structured fields vs. 45 raw responses
- 🤖 **Better AI**: Concise identity = more focused, effective AI

---

*Last updated: 2025-01-11*
