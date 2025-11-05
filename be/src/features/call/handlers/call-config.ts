/**
 * Call Configuration Endpoint - SUPER MVP 🚀
 *
 * This module provides primary endpoint for generating intelligent call configurations
 * for 11labs Convo AI. It's responsible for creating personalized, behaviorally-aware
 * prompts that drive effective accountability conversations.
 *
 * Key Responsibilities:
 * - Generate personalized call prompts based on user behavioral data
 * - Calculate optimal tone and mood for each call scenario
 * - Integrate with prompt engine for intelligent conversation generation
 * - Provide call tracking metadata for monitoring and analytics
 *
 * Call Types Supported (Super MVP):
 * - daily_reckoning: Daily accountability calls (unified morning/evening)
 *
 * Integration Flow:
 * 1. Frontend requests call configuration
 * 2. System analyzes user behavioral patterns
 * 3. Generates personalized prompts and tone
 * 4. Returns configuration for 11labs execution
 * 5. Call is executed with intelligent personalization
 */

import { Context } from "hono";
import { Env } from "@/index";
import { CallType } from "@/types/database";
import { generateCallMetadata } from "@/features/call/services/call-config";
import { createVoipCallPayload } from "@/features/voip/services/payload";

/**
 * Get appropriate voice ID based on call type, mood, and user preferences
 */
function getVoiceForCall(
  callType: CallType,
  mood: string,
  userContext: any, // This type is not defined in new_code, so we'll keep it as is
): string | undefined {
  // Different voices for different moods/scenarios
  const voiceMap: Record<string, string> = {
    // Aggressive/confrontational voices
    "angry": "pNInz6obpgDQGcFmaJgB", // Adam (assertive, confident)
    "disappointed": "TxGEqnHWrfWFTfGW9XjX", // Josh (serious, direct)
    "nuclear": "pNInz6obpgDQGcFmaJgB", // Adam (for extreme intensity)

    // Supportive/calm voices
    "calm": "21m00Tcm4TlvDq8ikWAM", // Rachel (warm, supportive)
    "encouraging": "21m00Tcm4TlvDq8ikWAM", // Rachel

    // Call-type specific overrides
    "first_call": "21m00Tcm4TlvDq8ikWAM", // Always start with warm Rachel
    "apology_call": "TxGEqnHWrfWFTfGW9XjX", // Always serious Josh
  };

  // First check call-type specific voice
  if (voiceMap[callType]) {
    return voiceMap[callType];
  }

  // Then check mood-based voice
  if (voiceMap[mood]) {
    return voiceMap[mood];
  }

  // Check if user has a preferred 11Labs voice saved in their profile
  // voice_clone_id stores user's preferred ElevenLabs voice ID
  if (userContext.user?.voice_clone_id) {
    return userContext.user.voice_clone_id;
  }

  // Default fallback - let agent use its configured voice
  return undefined;
}

/**
 * Generate call configuration for 11labs Convo AI calls
 *
 * This endpoint creates intelligent, personalized call configurations that
 * adapt to each user's behavioral patterns and accountability needs. It
 * integrates behavioral intelligence with tone analysis to generate
 * highly effective accountability conversations.
 *
 * The configuration includes:
 * - Agent ID for 11labs routing
 * - Optimized mood based on user patterns
 * - Personalized system prompts and first messages
 * - Call tracking metadata for analytics
 * - Behavioral intelligence indicators
 *
 * @param c Hono context with userId and callType parameters
 * @returns JSON response with complete call configuration
 */
export const getCallConfig = async (c: Context) => {
  const { userId, callType } = c.req.param();
  const env = c.env as Env;

  // Super MVP: Only one call type
  const validCallTypes: CallType[] = [
    "daily_reckoning",
  ];

  if (!userId || !callType || !validCallTypes.includes(callType as CallType)) {
    return c.json({ error: "Invalid userId or callType" }, 400);
  }

  try {
    const callUUID = `${callType}-${userId.slice(-8)}-${Date.now()}`;
    const metadata = await generateCallMetadata(env, userId, callType as CallType, callUUID);

    const basePayload = {
      callUUID,
      userId,
      callType: callType as CallType,
      agentId: metadata.agentId,
      mood: metadata.mood,
      handoff: {
        initiatedBy: "manual" as const,
      },
      metadata: {
        tone: metadata.toneAnalysis,
        generatedBy: "getCallConfig",
      },
    };

    const payload = createVoipCallPayload(
      metadata.voiceId ? { ...basePayload, voiceId: metadata.voiceId } : basePayload,
    );

    return c.json({
      success: true,
      payload,
    });
  } catch (error) {
    return c.json(
      {
        success: false,
        error: "Config generation failed",
        details: error instanceof Error ? error.message : "Unknown error",
      },
      500,
    );
  }
};
