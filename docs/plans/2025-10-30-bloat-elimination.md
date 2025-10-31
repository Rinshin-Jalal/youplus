# You+ Bloat Elimination Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Strip You+ app to essential MVP by removing 60-70% bloat features while preserving core accountability loop and optimizing onboarding experience.

**Architecture:** Remove unnecessary AI features (Brutal Reality, memory embeddings), simplify call system to 1x daily, optimize onboarding flow to 60 steps (35 questions + 25 explanations), keep essential promise tracking infrastructure.

**Tech Stack:** TypeScript/Cloudflare Workers (backend), Swift/iOS (frontend), Supabase (database), ElevenLabs (voice)

---

## Phase 1: Backend - Kill Brutal Reality System

### Task 1.1: Remove Brutal Reality API Routes

**Files:**
- Modify: `be/src/index.ts`
- Delete: `be/src/features/brutal-reality/` (entire directory)

**Step 1: Identify brutal reality routes in main router**

```bash
grep -n "brutal-reality" be/src/index.ts
```

Expected: Find route registrations for brutal reality endpoints

**Step 2: Remove brutal reality route imports and registrations**

In `be/src/index.ts`, remove:
```typescript
import { brutalRealityRouter } from './features/brutal-reality/router';
// ... and later:
app.route('/brutal-reality', brutalRealityRouter);
```

**Step 3: Delete brutal reality feature directory**

```bash
rm -rf be/src/features/brutal-reality/
```

**Step 4: Verify build still works**

```bash
cd be && npm run build
```

Expected: Build succeeds without errors

**Step 5: Commit**

```bash
git add be/src/index.ts
git add -u be/src/features/brutal-reality/
git commit -m "refactor(backend): remove brutal reality API routes and handlers"
```

---

### Task 1.2: Remove Brutal Reality Database References

**Files:**
- Modify: `be/src/types/database.types.ts` (if exists)
- Modify: Database migration files or schema references

**Step 1: Search for brutal_reality table references**

```bash
cd be && grep -r "brutal_reality" src/
```

**Step 2: Remove TypeScript type definitions**

Remove `brutal_reality` table types from database type definitions.

**Step 3: Create database migration to drop table**

Check Supabase dashboard or create migration:
```sql
DROP TABLE IF EXISTS brutal_reality CASCADE;
```

**Step 4: Verify no remaining references**

```bash
grep -r "brutalReality\|brutal_reality" be/src/
```

Expected: No results (or only in git history)

**Step 5: Commit**

```bash
git add -A
git commit -m "refactor(database): remove brutal_reality table and references"
```

---

## Phase 2: Backend - Kill Memory Embedding System

### Task 2.1: Remove Memory/Tool Feature

**Files:**
- Delete: `be/src/features/tool/` (entire directory)
- Modify: `be/src/index.ts`

**Step 1: Identify tool/memory routes**

```bash
grep -n "tool\|memory" be/src/index.ts
```

**Step 2: Remove tool route imports and registrations**

In `be/src/index.ts`, remove tool router registration

**Step 3: Delete tool feature directory**

```bash
rm -rf be/src/features/tool/
```

**Step 4: Verify build**

```bash
cd be && npm run build
```

**Step 5: Commit**

```bash
git add -A
git commit -m "refactor(backend): remove memory embedding and tool features"
```

---

### Task 2.2: Remove Memory Embeddings Database Table

**Files:**
- Database schema

**Step 1: Create migration to drop memory_embeddings**

```sql
DROP TABLE IF EXISTS memory_embeddings CASCADE;
```

**Step 2: Remove any related indexes or triggers**

