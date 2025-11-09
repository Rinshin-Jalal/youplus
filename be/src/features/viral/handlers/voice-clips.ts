/**
 * Voice Clip Shares - Shareable voice moments from calls
 *
 * This module handles the creation and sharing of 5-10 second voice clips
 * from accountability calls. These are THE unique differentiator.
 *
 * Key Features:
 * - AI-suggested shareable moments
 * - Explicit user consent required
 * - Waveform visualization data
 * - Auto-generated captions
 * - Privacy controls
 *
 * Clip Types:
 * - question: "Did you do what you said you'd do?"
 * - excuse: User's excuse + AI response
 * - victory: "You kept your word"
 * - pattern: "You've broken this promise 4 times"
 * - future_self: From future self message
 *
 * Viral Mechanics:
 * - Surprising (hearing YOUR voice)
 * - Intrigue ("What app is this??")
 * - Emotional payload
 * - Requires explicit opt-in (respects privacy, increases value)
 */

import { Context } from "hono";
import { createSupabaseClient } from "@/features/core/utils/database";
import { Env } from "@/index";
import { getAuthenticatedUserId } from "@/middleware/auth";

/**
 * Create a voice clip (manually or AI-suggested)
 *
 * POST /api/viral/voice-clips/create
 *
 * Body:
 * {
 *   audio_url: string,
 *   transcript: string,
 *   duration_seconds: number,
 *   clip_type: string,
 *   livekit_session_id?: string,
 *   call_uuid?: string,
 *   ai_suggested?: boolean,
 *   ai_confidence_score?: number,
 *   waveform_data?: object,
 *   caption_text?: string
 * }
 */
export const createVoiceClip = async (c: Context) => {
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const body = await c.req.json();
    const {
      audio_url,
      transcript,
      duration_seconds,
      clip_type,
      livekit_session_id,
      call_uuid,
      ai_suggested,
      ai_confidence_score,
      waveform_data,
      caption_text,
    } = body;

    // Validation
    if (!audio_url || !transcript || !duration_seconds || !clip_type) {
      return c.json({ error: "Missing required fields" }, 400);
    }

    const validTypes = ['question', 'excuse', 'victory', 'pattern', 'future_self', 'custom'];
    if (!validTypes.includes(clip_type)) {
      return c.json({ error: "Invalid clip_type" }, 400);
    }

    if (duration_seconds < 3 || duration_seconds > 15) {
      return c.json({ error: "Duration must be between 3 and 15 seconds" }, 400);
    }

    // Create voice clip
    const { data, error } = await supabase
      .from("voice_clip_shares")
      .insert({
        user_id: authenticatedUserId,
        audio_url,
        transcript,
        duration_seconds,
        clip_type,
        livekit_session_id,
        call_uuid,
        ai_suggested: ai_suggested || false,
        ai_confidence_score,
        waveform_data,
        caption_text,
        share_permission: false,  // Default to false, requires explicit opt-in
      })
      .select()
      .single();

    if (error) {
      console.error("Error creating voice clip:", error);
      return c.json({ error: "Failed to create clip" }, 500);
    }

    return c.json({
      success: true,
      clip: data,
    });
  } catch (error) {
    console.error("Error in createVoiceClip:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Get voice clips for a user
 *
 * GET /api/viral/voice-clips/:userId?type=victory&shareable=true
 *
 * Query params:
 * - type: Filter by clip_type
 * - shareable: Filter by share_permission (true/false)
 * - limit: Max results (default 20)
 */
export const getVoiceClips = async (c: Context) => {
  const userId = c.req.param("userId");
  const authenticatedUserId = getAuthenticatedUserId(c);

  if (userId !== authenticatedUserId) {
    return c.json({ error: "Access denied" }, 403);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const type = c.req.query("type");
    const shareable = c.req.query("shareable");
    const limit = parseInt(c.req.query("limit") || "20");

    let query = supabase
      .from("voice_clip_shares")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(limit);

    if (type) {
      query = query.eq("clip_type", type);
    }

    if (shareable === "true") {
      query = query.eq("share_permission", true);
    } else if (shareable === "false") {
      query = query.eq("share_permission", false);
    }

    const { data, error } = await query;

    if (error) {
      console.error("Error fetching voice clips:", error);
      return c.json({ error: "Failed to fetch clips" }, 500);
    }

    return c.json({
      success: true,
      clips: data,
      total: data.length,
    });
  } catch (error) {
    console.error("Error in getVoiceClips:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Get AI-suggested clips for sharing
 *
 * GET /api/viral/voice-clips/suggested/:userId
 *
 * Returns clips that AI identified as highly shareable
 */
export const getSuggestedClips = async (c: Context) => {
  const userId = c.req.param("userId");
  const authenticatedUserId = getAuthenticatedUserId(c);

  if (userId !== authenticatedUserId) {
    return c.json({ error: "Access denied" }, 403);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Get AI-suggested clips with high confidence that haven't been shared yet
    const { data, error } = await supabase
      .from("voice_clip_shares")
      .select("*")
      .eq("user_id", userId)
      .eq("ai_suggested", true)
      .eq("share_permission", false)
      .gte("ai_confidence_score", 0.7)
      .order("ai_confidence_score", { ascending: false })
      .limit(5);

    if (error) {
      console.error("Error fetching suggested clips:", error);
      return c.json({ error: "Failed to fetch suggested clips" }, 500);
    }

    return c.json({
      success: true,
      suggested_clips: data,
      total: data.length,
    });
  } catch (error) {
    console.error("Error in getSuggestedClips:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Update voice clip share permission
 *
 * PUT /api/viral/voice-clips/permission/:clipId
 *
 * Body:
 * {
 *   share_permission: boolean
 * }
 *
 * Requires explicit user consent before sharing voice clips
 */
export const updateVoiceClipPermission = async (c: Context) => {
  const clipId = c.req.param("clipId");
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const body = await c.req.json();
    const { share_permission } = body;

    if (typeof share_permission !== "boolean") {
      return c.json({ error: "share_permission must be a boolean" }, 400);
    }

    // Verify ownership
    const { data: clip } = await supabase
      .from("voice_clip_shares")
      .select("user_id")
      .eq("id", clipId)
      .single();

    if (!clip || clip.user_id !== authenticatedUserId) {
      return c.json({ error: "Access denied" }, 403);
    }

    // Update permission
    const updateData: any = {
      share_permission,
    };

    // Track when permission was granted
    if (share_permission) {
      updateData.permission_granted_at = new Date().toISOString();
    }

    const { data, error } = await supabase
      .from("voice_clip_shares")
      .update(updateData)
      .eq("id", clipId)
      .select()
      .single();

    if (error) {
      console.error("Error updating voice clip permission:", error);
      return c.json({ error: "Failed to update permission" }, 500);
    }

    // Increment share count if sharing
    if (share_permission) {
      await supabase
        .from("voice_clip_shares")
        .update({
          shared_count: (data.shared_count || 0) + 1,
        })
        .eq("id", clipId);
    }

    return c.json({
      success: true,
      clip: data,
    });
  } catch (error) {
    console.error("Error in updateVoiceClipPermission:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};
