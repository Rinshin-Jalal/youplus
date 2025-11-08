/**
 * LiveKit Call Initiator Service
 * Creates LiveKit rooms and initiates agent dispatch
 */

import { Env } from "@/index";
import {
  generateLiveKitToken,
  generateRoomName,
  generateParticipantIdentity,
} from "./token-generator";
import { CallType, UserContext } from "@/types/database";

export interface LiveKitRoomConfig {
  roomName: string;
  userId: string;
  callUUID: string;
  callType: CallType;
  mood: string;
  prompts: {
    systemPrompt: string;
    firstMessage: string;
  };
  cartesiaVoiceId: string;
  supermemoryUserId: string;
  metadata: Record<string, unknown>;
}

export interface LiveKitInitiationResult {
  roomName: string;
  participantIdentity: string;
  token: string;
  expiresIn: number;
  agentDispatchUrl: string;
}

/**
 * Initiate a LiveKit call by creating room and generating access token
 */
export async function initiateLiveKitCall(
  env: Env,
  config: LiveKitRoomConfig
): Promise<LiveKitInitiationResult> {
  try {
    // Generate room and participant identities
    const roomName = generateRoomName(config.userId, config.callUUID);
    const participantIdentity = generateParticipantIdentity(
      config.userId,
      config.callUUID
    );

    // Generate JWT token for iOS client
    const tokenResult = await generateLiveKitToken(
      env,
      {
        userId: config.userId,
        callUUID: config.callUUID,
        roomName: roomName,
        identity: participantIdentity,
        metadata: {
          callType: config.callType,
          mood: config.mood,
        },
      },
      3600 // 1 hour token expiration
    );

    console.log(
      `✅ Generated LiveKit token for call ${config.callUUID} in room ${roomName}`
    );

    // Prepare agent dispatch request
    const agentDispatchUrl = buildAgentDispatchUrl(
      env,
      roomName,
      config
    );

    // In production, you would dispatch the agent here:
    // await dispatchAgent(env, {
    //   roomName,
    //   userId: config.userId,
    //   callUUID: config.callUUID,
    //   ...config
    // });

    return {
      roomName,
      participantIdentity,
      token: tokenResult.token,
      expiresIn: tokenResult.expiresIn,
      agentDispatchUrl,
    };
  } catch (error) {
    console.error("Error initiating LiveKit call:", error);
    throw new Error(`Failed to initiate LiveKit call: ${String(error)}`);
  }
}

/**
 * Build URL for agent dispatch (LiveKit Cloud Agents or self-hosted)
 * This URL would be called to spawn the Python agent in the room
 */
function buildAgentDispatchUrl(
  env: Env,
  roomName: string,
  config: LiveKitRoomConfig
): string {
  const baseUrl = (env.LIVEKIT_AGENTS_DISPATCH_URL as string) ||
    "https://agents.livekit.cloud/dispatch";

  const params = new URLSearchParams({
    room: roomName,
    user_id: config.userId,
    call_type: config.callType,
    mood: config.mood,
    cartesia_voice_id: config.cartesiaVoiceId,
    supermemory_user_id: config.supermemoryUserId,
  });

  return `${baseUrl}?${params.toString()}`;
}

/**
 * Store call session metadata to database
 * Used for tracking and auditing
 */
export async function storeCallSession(
  env: Env,
  userId: string,
  callUUID: string,
  roomName: string,
  metadata: Record<string, unknown>
): Promise<boolean> {
  try {
    // TODO: Insert into livekit_sessions table
    // This is database storage for session tracking
    console.log(`📝 Storing session for call ${callUUID} in room ${roomName}`);
    return true;
  } catch (error) {
    console.error("Error storing call session:", error);
    return false;
  }
}

/**
 * Validate LiveKit Cloud credentials
 */
export async function validateLiveKitCredentials(env: Env): Promise<boolean> {
  const apiKey = env.LIVEKIT_API_KEY as string;
  const apiSecret = env.LIVEKIT_API_SECRET as string;
  const url = env.LIVEKIT_URL as string;

  if (!apiKey || !apiSecret || !url) {
    console.error("Missing required LiveKit credentials");
    return false;
  }

  try {
    // Basic validation - in production, you might call LiveKit API to verify
    console.log("✅ LiveKit credentials validated");
    return true;
  } catch (error) {
    console.error("LiveKit credential validation failed:", error);
    return false;
  }
}
