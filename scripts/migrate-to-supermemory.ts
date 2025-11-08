/**
 * Supermemory Data Migration Script
 * Exports user data from Supabase to Supermemory API
 *
 * Migrates:
 * - Promises (daily commitments)
 * - Identity metrics (onboarding profile)
 * - Call history (previous calls & progress)
 *
 * Usage:
 * SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... SUPERMEMORY_API_KEY=... npm run migrate:supermemory
 */

import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";

dotenv.config();

interface SuprememoryMemory {
  user_id: string;
  content: string;
  tags: string[];
  metadata?: Record<string, unknown>;
}

/**
 * Migrate user promises to Supermemory
 */
async function migratePromises(
  supabaseClient: any,
  userId: string,
  supermemoryApiKey: string
): Promise<number> {
  console.log(`📝 Migrating promises for user ${userId}...`);

  try {
    // Fetch all promises for user
    const { data: promises, error } = await supabaseClient
      .from("promises")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false });

    if (error) throw error;

    if (!promises || promises.length === 0) {
      console.log("  No promises found");
      return 0;
    }

    let successCount = 0;

    // Convert each promise to Supermemory memory
    for (const promise of promises) {
      const memory: SuprememoryMemory = {
        user_id: userId,
        content: `Promise: "${promise.promise_text}" - Due: ${promise.due_date} - Status: ${promise.completed ? "✅ Completed" : "⏳ Pending"}`,
        tags: [
          "promise",
          promise.completed ? "completed" : "pending",
          new Date(promise.due_date).getFullYear().toString(),
        ],
        metadata: {
          promise_id: promise.id,
          created_at: promise.created_at,
          completed_at: promise.completed_at,
          original_source: "supabase_promises",
        },
      };

      // Send to Supermemory
      const response = await fetch("https://api.supermemory.ai/v1/memories", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${supermemoryApiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(memory),
      });

      if (response.ok) {
        successCount++;
      } else {
        console.error(
          `  Failed to save promise: ${promise.promise_text}`,
          response.statusText
        );
      }
    }

    console.log(`  ✅ Saved ${successCount}/${promises.length} promises`);
    return successCount;
  } catch (error) {
    console.error("Error migrating promises:", error);
    return 0;
  }
}

/**
 * Migrate user identity/onboarding data to Supermemory
 */
async function migrateIdentity(
  supabaseClient: any,
  userId: string,
  supermemoryApiKey: string
): Promise<number> {
  console.log(`👤 Migrating identity profile for user ${userId}...`);

  try {
    // Fetch identity and status
    const { data: identity, error: identityError } = await supabaseClient
      .from("identity")
      .select("*")
      .eq("user_id", userId)
      .single();

    if (identityError && identityError.code !== "PGRST116") {
      throw identityError;
    }

    if (!identity) {
      console.log("  No identity data found");
      return 0;
    }

    // Fetch identity status
    const { data: status } = await supabaseClient
      .from("identity_status")
      .select("*")
      .eq("user_id", userId)
      .single();

    // Format onboarding context
    const context = identity.onboarding_context || {};

    // Create comprehensive identity memory
    const memory: SuprememoryMemory = {
      user_id: userId,
      content: `Identity Profile - ${identity.name}
Daily Commitment: ${identity.daily_commitment}
Path: ${identity.chosen_path}
Call Time: ${identity.call_time}
Strikes Allowed: ${identity.strike_limit}

Motivation: ${context.motivation_level || "Unknown"}
Goal: ${context.goal || "Unknown"}
Current Streak: ${status?.current_streak_days || 0} days
Total Calls: ${status?.total_calls_completed || 0}

Key Insights:
- Favorite Excuse: ${context.favorite_excuse || "N/A"}
- Witness: ${context.witness || "N/A"}
- Future if No Change: ${context.future_if_no_change || "N/A"}
`,
      tags: [
        "identity",
        "profile",
        "onboarding",
        identity.chosen_path || "unknown",
      ],
      metadata: {
        identity_id: identity.id,
        streak_days: status?.current_streak_days || 0,
        total_calls: status?.total_calls_completed || 0,
        last_call: status?.last_call_at,
        onboarding_context: context,
        original_source: "supabase_identity",
      },
    };

    // Send to Supermemory
    const response = await fetch("https://api.supermemory.ai/v1/memories", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${supermemoryApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(memory),
    });

    if (response.ok) {
      console.log(`  ✅ Saved identity profile`);
      return 1;
    } else {
      console.error("Failed to save identity profile", response.statusText);
      return 0;
    }
  } catch (error) {
    console.error("Error migrating identity:", error);
    return 0;
  }
}

/**
 * Migrate call history to Supermemory
 */
