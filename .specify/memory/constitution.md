<!--
SYNC IMPACT REPORT - Constitution v1.0.0
Generated: 2025-10-16

VERSION CHANGE: Template → 1.0.0 (Initial ratification)

PRINCIPLES DEFINED:
- I. Simplicity-First Development (NEW)
- II. Mobile-First Experience (NEW)
- III. Edge-Native Architecture (NEW)
- IV. API-First Design (NEW)
- V. Security & Privacy (NEW)
- VI. Testable Critical Paths (NEW)

SECTIONS ADDED:
- Development Workflow (NEW)
- Technology Standards (NEW)
- Governance (NEW)

TEMPLATES REQUIRING UPDATES:
✅ plan-template.md - Constitution Check section updated
✅ spec-template.md - Compatible, no changes needed
✅ tasks-template.md - Compatible, no changes needed

FOLLOW-UP TODOS: None - all placeholders filled

COMMIT MESSAGE SUGGESTION:
docs: ratify constitution v1.0.0 (initial BigBruh project governance)
-->

# BigBruh Constitution

## Core Principles

### I. Simplicity-First Development

Ship working code over perfect architecture. Prefer direct, obvious solutions to abstractions and frameworks. Only add complexity when absolutely necessary and justified.

**Rules**:
- Start with the simplest solution that works ("the dumbest thing that works")
- Hardcode reasonable defaults instead of building configuration systems
- Extract functions for readability only, not speculative reusability
- No abstractions until pain from duplication becomes clear
- No premature optimization
- Copy-paste code is acceptable if abstraction would add complexity

**Rationale**: Solo developer working on POC/product iterations. Shipping speed and maintainability matter more than theoretical "best practices." Simple code is debuggable code.

### II. Mobile-First Experience

The React Native mobile app is the primary user interface. All features and designs MUST prioritize the mobile experience. Backend services exist to support mobile app functionality.

**Rules**:
- Design decisions favor mobile UX over web/desktop
- VoIP functionality is critical and MUST work reliably
- Test all features on physical iOS and Android devices before considering complete
- API responses optimized for mobile bandwidth constraints
- Push notifications and background processing MUST be reliable

**Rationale**: BigBruh's core experience is "one daily call from your phone." Mobile reliability determines product success or failure.

### III. Edge-Native Architecture

Backend runs on Cloudflare Workers (serverless edge computing). All backend code MUST respect edge environment constraints and optimize for global distribution.

**Rules**:
- Stateless request handling (no in-memory session state)
- Cold start performance matters (minimize dependencies)
- Respect Workers limits: CPU time, memory, request size
- Use Workers KV/Durable Objects for state when needed
- No long-running processes (everything completes within request lifecycle)

**Rationale**: Edge computing provides global low-latency responses and scales automatically. Architecture must respect platform constraints.

### IV. API-First Design

Clear separation between frontend (React Native) and backend (Cloudflare Workers). All business logic resides in backend. Frontend is a thin client consuming RESTful APIs.

**Rules**:
- All user actions that modify data MUST call backend APIs
- No business logic in frontend components (validation, calculations, decisions)
- Backend endpoints MUST be RESTful and independently testable
- API responses MUST include proper error codes and messages
- Authentication required on all non-public endpoints

**Rationale**: Separation enables independent frontend/backend development, supports future clients (web dashboard, etc.), and centralizes business logic for consistency.

### V. Security & Privacy

BigBruh handles deeply personal psychological assessment data, voice recordings, and financial transactions. Security and privacy are NON-NEGOTIABLE.

**Rules**:
- Never commit API keys, secrets, or credentials to version control
- All user data MUST be encrypted in transit (HTTPS) and at rest (Supabase encryption)
- VoIP tokens MUST be securely managed (no client-side exposure)
- Sensitive endpoints MUST validate authentication and authorization
- Payment data handled exclusively through RevenueCat (PCI compliance)
- Voice recordings stored securely with access controls
- Psychological assessment data MUST NOT be logged or exposed

**Rationale**: Trust is fundamental. A single data breach would destroy user confidence in a product that requires psychological vulnerability.

### VI. Testable Critical Paths

Core business flows MUST have automated tests. Critical features that fail break the product's value proposition.

**Rules**:
- VoIP call flow MUST be tested (inbound call handling, user response, call termination)
- Payment/subscription flow MUST be tested (purchase, restoration, expiration)
- Onboarding completion MUST be tested (data capture, validation, storage)
- Authentication flow MUST be tested (signup, login, token refresh)
- Tests written BEFORE implementation (TDD for critical paths)
- Integration tests preferred over unit tests for end-to-end validation

**Rationale**: These flows have high complexity (external integrations) and high impact (revenue/UX). Manual testing is insufficient and unscalable.

## Development Workflow

### POC Mindset

Treat all features as prototypes until proven valuable. Optimize for learning and iteration speed.

**Guidelines**:
- Build minimum viable implementations first
- User feedback determines if feature graduates from POC to polished
- Refactor only when code becomes painful to work with
- Delete unused code aggressively
- Document decisions in git commits (why, not what)

### Shipping Cadence

- Small commits (single logical change)
- Deploy backend changes immediately (Cloudflare Workers auto-deploy)
- Mobile deploys via TestFlight for validation before App Store
- No feature branches longer than 3 days (merge or delete)

## Technology Standards

### Required Stack

- **Frontend**: React Native (Expo), TypeScript
- **Backend**: Cloudflare Workers (Hono framework), TypeScript
- **Database**: Supabase (PostgreSQL)
- **Voice**: ElevenLabs/Cartesia (TTS), VoIP push notifications
- **Payments**: RevenueCat
- **AI**: OpenAI

### Constraints

- TypeScript MUST be used for all new code (frontend and backend)
- No additional frameworks without explicit justification
- Dependencies added only when necessary (minimize bundle size)
- Prefer Expo SDK modules over third-party libraries when available

## Governance

This Constitution supersedes all other project practices and guidelines. When conflicts arise between this document and ad-hoc decisions, the Constitution wins.

### Amendment Process

1. Propose changes via git commit with rationale in commit message
2. Update CONSTITUTION_VERSION according to semantic versioning:
   - **MAJOR**: Removing/redefining principles (breaking changes)
   - **MINOR**: Adding new principles or sections
   - **PATCH**: Clarifications, wording improvements, typo fixes
3. Update LAST_AMENDED_DATE to amendment date
4. Verify dependent templates updated (plan-template.md, spec-template.md, tasks-template.md)

### Compliance Verification

- All feature specs MUST include Constitution Check section (via plan-template.md)
- PRs that violate principles MUST include Complexity Tracking justification
- Security principle violations are automatic PR rejection
- Runtime development guidance available in `docs/cursor.md`

**Version**: 1.0.0 | **Ratified**: 2025-10-16 | **Last Amended**: 2025-10-16