# VOIP Call Integration Blueprint

1. Map Backend Call Flow
   - Audit existing 11Labs + VoIP modules (`be/src/routes/11labs-call-init.ts`, `be/src/services/voip/*`).
   - Define unified payload schema (callUUID, agent, mood, handoff metadata) for scheduler-driven VoIP pushes and CallKit.
   - Document sequence from call scheduling → VoIP push dispatch → webhook updates.

2. Backend Scheduling Enhancements
   - Keep call initiation inside existing scheduler pipeline (`be/src/services/scheduler-engine.ts`, `be/src/services/call-trigger.ts`); no new public trigger routes.
   - Extend scheduler jobs to compose the VoIP payload using the unified schema, persist session tokens, and reuse `call-tracker` + `delivery-handler` for acknowledgment.
   - Wire webhook handlers (`be/src/routes/elevenlabs-webhooks.ts`) to relay call state changes (ringing, connected, ended) to the app via Supabase Realtime or a polling endpoint.

3. Native Push + CallKit Bootstrapping
   - Create `CallKitManager.swift` under `swift-ios-rewrite/bigbruhh/bigbruhh/Features/Call/Services/` to configure `CXProvider`, manage transactions, and expose state to SwiftUI via an observable.
   - Add `VoIPPushManager` using `PushKit` to register the VoIP token, send it to the backend, and report incoming pushes to CallKit immediately.
   - Verify background modes, entitlements (`bigbruhh.entitlements`), and `Info.plist` strings cover VoIP + CallKit requirements.

4. 11Labs Call Session Handling
   - Implement `CallSessionController.swift` to authenticate with backend-issued tokens, start/stop ElevenLabs audio when CallKit answers/ends, and surface transcription or metrics to the app.
   - Log issues or retries back to backend debug endpoints (`be/src/routes/voip-debug.ts`).

5. App UI Integration & Handoff
   - Feed call state through a shared observable (e.g., `CallStateStore`) so `CallScreen.swift` mirrors timer, mood, and messaging once CallKit is active.
   - On CallKit answer, auto-navigate to the in-app `CallScreen` while keeping native controls available via `CXCallUpdate`.

6. Testing & Monitoring Strategy
   - Define QA scenarios covering foreground/background/locked states, declines, retries, and recovery.
   - Add instrumentation in backend + iOS to existing debug routes for traceability.
   - Document a developer runbook for APNs certificates, PushKit setup, and troubleshooting.

### To-dos

- [ ] Review existing 11Labs + VoIP backend scheduling services and finalize the shared payload schema.
- [ ] Enhance scheduler jobs to build/distribute that payload and persist session credentials (no external trigger route).
- [ ] Implement CallKit + PushKit managers in Swift for native incoming call UI.
- [ ] Establish the 11Labs session controller in Swift triggered by CallKit events.
- [ ] Bind call session state into `CallScreen.swift` and navigation flow.
- [ ] Outline QA scenarios and logging for the VoIP→CallKit→app lifecycle.

