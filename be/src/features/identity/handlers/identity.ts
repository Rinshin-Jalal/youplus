/**
 * Identity System - Current identity management and evolution tracking
 *
 * This module provides comprehensive identity management for the BIG BRUH accountability
 * system. It handles the user's current identity, psychological profile, performance
 * tracking, and behavioral statistics. The identity system is central to creating
 * personalized accountability experiences.
 *
 * Key Features:
 * - Current identity management with 60+ psychological data points
 * - Trust percentage and streak tracking
 * - Promise performance analytics
 * - Voice clip management for emotional impact
 * - Performance statistics and trending analysis
 * - Final oath and commitment tracking
 *
 * Psychological Components:
 * - Identity Name: The persona the user wants to become
 * - Fear Version: Who they're afraid of becoming
 * - Desired Outcome: Their transformation goal
 * - Key Sacrifice: What they must give up
 * - Identity Oath: Their sacred commitment
 * - Enforcement Tone: How they want accountability
 *
 * Data Flow:
 * 1. User creates/updates identity during onboarding
 * 2. System tracks performance against identity goals
 * 3. Trust percentage adjusts based on promise-keeping
 * 4. Voice clips provide emotional connection to commitments
 * 5. Statistics drive behavioral insights and interventions
 */

import { Context } from "hono";
import { createSupabaseClient } from "@/features/core/utils/database";
import { Env } from "@/index";
import { getAuthenticatedUserId } from "@/middleware/auth";
import { Identity, IdentityStatus } from "@/types/database";

/**
 * Get current identity with status and statistics
 *
 * This endpoint provides a complete identity profile including psychological
 * data, performance metrics, voice clips, and call statistics. It serves as
 * the central hub for identity-related information and accountability tracking.
 *
 * Features:
 * - Complete identity profile with 60+ psychological fields
 * - Trust percentage and streak tracking
 * - Promise performance analytics
 * - Voice clip management
 * - Call statistics and success rates
 * - Days active since identity creation
 *
 * @param c Hono context with userId parameter
 * @returns JSON response with complete identity data and statistics
 */