**Step 3: Update database types if needed**

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor(database): remove memory_embeddings table"
```

---

## Phase 3: Backend - Simplify Call System (1x Daily)

### Task 3.1: Remove Legacy Call Types

**Files:**
- Modify: `be/src/services/prompt-engine/call-configs.ts`
- Modify: `be/src/features/call/` (related handlers)

**Step 1: Read current call config**

```bash
cat be/src/services/prompt-engine/call-configs.ts
```

**Step 2: Keep only daily_reckoning call type**

Remove exports/definitions for:
- `morning`
- `evening`
- `first_call`
- `apology_call`
- `emergency`

Keep only:
- `daily_reckoning`

**Step 3: Update call type enum/union types**

```typescript
type CallType = 'daily_reckoning'; // Remove other types
```

**Step 4: Remove unused tone variations**

Keep ONE tone (recommend: `ColdMirror` or `Confrontational`), remove others:
- Encouraging
- Ruthless
- Protective
- etc.

**Step 5: Verify build**

```bash
cd be && npm run build
```

**Step 6: Commit**

```bash
git add be/src/services/prompt-engine/
git commit -m "refactor(calls): simplify to single daily_reckoning call type"
```

---

### Task 3.2: Update Call Scheduling Logic

**Files:**
- Modify: `be/src/services/call-scheduler.ts` (or equivalent)
- Modify: Cron job configurations

**Step 1: Locate call scheduling service**

```bash
find be/src -name "*scheduler*" -o -name "*cron*"
```

**Step 2: Update to schedule only 1x daily call**

Remove morning/evening dual scheduling logic.
Keep single daily call at user's preferred time.

**Step 3: Update database schema for call windows**

Users table should have single `call_window` field (not morning + evening).

**Step 4: Test scheduling logic**

**Step 5: Commit**

```bash
git add be/src/services/
git commit -m "refactor(scheduling): simplify to single daily call window"
```

---

## Phase 4: Backend - Clean Up Database Schema

### Task 4.1: Remove Redundant Onboarding Table

**Files:**
- Database schema

**Step 1: Verify onboarding data is in main onboarding JSONB column**

```sql
SELECT id, onboarding FROM onboarding LIMIT 5;
```

**Step 2: Drop onboarding_response_v3 table**

```sql
DROP TABLE IF EXISTS onboarding_response_v3 CASCADE;
```

**Step 3: Update TypeScript types**

Remove `onboarding_response_v3` from database type definitions.

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor(database): remove redundant onboarding_response_v3 table"
```

---

## Phase 5: Frontend - Remove Brutal Reality UI

### Task 5.1: Delete Brutal Reality Mirror View

**Files:**
- Delete: `swift/Features/BrutalRealityMirror/` (directory)
- Modify: Xcode project file to remove references

**Step 1: Delete brutal reality directory**

```bash
rm -rf swift/Features/BrutalRealityMirror/
```

**Step 2: Remove from Xcode project**

Open Xcode project, remove `BrutalRealityMirror` group from project navigator.

**Step 3: Search for imports/references**

```bash
grep -r "BrutalRealityMirror" swift/
```

**Step 4: Remove navigation to brutal reality view**

Remove any navigation links, buttons, or routes that show brutal reality screen.

**Step 5: Build and verify**

Build iOS app in Xcode, verify no compilation errors.

**Step 6: Commit**

```bash
git add -A
git commit -m "refactor(ios): remove brutal reality mirror feature"
```

---

### Task 5.2: Simplify Evidence View (Call History)

**Files:**
- Modify: `swift/Features/Evidence/EvidenceView.swift`
- Modify: Related view models/services

**Step 1: Read current EvidenceView implementation**

```bash
cat swift/Features/Evidence/EvidenceView.swift
```

**Step 2: Remove AI brutal review displays**

Keep: Call timestamp, duration, yes/no answer
Remove: AI-generated review text, emotion scoring, impact ratings

**Step 3: Simplify UI to basic list**

```swift
List(calls) { call in
    VStack(alignment: .leading) {
        Text(call.timestamp.formatted())
        Text("Promise: \(call.promiseKept ? "✅ Kept" : "❌ Broken")")
        Text("Duration: \(call.duration)s")
    }
}
```

**Step 4: Remove brutal reality API calls**

Remove any network calls to `/brutal-reality/*` endpoints.

**Step 5: Build and test**

**Step 6: Commit**

