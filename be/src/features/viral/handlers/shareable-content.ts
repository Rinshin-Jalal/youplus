/**
 * Shareable Content - Algorithm-friendly social media formats
 *
 * This module generates viral-optimized content formats for TikTok/Reels/Stories.
 * Content is primarily generated iOS-side for performance, but metadata is tracked here.
 *
 * Content Types:
 * - countdown: Next call countdown timer
 * - streak: Streak milestone announcements
 * - transformation: Before/after progress
 * - confrontation: Broken promise moments
 * - future_self_reveal: Revealed message moments
 *
 * Viral Mechanics:
 * - 9:16 aspect ratio (optimized for vertical video)
 * - High contrast brand aesthetic
 * - Glitch transitions and effects
 * - Early adopter status display
 * - One-tap sharing
 */

import { Context } from "hono";
import { createSupabaseClient } from "@/features/core/utils/database";
import { Env } from "@/index";
import { getAuthenticatedUserId } from "@/middleware/auth";

/**
 * Generate shareable content metadata
 *
 * POST /api/viral/shareable/generate
 *
 * Body:
 * {
 *   content_type: 'countdown' | 'streak' | 'transformation' | 'confrontation' | 'future_self_reveal',
 *   format: 'image' | 'video',
 *   data_snapshot: object,  // Data needed to regenerate (varies by type)
 *   template_id?: string
 * }
 *
 * Note: Actual image/video generation happens iOS-side for performance.
 * This endpoint tracks metadata for analytics.
 */
export const generateShareableContent = async (c: Context) => {
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const body = await c.req.json();
    const { content_type, format, data_snapshot, template_id, asset_url } = body;

    // Validation
    if (!content_type || !format || !data_snapshot) {
      return c.json({ error: "Missing required fields" }, 400);
    }

    const validTypes = ['countdown', 'streak', 'transformation', 'confrontation', 'future_self_reveal'];
    if (!validTypes.includes(content_type)) {
      return c.json({ error: "Invalid content_type" }, 400);
    }

    const validFormats = ['image', 'video'];
    if (!validFormats.includes(format)) {
      return c.json({ error: "Invalid format" }, 400);
    }

    // Get user's early adopter number for content
    const { data: userData } = await supabase
      .from("users")
      .select("early_adopter_number")
      .eq("id", authenticatedUserId)
      .single();

    // Enhance data snapshot with early adopter number
    const enhanced_snapshot = {
      ...data_snapshot,
      early_adopter_number: userData?.early_adopter_number,
      generated_at: new Date().toISOString(),
    };

    // Create shareable content record
    const { data, error } = await supabase
      .from("shareable_content")
      .insert({
        user_id: authenticatedUserId,
        content_type,
        format,
        data_snapshot: enhanced_snapshot,
        template_id,
        asset_url,
      })
      .select()
      .single();

    if (error) {
      console.error("Error creating shareable content:", error);
      return c.json({ error: "Failed to create content" }, 500);
    }

    return c.json({
      success: true,
      content: data,
    });
  } catch (error) {
    console.error("Error in generateShareableContent:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Get shareable content for a user
 *
 * GET /api/viral/shareable/:userId?type=streak&limit=10
 *
 * Query params:
 * - type: Filter by content_type
 * - limit: Max results (default 20)
 */
export const getShareableContent = async (c: Context) => {
  const userId = c.req.param("userId");
  const authenticatedUserId = getAuthenticatedUserId(c);

  if (userId !== authenticatedUserId) {
    return c.json({ error: "Access denied" }, 403);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const type = c.req.query("type");
    const limit = parseInt(c.req.query("limit") || "20");

    let query = supabase
      .from("shareable_content")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(limit);

    if (type) {
      query = query.eq("content_type", type);
    }

    const { data, error } = await query;

    if (error) {
      console.error("Error fetching shareable content:", error);
      return c.json({ error: "Failed to fetch content" }, 500);
    }

    // Group by type
    const byType = data.reduce((acc, item) => {
      if (!acc[item.content_type]) {
        acc[item.content_type] = [];
      }
      acc[item.content_type].push(item);
      return acc;
    }, {} as Record<string, any[]>);

    return c.json({
      success: true,
      content: data,
      by_type: byType,
      total: data.length,
    });
  } catch (error) {
    console.error("Error in getShareableContent:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Track when content is shared
 *
 * POST /api/viral/shareable/track-share/:contentId
 *
 * Increments share count for analytics
 */
export const trackShare = async (c: Context) => {
  const contentId = c.req.param("contentId");
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Verify ownership
    const { data: content } = await supabase
      .from("shareable_content")
      .select("user_id, share_count")
      .eq("id", contentId)
      .single();

    if (!content || content.user_id !== authenticatedUserId) {
      return c.json({ error: "Access denied" }, 403);
    }

    // Increment share count
    const { data, error } = await supabase
      .from("shareable_content")
      .update({
        shared_count: (content.share_count || 0) + 1,
      })
      .eq("id", contentId)
      .select()
      .single();

    if (error) {
      console.error("Error tracking share:", error);
      return c.json({ error: "Failed to track share" }, 500);
    }

    return c.json({
      success: true,
      content: data,
    });
  } catch (error) {
    console.error("Error in trackShare:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};
