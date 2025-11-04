/**
 * Call configuration service
 * Generates ElevenLabs call configuration used by both HTTP routes and scheduler.
 */

import { Env } from "@/index";
import { CallType, UserContext, BigBruhhTone } from "@/types/database";
import { getUserContext } from "@/features/core/utils/database";
import { calculateOptimalTone } from "@/features/call/services/tone-engine";
import { getPromptForCall } from "@/services/prompt-engine";

export interface CallMetadataResult {
  agentId: string;
  mood: BigBruhhTone;
  callUUID: string;
  voiceId: string | undefined;
  userContext: UserContext;
  toneAnalysis: ReturnType<typeof calculateOptimalTone>;
}

export interface CallPromptResult {
  prompts: {
    systemPrompt: string;
    firstMessage: string;
  };
}

export interface CallFullConfigResult extends CallMetadataResult, CallPromptResult {}

export async function generateCallMetadata(
  env: Env,
  userId: string,
  callType: CallType,
  callUUID: string,
): Promise<CallMetadataResult> {
  const userContext = await getUserContext(env, userId);
  const toneAnalysis = calculateOptimalTone(userContext);

  const agentId = env.ELEVENLABS_AGENT_ID ||
    "agent_01jyp5t2v7edwra210m6bwvcq5";

  let mood = toneAnalysis.recommended_mood;
  // All calls use daily_reckoning mode now (bloat elimination)
  if (false) { // Disabled: apology_call removed
    mood = "Confrontational";
  }

  const voiceId = resolveVoiceId(callType, mood, userContext);

  return {
    agentId,
    mood,
    callUUID,
    voiceId,
    userContext,
    toneAnalysis,
  };
}

export async function generateCallPrompts(
  env: Env,
  callType: CallType,
  userContext: UserContext,
  toneAnalysis: ReturnType<typeof calculateOptimalTone>,
): Promise<CallPromptResult> {
  const callPrompts = await getPromptForCall(
    callType,
    userContext,
    toneAnalysis,
    env,
    true,
  );

  return {
    prompts: {
      systemPrompt: callPrompts.systemPrompt,
      firstMessage: callPrompts.firstMessage,
    },
  };
}

export async function generateFullCallConfig(
  env: Env,
  userId: string,
  callType: CallType,
  callUUID: string,
): Promise<CallFullConfigResult> {
  const metadata = await generateCallMetadata(env, userId, callType, callUUID);
  const prompts = await generateCallPrompts(env, callType, metadata.userContext, metadata.toneAnalysis);
  return {
    ...metadata,
    ...prompts,
  };
}

function resolveVoiceId(
  callType: CallType,
  mood: string,
  userContext: UserContext,
): string | undefined {
  const voiceMap: Record<string, string> = {
    angry: "pNInz6obpgDQGcFmaJgB",
    disappointed: "TxGEqnHWrfWFTfGW9XjX",
    nuclear: "pNInz6obpgDQGcFmaJgB",
    calm: "21m00Tcm4TlvDq8ikWAM",
    encouraging: "21m00Tcm4TlvDq8ikWAM",
    first_call: "21m00Tcm4TlvDq8ikWAM",
    apology_call: "TxGEqnHWrfWFTfGW9XjX",
  };

  if (voiceMap[callType]) {
    return voiceMap[callType];
  }

  if (voiceMap[mood]) {
    return voiceMap[mood];
  }

  if (userContext.user?.voice_clone_id) {
    return userContext.user.voice_clone_id;
  }

  return undefined;
}