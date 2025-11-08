# ElevenLabs → Cartesia + LiveKit + Supermemory Migration

## Overview
Complete system replacement from ElevenLabs to Cartesia TTS + LiveKit infrastructure + Supermemory for memory management.

**Timeline:** 2-3 weeks
**Strategy:** Big Bang Replacement with minimal backward compatibility

---

## Architecture

### Current State (ElevenLabs)
```
iOS App → VoIP Push → CallKit → [PLACEHOLDER Audio Stream] → ElevenLabs Webhook → Cloudflare Workers
```

### Target State (Cartesia + LiveKit + Supermemory)
```
iOS App (LiveKit Swift SDK) ↔ LiveKit Cloud ↔ Python Agent (STT→LLM→Cartesia TTS) + Supermemory API
         ↓                                              ↓
    VoIP Push (hybrid)                          Cloudflare Workers (webhooks)
```

---

## Services & Credentials Required

### LiveKit Cloud
- **API Key:** `LIVEKIT_API_KEY`
- **API Secret:** `LIVEKIT_API_SECRET`
- **URL:** `LIVEKIT_URL`
- **Package:** `livekit-agents[openai,silero,deepgram,cartesia,turn-detector]~=1.0`

### Cartesia AI
- **API Key:** `CARTESIA_API_KEY`
- **Voice Model:** Sonic-3 or Sonic Turbo
- **Pricing:** ~$0.03-0.05 per minute

### Supermemory
- **API Key:** `SUPERMEMORY_API_KEY`
- **Setup:** https://supermemory.ai
- **Pricing:** $49-99/mo for API access

### Language Model (OpenAI or Anthropic)
- **OpenAI:** `OPENAI_API_KEY` (GPT-4o-mini recommended)
- **Anthropic:** `ANTHROPIC_API_KEY` (Claude 3.5 Sonnet)

### Database
- **Supabase:** `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`

### Python Agent Hosting
- **Option A:** Fly.io (~$20-50/mo)
- **Option B:** Railway (~$20-50/mo)
- **Option C:** Google Cloud Run (pay-per-use)

---

## Cost Comparison

### Current (ElevenLabs)
- **~$0.10-0.30 per minute**
- All-in-one solution

### Target (Estimated)
- LiveKit: ~$0.01-0.02 per participant-minute
- Cartesia TTS: ~$0.03-0.05 per minute
- Deepgram STT: ~$0.01-0.02 per minute
- OpenAI GPT-4o-mini: ~$0.01-0.02 per call
- Supermemory: ~$49-99/mo (fixed)
- Python Agent Hosting: ~$20-50/mo (fixed)
- **Total:** ~$0.06-0.11 per minute + fixed costs

**Potential Savings:** 20-40% vs ElevenLabs

---

## Key Files to Create/Modify

### Backend (17 files)

**NEW:**
- `/be/src/features/livekit/services/token-generator.ts`
- `/be/src/features/livekit/services/call-initiator.ts`
- `/be/src/features/livekit/handlers/livekit-api.ts`
- `/be/src/features/webhook/handlers/livekit-webhooks.ts`
- `/be/src/features/webhook/services/livekit-webhook-handler.ts`
- `/be/src/features/supermemory/services/supermemory-client.ts`
- `/be/src/types/livekit.ts`

**MODIFIED:**
- `/be/src/features/voip/services/payload.ts` - New payload structure
- `/be/src/features/voip/handlers/voip-session.ts`
- `/be/src/features/call/services/call-config.ts`
- `/be/wrangler.toml` - Add secrets

### Python Agent (8 files)

**NEW:**
- `/agent/src/main.py` - Agent entrypoint
- `/agent/src/memory.py` - Supermemory integration
- `/agent/src/assistant.py` - Conversation logic
- `/agent/src/tools.py` - Device tool implementations
- `/agent/src/post_call.py` - Post-call processing
- `/agent/requirements.txt`
- `/agent/Dockerfile`
- `/agent/.env.example`

### iOS (6 files)

**NEW:**
- `/swift/bigbruhh/Features/Call/Services/LiveKitManager.swift`

**MODIFIED:**
- `/swift/bigbruhh/Features/Call/Services/CallSessionController.swift`
- `/swift/bigbruhh/Features/Call/Services/CallKitManager.swift`
- `/swift/bigbruhh/Features/Call/Services/VoIPPushManager.swift`
- `/swift/bigbruhh/Models/APIModels.swift`
- `/swift/Package.swift` or `Podfile`

---

## Phase Breakdown

### Phase 1: Infrastructure Setup (3-4 days)
1.1 LiveKit Cloud Configuration
1.2 Python Agent Service Deployment
1.3 Supermemory Setup

### Phase 2: Backend Migration (4-5 days)
2.1 New Backend Services
2.2 VoIP Payload Updates
2.3 Webhook Migration

### Phase 3: Python Agent Implementation (5-6 days)
3.1 Core Agent Service
3.2 Supermemory Integration
3.3 Post-Call Processing

### Phase 4: iOS Frontend Migration (5-6 days)
4.1 LiveKit SDK Integration
4.2 LiveKit Manager Service
4.3 CallSessionController Rewrite
4.4 CallKit Integration Updates
4.5 VoIP Push Integration

### Phase 5: Data Migration & Cleanup (2-3 days)
5.1 Supermemory Data Import
5.2 Database Schema Updates
5.3 Remove ElevenLabs Dependencies

### Phase 6: Testing & Rollout (3-4 days)
6.1 Integration Testing
6.2 Monitoring Setup
6.3 Rollout Strategy

---

## Success Criteria

### Functional
- VoIP push notifications work with LiveKit
- Agent speaks with Cartesia voice within 2s of connection
- Device tools (battery, flash) functional
- Supermemory context retrieved in < 400ms
- Post-call webhooks fire successfully

### Quality
- Audio quality ≥ current ElevenLabs quality
- End-to-end latency ≤ 500ms
- Call completion rate ≥ 95%
- No audio dropouts or glitches

### Business
- Cost per call reduced by 20-40%
- Agent personalization improved
- All existing features maintained

---

## Risk Mitigation

### High Risks
- **Python Agent Deployment Complexity**
  - Use managed LiveKit Cloud agents if available
  - Alternative: Deploy to Fly.io with auto-scaling

- **Audio Quality Degradation**
  - Extensive testing with Cartesia voices
  - Fallback: Different Cartesia model

- **Latency Increases**
  - Optimize STT→LLM→TTS pipeline
  - Use streaming everywhere

### Medium Risks
- **CallKit Integration Issues**
  - Thorough testing on iOS 15-17
  - Keep existing VoIP infrastructure

- **Cost Overruns**
  - Monitor usage closely
  - Set up billing alerts

---

## Timeline

| Week | Phase | Duration |
|------|-------|----------|
| 1 | Infrastructure + Backend | 7 days |
| 2 | Python Agent + iOS | 7 days |
| 3 | Testing + Deployment | 7 days |
| **Total** | **Full Migration** | **~3 weeks** |
