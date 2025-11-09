/**
 * Future Self Messages - Record messages to your future self
 *
 * This module handles the emotional core of viral shareability: recording messages
 * to your future self and revealing them after a chosen duration (30/60/90/180 days).
 *
 * Key Features:
 * - Record voice messages with transcription
 * - User-chosen reveal dates
 * - Context snapshot at recording time (streak, trust, promises)
 * - Shareable reveal moments
 * - Push notifications for reveals
 *
 * Viral Mechanics:
 * - High emotional payload (confronting past self)
 * - Before/after comparison
 * - Creates anticipation with countdown
 * - Shareable transformation moment
 */

import { Context } from "hono";
import { createSupabaseClient } from "@/features/core/utils/database";
import { Env } from "@/index";
import { getAuthenticatedUserId } from "@/middleware/auth";

/**
 * Create a new future self message
 *
 * POST /api/viral/future-self/create
 *
 * Body:
 * {
 *   audio_url: string,           // R2 URL where audio is stored
 *   transcript?: string,          // Auto-transcribed
 *   user_prompt: string,          // What question they answered
 *   reveal_duration_days: 30 | 60 | 90 | 180
 * }
 */
export const createFutureSelfMessage = async (c: Context) => {
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const body = await c.req.json();
    const { audio_url, transcript, user_prompt, reveal_duration_days } = body;

    // Validation
    if (!audio_url || !reveal_duration_days) {
      return c.json({ error: "Missing required fields" }, 400);
    }

    if (![30, 60, 90, 180].includes(reveal_duration_days)) {
      return c.json({ error: "Invalid reveal duration. Must be 30, 60, 90, or 180 days" }, 400);
    }

    // Calculate reveal date
    const reveal_at = new Date();
    reveal_at.setDate(reveal_at.getDate() + reveal_duration_days);

    // Get current context for comparison on reveal
    const { data: identityStatus } = await supabase
      .from("identity_status")
      .select("current_streak_days")
      .eq("user_id", authenticatedUserId)
      .single();

    const { data: promisesData } = await supabase
      .from("promises")
      .select("completed")
      .eq("user_id", authenticatedUserId);

    const totalPromises = promisesData?.length || 0;
    const completedPromises = promisesData?.filter(p => p.completed).length || 0;
    const trustScore = totalPromises > 0 ? Math.round((completedPromises / totalPromises) * 100) : 0;

    const context_snapshot = {
      streak_days: identityStatus?.current_streak_days || 0,
      trust_score: trustScore,
      promises_kept: completedPromises,
      total_promises: totalPromises,
      recorded_at: new Date().toISOString(),
    };

    // Create future self message
    const { data, error } = await supabase
      .from("future_self_messages")
      .insert({
        user_id: authenticatedUserId,
        audio_url,
        transcript,
        user_prompt,
        reveal_duration_days,
        reveal_at: reveal_at.toISOString(),
        context_snapshot,
      })
      .select()
      .single();

    if (error) {
      console.error("Error creating future self message:", error);
      return c.json({ error: "Failed to create message" }, 500);
    }

    return c.json({
      success: true,
      message: data,
      reveal_at: reveal_at.toISOString(),
    });
  } catch (error) {
    console.error("Error in createFutureSelfMessage:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Get all future self messages for a user
 *
 * GET /api/viral/future-self/:userId
 *
 * Returns both revealed and unrevealed messages
 */
export const getFutureSelfMessages = async (c: Context) => {
  const userId = c.req.param("userId");
  const authenticatedUserId = getAuthenticatedUserId(c);

  if (userId !== authenticatedUserId) {
    return c.json({ error: "Access denied" }, 403);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const { data, error } = await supabase
      .from("future_self_messages")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false });

    if (error) {
      console.error("Error fetching future self messages:", error);
      return c.json({ error: "Failed to fetch messages" }, 500);
    }

    // Separate revealed and unrevealed
    const revealed = data.filter(m => m.revealed);
    const unrevealed = data.filter(m => !m.revealed);

    return c.json({
      success: true,
      revealed,
      unrevealed,
      total: data.length,
    });
  } catch (error) {
    console.error("Error in getFutureSelfMessages:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Reveal a future self message
 *
 * POST /api/viral/future-self/reveal/:messageId
 *
 * Marks message as revealed and returns current context for comparison
 */
export const revealFutureSelfMessage = async (c: Context) => {
  const messageId = c.req.param("messageId");
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Get message
    const { data: message, error: fetchError } = await supabase
      .from("future_self_messages")
      .select("*")
      .eq("id", messageId)
      .single();

    if (fetchError || !message) {
      return c.json({ error: "Message not found" }, 404);
    }

    // Security check
    if (message.user_id !== authenticatedUserId) {
      return c.json({ error: "Access denied" }, 403);
    }

    // Check if already revealed
    if (message.revealed) {
      return c.json({
        success: true,
        message,
        already_revealed: true,
      });
    }

    // Check if it's time to reveal (allow early reveal if within 24 hours)
    const revealDate = new Date(message.reveal_at);
    const now = new Date();
    const hoursDiff = (now.getTime() - revealDate.getTime()) / (1000 * 60 * 60);

    if (hoursDiff < -24) {
      return c.json({
        error: "Too early to reveal",
        reveal_at: message.reveal_at,
        hours_remaining: Math.abs(hoursDiff),
      }, 400);
    }

    // Get current context for comparison
    const { data: identityStatus } = await supabase
      .from("identity_status")
      .select("current_streak_days")
      .eq("user_id", authenticatedUserId)
      .single();

    const { data: promisesData } = await supabase
      .from("promises")
      .select("completed")
      .eq("user_id", authenticatedUserId);

    const totalPromises = promisesData?.length || 0;
    const completedPromises = promisesData?.filter(p => p.completed).length || 0;
    const currentTrustScore = totalPromises > 0 ? Math.round((completedPromises / totalPromises) * 100) : 0;

    const current_context = {
      streak_days: identityStatus?.current_streak_days || 0,
      trust_score: currentTrustScore,
      promises_kept: completedPromises,
      total_promises: totalPromises,
      revealed_at: now.toISOString(),
    };

    // Mark as revealed
    const { data: updatedMessage, error: updateError } = await supabase
      .from("future_self_messages")
      .update({
        revealed: true,
        revealed_at: now.toISOString(),
      })
      .eq("id", messageId)
      .select()
      .single();

    if (updateError) {
      console.error("Error marking message as revealed:", updateError);
      return c.json({ error: "Failed to reveal message" }, 500);
    }

    // Calculate improvements
    const then = message.context_snapshot;
    const improvements = {
      streak_change: current_context.streak_days - (then.streak_days || 0),
      trust_change: current_context.trust_score - (then.trust_score || 0),
      promises_change: current_context.promises_kept - (then.promises_kept || 0),
    };

    return c.json({
      success: true,
      message: updatedMessage,
      then: message.context_snapshot,
      now: current_context,
      improvements,
    });
  } catch (error) {
    console.error("Error in revealFutureSelfMessage:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Update share permission for a message
 *
 * PUT /api/viral/future-self/share/:messageId
 *
 * Body:
 * {
 *   share_permission: boolean
 * }
 */
export const updateSharePermission = async (c: Context) => {
  const messageId = c.req.param("messageId");
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const body = await c.req.json();
    const { share_permission } = body;

    if (typeof share_permission !== "boolean") {
      return c.json({ error: "share_permission must be a boolean" }, 400);
    }

    // Security: verify ownership
    const { data: message } = await supabase
      .from("future_self_messages")
      .select("user_id")
      .eq("id", messageId)
      .single();

    if (!message || message.user_id !== authenticatedUserId) {
      return c.json({ error: "Access denied" }, 403);
    }

    // Update permission
    const { data, error } = await supabase
      .from("future_self_messages")
      .update({ share_permission })
      .eq("id", messageId)
      .select()
      .single();

    if (error) {
      console.error("Error updating share permission:", error);
      return c.json({ error: "Failed to update permission" }, 500);
    }

    // Increment share count if sharing
    if (share_permission) {
      await supabase
        .from("future_self_messages")
        .update({
          share_count: (data.share_count || 0) + 1,
        })
        .eq("id", messageId);
    }

    return c.json({
      success: true,
      message: data,
    });
  } catch (error) {
    console.error("Error in updateSharePermission:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};
