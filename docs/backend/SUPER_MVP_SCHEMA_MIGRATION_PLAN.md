# 🚨 Super MVP Schema Migration Plan

## Executive Summary

**CRITICAL FINDING**: While TypeScript types were updated to match Super MVP schema, **ALL handler code still references the old bloated schema**. This will cause runtime failures when queries try to SELECT non-existent columns.

**Status**: ~30 handlers need fixes
**Severity**: HIGH - App will crash on these endpoints
**Estimated Fix Time**: 3-4 hours

---

## 📊 Schema Changes (Reminder)

### Before (Bloated Schema - 60+ identity fields)
```typescript
identity: {
  shame_trigger, war_cry, financial_pain_point,
  relationship_damage_specific, breaking_point_event,
  self_sabotage_pattern, accountability_history,
  current_self_summary, aspirational_identity_gap,
  non_negotiable_commitment, war_cry_or_death_vision,
  identity_name, identity_summary, current_struggle,
  nightmare_self, desired_outcome, key_sacrifice,
  final_oath, last_broken_promise, most_common_slip_moment,
  daily_non_negotiable, enforcement_tone, external_judgment,
  regret_if_no_change, meaning_of_breaking_contract,
  ... 35+ more fields
}

identity_status: {
  trust_percentage,
  promises_made_count,
  promises_broken_count,
  next_call_timestamp,
  status_summary,
  ... more fields
}

users: {
  voice_clone_id,
  schedule_change_count,
  voice_reclone_count
}
```

### After (Super MVP - 12 identity columns)
```typescript
identity: {
  // System (4)
  id, user_id, created_at, updated_at,

  // Core (5)
  name, daily_commitment, chosen_path, call_time, strike_limit,

  // Voice URLs (3)
  why_it_matters_audio_url,
  cost_of_quitting_audio_url,
  commitment_audio_url,

  // JSONB context (1)
  onboarding_context: {
    goal, motivation_level, attempt_history,
    favorite_excuse, who_disappointed, quit_pattern,
    future_if_no_change, witness, will_do_this,
    permissions, completed_at, time_spent_minutes,
    ... all other onboarding data
  }
}

identity_status: {
  id, user_id, created_at, updated_at,
  current_streak_days,
  total_calls_completed,
  last_call_at
}

users: {
  // voice_clone_id REMOVED
  // schedule_change_count REMOVED
  // voice_reclone_count REMOVED
}
```

---

## 🔴 Critical Issues Found

### 1. Identity Handlers (`/be/src/features/identity/handlers/identity.ts`)

**Lines 203-234: getCurrentIdentity**
```typescript
// ❌ WRONG - These fields don't exist
name: identity.identity_name,  // Should be: identity.name
summary: identity.identity_summary,  // Doesn't exist
achievements: identity.achievements,  // Doesn't exist
failureReasons: identity.failure_reasons,  // Doesn't exist
singleTruthUserHides: identity.current_struggle,  // Doesn't exist
fearVersionOfSelf: identity.nightmare_self,  // Doesn't exist
desiredOutcome: identity.desired_outcome,  // Doesn't exist
keySacrifice: identity.key_sacrifice,  // Doesn't exist
identityOath: identity.final_oath,  // Doesn't exist
lastBrokenPromise: identity.last_broken_promise,  // Doesn't exist
trustPercentage: identityStatus?.trust_percentage,  // Doesn't exist
promisesMadeCount: identityStatus?.promises_made_count,  // Doesn't exist
promisesBrokenCount: identityStatus?.promises_broken_count,  // Doesn't exist
nextCallTimestamp: nextCallTimestamp,  // Complex calculation - should use call_time
statusSummary: identityStatus?.status_summary,  // Doesn't exist
```

**Lines 283-304: updateIdentity**
```typescript
// ❌ WRONG - Updating non-existent fields
identity_name: identityData.identity_name,  // Should be: name
identity_summary: identityData.identity_summary,  // Doesn't exist
current_struggle: identityData.single_truth_user_hides,  // Doesn't exist
nightmare_self: identityData.fear_version_of_self,  // Doesn't exist
desired_outcome: identityData.desired_outcome,  // Doesn't exist
key_sacrifice: identityData.key_sacrifice,  // Doesn't exist
final_oath: identityData.identity_oath,  // Doesn't exist
last_broken_promise: identityData.last_broken_promise,  // Doesn't exist
most_common_slip_moment: identityData.most_common_slip_moment,  // Doesn't exist
daily_non_negotiable: identityData.daily_non_negotiable,  // Doesn't exist
enforcement_tone: identityData.enforcement_tone,  // Doesn't exist
external_judgment: identityData.external_judgment,  // Doesn't exist
regret_if_no_change: identityData.regret_if_no_change,  // Doesn't exist
```

