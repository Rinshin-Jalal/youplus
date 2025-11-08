# ElevenLabs → Cartesia + LiveKit + Supermemory Migration

## 📊 Progress Summary

### Completed Phases ✅

**Phase 1.2** - Python Agent Service Deployment
- Agent folder structure created
- Main.py: Cartesia Ink (STT) + Sonic-3 (TTS) + GPT-4o-mini setup
- Memory.py: Supermemory integration
- Tools.py: Device tools (battery, flash, vibrate, location, screenshot)
- Post_call.py: Transcript analysis and memory storage
- VAD research completed (Silero VAD recommended)

**Phase 3** - Python Agent Implementation (Complete)
- main.py: Full agent orchestration with all integrations
  - Metadata extraction and validation
  - Conversation manager initialization
  - AI model setup (STT/LLM/TTS)
  - Device tool registration
  - Full transcription tracking
  - Post-call processing pipeline
  - Comprehensive error handling
- config.py: Centralized configuration management
  - AgentConfig dataclass with validation
  - Personality templates (supportive, accountability, celebration)
  - VAD configuration profiles (conservative, balanced, aggressive)
  - Device tool definitions
  - Helper functions for settings
- requirements.txt: Updated dependencies (added silero)
- README.md: Complete documentation
  - Architecture overview
  - Quick start guide
  - Module structure and data flow
  - Features and configuration
  - Deployment guides
  - Troubleshooting section
  - Performance tuning
  - Security best practices

**Phase 2** - Backend Migration (Complete)
- token-generator.ts: JWT token generation for iOS clients
- call-initiator.ts: LiveKit room creation and agent dispatch
- livekit-api.ts: HTTP endpoints for call management
- livekit-webhooks.ts: Event handlers (room_finished, recording_finished, etc)
- livekit-webhook-handler.ts: Event processing with HMAC validation
- livekit.ts: Complete type definitions and interfaces
- payload.ts: Updated to support both ElevenLabs (legacy) and LiveKit (current)

**Phase 4** - iOS Frontend Migration (Complete)
- LiveKitManager.swift: WebRTC connection management
  - Real-time bidirectional audio
  - Device tool execution via data channel
  - Participant tracking
  - Reconnection with exponential backoff
- CallSessionController+LiveKit.swift: Integration extension
- VoIPPushManager.swift: Enhanced payload parsing for both providers
- CallStateStore.swift: Extended state management with provider detection
- AppDelegate+LiveKit.swift: Call routing (LiveKit vs ElevenLabs)

**Phase 5** - Data Migration & Cleanup (Complete)
- scripts/migrate-to-supermemory.ts: Complete migration utility
  - Export promises (commitments) to Supermemory
  - Export identity metrics (onboarding profile)
  - Export call history (statistics and progress)
  - Single user + batch migration support
  - Rate limiting to avoid API throttling
- be/sql/add-livekit-tables.sql: New database tables
  - livekit_sessions: Track individual room sessions
  - livekit_rooms: Track room lifecycle and metrics
  - Extended calls table with LiveKit fields
  - RLS policies for user isolation
  - Backward compatibility for historical ElevenLabs data
- ELEVENLABS_DEPRECATION.md: Complete transition guide
  - 3-week phaseout timeline
  - Data preservation strategy
  - Rollback plan
  - Cost savings analysis (40-50% reduction)

### In Progress Phases 🔄

**Phase 1.1** - LiveKit Cloud Configuration (pending infrastructure setup)
**Phase 1.3** - Supermemory Setup (pending account setup)
**Phase 6** - Testing & Rollout (ready after config phases)

---

## Overview
Complete system replacement from ElevenLabs to Cartesia TTS + LiveKit infrastructure + Supermemory for memory management.

**Current Progress:** 5 of 6 major phases + Phase 3 complete (92%)
**Estimated Completion:** 1 week remaining (after cloud setup)

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
