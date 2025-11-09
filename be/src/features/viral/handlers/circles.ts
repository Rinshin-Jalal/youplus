/**
 * Accountability Circles - Shared accountability with friends
 *
 * This module handles the social accountability feature where users can
 * opt into sharing their progress with friends who also use You+.
 *
 * Key Features:
 * - Create private circles (3-10 friends)
 * - Granular privacy controls (streak, trust score, call status)
 * - Weekly summary reports
 * - No detailed data sharing (respects privacy)
 * - Opt-in/opt-out at any time
 *
 * Privacy Levels:
 * - Streak only: Just show current streak count
 * - Trust score: Show trust percentage
 * - Call status: Show ✅/❌ for last call
 *
 * Unlocked at: 3 referral sign-ups
 *
 * Viral Mechanics:
 * - Social proof (seeing friends' progress)
 * - FOMO (wanting to catch up)
 * - Movement feeling (we're in this together)
 * - Respectful privacy (not invasive)
 */

import { Context } from "hono";
import { createSupabaseClient } from "@/features/core/utils/database";
import { Env } from "@/index";
import { getAuthenticatedUserId } from "@/middleware/auth";

/**
 * Create a new accountability circle
 *
 * POST /api/viral/circles/create
 *
 * Body:
 * {
 *   name?: string,  // Optional circle name
 * }
 */