**Lines 343-372: updateIdentityStatus**
```typescript
// ❌ WRONG - These fields were removed
trust_percentage: trustPercentage,  // Removed
promises_made_count: promisesMadeCount,  // Removed
promises_broken_count: promisesBrokenCount,  // Removed
```

**Lines 474-576: getIdentityStats**
```typescript
// ❌ WRONG - References removed fields
trustPercentage: identityStatus?.trust_percentage  // Removed
```

**Impact**: GET/PUT `/api/identity/:userId` will fail with database errors

---

### 2. Prompt Engine (`/be/src/services/prompt-engine/core/onboarding-intel.ts`)

**Lines 46-139: buildOnboardingIntelligence**
```typescript
// ❌ WRONG - ALL these fields don't exist in Super MVP
i.current_self_summary           // Doesn't exist
i.aspirational_identity_gap      // Doesn't exist
i.shame_trigger                  // Doesn't exist (in JSONB now)
i.financial_pain_point           // Doesn't exist (in JSONB now)
i.relationship_damage_specific   // Doesn't exist (in JSONB now)
i.self_sabotage_pattern          // Doesn't exist (in JSONB now)
i.breaking_point_event           // Doesn't exist (in JSONB now)
i.accountability_history         // Doesn't exist (in JSONB now)
i.non_negotiable_commitment      // Doesn't exist (use daily_commitment)
i.daily_non_negotiable           // Doesn't exist (use daily_commitment)
i.war_cry_or_death_vision        // Doesn't exist (in JSONB now)
i.identity_summary               // Doesn't exist
```

**Impact**: AI call prompt generation will fail or have empty data

---

### 3. Behavioral Intel (`/be/src/services/prompt-engine/core/behavioral-intel.ts`)

**Lines 50-58: generateBehavioralIntelligence**
```typescript
// ❌ WRONG - These fields were removed from identity_status
const trustPercentage = identityStatus?.trust_percentage  // Removed
const promisesMadeCount = identityStatus?.promises_made_count  // Removed
const promisesBrokenCount = identityStatus?.promises_broken_count  // Removed
```

**Impact**: Behavioral analysis will have incorrect/missing data

---

### 4. Identity Extractor (`/be/src/features/identity/services/unified-identity-extractor.ts`)

**Lines 100-124: extractOperationalFieldsDirectly**
```typescript
// ❌ WRONG - These don't match Super MVP
operational.name  // Should read from onboarding_context
operational.daily_non_negotiable  // Should be daily_commitment
operational.transformation_target_date  // Doesn't exist
```

**Lines 240-291: generateIntelligentSummary**
```typescript
// ❌ WRONG - All these fields don't exist
identity.current_self_summary
identity.shame_trigger
identity.financial_pain_point
identity.self_sabotage_pattern
identity.accountability_history
identity.war_cry_or_death_vision
```

**Impact**: Onboarding completion will fail to extract identity data

---

### 5. Embedding Services (`/be/src/services/embedding-services/identity.ts`)

**Lines 77-92: Memory mapping**
```typescript
// ❌ WRONG - All these fields don't exist
{ field: "current_struggle", contentType: "self_deception" }
{ field: "nightmare_self", contentType: "nightmare_fear" }
{ field: "last_broken_promise", contentType: "broken_promise" }
{ field: "most_common_slip_moment", contentType: "trigger_moment" }
{ field: "empty_excuse", contentType: "excuse" }
{ field: "weak_excuse_counter", contentType: "excuse_pattern" }
{ field: "desired_outcome", contentType: "vision" }
{ field: "daily_non_negotiable", contentType: "commitment" }
{ field: "regret_if_no_change", contentType: "regret_fear" }
{ field: "meaning_of_breaking_contract", contentType: "betrayal_cost" }
{ field: "external_judgment", contentType: "shame_source" }
{ field: "final_oath", contentType: "sacred_oath" }
```

**Impact**: Memory embeddings won't be generated (but feature may be deprecated anyway)

---

### 6. Query Builders (`/be/src/utils/query-builders.ts`)

**Lines 211-218: updateVoiceCloneId**
```typescript
// ❌ WRONG - Field removed
updateData.voice_clone_id = voiceCloneId;  // Removed in Super MVP
```

