/**
 * LiveKit API Handler
 * HTTP endpoints for initiating calls and managing LiveKit sessions
 */

import { Context } from "hono";
import { Env } from "@/index";
import { initiateLiveKitCall } from "@/features/livekit/services/call-initiator";
import { generateFullCallConfig } from "@/features/call/services/call-config";
import { CallType } from "@/types/database";
import { createVoipCallPayload } from "@/features/voip/services/payload";

/**
 * POST /api/call/initiate-livekit
 * Initiate a new LiveKit call
 *
 * Body:
 * {
 *   userId: string;
 *   callType: "daily_reckoning";
 * }
 */
export const postInitiateLiveKitCall = async (c: Context) => {
  const env = c.env as Env;

  try {
    const body = await c.req.json();
    const { userId, callType } = body as {
      userId: string;
      callType: CallType;
    };

    if (!userId || !callType) {
      return c.json(
        { error: "Missing required fields: userId, callType" },
        400
      );
    }

    console.log(`📞 Initiating LiveKit call for user ${userId}`);

    // Generate unique call UUID
    const callUUID = crypto.randomUUID();

    // Generate call configuration (tone, prompts, voice, etc.)
    const callConfig = await generateFullCallConfig(env, userId, callType, callUUID);

    // Initiate LiveKit call
    const liveKitResult = await initiateLiveKitCall(env, {
      roomName: `youplus-${userId}-${callUUID}`.toLowerCase(),
      userId,
      callUUID,
      callType,
      mood: callConfig.mood,
      prompts: callConfig.prompts,
      cartesiaVoiceId: callConfig.cartesiaVoiceId,
      supermemoryUserId: callConfig.supermemoryUserId,
      metadata: {
        userContext: callConfig.userContext,
        toneAnalysis: callConfig.toneAnalysis,
      },
    });

    // Create VoIP payload for push notification
    const voipPayload = createVoipCallPayload({
      callUUID,
      userId,
      callType,
      mood: callConfig.mood,
      prompts: callConfig.prompts,
      roomName: liveKitResult.roomName,
      liveKitToken: liveKitResult.token,
      cartesiaVoiceId: callConfig.cartesiaVoiceId,
      supermemoryUserId: callConfig.supermemoryUserId,
      metadata: {
        expiresIn: liveKitResult.expiresIn,
      },
    });

    console.log(`✅ LiveKit call initiated: ${callUUID}`);

    return c.json({
      status: "success",
      callUUID,
      roomName: liveKitResult.roomName,
      token: liveKitResult.token,
      expiresIn: liveKitResult.expiresIn,
      voipPayload,
    });
  } catch (error) {
    console.error("Error initiating LiveKit call:", error);
    return c.json(
      { error: "Failed to initiate call", details: String(error) },
      500
    );
  }
};

/**
 * GET /api/call/livekit/:callUUID
 * Get call status and information
 */
export const getLiveKitCallStatus = async (c: Context) => {
  const env = c.env as Env;
  const callUUID = c.req.param("callUUID");

  try {
    if (!callUUID) {
      return c.json({ error: "Missing callUUID parameter" }, 400);
    }

    console.log(`📞 Getting status for call ${callUUID}`);

    // TODO: Query database for call status
    // For now, return placeholder
    return c.json({
      callUUID,
      status: "active", // active, ended, failed
      startedAt: new Date().toISOString(),
      duration: 0,
    });
  } catch (error) {
    console.error("Error getting call status:", error);
    return c.json(
      { error: "Failed to get call status", details: String(error) },
      500
    );
  }
};

/**
 * POST /api/call/livekit/:callUUID/end
 * End a LiveKit call manually
 */
export const postEndLiveKitCall = async (c: Context) => {
  const env = c.env as Env;
  const callUUID = c.req.param("callUUID");

  try {
    if (!callUUID) {
      return c.json({ error: "Missing callUUID parameter" }, 400);
    }

    console.log(`📞 Ending call ${callUUID}`);

    // TODO: Call LiveKit API to remove participants from room
    // LiveKit will automatically clean up the room after empty_timeout

    return c.json({
      status: "success",
      message: `Call ${callUUID} ended`,
    });
  } catch (error) {
    console.error("Error ending call:", error);
    return c.json(
      { error: "Failed to end call", details: String(error) },
      500
    );
  }
};
