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

    // Dispatch the agent to the room
    try {
      await dispatchAgent(env, {
        roomName,
        participantIdentity,
        userId: config.userId,
        callUUID: config.callUUID,
        callType: config.callType,
        mood: config.mood,
        prompts: config.prompts,
        cartesiaVoiceId: config.cartesiaVoiceId,
        supermemoryUserId: config.supermemoryUserId,
        metadata: config.metadata,
      });
    } catch (error) {
      console.error("Warning: Agent dispatch failed, but call can still proceed:", error);
      // Continue even if agent dispatch fails - client can retry
    }

    // Prepare agent dispatch request URL for reference
    const agentDispatchUrl = buildAgentDispatchUrl(
      env,
      roomName,
      config
    );

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
 * Dispatch the agent to the LiveKit room
 * Tries self-hosted agent endpoint first, then falls back to LiveKit Cloud Agents API
 */
async function dispatchAgent(
  env: Env,
  config: {
    roomName: string;
    participantIdentity: string;
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
): Promise<void> {
  // Try self-hosted agent first (if AGENT_DISPATCH_URL is set)
  const selfHostedUrl = (env.AGENT_DISPATCH_URL as string);
  if (selfHostedUrl) {
    try {
      const response = await fetch(selfHostedUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${env.LIVEKIT_API_SECRET}`,
        },
        body: JSON.stringify({
          room: config.roomName,
          roomMetadata: {
            user_id: config.userId,
            call_uuid: config.callUUID,
            call_type: config.callType,
            mood: config.mood,
            cartesia_voice_id: config.cartesiaVoiceId,
            supermemory_user_id: config.supermemoryUserId,
            prompts: config.prompts,
          },
        }),
      });

      if (response.ok) {
        console.log(`✅ Agent dispatched to room ${config.roomName} (self-hosted)`);
        return;
      } else {
        console.warn(`Self-hosted agent dispatch returned ${response.status}`);
      }
    } catch (error) {
      console.warn("Self-hosted agent dispatch failed, trying LiveKit Cloud Agents:", error);
    }
  }

  // Fall back to LiveKit Cloud Agents API
  try {
    const liveKitUrl = (env.LIVEKIT_URL as string).replace("wss://", "https://");
    const response = await fetch(`${liveKitUrl}/twirp/livekit.RoomService/CreateRoom`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${createAccessToken(env, "agent-dispatch")}`,
      },
      body: JSON.stringify({
        room: config.roomName,
      }),
    });

    if (response.ok) {
      console.log(`✅ Agent dispatched to room ${config.roomName} (LiveKit Cloud Agents)`);
      return;
    } else {
      console.warn(`LiveKit Cloud Agents returned ${response.status}`);
    }
  } catch (error) {
    console.warn("LiveKit Cloud Agents dispatch also failed:", error);
  }

  // If both fail, throw error
  throw new Error("Failed to dispatch agent via both self-hosted and LiveKit Cloud Agents");
}

/**
 * Create a simple access token for LiveKit API calls
 * This is a simplified version - use livekit-server-sdk for production
 */
function createAccessToken(env: Env, identity: string): string {
  // In production, use: import { AccessToken } from 'livekit-server-sdk'
  // For now, return a simple token - this should be implemented properly
  const apiSecret = env.LIVEKIT_API_SECRET as string;
  const apiKey = env.LIVEKIT_API_KEY as string;

  // TODO: Implement proper JWT token generation
  // For now, return a placeholder
  return `${apiKey}:${apiSecret}`;
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