**Impact**: Voice clone updates will fail (but feature removed anyway)

---

### 7. Settings Handler (`/be/src/features/core/handlers/settings.ts`)

**Lines 84-120: getScheduleSettings**
```typescript
// ❌ WRONG - Field removed
.select(`
  timezone,
  call_window_start,
  call_window_timezone,
  schedule_change_count  // ← Removed field
`)
```

**Impact**: GET `/api/settings/schedule` will fail

---

## ✅ Already Correct Files

These files were already updated correctly:

1. ✅ `/be/src/features/onboarding/handlers/conversion-complete.ts`
   - Uses Super MVP schema correctly
   - Uploads voice files to R2
   - Builds onboarding_context JSONB
   - Inserts with 12 columns

2. ✅ `/be/src/types/database.ts`
   - TypeScript types updated
   - Matches Super MVP schema

---

## 🔧 Fix Strategy

### Phase 1: Critical Handlers (Fix First)

**1. Fix Identity Handlers** (`identity.ts`)
- **getCurrentIdentity**: Return Super MVP fields
  ```typescript
  name: identity.name,
  dailyCommitment: identity.daily_commitment,
  chosenPath: identity.chosen_path,
  callTime: identity.call_time,
  strikeLimit: identity.strike_limit,
  voiceUrls: {
    whyItMatters: identity.why_it_matters_audio_url,
    costOfQuitting: identity.cost_of_quitting_audio_url,
    commitment: identity.commitment_audio_url
  },
  onboardingContext: identity.onboarding_context,

  // Status (simplified)
  currentStreakDays: identityStatus?.current_streak_days || 0,
  totalCallsCompleted: identityStatus?.total_calls_completed || 0,
  lastCallAt: identityStatus?.last_call_at
  ```

- **updateIdentity**: Only allow updating Super MVP fields
  ```typescript
  .update({
    daily_commitment: identityData.dailyCommitment,
    chosen_path: identityData.chosenPath,
    call_time: identityData.callTime,
    strike_limit: identityData.strikeLimit,
    updated_at: new Date().toISOString()
  })
  ```

- **updateIdentityStatus**: Only update Super MVP fields
  ```typescript
  .upsert({
    user_id: userId,
    current_streak_days: currentStreakDays,
    total_calls_completed: totalCallsCompleted,
    last_call_at: lastCallAt,
    updated_at: new Date().toISOString()
  })
  ```

**2. Fix Prompt Engine** (`onboarding-intel.ts`, `behavioral-intel.ts`)