```bash
git add swift/Features/Evidence/
git commit -m "refactor(ios): simplify evidence view to basic call history"
```

---

### Task 5.3: Simplify Home Dashboard (FaceView)

**Files:**
- Modify: `swift/Features/Face/FaceView.swift`

**Step 1: Read current FaceView**

```bash
cat swift/Features/Face/FaceView.swift
```

**Step 2: Remove grade card AI messages**

Keep: Trust percentage display, streak counter, promises count
Remove: A-F grade cards, dynamic AI discipline messages, "dominant emotion" theming

**Step 3: Simplify stats display**

```swift
VStack {
    Text("Trust: \(trustPercentage)%")
        .font(.largeTitle)

    HStack {
        Text("Streak: \(streak) days")
        Text("Promises: \(promisesKept)/\(promisesTotal)")
    }

    Text("Next call: \(nextCallCountdown)")
}
```

**Step 4: Remove emotion-based color theming**

Use fixed color scheme instead of dynamic emotion-based colors.

**Step 5: Build and test**

**Step 6: Commit**

```bash
git add swift/Features/Face/
git commit -m "refactor(ios): simplify home dashboard to basic stats"
```

---

## Phase 6: Optimize Onboarding Flow

### Task 6.1: Audit Current Onboarding Steps

**Files:**
- Read: `swift/Features/Onboarding/OnboardingView.swift`
- Read: Step component files

**Step 1: List all current onboarding steps**

```bash
grep -n "Step\|Phase" swift/Features/Onboarding/OnboardingView.swift
```

**Step 2: Categorize by type**

Count:
- Voice recording steps
- Text input steps
- Choice/option steps
- Slider steps
- Explanation/value messaging steps

**Step 3: Document current flow**

Create `docs/onboarding-audit.md` with:
```markdown
# Current Onboarding Flow

## Phase 1: [Name]
1. Step 1: [Type] - [Question]
2. Step 2: [Type] - [Question]
...

Total: X steps
- Y question steps
- Z explanation steps
```

**Step 4: No code changes - just documentation**

**Step 5: Commit**

```bash
git add docs/onboarding-audit.md
git commit -m "docs: audit current onboarding flow structure"
```

---

### Task 6.2: Design Optimized 60-Step Flow

**Files:**
- Create: `docs/onboarding-optimized.md`

**Step 1: Design new structure**

Target:
- 30-35 question steps (less voice, more choices/text)
- 20-25 explanation steps (value messaging, aura preservation)
- 3-5 voice recording moments (strategic emotional anchors)

**Step 2: Map psychological weapons to step types**

```markdown
# Optimized Onboarding (60 Steps)

## Phase 1: Introduction (8 steps)
1. Explanation: "Welcome to psychological warfare"
2. Explanation: "How this works"
3. Choice: "What's your biggest struggle?" [options]
4. Explanation: "Why this matters"
...

## Phase 2: Commitment Definition (12 steps)
1. Text: "What's the ONE thing you keep failing at?"
2. Explanation: "The power of singular focus"
3. Choice: "What category?" [fitness/work/creative/other]
4. Voice: "Record your commitment in your own words"
...
```

**Step 3: Balance question vs explanation ratio**

Ensure ~35 questions / ~25 explanations

**Step 4: Identify voice recording moments**

Limit to 3-5 strategic points:
- Initial commitment recording
- Why this matters emotionally
- War cry or consequence statement

**Step 5: Document flow**

Save to `docs/onboarding-optimized.md`

**Step 6: Commit**

```bash
git add docs/onboarding-optimized.md
git commit -m "docs: design optimized 60-step onboarding flow"
```

---

### Task 6.3: Implement Optimized Onboarding Steps (Iterative)

**Files:**
- Modify: `swift/Features/Onboarding/OnboardingView.swift`
- Modify: Step components (TextStep, ChoiceStep, VoiceStep, ExplanationStep, etc.)

**Step 1: Implement Phase 1 steps**

Replace current Phase 1 with optimized steps from design doc.