export const getCurrentIdentity = async (c: Context) => {
  const userId = c.req.param("userId");
  const authenticatedUserId = getAuthenticatedUserId(c);

  // Security: Users can only access their own identity
  // This ensures privacy and prevents unauthorized access to personal identity data
  if (userId !== authenticatedUserId) {
    return c.json({ error: "Access denied" }, 403);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Step 1: Get current identity with all psychological data
    // This includes identity name, summary, fears, goals, and commitments
    const { data: identity, error: identityError } = await supabase
      .from("identity")
      .select("*")
      .eq("user_id", userId)
      .single();

    if (identityError) {
      return c.json({ error: "Identity not found" }, 404);
    }

    // Step 2: Get identity status for performance tracking
    // This includes trust percentage, streak days, and promise counts
    const { data: identityStatus, error: statusError } = await supabase
      .from("identity_status")
      .select("*")
      .eq("user_id", userId)
      .single();

    // Step 2.5: Get user data for timezone and call window if next_call_timestamp is null
    let nextCallTimestamp = identityStatus?.next_call_timestamp;

    if (!nextCallTimestamp) {
      const { data: userData } = await supabase
        .from("users")
        .select("timezone, call_window_start, call_window_timezone")
        .eq("id", userId)
        .single();

      console.log(`🔍 User data for ${userId}: call_window_start=${userData?.call_window_start}, timezone=${userData?.timezone}, call_window_timezone=${userData?.call_window_timezone}`);

      // Use call_window_start or default to 20:00 (8 PM)
      const callWindowStart = userData?.call_window_start || "20:00";
      const userTimezone = userData?.call_window_timezone || userData?.timezone || "America/New_York";
      console.log(`🔍 User data for ${userId}: call_window_start=${userData?.call_window_start}, timezone=${userData?.timezone}, call_window_timezone=${userData?.call_window_timezone}`);

      const [hours, minutes] = callWindowStart.split(":").map(Number);

      console.log(`⏰ Calculating next call for ${userId}: time=${callWindowStart}, timezone=${userTimezone}`);

      // Get current UTC time
      const nowUTC = new Date();

      // Format current time in user's timezone to get local date/time components
      const formatter = new Intl.DateTimeFormat('en-US', {
        timeZone: userTimezone,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        hour12: false
      });

      const parts = formatter.formatToParts(nowUTC);
      const getPart = (type: string) => parts.find(p => p.type === type)?.value || '';

      const year = parseInt(getPart('year'));
      const month = parseInt(getPart('month'));
      const day = parseInt(getPart('day'));
      const currentHour = parseInt(getPart('hour'));
      const currentMinute = parseInt(getPart('minute'));

      console.log(`📍 Current time in ${userTimezone}: ${year}-${month}-${day} ${currentHour}:${currentMinute}`);

      // Check if the call time has passed today in user's timezone
      const callTimePassed = (currentHour > hours) || (currentHour === hours && currentMinute >= minutes);

      console.log(`🕐 Call time passed? ${callTimePassed} (current: ${currentHour}:${currentMinute}, call: ${hours}:${minutes})`);

      // Determine target date (today or tomorrow)
      const targetDate = new Date(year, month - 1, day);
      if (callTimePassed) {
        targetDate.setDate(targetDate.getDate() + 1);
        console.log(`➡️  Scheduling for tomorrow: ${targetDate.toDateString()}`);
      } else {
        console.log(`➡️  Scheduling for today: ${targetDate.toDateString()}`);
      }

      // Create a date string that represents call time in user's timezone
      // Format: YYYY-MM-DDTHH:MM:SS
      const callDateString = `${targetDate.getFullYear()}-${(targetDate.getMonth() + 1).toString().padStart(2, '0')}-${targetDate.getDate().toString().padStart(2, '0')} ${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:00`;

      // Use toLocaleString to convert from user's timezone to UTC
      // This creates a Date object representing when the call should happen
      const referenceDate = new Date();
      const referenceDateInUserTZ = referenceDate.toLocaleString('en-US', { timeZone: userTimezone });
      const referenceDateInUTC = referenceDate.toLocaleString('en-US', { timeZone: 'UTC' });

      // Calculate offset in milliseconds
      const offsetMs = new Date(referenceDateInUTC).getTime() - new Date(referenceDateInUserTZ).getTime();

      // Create call time as if it were UTC, then apply the timezone offset
      const callTimeAsLocal = new Date(callDateString);
      const callTimeUTC = new Date(callTimeAsLocal.getTime() - offsetMs);

      // Convert to Unix timestamp in seconds
      nextCallTimestamp = Math.floor(callTimeUTC.getTime() / 1000);

      const nextCallDateUTC = new Date(nextCallTimestamp * 1000);
      const nextCallInUserTZ = nextCallDateUTC.toLocaleString('en-US', { timeZone: userTimezone, dateStyle: 'full', timeStyle: 'long' });

      console.log(`📅 Calculated next call timestamp for user ${userId}:`);
      console.log(`   - UTC time: ${nextCallDateUTC.toISOString()}`);
      console.log(`   - User's local time (${userTimezone}): ${nextCallInUserTZ}`);
      console.log(`   - Unix timestamp: ${nextCallTimestamp} seconds`);
      console.log(`   - Time from now: ${Math.floor((nextCallTimestamp * 1000 - Date.now()) / 1000 / 60)} minutes`);
    }

    // Step 3: Calculate days since identity creation
    // This provides context for identity evolution and commitment duration
    const startDate = new Date(identity.created_at);
    const daysActive = Math.floor(
      (new Date().getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)
    );

    // Step 4: Get call statistics for accountability tracking
    // This measures how well the user responds to accountability calls
    const { data: callStats, error: callError } = await supabase
      .from("calls")
      .select("duration_sec")
      .eq("user_id", userId);

    const totalCalls = callStats?.length || 0;
    const answeredCalls =
      callStats?.filter((call) => call.duration_sec > 0).length || 0;
    const successRate =
      totalCalls > 0 ? Math.round((answeredCalls / totalCalls) * 100) : 0;

    // Step 5: Compile comprehensive identity data
    // This combines all identity information into a single response
    const identityData = {
      id: identity.id,
      name: identity.identity_name,
      summary: identity.identity_summary,
      createdAt: identity.created_at,
      updatedAt: identity.updated_at,
      daysActive,
      // Core identity information - psychological foundation
      achievements: identity.achievements,
      failureReasons: identity.failure_reasons,
      singleTruthUserHides: identity.current_struggle,
      fearVersionOfSelf: identity.nightmare_self,
      desiredOutcome: identity.desired_outcome,
      keySacrifice: identity.key_sacrifice,
      identityOath: identity.final_oath,
      lastBrokenPromise: identity.last_broken_promise,
      // Status information - performance tracking
      trustPercentage: identityStatus?.trust_percentage || 100,
      currentStreakDays: identityStatus?.current_streak_days || 0,
      promisesMadeCount: identityStatus?.promises_made_count || 0,
      promisesBrokenCount: identityStatus?.promises_broken_count || 0,
      nextCallTimestamp: nextCallTimestamp,
      statusSummary: identityStatus?.status_summary || null,

      // Call statistics - accountability performance
      stats: {
        totalCalls,
        answeredCalls,
        successRate,
        longestStreak: identityStatus?.current_streak_days || 0,
      },
    };

    return c.json({
      success: true,
      data: identityData,
    });
  } catch (error) {
    console.error("Identity fetch failed:", error);
    return c.json(
      {
        error: "Failed to fetch identity",
        details: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
};

/**
 * Update current identity
 *
 * This endpoint allows updating the user's identity profile with new
 * psychological data, commitments, and behavioral insights. It supports
 * the full range of identity fields for comprehensive personalization.
 *
 * Identity Fields Updated:
 * - Core identity: name, summary, oath
 * - Psychological insights: fears, truths, desired outcomes
 * - Behavioral patterns: slip moments, derail triggers
 * - Accountability preferences: enforcement tone, non-negotiables
 * - Commitment tracking: final oath, external judgment
 *
 * @param c Hono context with identity data in request body
 * @returns JSON response confirming identity update
 */
export const updateIdentity = async (c: Context) => {
  const userId = getAuthenticatedUserId(c);
  const identityData = await c.req.json();

  if (!identityData || typeof identityData !== "object") {
    return c.json({ error: "Identity data required" }, 400);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Update the identity record with comprehensive psychological data
    // This supports all 60+ identity fields for deep personalization
    const { data: updatedIdentity, error: updateError } = await supabase
      .from("identity")
      .update({
        identity_name: identityData.identity_name,
        identity_summary: identityData.identity_summary,
        current_struggle: identityData.single_truth_user_hides,
        nightmare_self: identityData.fear_version_of_self,
        desired_outcome: identityData.desired_outcome,
        key_sacrifice: identityData.key_sacrifice,
        final_oath: identityData.identity_oath,
        last_broken_promise: identityData.last_broken_promise,
        most_common_slip_moment: identityData.most_common_slip_moment,
        // derail_trigger field removed in BIGBRUH schema migration
        daily_non_negotiable: identityData.daily_non_negotiable,
        enforcement_tone: identityData.enforcement_tone,
        external_judgment: identityData.external_judgment,
        regret_if_no_change: identityData.regret_if_no_change,
        updated_at: new Date().toISOString(),
      })
      .eq("user_id", userId)
      .select()
      .single();

    if (updateError) throw updateError;

    console.log(`🆔 Identity updated for user ${userId}`);

    return c.json({
      success: true,
      data: updatedIdentity,
      message: "Identity updated successfully",
    });
  } catch (error) {
    console.error("Identity update failed:", error);
    return c.json(
      {
        error: "Failed to update identity",
        details: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
};

/**
 * Update identity status (trust, streak, promises)
 *
 * This endpoint manages the performance tracking aspects of identity,
 * including trust percentage, current streak, and promise statistics.
 * It uses upsert to handle both creation and updates seamlessly.
 *
 * Status Components:
 * - Trust Percentage: Psychological pressure mechanism (0-100%)
 * - Current Streak: Consecutive days of promise-keeping
 * - Promise Counts: Made vs broken promises for accountability
 * - Last Updated: Timestamp for tracking changes
 *
 * @param c Hono context with status data in request body
 * @returns JSON response confirming status update
 */
export const updateIdentityStatus = async (c: Context) => {
  const userId = getAuthenticatedUserId(c);
  const {
    trustPercentage,
    currentStreakDays,
    promisesMadeCount,
    promisesBrokenCount,
  } = await c.req.json();

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Update identity status using upsert for seamless creation/update
    // This ensures the status record exists and is always current
    const { data: updatedStatus, error: statusError } = await supabase
      .from("identity_status")
      .upsert(
        {
          user_id: userId,
          trust_percentage: trustPercentage,
          current_streak_days: currentStreakDays,
          promises_made_count: promisesMadeCount,
          promises_broken_count: promisesBrokenCount,
          last_updated: new Date().toISOString(),
        },
        { onConflict: "user_id" }
      )
      .select()
      .single();

    if (statusError) throw statusError;

    console.log(`📊 Identity status updated for user ${userId}`);

    return c.json({
      success: true,
      data: updatedStatus,
      message: "Identity status updated successfully",
    });
  } catch (error) {
    console.error("Identity status update failed:", error);
    return c.json(
      {
        error: "Failed to update identity status",
        details: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
};

/**
 * Update identity final oath
 *
 * This endpoint allows users to record their final, binding oath
 * that represents their ultimate commitment to their identity transformation.
 * The final oath serves as the most powerful psychological anchor.
 *
 * Final Oath Psychology:
 * - Represents the ultimate commitment
 * - Creates maximum psychological pressure
 * - Serves as the final line of accountability
 * - Cannot be broken without severe psychological cost
 *
 * @param c Hono context with final oath in request body
 * @returns JSON response confirming oath recording
 */
export const updateFinalOath = async (c: Context) => {
  const userId = getAuthenticatedUserId(c);
  const { finalOath } = await c.req.json();

  if (!finalOath || typeof finalOath !== "string") {
    return c.json({ error: "Final oath required" }, 400);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Update final oath in identity - ultimate commitment
    // This represents the user's most binding promise to themselves
    const { data: updatedIdentity, error: updateError } = await supabase
      .from("identity")
      .update({
        final_oath: finalOath,
        updated_at: new Date().toISOString(),
      })
      .eq("user_id", userId)
      .select()
      .single();

    if (updateError) throw updateError;

    console.log(`💬 Final oath updated for user ${userId}`);

    return c.json({
      success: true,
      data: updatedIdentity,
      message: "Final oath recorded",
    });
  } catch (error) {
    console.error("Final oath update failed:", error);
    return c.json(
      {
        error: "Failed to update final oath",
        details: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
};

/**
 * Get identity performance statistics
 *
 * This endpoint provides comprehensive performance analytics for the user's
 * identity journey. It calculates success rates, trends, and behavioral
 * insights to drive accountability and motivation.
 *
 * Performance Metrics:
 * - Days Active: Time since identity creation
 * - Trust Percentage: Current psychological pressure level
 * - Promise Success Rate: Kept vs broken promises
 * - Call Answer Rate: Responsiveness to accountability
 * - Performance Trending: Excellent/Good/Needs Improvement
 * - Consistency Score: Streak-based reliability measure
 *
 * @param c Hono context with userId parameter
 * @returns JSON response with comprehensive performance statistics
 */
export const getIdentityStats = async (c: Context) => {
  const userId = c.req.param("userId");
  const authenticatedUserId = getAuthenticatedUserId(c);

  if (userId !== authenticatedUserId) {
    return c.json({ error: "Access denied" }, 403);
  }

  const env = c.env as Env;
  const supabase = createSupabaseClient(env);

  try {
    // Step 1: Get current identity status for performance tracking
    const { data: identityStatus, error: statusError } = await supabase
      .from("identity_status")
      .select("*")
      .eq("user_id", userId)
      .single();

    // Step 2: Get promises statistics for accountability tracking
    const { data: promises } = await supabase
      .from("promises")
      .select("status, created_at")
      .eq("user_id", userId);

    // Step 3: Get calls statistics for responsiveness measurement
    const { data: calls } = await supabase
      .from("calls")
      .select("duration_sec, created_at")
      .eq("user_id", userId);

    if (statusError && statusError.code !== "PGRST116") {
      // Not found is OK
      throw statusError;
    }

    // Step 4: Calculate comprehensive performance metrics
    const totalPromises = promises?.length || 0;
    const keptPromises =
      promises?.filter((p) => p.status === "kept").length || 0;
    const brokenPromises =
      promises?.filter((p) => p.status === "broken").length || 0;
    const successRate =
      totalPromises > 0 ? Math.round((keptPromises / totalPromises) * 100) : 0;

    const totalCalls = calls?.length || 0;
    const answeredCalls = calls?.filter((c) => c.duration_sec > 0).length || 0;
    const callAnswerRate =
      totalCalls > 0 ? Math.round((answeredCalls / totalCalls) * 100) : 0;

    // Step 5: Calculate days since identity creation for context
    const { data: identity } = await supabase
      .from("identity")
      .select("created_at")
      .eq("user_id", userId)
      .single();

    const daysActive = identity
      ? Math.floor(
          (new Date().getTime() - new Date(identity.created_at).getTime()) /
            (1000 * 60 * 60 * 24)
        )
      : 0;

    // Step 6: Return comprehensive performance statistics
    return c.json({
      success: true,
      data: {
        daysActive,
        trustPercentage: identityStatus?.trust_percentage || 100,
        currentStreakDays: identityStatus?.current_streak_days || 0,
        promises: {
          total: totalPromises,
          kept: keptPromises,
          broken: brokenPromises,
          successRate,
        },
        calls: {
          total: totalCalls,
          answered: answeredCalls,
          answerRate: callAnswerRate,
        },
        performance: {
          trending:
            successRate >= 80
              ? "excellent"
              : successRate >= 60
              ? "good"
              : "needs_improvement",
          consistencyScore: identityStatus?.current_streak_days || 0,
        },
      },
    });
  } catch (error) {
    console.error("Identity stats fetch failed:", error);
    return c.json(
      {
        error: "Failed to fetch identity statistics",
        details: error instanceof Error ? error.message : "Unknown error",
      },
      500
    );
  }
};