async function migrateCallHistory(
  supabaseClient: any,
  userId: string,
  supermemoryApiKey: string
): Promise<number> {
  console.log(`📞 Migrating call history for user ${userId}...`);

  try {
    // Fetch recent calls
    const { data: calls, error } = await supabaseClient
      .from("calls")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(20); // Only last 20 calls for memory

    if (error) throw error;

    if (!calls || calls.length === 0) {
      console.log("  No call history found");
      return 0;
    }

    let successCount = 0;

    // Group calls by month for summary
    const callsByMonth: Record<string, number> = {};
    let successfulCalls = 0;
    let totalDuration = 0;

    for (const call of calls) {
      const monthKey = new Date(call.created_at)
        .toISOString()
        .slice(0, 7);
      callsByMonth[monthKey] = (callsByMonth[monthKey] || 0) + 1;

      if (call.call_successful === "success") successfulCalls++;
      if (call.duration_sec) totalDuration += call.duration_sec;
    }

    // Create call history summary
    const memory: SuprememoryMemory = {
      user_id: userId,
      content: `Call History Summary
Total Calls: ${calls.length}
Successful: ${successfulCalls}
Success Rate: ${((successfulCalls / calls.length) * 100).toFixed(1)}%
Total Duration: ${(totalDuration / 60).toFixed(0)} minutes

Recent Calls:
${calls
  .slice(0, 5)
  .map(
    (c) =>
      `- ${new Date(c.created_at).toLocaleDateString()}: ${c.call_type} (${c.duration_sec}s) - ${c.call_successful}`
  )
  .join("\n")}

Monthly Activity:
${Object.entries(callsByMonth)
  .map(([month, count]) => `- ${month}: ${count} calls`)
  .join("\n")}
`,
      tags: ["call_history", "progress", "summary"],
      metadata: {
        total_calls: calls.length,
        successful_calls: successfulCalls,
        success_rate: (successfulCalls / calls.length) * 100,
        total_duration_seconds: totalDuration,
        last_call_date: calls[0]?.created_at,
        calls_by_month: callsByMonth,
        original_source: "supabase_calls",
      },
    };

    // Send to Supermemory
    const response = await fetch("https://api.supermemory.ai/v1/memories", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${supermemoryApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(memory),
    });

    if (response.ok) {
      console.log(`  ✅ Saved call history summary`);
      return 1;
    } else {
      console.error("Failed to save call history", response.statusText);
      return 0;
    }
  } catch (error) {
    console.error("Error migrating call history:", error);
    return 0;
  }
}

/**
 * Main migration function
 */
async function migrateUserToSupermemory(
  userId: string,
  supabaseUrl: string,
  supabaseKey: string,
  supermemoryApiKey: string
): Promise<void> {
  console.log(`\n🚀 Starting migration for user ${userId}...\n`);

  // Initialize Supabase
  const supabase = createClient(supabaseUrl, supabaseKey);

  // Verify user exists
  const { data: user } = await supabase
    .from("users")
    .select("id, email")
    .eq("id", userId)
    .single();

  if (!user) {
    console.error(`❌ User ${userId} not found`);
    return;
  }

  console.log(`✅ Found user: ${user.email}`);

  // Migrate data
  let totalMigrated = 0;

  totalMigrated += await migrateIdentity(supabase, userId, supermemoryApiKey);
  totalMigrated += await migratePromises(supabase, userId, supermemoryApiKey);
  totalMigrated += await migrateCallHistory(supabase, userId, supermemoryApiKey);

  console.log(
    `\n✅ Migration complete! Total memories created: ${totalMigrated}`
  );
}

/**
 * Migrate all active users
 */
async function migrateAllUsers(
  supabaseUrl: string,
  supabaseKey: string,
  supermemoryApiKey: string
): Promise<void> {
  console.log("\n🌍 Starting full user migration...\n");

  const supabase = createClient(supabaseUrl, supabaseKey);

  // Fetch all active users
  const { data: users, error } = await supabase
    .from("users")
    .select("id, email, subscription_status")
    .eq("subscription_status", "active");

  if (error) {
    console.error("Failed to fetch users:", error);
    return;
  }

  if (!users || users.length === 0) {
    console.log("No active users found");
    return;
  }

  console.log(`Found ${users.length} active users\n`);

  for (const user of users) {
    await migrateUserToSupermemory(
      user.id,
      supabaseUrl,
      supabaseKey,
      supermemoryApiKey
    );
    // Add delay to avoid rate limiting
    await new Promise((resolve) => setTimeout(resolve, 500));
  }

  console.log("\n🎉 All users migrated!");
}

// Run migration
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supermemoryApiKey = process.env.SUPERMEMORY_API_KEY;
const userId = process.argv[2]; // Optional: specific user ID

if (!supabaseUrl || !supabaseKey || !supermemoryApiKey) {
  console.error(
    "Missing environment variables: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPERMEMORY_API_KEY"
  );
  process.exit(1);
}

if (userId) {
  // Migrate specific user
  migrateUserToSupermemory(
    userId,
    supabaseUrl,
    supabaseKey,
    supermemoryApiKey
  ).catch(console.error);
} else {
  // Migrate all users
  migrateAllUsers(supabaseUrl, supabaseKey, supermemoryApiKey).catch(
    console.error
  );
}
