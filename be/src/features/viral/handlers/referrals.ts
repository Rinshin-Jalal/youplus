/**
 * Referrals - "Call Out Your Friends" confrontational referral system
 *
 * This module handles the growth engine: letting users "call out" friends
 * who also need to stop lying to themselves.
 *
 * Key Features:
 * - Confrontational messaging templates
 * - Referral code generation
 * - Status tracking (sent → signed_up → active)
 * - Reward tiers (1, 3, 5, 10, 25 referrals)
 * - Attribution tracking
 *
 * Reward Tiers:
 * - 1: Movement Starter (badge)
 * - 3: Accountability Circle (unlock feature)
 * - 5: Custom Voice Prompts
 * - 10: Founding Member (lifetime priority)
 * - 25: Legendary Caller
 *
 * Viral Mechanics:
 * - Movement positioning ("join us")
 * - Non-monetary rewards (maintains premium)
 * - Confrontational tone (stands out)
 * - Social proof (early adopter number)
 */

import { Context } from "hono";
import { createSupabaseClient } from "@/features/core/utils/database";
import { Env } from "@/index";
import { getAuthenticatedUserId } from "@/middleware/auth";

/**
 * Generate a unique referral code for a user
 */
function generateReferralCode(userId: string): string {
  // Take first 8 chars of user ID + random 4 chars
  const userPart = userId.substring(0, 8).toUpperCase();
  const randomPart = Math.random().toString(36).substring(2, 6).toUpperCase();
  return `YOU${userPart}${randomPart}`;
}

/**
 * Create a new referral
 *
 * POST /api/viral/referrals/create
 *
 * Body:
 * {
 *   referred_email?: string,
 *   referred_phone?: string,
 *   message_template: string,   // 'direct' | 'provocative' | 'movement' | 'custom'
 *   custom_message?: string,
 *   attribution_source: string   // 'sms' | 'email' | 'link' | 'qr_code'
 * }
 */
