<!-- 71303392-12aa-4b22-af89-561afc153e18 cabb4cbc-e514-4ee1-8416-103411e364a2 -->
# Identity Status Sync Implementation

## Problem

The Swift FaceView displays all F grades because `identity_status` table is empty. The backend returns defaults (promises: 0, broken: 0, streak: 0, trust: 100) instead of real data from the `promises` table.

## Solution

Create a sync function that calculates and updates `identity_status` from `promises` table data, triggered automatically after successful evening calls.

## Implementation Steps

### 1. Create Sync Utility Function

**File**: `be/src/utils/identity-status-sync.ts`

Calculate from `promises` table:

- **promises_made_count**: Total promises with status "kept" or "broken" (all-time)
- **promises_broken_count**: Total promises with status "broken" (all-time)
- **current_streak_days**: Consecutive days with at least one kept promise, counting backwards from today
- **trust_percentage**: Based on recent success rate (last 7 days), formula: `max(0, 100 - (brokenLast7Days * 10))`

Algorithm for streak:

```typescript
// Start from today, count backwards
// For each day:
//   - If has promises AND all kept -> increment streak
//   - If has promises AND any broken -> stop counting
//   - If no promises -> stop counting (day without commitment breaks streak)
```

Query promises ordered by `promise_date DESC`, group by date, check if each day was successful.

### 2. Hook Into Evening Call Completion

**File**: `be/src/services/elevenlabs-webhook-handler.ts` (line 243)

Add sync immediately after brutal reality generation:

```typescript
// After line 242 (brutal reality generation)
// Add:
try {
  const { syncIdentityStatus } = await import("@/utils/identity-status-sync");
  await syncIdentityStatus(userId, this.env);
  console.log(`📊 Identity status synced for user ${userId}`);
} catch (error) {
  console.error(`Failed to sync identity status for user ${userId}:`, error);
}
```

This ensures metrics update after each evening call when promise statuses are finalized.

### 3. Import and Type Setup

**File**: `be/src/utils/identity-status-sync.ts`

Use existing imports:

- `createSupabaseClient` from `@/utils/database`
- `Env` type from `@/index`
- `format`, `subDays` from `date-fns`

Return type: `Promise<{ success: boolean; data?: any; error?: string }>`

### 4. Error Handling

- Handle missing promises gracefully (new users)
- Log all sync operations
- Don't throw errors that would break webhook processing
- Use upsert to handle both create and update

### ✅ Post-Implementation Update

- Added AI-generated status summary (discipline level + notification messaging) stored in `identity_status.status_summary`.
- Updated `GET /api/identity/:userId` to return the new `statusSummary` field so the Swift UI can display dynamic messaging.

## Why Evening Calls?

Evening calls are when:

- Day's promises are reviewed and finalized
- Statuses change from "pending" to "kept"/"broken"
- Streaks are determined
- Next day baseline is set

Perfect trigger point for daily sync.

## Expected Outcome

After implementation:

- Swift FaceView shows real grades (A/B/C/F based on actual performance)
- Discipline level displays accurate percentage
- Streak counter reflects consecutive kept promises
- Trust percentage decreases with broken promises
- Dynamic discipline copy + notification text updates after evening calls
- All data syncs automatically after evening calls