Option A: **Read from onboarding_context JSONB**
```typescript
export function buildOnboardingIntelligence(identity: Identity | null): string {
  if (!identity || !identity.onboarding_context) {
    return "**INSUFFICIENT DATA**: No onboarding context available.\n\n";
  }

  const ctx = identity.onboarding_context;
  let intelligence = "# 🎯 PSYCHOLOGICAL PROFILE\n\n";

  intelligence += `**User Name**: ${identity.name}\n\n`;
  intelligence += `**Goal**: ${ctx.goal}\n`;
  intelligence += `**Daily Commitment**: ${identity.daily_commitment}\n`;
  intelligence += `**Chosen Path**: ${identity.chosen_path}\n\n`;

  if (ctx.favorite_excuse) {
    intelligence += `## 🔪 FAVORITE EXCUSE\n`;
    intelligence += `"${ctx.favorite_excuse}"\n`;
    intelligence += `*Deploy when: They're making excuses*\n\n`;
  }

  if (ctx.quit_pattern) {
    intelligence += `### QUIT PATTERN\n`;
    intelligence += `"${ctx.quit_pattern}"\n`;
    intelligence += `*Deploy when: You see the pattern starting*\n\n`;
  }

  if (ctx.future_if_no_change) {
    intelligence += `### FUTURE IF NO CHANGE\n`;
    intelligence += `"${ctx.future_if_no_change}"\n`;
    intelligence += `*Deploy when: They need reality check*\n\n`;
  }

  // ... map other JSONB fields as needed
}
```

Option B: **Simplify to only use core fields** (Recommended for MVP)
```typescript
export function buildOnboardingIntelligence(identity: Identity | null): string {
  if (!identity) return "**INSUFFICIENT DATA**\n\n";

  return `# 🎯 ACCOUNTABILITY PROFILE

**Name**: ${identity.name}
**Daily Commitment**: ${identity.daily_commitment}
**Path**: ${identity.chosen_path === 'hopeful' ? 'Hopeful Journey' : 'Doubtful - Needs Push'}
**Strike Limit**: ${identity.strike_limit} strikes before consequences
**Call Time**: ${identity.call_time}

## 🔥 VOICE RECORDINGS
- Why it matters: ${identity.why_it_matters_audio_url ? 'Available' : 'Missing'}
- Cost of quitting: ${identity.cost_of_quitting_audio_url ? 'Available' : 'Missing'}
- Commitment: ${identity.commitment_audio_url ? 'Available' : 'Missing'}

## 🎯 CALL STRATEGY
1. Play "why it matters" voice recording
2. Ask: "Did you [daily_commitment]? Yes or no."
3. If no: Play "cost of quitting" recording
4. Update streak and strike count
5. ${identity.chosen_path === 'doubtful' ? 'Deploy tough love approach' : 'Encourage and support'}
`;
}
```

**3. Fix Behavioral Intel**
```typescript
export function generateBehavioralIntelligence(
  streakPattern: UserPromise[],
  identityStatus: IdentityStatus | null
): string {
  let intelligence = "## Behavioral Pattern Analysis\n\n";

  // Performance pattern
  const kept = streakPattern.filter(p => p.status === "kept").length;
  const broken = streakPattern.filter(p => p.status === "broken").length;
  const total = kept + broken;
  const successRate = total > 0 ? Math.round((kept / total) * 100) : 0;

  intelligence += `**Seven-Day Performance**: ${kept} kept, ${broken} broken (${successRate}% success rate)\n`;

  // Super MVP status (simplified)
  intelligence += `**Current Streak**: ${identityStatus?.current_streak_days || 0} days\n`;
  intelligence += `**Total Calls Completed**: ${identityStatus?.total_calls_completed || 0}\n`;
  intelligence += `**Last Call**: ${identityStatus?.last_call_at || 'Never'}\n\n`;

  return intelligence;
}
```

**4. Fix Settings Handler**
```typescript
// Remove schedule_change_count from SELECT
.select(`
  timezone,
  call_window_start,
  call_window_timezone
`)
```

### Phase 2: Deprecate/Remove (Optional)

**Consider removing entirely** (if not used in Super MVP):
1. `/be/src/features/identity/services/unified-identity-extractor.ts` - May not be needed if onboarding handles everything
2. `/be/src/services/embedding-services/identity.ts` - Memory embeddings feature may be deprecated
3. `/be/src/utils/query-builders.ts` - `updateVoiceCloneId` method

---

## 📋 Implementation Checklist

### Immediate (Critical Path - 2-3 hours)

- [ ] Fix `identity.ts` handlers
  - [ ] getCurrentIdentity - Return Super MVP fields only
  - [ ] updateIdentity - Update Super MVP fields only
  - [ ] updateIdentityStatus - Update Super MVP fields only
  - [ ] getIdentityStats - Use Super MVP fields only

- [ ] Fix prompt engine
  - [ ] Rewrite `buildOnboardingIntelligence` to use Super MVP schema
  - [ ] Fix `generateBehavioralIntelligence` to use Super MVP identity_status

- [ ] Fix settings handler
  - [ ] Remove `schedule_change_count` from getScheduleSettings SELECT

### Optional (Can defer - 1 hour)

- [ ] Deprecate identity extractor (if not used)
- [ ] Deprecate embedding services (if memory feature removed)
- [ ] Remove voice clone methods from query builders

### Testing (1 hour)

- [ ] Test GET `/api/identity/:userId` - Should return Super MVP data
- [ ] Test PUT `/api/identity/:userId` - Should update Super MVP fields
- [ ] Test prompt generation - Should use Super MVP schema
- [ ] Test GET `/api/settings/schedule` - Should not fail on schedule_change_count
- [ ] Test onboarding completion - Should create proper identity record

### Deployment

- [ ] Deploy backend to staging
- [ ] Test end-to-end flow
- [ ] Deploy to production

---

## 🎯 Recommendation

**Simplify for MVP Launch**:
1. Fix the critical handlers (identity, prompts, settings)
2. Use ONLY the Super MVP core fields for now
3. Defer complex JSONB extraction until post-MVP
4. Remove deprecated features (embeddings, voice clone, etc.)

This gets you to launch FAST with a clean schema.

---

## 📝 Next Steps

1. **Review this plan** - Confirm approach
2. **Implement fixes** - Follow checklist above
3. **Test locally** - Verify queries work
4. **Deploy** - Push to production
5. **Monitor** - Watch for errors

**Estimated Total Time**: 3-4 hours to complete all fixes and testing.