export const createReferral = async (c: Context) => {
  const authenticatedUserId = getAuthenticatedUserId(c);
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const body = await c.req.json();
    const {
      referred_email,
      referred_phone,
      message_template,
      custom_message,
      attribution_source,
    } = body;

    // Validation
    if (!referred_email && !referred_phone) {
      return c.json({ error: "Must provide either email or phone" }, 400);
    }

    if (!message_template) {
      return c.json({ error: "Message template required" }, 400);
    }

    // Get or create referral code for user
    let { data: user } = await supabase
      .from("users")
      .select("referral_code")
      .eq("id", authenticatedUserId)
      .single();

    let referralCode = user?.referral_code;

    if (!referralCode) {
      // Generate and save referral code
      referralCode = generateReferralCode(authenticatedUserId);

      await supabase
        .from("users")
        .update({ referral_code: referralCode })
        .eq("id", authenticatedUserId);
    }

    // Create referral
    const { data, error } = await supabase
      .from("referrals")
      .insert({
        referrer_user_id: authenticatedUserId,
        referred_email,
        referred_phone,
        referral_code: referralCode,
        message_template,
        custom_message,
        attribution_source,
        status: 'sent',
      })
      .select()
      .single();

    if (error) {
      console.error("Error creating referral:", error);
      return c.json({ error: "Failed to create referral" }, 500);
    }

    return c.json({
      success: true,
      referral: data,
      referral_code: referralCode,
    });
  } catch (error) {
    console.error("Error in createReferral:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Get referral stats for a user
 *
 * GET /api/viral/referrals/stats/:userId
 *
 * Returns referral counts, next reward tier, and progress
 */
export const getReferralStats = async (c: Context) => {
  const userId = c.req.param("userId");
  const authenticatedUserId = getAuthenticatedUserId(c);

  if (userId !== authenticatedUserId) {
    return c.json({ error: "Access denied" }, 403);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Use the helper function from the migration
    const { data, error } = await supabase
      .rpc('get_user_referral_stats', { p_user_id: userId });

    if (error) {
      console.error("Error fetching referral stats:", error);
      return c.json({ error: "Failed to fetch stats" }, 500);
    }

    const stats = data[0];

    // Get recent referrals
    const { data: recentReferrals } = await supabase
      .from("referrals")
      .select("*")
      .eq("referrer_user_id", userId)
      .order("created_at", { ascending: false })
      .limit(10);

    // Get unlocked rewards
    const { data: rewards } = await supabase
      .from("referral_rewards")
      .select("*")
      .eq("user_id", userId)
      .eq("unlocked", true)
      .order("reward_tier", { ascending: true });

    return c.json({
      success: true,
      stats: {
        total_sent: stats.total_sent,
        total_signed_up: stats.total_signed_up,
        total_active: stats.total_active,
        conversion_rate: stats.total_sent > 0
          ? Math.round((stats.total_signed_up / stats.total_sent) * 100)
          : 0,
      },
      next_reward: {
        tier: stats.next_reward_tier,
        type: stats.next_reward_type,
        progress: stats.total_signed_up,
        needed: stats.next_reward_tier,
      },
      recent_referrals: recentReferrals,
      unlocked_rewards: rewards,
    });
  } catch (error) {
    console.error("Error in getReferralStats:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Get user's referral code
 *
 * GET /api/viral/referrals/code/:userId
 *
 * Returns or generates referral code
 */
export const getUserReferralCode = async (c: Context) => {
  const userId = c.req.param("userId");
  const authenticatedUserId = getAuthenticatedUserId(c);

  if (userId !== authenticatedUserId) {
    return c.json({ error: "Access denied" }, 403);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    let { data: user } = await supabase
      .from("users")
      .select("referral_code, early_adopter_number")
      .eq("id", userId)
      .single();

    let referralCode = user?.referral_code;

    if (!referralCode) {
      // Generate and save
      referralCode = generateReferralCode(userId);

      await supabase
        .from("users")
        .update({ referral_code: referralCode })
        .eq("id", userId);
    }

    return c.json({
      success: true,
      referral_code: referralCode,
      early_adopter_number: user?.early_adopter_number,
      share_url: `https://youplus.app/join?ref=${referralCode}`,
    });
  } catch (error) {
    console.error("Error in getUserReferralCode:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Validate a referral code (public endpoint for signup)
 *
 * POST /api/viral/referrals/validate
 *
 * Body:
 * {
 *   referral_code: string
 * }
 */
export const validateReferralCode = async (c: Context) => {
  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    const body = await c.req.json();
    const { referral_code } = body;

    if (!referral_code) {
      return c.json({ error: "Referral code required" }, 400);
    }

    // Find user with this referral code
    const { data: user, error } = await supabase
      .from("users")
      .select("id, email, early_adopter_number")
      .eq("referral_code", referral_code)
      .single();

    if (error || !user) {
      return c.json({
        success: false,
        valid: false,
        error: "Invalid referral code",
      }, 404);
    }

    return c.json({
      success: true,
      valid: true,
      referrer_id: user.id,
      early_adopter_number: user.early_adopter_number,
    });
  } catch (error) {
    console.error("Error in validateReferralCode:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};

/**
 * Get referral rewards for a user
 *
 * GET /api/viral/referrals/rewards/:userId
 *
 * Returns all rewards (locked and unlocked) with progress
 */
export const getReferralRewards = async (c: Context) => {
  const userId = c.req.param("userId");
  const authenticatedUserId = getAuthenticatedUserId(c);

  if (userId !== authenticatedUserId) {
    return c.json({ error: "Access denied" }, 403);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Get current referral count
    const { data: referralCount } = await supabase
      .from("referrals")
      .select("id", { count: 'exact' })
      .eq("referrer_user_id", userId)
      .in("status", ['signed_up', 'active_7_days', 'active_30_days']);

    const signedUpCount = referralCount?.length || 0;

    // Define all reward tiers
    const allRewards = [
      { tier: 1, type: 'movement_starter', name: 'Movement Starter', description: 'Badge + early adopter display' },
      { tier: 3, type: 'accountability_circle', name: 'Accountability Circle', description: 'Unlock circles feature' },
      { tier: 5, type: 'custom_voice_prompts', name: 'Custom Voice Prompts', description: 'Personalize call questions' },
      { tier: 10, type: 'founding_member', name: 'Founding Member', description: 'Lifetime priority features' },
      { tier: 25, type: 'legendary_caller', name: 'Legendary Caller', description: 'Elite status + exclusive features' },
    ];

    // Get unlocked rewards from DB
    const { data: unlockedRewards } = await supabase
      .from("referral_rewards")
      .select("*")
      .eq("user_id", userId);

    const unlockedTypes = new Set(unlockedRewards?.map(r => r.reward_type) || []);

    // Build response with lock status
    const rewards = allRewards.map(reward => ({
      ...reward,
      unlocked: signedUpCount >= reward.tier,
      progress: signedUpCount,
      is_in_db: unlockedTypes.has(reward.type),
    }));

    return c.json({
      success: true,
      current_referrals: signedUpCount,
      rewards,
    });
  } catch (error) {
    console.error("Error in getReferralRewards:", error);
    return c.json({ error: "Internal server error" }, 500);
  }
};
