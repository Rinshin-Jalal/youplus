# ElevenLabs Deprecation Guide

## ⚠️ Status: Legacy Support (Read-Only)

ElevenLabs integration is being phased out in favor of **LiveKit + Cartesia + Supermemory**.

This document outlines:
1. What's being deprecated
2. What data is preserved
3. Migration timeline
4. Historical data access

---

## What's Deprecated

### ❌ Webhook Handlers (Comment Out, Don't Delete)

**Files:**
- `/be/src/features/webhook/handlers/elevenlabs-webhooks.ts`
- `/be/src/features/webhook/services/elevenlabs-webhook-handler.ts`

**Action:** Keep these files for reference, but:
1. Remove webhook URL registrations from ElevenLabs dashboard
2. Stop sending webhooks to your backend
3. Keep code for 30 days during transition period

**Why Keep?**
- Historical webhook payloads might still arrive
- Data integrity for existing calls
- Easy rollback if needed

### ❌ ElevenLabs Agent Configuration

**File:** `/be/src/features/call/services/call-config.ts` (lines 40-41)

**Old Code:**
```typescript
const agentId = (env.ELEVENLABS_AGENT_ID as string) ||
  "agent_01jyp5t2v7edwra210m6bwvcq5";
```

**Replacement:** Use LiveKit agent dispatch instead

### ❌ Environment Variables (Optional)

**Optional Removals:**
- `ELEVENLABS_AGENT_ID` - Can remove, not used by LiveKit
- `ELEVENLABS_WEBHOOK_SECRET` - Can remove after migration period
- `ELEVENLABS_API_KEY` - Can remove, not needed

**Recommendation:** Keep for 2 weeks during transition, then remove.

---

## What's Preserved (Read-Only Access)

### ✅ Historical Call Data

**Table:** `calls`

**Preserved Fields:**
```
- id (UUID)
- user_id (FK to users)
- created_at, start_time, end_time
- audio_url (R2 stored MP3)
- transcript_json (original conversation)
- transcript_summary
- call_successful (success | failure | unknown)
- conversation_id (ElevenLabs ID)
- agent_id (ElevenLabs agent)
- source = 'elevenlabs' (marker)
```

**Status:** READ-ONLY
- Users can view old call history
- Transcripts remain accessible
- Audio files stay in R2 storage

### ✅ User Identity & Promises

**Tables:**
- `identity` - Onboarding profile (migrated to Supermemory)
- `identity_status` - Streaks and stats (migrated to Supermemory)
- `promises` - Daily commitments (migrated to Supermemory)

**Status:** All data migrated to Supermemory, originals kept for backup

---

## Migration Timeline

### Phase 1: Dual Support (Week 1)
- ✅ LiveKit fully functional
- ✅ Both providers work (auto-detection in VoIP payload)
- ✅ ElevenLabs webhooks still received

### Phase 2: ElevenLabs Webhooks Disabled (Week 2)
- 🚫 Stop accepting ElevenLabs webhooks
- ✅ Comment out webhook handlers
- ✅ iOS still supports legacy calls if needed
- ✅ Data preserved for historical access

### Phase 3: Complete Migration (Week 3+)
- 🚫 Remove `ELEVENLABS_*` environment variables
- 🚫 Remove webhook routes from router
- ✅ Keep type definitions for data access
- ✅ Keep historical data in database

---

## How to Access Historical Data

### Query ElevenLabs Calls

```typescript
// Get all ElevenLabs calls for user
const { data } = await supabase
  .from('calls')
  .select('*')
  .eq('source', 'elevenlabs')
  .eq('user_id', userId)
  .order('created_at', { ascending: false });
```

### Query Archived Audio

```typescript
// Download archived audio from R2
const audioUrl = call.audio_url; // Direct R2 URL
// Audio stored forever in R2 bucket: youplus-audio-recordings
```

### Query Preserved Transcripts

```typescript
// Get original ElevenLabs transcript
const transcript = call.transcript_json; // Array of conversation turns
const summary = call.transcript_summary;
```

---

## Code Comments to Add

Add deprecation comments to legacy code:

```typescript
/**
 * @deprecated Use LiveKit + Cartesia instead
 * Kept for backward compatibility during transition period
 * Remove after 2025-01-15
 */
export const postElevenLabsWebhook = async (c: Context) => {
  // ...
};
```

---

## Rollback Plan (If Needed)

If LiveKit has issues, you can temporarily revert:

1. **Uncommit ElevenLabs webhook handlers**
   ```bash
   git revert <commit>
   ```

2. **Re-enable ElevenLabs in VoIP payload**
   - Update backend to generate `agentId` for new calls
   - iOS will auto-route based on payload

3. **Register webhook URL with ElevenLabs**
   - Re-add to dashboard
   - Start receiving webhooks again

**Estimated Rollback Time:** < 30 minutes

---

## Checklist for Deprecation

- [ ] Week 1: Deploy LiveKit + keep ElevenLabs functional
- [ ] Week 2: Comment out ElevenLabs webhook handlers
- [ ] Week 2: Monitor for any ElevenLabs webhook payloads
- [ ] Week 3: Remove `ELEVENLABS_*` environment variables
- [ ] Week 3: Clean up unused imports/types (optional)
- [ ] Document that ElevenLabs is deprecated for new users
- [ ] Verify all historical data accessible
- [ ] Test data export to Supermemory

---

## Questions & Troubleshooting

### Q: Can users still download old call transcripts?
**A:** Yes! All old calls remain in the `calls` table. The transcript_json field preserves conversation data.

### Q: Is the audio still playable?
**A:** Yes! Audio is stored in R2 bucket (`youplus-audio-recordings`). Files are permanent (no TTL).

### Q: Will new users see ElevenLabs in UI?
**A:** No. The app is LiveKit-only for new calls. Old calls show as historical records.

### Q: Can I delete old ElevenLabs data?
**A:** Not recommended. Keep for 1+ year for compliance/audit.

### Q: What if webhooks still arrive from ElevenLabs?
**A:** They'll be rejected if handler is commented out. No data loss - just log a warning.

---

## Files Reference

| File | Status | Action |
|------|--------|--------|
| `/be/src/features/webhook/handlers/elevenlabs-webhooks.ts` | Deprecated | Comment out routes |
| `/be/src/features/webhook/services/elevenlabs-webhook-handler.ts` | Deprecated | Keep for reference |
| `/be/src/types/elevenlabs.ts` | Deprecated | Keep for historical data types |
| `/be/src/features/call/services/call-config.ts` | Partial | Remove agentId generation |
| `wrangler.toml` | Update | Remove ELEVENLABS_* secrets after week 2 |

---

## Cost Savings

**ElevenLabs:**
- $0.10-0.30 per minute
- Fixed base fee

**LiveKit + Cartesia + Supermemory:**
- $0.06-0.11 per minute (40% cheaper)
- Variable costs only (no base fee)

**Expected Annual Savings:** 40-50% on voice call costs