export const createAccountabilityCircle = async (c: Context) => {
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Check if user has unlocked circles feature (3+ referrals)
    const { data: referralCount } = await supabase
      .from("referrals")
      .select("id", { count: 'exact' })
      .eq("referrer_user_id", authenticatedUserId)
      .in("status", ['signed_up', 'active_7_days', 'active_30_days']);

    if ((referralCount?.length || 0) < 3) {
      return c.json({
        error: "Accountability circles require 3 referrals",
        required_referrals: 3,
        current_referrals: referralCount?.length || 0,
      }, 403);
    }

    const body = await c.req.json();
    const { name } = body;

    // Create circle
    const { data: circle, error: circleError } = await supabase
      .from("accountability_circles")
      .insert({
        created_by: authenticatedUserId,
        name: name || "My Circle",
        is_active: true,
      })
      .select()
      .single();

    if (circleError) {
      console.error("Error creating circle:", circleError);
      return c.json({ error: "Failed to create circle" }, 500);
    }

    // Add creator as first member
    const { data: membership, error: memberError } = await supabase
      .from("circle_members")
      .insert({
        circle_id: circle.id,
        user_id: authenticatedUserId,
        share_streak: true,
        share_trust_score: false,
        share_call_status: false,
        is_active: true,
      })
      .select()
      .single();

    if (memberError) {
      console.error("Error adding circle member:", memberError);
      return c.json({ error: "Failed to add member" }, 500);
    }

    return c.json({
      success: true,
      circle,
      membership,
    });
  } catch (error) {
    console.error("Error in createAccountabilityCircle:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Get accountability circles for a user
 *
 * GET /api/viral/circles/:userId
 *
 * Returns circles the user created or is a member of
 */
export const getAccountabilityCircles = async (c: Context) => {
  const userId = c.req.param("userId");
  const authenticatedUserId = getAuthenticatedUserId(c);

  if (userId !== authenticatedUserId) {
    return c.json({ error: "Access denied" }, 403);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Get circles where user is a member
    const { data: memberships, error } = await supabase
      .from("circle_members")
      .select(`
        *,
        accountability_circles (*)
      `)
      .eq("user_id", userId)
      .eq("is_active", true);

    if (error) {
      console.error("Error fetching circles:", error);
      return c.json({ error: "Failed to fetch circles" }, 500);
    }

    // For each circle, get member count and stats
    const circlesWithStats = await Promise.all(
      (memberships || []).map(async (membership: any) => {
        const circle = membership.accountability_circles;

        // Get member count
        const { data: members } = await supabase
          .from("circle_members")
          .select("user_id", { count: 'exact' })
          .eq("circle_id", circle.id)
          .eq("is_active", true);

        return {
          circle,
          membership: {
            share_streak: membership.share_streak,
            share_trust_score: membership.share_trust_score,
            share_call_status: membership.share_call_status,
            joined_at: membership.joined_at,
          },
          member_count: members?.length || 0,
        };
      })
    );

    return c.json({
      success: true,
      circles: circlesWithStats,
    });
  } catch (error) {
    console.error("Error in getAccountabilityCircles:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Invite someone to an accountability circle
 *
 * POST /api/viral/circles/invite
 *
 * Body:
 * {
 *   circle_id: string,
 *   invited_user_id: string,
 * }
 */
export const inviteToCircle = async (c: Context) => {
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const body = await c.req.json();
    const { circle_id, invited_user_id } = body;

    if (!circle_id || !invited_user_id) {
      return c.json({ error: "Missing required fields" }, 400);
    }

    // Verify circle exists and user is a member
    const { data: membership } = await supabase
      .from("circle_members")
      .select("*")
      .eq("circle_id", circle_id)
      .eq("user_id", authenticatedUserId)
      .eq("is_active", true)
      .single();

    if (!membership) {
      return c.json({ error: "Not a member of this circle" }, 403);
    }

    // Check if invited user exists
    const { data: invitedUser } = await supabase
      .from("users")
      .select("id")
      .eq("id", invited_user_id)
      .single();

    if (!invitedUser) {
      return c.json({ error: "Invited user not found" }, 404);
    }

    // Check if already a member
    const { data: existingMembership } = await supabase
      .from("circle_members")
      .select("*")
      .eq("circle_id", circle_id)
      .eq("user_id", invited_user_id)
      .single();

    if (existingMembership?.is_active) {
      return c.json({ error: "User is already a member" }, 400);
    }

    // Add invited user to circle (with default privacy settings)
    const { data, error } = await supabase
      .from("circle_members")
      .insert({
        circle_id,
        user_id: invited_user_id,
        share_streak: true,
        share_trust_score: false,
        share_call_status: false,
        is_active: true,
      })
      .select()
      .single();

    if (error) {
      console.error("Error inviting to circle:", error);
      return c.json({ error: "Failed to invite user" }, 500);
    }

    return c.json({
      success: true,
      membership: data,
    });
  } catch (error) {
    console.error("Error in inviteToCircle:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Update privacy settings for a circle
 *
 * PUT /api/viral/circles/privacy/:circleId
 *
 * Body:
 * {
 *   share_streak?: boolean,
 *   share_trust_score?: boolean,
 *   share_call_status?: boolean
 * }
 */
export const updateCirclePrivacy = async (c: Context) => {
  const circleId = c.req.param("circleId");
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const body = await c.req.json();
    const { share_streak, share_trust_score, share_call_status } = body;

    // Verify user is a member
    const { data: membership } = await supabase
      .from("circle_members")
      .select("*")
      .eq("circle_id", circleId)
      .eq("user_id", authenticatedUserId)
      .eq("is_active", true)
      .single();

    if (!membership) {
      return c.json({ error: "Not a member of this circle" }, 403);
    }

    // Build update object
    const updates: any = {};
    if (typeof share_streak === "boolean") updates.share_streak = share_streak;
    if (typeof share_trust_score === "boolean") updates.share_trust_score = share_trust_score;
    if (typeof share_call_status === "boolean") updates.share_call_status = share_call_status;

    if (Object.keys(updates).length === 0) {
      return c.json({ error: "No valid fields to update" }, 400);
    }

    // Update privacy settings
    const { data, error } = await supabase
      .from("circle_members")
      .update(updates)
      .eq("circle_id", circleId)
      .eq("user_id", authenticatedUserId)
      .select()
      .single();

    if (error) {
      console.error("Error updating privacy:", error);
      return c.json({ error: "Failed to update privacy" }, 500);
    }

    return c.json({
      success: true,
      membership: data,
    });
  } catch (error) {
    console.error("Error in updateCirclePrivacy:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Get circle stats (for members only)
 *
 * GET /api/viral/circles/stats/:circleId
 *
 * Returns aggregate stats for circle members based on their privacy settings
 */
export const getCircleStats = async (c: Context) => {
  const circleId = c.req.param("circleId");
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Verify user is a member
    const { data: membership } = await supabase
      .from("circle_members")
      .select("*")
      .eq("circle_id", circleId)
      .eq("user_id", authenticatedUserId)
      .eq("is_active", true)
      .single();

    if (!membership) {
      return c.json({ error: "Not a member of this circle" }, 403);
    }

    // Get all active members with their privacy settings
    const { data: members, error } = await supabase
      .from("circle_members")
      .select("*")
      .eq("circle_id", circleId)
      .eq("is_active", true);

    if (error) {
      console.error("Error fetching members:", error);
      return c.json({ error: "Failed to fetch members" }, 500);
    }

    // For each member, get their stats based on privacy settings
    const memberStats = await Promise.all(
      (members || []).map(async (member: any) => {
        const stats: any = {
          user_id: member.user_id,
        };

        // Get user's identity status
        const { data: identityStatus } = await supabase
          .from("identity_status")
          .select("current_streak_days")
          .eq("user_id", member.user_id)
          .single();

        // Add stats based on privacy settings
        if (member.share_streak) {
          stats.streak_days = identityStatus?.current_streak_days || 0;
        }

        if (member.share_trust_score) {
          // Calculate trust score
          const { data: promisesData } = await supabase
            .from("promises")
            .select("completed")
            .eq("user_id", member.user_id);

          const total = promisesData?.length || 0;
          const completed = promisesData?.filter((p: any) => p.completed).length || 0;
          stats.trust_score = total > 0 ? Math.round((completed / total) * 100) : 0;
        }

        if (member.share_call_status) {
          // Get last call status
          const { data: lastCall } = await supabase
            .from("calls")
            .select("status")
            .eq("user_id", member.user_id)
            .order("created_at", { ascending: false })
            .limit(1)
            .single();

          stats.last_call_status = lastCall?.status || null;
        }

        return stats;
      })
    );

    // Calculate circle aggregates
    const circleAggregates = {
      total_members: memberStats.length,
      avg_streak: memberStats
        .filter((m: any) => m.streak_days !== undefined)
        .reduce((sum: number, m: any) => sum + m.streak_days, 0) /
        Math.max(memberStats.filter((m: any) => m.streak_days !== undefined).length, 1),
      active_this_week: memberStats.filter((m: any) =>
        m.last_call_status === 'completed' || m.streak_days > 0
      ).length,
    };

    return c.json({
      success: true,
      member_stats: memberStats,
      circle_aggregates: circleAggregates,
    });
  } catch (error) {
    console.error("Error in getCircleStats:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};
