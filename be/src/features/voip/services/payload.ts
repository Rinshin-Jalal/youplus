/**
 * VoIP payload helpers
 * Provides shared schema for scheduler → push → CallKit handoff.
 */
import { CallType } from "@/types/database";

interface VoipCallPrompts {
  systemPrompt: string;
  firstMessage: string;
}

export interface VoipCallPayload {
  callUUID: string;
  userId: string;
  callType: CallType;
  agentId: string;
  mood: string;
  prompts?: VoipCallPrompts;
  sessionToken?: string;
  voiceId?: string;
  handoff?: {
    scheduleId?: string;
    jobId?: string;
    initiatedBy: "scheduler" | "manual";
    retries?: number;
  };
  metadata?: Record<string, unknown>;
}

export function createVoipCallPayload(params: VoipCallPayload): VoipCallPayload {
  return {
    ...params,
    metadata: {
      ...params.metadata,
      generatedAt: new Date().toISOString(),
      version: "2.0.0",
    },
  };
}