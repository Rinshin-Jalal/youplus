# VoIP Call Flow

## Sequence Overview

1. Scheduler identifies eligible users and invokes `processUserCall`; only call metadata is generated.
2. Device receives push, triggers CallKit via native managers, and requests prompts on-demand through `/voip/session/prompts` once the call is accepted.
3. Deferred endpoint generates prompts once per `callUUID`, caches them in `voip_sessions`, and returns mood + agent metadata.
4. ElevenLabs webhooks report transcription/audio; backend updates call records and broadcasts state changes.

## Payload Schema

- `prompts` are now optional and omitted during initial push.

## State Persistence

- `voip/session-store.ts` records session payloads, prompt cache flags, and cached prompt body once generated.

## Webhook Integration

- Signature + session token semantics remain unchanged; webhook handlers can look up prompt cache when needed.

## iOS Flow

- `CallSessionController` fetches `/voip/session/prompts` after CallKit answers, then streams audio using the returned prompts.
- `CallStateStore` transitions through `.awaitingPrompts` until the prompt cache arrives, keeping UI in sync.
- `DeviceTools` registers client tools: `get_battery_level`, `change_brightness`, `flash_screen` mirroring NRN behaviour.

## QA Scenarios

- Deferred prompt fetch failure / retry states
- Client tool registration availability before conversation begins

## Monitoring & Instrumentation

- `voip_sessions` captures `prompts_generated` and cached prompt bodies for auditing.

## Developer Runbook

- Use `/voip/session/init` for manual testing of the new flow prior to push dispatch.
- `/voip/session/prompts` can be called repeatedly; subsequent calls return `cached: true` with stored prompts.
