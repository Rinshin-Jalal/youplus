# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

You+ is a psychological accountability system that uses your own voice to hold you accountable. Built as a Swift iOS app with a Cloudflare Workers backend, it creates daily phone calls where your recorded voice asks: "Did you do what you said you'd do?" You can't lie to your future self.

## Development Commands

### Frontend (Swift iOS) - `/swift` directory

```bash
# Open project in Xcode
open swift/bigbruhh.xcodeproj

# Build and run via Xcode
# - Select target device/simulator
# - Press Cmd+R to build and run
# - Use Cmd+B to build only

# Note: Code references "bigbruhh" for technical reasons
# Brand name is "You+" in all user-facing content
```

### Backend (Cloudflare Workers) - `/be` directory  

```bash
# Start local dev server
npm run dev       # Runs wrangler dev

# Deploy to Cloudflare
npm run deploy    # Runs wrangler deploy

# Build TypeScript
npm run build     # Runs tsc

# Run tests
npm test         # Runs jest
```

## Architecture Overview

### Tech Stack

- **Frontend**: Swift, SwiftUI, iOS native
- **Backend**: Hono framework on Cloudflare Workers, TypeScript
- **Database**: Supabase (PostgreSQL)
- **Storage**: Cloudflare R2 (S3-compatible)
- **Voice/AI**: ElevenLabs (Convo AI), OpenAI for voice processing
- **Payments**: RevenueCat
- **Push Notifications**: VoIP push for iOS (CallKit integration)

### Key Integrations

- **Supabase**: Authentication, user data, embeddings, call history
- **ElevenLabs**: AI voice synthesis and conversation management
- **OpenAI**: LLM for prompt generation and behavioral analysis
- **RevenueCat**: Subscription management and payment processing
- **VoIP Push**: Custom native module for iOS background calls

### Project Structure

```
bigbruh/
├── rn/                    # React Native mobile app
│   ├── app/              # Expo Router screens (file-based routing)
│   │   ├── (public)/     # Landing, onboarding
│   │   ├── (auth)/       # Login, signup, processing
│   │   ├── (app)/        # Main app screens (home, call, history, settings)
│   │   └── (purchase)/   # Paywall, subscription flows
│   ├── components/       # Reusable UI components
│   │   ├── onboarding/   # 54-step psychological assessment
│   │   └── 11labs/       # Voice conversation UI
│   ├── hooks/            # Custom React hooks
│   │   └── voip/         # VoIP call management hooks
│   ├── services/         # Business logic services
│   └── modules/          # Native modules (VoIP push token)
│
└── be/                    # Backend Cloudflare Workers
    ├── src/
    │   ├── index.ts      # Main server entry point
    │   ├── routes/       # API endpoints
    │   │   └── tool-handlers/  # AI tool function handlers
    │   ├── services/     # Core business logic
    │   │   ├── prompt-engine/  # AI prompt generation system
    │   │   └── embedding-services/  # Vector embeddings
    │   └── middleware/   # Auth, security
    └── sql/              # Database migrations
```

## Critical Workflows

### 1. Onboarding Flow (54 Steps)
- Anonymous session starts → Psychological assessment → Data stored temporarily
- After payment → User creates account → Data migrated from session to user ID
- Location: `rn/app/(public)/onboarding.tsx`, `rn/components/onboarding/`
- Backend: `be/src/routes/onboarding.ts`, `be/src/services/onboarding-data-extractor.ts`

### 2. Daily Accountability Calls
- Scheduled by timezone-aware cron job
- Morning call (6-9 AM user time), Evening call (8-11 PM user time)  
- Backend scheduler: `be/src/services/scheduler-engine.ts`
- Frontend handling: `rn/hooks/voip/useRitualCallHandling.ts`
- Call modes: `be/src/services/prompt-engine/modes/`

### 3. VoIP Push Notifications (iOS)
- Custom native module: `rn/modules/expo-voip-push-token-v2/`
- Token registration: `rn/hooks/voip/useVoipToken.ts`
- Backend delivery: `be/src/services/voip/delivery-handler.ts`

### 4. AI Tool Functions
- Defined in: `be/src/routes/tool-handlers/`
- Each tool provides specific functionality during AI conversations
- Examples: `getUserContext`, `analyzeExcusePattern`, `deliverConsequence`

## Development Guidelines

### Code Style
- Use TypeScript with strict typing
- Prefer functional components and hooks in React Native
- Keep API routes focused - business logic in services
- Use Zod for runtime validation on API inputs

### Testing Approach
- Unit tests for core services
- Manual testing via dev routes (`/debug/*`, `/trigger/*` in dev mode only)
- VoIP testing endpoints: `be/src/services/voip/test-endpoints.ts`

### Security Considerations
- Never expose API keys in client code
- All sensitive routes require authentication via Supabase JWT
- Production endpoints are subscription-gated
- Dev/debug routes disabled in production environment

### Database Patterns
- Use Supabase RLS (Row Level Security) for user data isolation
- Embeddings stored in `memories` table with vector indexes
- Call history tracked with retry logic and acknowledgment states

## Common Development Tasks

### Add a New API Endpoint
1. Create route handler in `be/src/routes/`
2. Add to router in `be/src/index.ts`
3. Apply appropriate middleware (auth, subscription check)
4. Update TypeScript types in `be/src/types/`

### Add a New Onboarding Step
1. Create step component in `rn/components/onboarding/steps/`
2. Add to step sequence in `rn/components/onboarding/index.tsx`
3. Update data extraction in `be/src/services/onboarding-data-extractor.ts`

### Modify Call Prompts
1. Edit prompt templates in `be/src/services/prompt-engine/templates/`
2. Adjust tone in `be/src/services/tone-engine.ts`
3. Update call modes in `be/src/services/prompt-engine/modes/`

### Handle VoIP Events
1. Update event handlers in `rn/hooks/voip/useCallEvents.ts`
2. Modify call flow in `rn/hooks/voip/useRitualCallHandling.ts`
3. Adjust backend webhook processing in `be/src/services/elevenlabs-webhook-handler.ts`

## Environment Variables

### Frontend (Expo)
- Configured in app through Expo SecureStore
- API endpoint configuration in `rn/lib/api.ts`

### Backend (Cloudflare)
- Secrets managed via Wrangler
- Environment bindings in `be/wrangler.toml`
- Type definitions in `be/src/index.ts` (Env interface)

## Deployment

### Frontend
- Uses EAS (Expo Application Services) for builds
- Configuration in `rn/eas.json`

### Backend  
- Deploy via `npm run deploy` in `/be` directory
- Uses Cloudflare Workers with R2 storage bindings
- Cron schedules configured in `be/wrangler.toml`

## Important Notes

- The app uses a "tough love" psychological approach - maintain this tone in all user-facing content
- Onboarding is designed as an intensive 54-step journey - changes affect user psychology
- VoIP calls are critical for iOS background functionality - test thoroughly
- All payment features are gated through RevenueCat subscriptions
- The backend uses timezone-aware scheduling - respect user local times