**Step 2: Test Phase 1 flow**

Run app, verify Phase 1 flows correctly with new steps.

**Step 3: Commit Phase 1**

```bash
git add swift/Features/Onboarding/
git commit -m "refactor(onboarding): implement optimized Phase 1 steps"
```

**Step 4: Repeat for remaining phases**

Implement Phase 2, test, commit.
Implement Phase 3, test, commit.
Continue until all phases updated.

**Step 5: Final verification**

Complete full onboarding flow, verify:
- 30-35 question steps
- 20-25 explanation steps
- 3-5 voice moments
- Total ~60 steps
- Smooth transitions
- Maintains "aura"

**Step 6: Final commit**

```bash
git add swift/Features/Onboarding/
git commit -m "refactor(onboarding): complete optimized 60-step flow implementation"
```

---

## Phase 7: Backend - Update Onboarding Data Extraction

### Task 7.1: Simplify Psychological Weapons Extraction

**Files:**
- Modify: `be/src/features/onboarding/handlers.ts`
- Modify: `be/src/features/onboarding/extract-data.ts`

**Step 1: Review current extraction logic**

```bash
cat be/src/features/onboarding/extract-data.ts
```

**Step 2: Update to match new onboarding structure**

Adjust extraction to work with:
- Fewer voice responses
- More choice-based responses
- New step numbering/keys

**Step 3: Simplify AI prompt for extraction**

Reduce complexity of psychological weapon extraction prompt if needed.

**Step 4: Test extraction with sample onboarding data**

**Step 5: Commit**

```bash
git add be/src/features/onboarding/
git commit -m "refactor(onboarding): update data extraction for optimized flow"
```

---

## Phase 8: Testing & Cleanup

### Task 8.1: Remove Dead Code

**Files:**
- Multiple files across backend/frontend

**Step 1: Search for unused imports**

```bash
# Backend
cd be && npx ts-prune

# Frontend - use Xcode's "Find Unused Code" or manual grep
```

**Step 2: Remove commented-out code**

Search for large comment blocks and remove if truly unused.

**Step 3: Remove debug logging**

```bash
grep -r "console.log\|print(" be/src/ swift/
```

Remove non-essential debug logs.

**Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove dead code and unused imports"
```

---

### Task 8.2: Update Environment Variables & Config

**Files:**
- Modify: `be/.env.example`
- Modify: Configuration files

**Step 1: Remove config for deleted features**

Remove environment variables for:
- Brutal Reality API keys (if any)
- Memory embedding API keys (OpenAI embeddings)
- Unused call types

**Step 2: Update .env.example**

Document only required environment variables.

**Step 3: Commit**

```bash
git add be/.env.example
git commit -m "chore: update environment config for simplified features"
```

---

### Task 8.3: Integration Testing

**Files:**
- Testing framework

**Step 1: Test onboarding flow end-to-end**

- Complete full onboarding in iOS app
- Verify data saves to backend
- Verify psychological weapons extracted correctly

**Step 2: Test call scheduling**

- Set call window
- Trigger test call
- Verify VoIP push received
- Verify call UI appears
- Answer yes/no
- Verify promise tracked

**Step 3: Test dashboard stats**

- Verify trust % calculates correctly
- Verify streak increments
- Verify call history displays

**Step 4: Document test results**

Create `docs/testing-bloat-elimination.md` with results.

**Step 5: Fix any bugs found**

Address issues discovered during testing.

**Step 6: Commit**

```bash
git add -A
git commit -m "test: verify bloat elimination doesn't break core features"
```

---

## Phase 9: Documentation & Deployment Prep

### Task 9.1: Update README and Docs

**Files:**
- Modify: `README.md`
- Modify: `DEPLOYMENT.md`
- Modify: `VOIP_SETUP.md`

**Step 1: Update feature list in README**

Remove mentions of:
- Brutal Reality system
- Memory embeddings
- Multiple call types
- Weekly reports (defer to v1.1)

Add:
- Simplified 1x daily call
- Optimized 60-step onboarding

**Step 2: Update deployment docs**

Remove deployment steps for deleted features.

**Step 3: Create v1.1 roadmap**

Document deferred features:
```markdown
# v1.1 Roadmap
- Weekly Truth Report generation
- 2x daily calls (morning + evening)
- Advanced psychological profiling (optional)
- Brutal Reality entertainment mode (premium feature)
```

**Step 4: Commit**

```bash
git add README.md DEPLOYMENT.md docs/
git commit -m "docs: update for bloat elimination changes"
```

---

### Task 9.2: Database Migration Checklist

**Files:**
- Create: `docs/database-migration-checklist.md`

**Step 1: Document all schema changes**

```markdown
# Database Migration Checklist

## Tables to Drop
- [ ] brutal_reality
- [ ] memory_embeddings
- [ ] onboarding_response_v3

## Tables to Modify
- [ ] users - simplify call_window (remove morning/evening split)

## Data to Preserve
- [ ] Backup existing users table
- [ ] Backup existing promises table
- [ ] Backup existing calls table
```

**Step 2: Create backup scripts**

```bash
# Supabase backup command
pg_dump [connection_string] > backup-$(date +%Y%m%d).sql
```

**Step 3: Create migration scripts**

Write SQL migration files for all changes.

**Step 4: Test on staging database**

Apply migrations to test environment first.

**Step 5: Document rollback plan**

**Step 6: Commit**

```bash
git add docs/database-migration-checklist.md
git commit -m "docs: create database migration checklist"
```

---

## Phase 10: Final Verification

### Task 10.1: Code Review Checklist

**Step 1: Verify all bloat features removed**

- [ ] No brutal reality code in backend
- [ ] No brutal reality UI in frontend
- [ ] No memory embedding system
- [ ] Call system simplified to 1x daily
- [ ] Onboarding optimized to 60 steps

**Step 2: Verify core features intact**

- [ ] Authentication works
- [ ] Payment/subscription works
- [ ] Onboarding completes successfully
- [ ] Voice recording works
- [ ] Voice cloning works
- [ ] VoIP calls work
- [ ] CallKit integration works
- [ ] Promise tracking works
- [ ] Trust % calculation works
- [ ] Streak tracking works
- [ ] Call history displays

**Step 3: Performance check**

- [ ] Backend build succeeds
- [ ] Frontend build succeeds
- [ ] No TypeScript errors
- [ ] No Swift compiler warnings
- [ ] App launches successfully
- [ ] No crashes during testing

**Step 4: Documentation complete**

- [ ] README updated
- [ ] DEPLOYMENT.md updated
- [ ] Migration checklist created
- [ ] v1.1 roadmap documented

---

### Task 10.2: Create Release Tag

**Step 1: Verify all changes committed**

```bash
git status
```

Expected: Clean working tree

**Step 2: Create release tag**

```bash
git tag -a v1.0.0-bloat-eliminated -m "Release: Bloat elimination - simplified to core MVP"
```

**Step 3: Push to remote**

```bash
git push origin master
git push origin v1.0.0-bloat-eliminated
```

**Step 4: Create GitHub release notes**

Document:
- Features removed (bloat)
- Features optimized (onboarding)
- Core features preserved
- v1.1 roadmap

---

## Summary

**Estimated Code Reduction:** 60-70%
**Files Deleted:** ~30-40 files
**Database Tables Dropped:** 3 tables
**API Endpoints Removed:** ~10-15 endpoints
**Lines of Code Removed:** ~5,000-7,000 lines

**Core Functionality Preserved:**
✅ Authentication & Payment
✅ Voice recording & cloning
✅ VoIP call system
✅ Promise tracking
✅ Trust % & streak calculation
✅ Call history

**Optimized:**
✅ Onboarding: 60 steps (35 questions + 25 explanations)
✅ Call system: 1x daily (simpler MVP)

**Deferred to v1.1:**
- Weekly Truth Report
- 2x daily calls
- Advanced features

**Ready to Ship:** Yes, after database migration and final testing
