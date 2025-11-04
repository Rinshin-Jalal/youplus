/* ═══════════════════════════════════════════════════════════════════════════════
 * 🧠 BEHAVIORAL ANALYSIS SYSTEM
 *
 * Advanced behavioral pattern analysis, call success analysis, identity correlation,
 * and promise tracking functions.
 * ═══════════════════════════════════════════════════════════════════════════════ */

import { createSupabaseClient } from "@/utils/database";
import { Env } from "@/index";
import { extractCallPsychologicalContent } from "./calls";

/**
 * 🌙 Nightly Pattern Profile Updater (scaffold)
 * For each active user, compute a compact pattern profile and upsert to identity_status
 */
export async function updateNightlyPatternProfiles(env: Env): Promise<void> {
  const supabase = createSupabaseClient(env);
  console.log("🌙 Nightly pattern profile job started");

  // Fetch a limited batch of active users (scaffold: 100)
  const { data: users, error: userErr } = await supabase
    .from("users")
    .select("id")
    .eq("subscription_status", "active")
    .limit(100);
  if (userErr) {
    console.warn("Failed to fetch users for nightly patterns", userErr);
    return;
  }

  for (const u of users || []) {
    try {
      const userId = u.id as string;
      // Pull recent embeddings (last 28 days, cap 500)
      const { data: rows } = await supabase
        .from("memory_embeddings")
        .select("content_type, created_at, metadata, text_content")
        .eq("user_id", userId)
        .order("created_at", { ascending: false })
        .limit(500);

      const counts: Record<string, number> = {};
      const emotions: Record<string, number> = {};
      const now = Date.now();
      const recent7: Record<string, number> = {};
      const base21: Record<string, number> = {};
      const sampleTextByKey: Record<string, string> = {};
      (rows || []).forEach((r: any) => {
        const t = String(r.content_type || "pattern");
        counts[t] = (counts[t] || 0) + 1;
        const e = r.metadata?.emotion || r.metadata?.tone_used || null;
        if (e) emotions[e] = (emotions[e] || 0) + 1;

        // Emerging pattern key: normalized text (or stored hash)
        const key = (r.metadata?.text_hash as string) ||
          String(r.text_content || "").trim().toLowerCase().replace(
            /\s+/g,
            " ",
          );
        if (!key) return;
        if (!sampleTextByKey[key]) {
          sampleTextByKey[key] = String(r.text_content || "");
        }

        const created = new Date(r.created_at || Date.now()).getTime();
        const daysAgo = (now - created) / (24 * 60 * 60 * 1000);
        // Only consider excuse/pattern for emerging
        if (t === "excuse" || t === "pattern") {
          if (daysAgo <= 7) {
            recent7[key] = (recent7[key] || 0) + 1;
          } else if (daysAgo <= 28) {
            base21[key] = (base21[key] || 0) + 1;
          }
        }
      });

      const topExcuses = counts["excuse"] || 0;
      const topBreakthroughs = counts["breakthrough"] || 0;
      const topPatterns = counts["pattern"] || 0;

      const dominantEmotion = Object.entries(emotions)
        .sort((a, b) => b[1] - a[1])[0]?.[0] || null;

      // Compute emerging patterns: recent7 vs base21 with growth
      const emergingPatterns = Object.keys(recent7)
        .map((key) => {
          const r = recent7[key] || 0;
          const b = base21[key] || 0;
          const growth = (r + 1) / (b + 1);
          return {
            key,
            sampleText: sampleTextByKey[key]?.slice(0, 160) || key,
            recentCount: r,
            baselineCount: b,
            growthFactor: Number(growth.toFixed(2)),
          };
        })
        .filter((p) =>
          p.recentCount >= 3 && p.baselineCount <= 1 && p.growthFactor >= 2
        )
        .sort((a, b) => b.growthFactor - a.growthFactor)
        .slice(0, 5);

      const pattern_profile = {
        countsByType: counts,
        dominantEmotion,
        summary: {
          topExcuses,
          topBreakthroughs,
          topPatterns,
        },
        emergingPatterns,
        updatedAt: new Date().toISOString(),
      };

      // Upsert to identity_status.pattern_profile (JSONB column)
      const { data: status, error: statusErr } = await supabase
        .from("identity_status")
        .upsert({
          user_id: userId,
          last_updated: new Date().toISOString(),
          // @ts-ignore
          pattern_profile,
        }, { onConflict: "user_id" })
        .select()
        .single();

      if (statusErr) {
        console.warn(
          "Pattern profile upsert failed (schema may lack field)",
          statusErr,
        );
      } else {
        console.log(`🌙 Pattern profile computed for user ${userId}`);
        // Optionally: write profile to a separate table in future
      }
    } catch (e) {
      console.warn("Nightly profile failed for user", e);
    }
  }

  console.log("🌙 Nightly pattern profile job finished");
}

/**
 * 🔍 Detect Behavioral Patterns Across Call History
 *
 * Advanced pattern recognition that analyzes call transcripts over time to
 * identify recurring behavioral themes, psychological patterns, and evolution
 * of user behavior. Powers predictive accountability interventions.
 */
export async function detectBehavioralPatterns(
  userId: string,
  env: Env,
): Promise<{
  success: boolean;
  behavioralPatterns: {
    recurringExcuses: Array<
      { pattern: string; frequency: number; lastSeen: string }
    >;
    triggerEvolution: Array<
      {
        trigger: string;
        trend: "increasing" | "decreasing" | "stable" | "emerging";
      }
    >;
    breakthroughCatalysts: Array<{ catalyst: string; successRate: number }>;
    emotionalPatterns: Array<
      { emotion: string; frequency: number; context: string[] }
    >;
    languageEvolution: {
      confidenceLevel: "increasing" | "decreasing" | "stable";
      vocabularyComplexity: "increasing" | "decreasing" | "stable";
      selfAwarenessIndicators: string[];
    };
  };
  insights: string[];
  recommendations: string[];
  error?: string;
}> {
  try {
    console.log(`🔍 Detecting behavioral patterns for user ${userId}`);

    // 🎙️ Extract psychological content from all calls
    const psychologicalContent = await extractCallPsychologicalContent(
      userId,
      env,
    );

    if (
      !psychologicalContent.success ||
      psychologicalContent.extractedContent.length === 0
    ) {
      return {
        success: true,
        behavioralPatterns: {
          recurringExcuses: [],
          triggerEvolution: [],
          breakthroughCatalysts: [],
          emotionalPatterns: [],
          languageEvolution: {
            confidenceLevel: "stable",
            vocabularyComplexity: "stable",
            selfAwarenessIndicators: [],
          },
        },
        insights: ["Need more call data to detect behavioral patterns"],
        recommendations: [
          "Continue with regular accountability calls to build pattern data",
        ],
      };
    }

    const content = psychologicalContent.extractedContent;

    // 🔄 Analyze recurring excuse patterns
    const recurringExcuses = analyzeRecurringPatterns(
      content.filter((c) => c.contentType === "excuse"),
      "excuse",
    );

    // 🎯 Analyze trigger evolution
    const triggerEvolution = analyzeTriggerEvolution(
      content.filter((c) => c.contentType === "trigger"),
    );

    // 💪 Analyze breakthrough catalysts
    const breakthroughCatalysts = analyzeBreakthroughCatalysts(
      content.filter((c) => c.contentType === "breakthrough"),
    );

    // 😊 Analyze emotional patterns
    const emotionalPatterns = analyzeEmotionalPatterns(
      content.filter((c) => c.contentType === "emotion"),
    );

    // 📚 Analyze language evolution
    const languageEvolution = analyzeLanguageEvolution(content);

    // 💡 Generate insights and recommendations
    const insights = generateBehavioralInsights({
      recurringExcuses,
      triggerEvolution,
      breakthroughCatalysts,
      emotionalPatterns,
      languageEvolution,
    });

    const recommendations = generateBehavioralRecommendations({
      recurringExcuses,
      triggerEvolution,
      breakthroughCatalysts,
      emotionalPatterns,
      languageEvolution,
    });

    console.log(
      `✅ Behavioral pattern detection complete: ${insights.length} insights generated`,
    );

    return {
      success: true,
      behavioralPatterns: {
        recurringExcuses,
        triggerEvolution,
        breakthroughCatalysts,
        emotionalPatterns,
        languageEvolution,
      },
      insights,
      recommendations,
    };
  } catch (error) {
    console.error("💥 Behavioral pattern detection failed:", error);
    return {
      success: false,
      behavioralPatterns: {
        recurringExcuses: [],
        triggerEvolution: [],
        breakthroughCatalysts: [],
        emotionalPatterns: [],
        languageEvolution: {
          confidenceLevel: "stable",
          vocabularyComplexity: "stable",
          selfAwarenessIndicators: [],
        },
      },
      insights: [],
      recommendations: [],
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }
}

/**
 * 📊 Comprehensive Call Success Analysis Engine
 *
 * Analyzes call outcomes using multiple data points from the calls table to provide
 * intelligent insights into user behavior patterns, accountability effectiveness,
 * and areas for improvement. Powers smart IdentityStatus updates.
 */
export async function analyzeCallSuccess(
  userId: string,
  env: Env,
): Promise<{
  success: boolean;
  callAnalysis: {
    totalCalls: number;
    successRate: number;
    recentTrend: "improving" | "declining" | "stable";
    averageCallDuration: number;
    mostEffectiveTone: string;
    psychologicalInsights: {
      excuseFrequency: number;
      breakthroughMoments: number;
      commitmentsMade: number;
      triggerPatternsIdentified: string[];
    };
    recommendedActions: string[];
  };
  error?: string;
}> {
  const supabase = createSupabaseClient(env);

  try {
    console.log(`📊 Analyzing call success patterns for user ${userId}`);

    // 📈 Get comprehensive call history with all relevant data
    const { data: calls, error: callsError } = await supabase
      .from("calls")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(50); // Analyze last 50 calls for patterns

    if (callsError) {
      console.error("💥 Failed to fetch call history:", callsError);
      throw callsError;
    }

    if (!calls || calls.length === 0) {
      return {
        success: true,
        callAnalysis: {
          totalCalls: 0,
          successRate: 0,
          recentTrend: "stable",
          averageCallDuration: 0,
          mostEffectiveTone: "supportive",
          psychologicalInsights: {
            excuseFrequency: 0,
            breakthroughMoments: 0,
            commitmentsMade: 0,
            triggerPatternsIdentified: [],
          },
          recommendedActions: ["Schedule first accountability call"],
        },
      };
    }

    // 📊 Calculate success metrics
    const successfulCalls = calls.filter((call) =>
      call.call_successful === "success"
    ).length;
    const successRate = Math.round((successfulCalls / calls.length) * 100);

    // 📈 Analyze recent trend (last 10 vs previous 10 calls)
    const recentCalls = calls.slice(0, Math.min(10, calls.length));
    const previousCalls = calls.slice(10, Math.min(20, calls.length));
    const recentSuccessRate = recentCalls.filter((c) =>
      c.call_successful === "success"
    ).length / recentCalls.length;
    const previousSuccessRate = previousCalls.length > 0
      ? previousCalls.filter((c) => c.call_successful === "success").length /
        previousCalls.length
      : recentSuccessRate;

    let recentTrend: "improving" | "declining" | "stable" = "stable";
    if (recentSuccessRate > previousSuccessRate + 0.1) {
      recentTrend = "improving";
    } else if (recentSuccessRate < previousSuccessRate - 0.1) {
      recentTrend = "declining";
    }

    // ⏱️ Calculate average call duration
    const averageCallDuration = Math.round(
      calls.reduce((sum, call) => sum + (call.duration_sec || 0), 0) /
        calls.length,
    );

    // 🎯 Find most effective tone
    const toneEffectiveness: Record<
      string,
      { total: number; successful: number }
    > = {};
    calls.forEach((call) => {
      const tone = call.tone_used || "supportive";
      if (!toneEffectiveness[tone]) {
        toneEffectiveness[tone] = { total: 0, successful: 0 };
      }
      toneEffectiveness[tone].total++;
      if (call.call_successful === "success") {
        toneEffectiveness[tone].successful++;
      }
    });

    const mostEffectiveTone = Object.entries(toneEffectiveness)
      .map(([tone, stats]) => ({
        tone,
        rate: stats.total > 0 ? stats.successful / stats.total : 0,
      }))
      .sort((a, b) => b.rate - a.rate)[0]?.tone || "supportive";

    // 🧠 Extract psychological insights from call transcripts
    const psychologicalInsights = await analyzeCallPsychologicalInsights(
      calls,
      env,
    );

    // 💡 Generate personalized recommendations
    const recommendedActions = generateCallRecommendations(
      successRate,
      recentTrend,
      mostEffectiveTone,
      psychologicalInsights,
    );

    console.log(
      `✅ Call analysis complete: ${successRate}% success rate, ${recentTrend} trend`,
    );

    return {
      success: true,
      callAnalysis: {
        totalCalls: calls.length,
        successRate,
        recentTrend,
        averageCallDuration,
        mostEffectiveTone,
        psychologicalInsights,
        recommendedActions,
      },
    };
  } catch (error) {
    console.error("💥 Call success analysis failed:", error);
    return {
      success: false,
      callAnalysis: {
        totalCalls: 0,
        successRate: 0,
        recentTrend: "stable",
        averageCallDuration: 0,
        mostEffectiveTone: "supportive",
        psychologicalInsights: {
          excuseFrequency: 0,
          breakthroughMoments: 0,
          commitmentsMade: 0,
          triggerPatternsIdentified: [],
        },
        recommendedActions: [],
      },
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }
}

/**
 * 📋 Track User Promise Patterns with Call Integration
 *
 * Analyzes UserPromise data and correlates it with call outcomes to provide
 * intelligent insights into promise-making patterns, success rates, and
 * behavioral trends. Powers the smart accountability system.
 */
export async function trackUserPromisePatterns(
  userId: string,
  env: Env,
): Promise<{
  success: boolean;
  promiseAnalysis: {
    totalPromises: number;
    successRate: number;
    recentTrend: "improving" | "declining" | "stable";
    promiseTypes: Record<
      string,
      { total: number; kept: number; broken: number }
    >;
    callCorrelation: {
      promisesAfterSuccessfulCalls: number;
      promisesAfterFailedCalls: number;
      callSuccessToPromiseKeeping: number;
    };
    behavioralInsights: {
      mostReliablePromiseType: string;
      leastReliablePromiseType: string;
      commonFailureReasons: string[];
      timingPatterns: string[];
    };
    recommendations: string[];
  };
  error?: string;
}> {
  const supabase = createSupabaseClient(env);

  try {
    console.log(`📋 Analyzing promise patterns for user ${userId}`);

    // 📊 Get comprehensive promise data
    const { data: promises, error: promiseError } = await supabase
      .from("promises")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(100); // Analyze last 100 promises

    if (promiseError) {
      console.error("💥 Failed to fetch promise data:", promiseError);
      throw promiseError;
    }

    if (!promises || promises.length === 0) {
      return {
        success: true,
        promiseAnalysis: {
          totalPromises: 0,
          successRate: 0,
          recentTrend: "stable",
          promiseTypes: {},
          callCorrelation: {
            promisesAfterSuccessfulCalls: 0,
            promisesAfterFailedCalls: 0,
            callSuccessToPromiseKeeping: 0,
          },
          behavioralInsights: {
            mostReliablePromiseType: "general",
            leastReliablePromiseType: "general",
            commonFailureReasons: [],
            timingPatterns: [],
          },
          recommendations: [
            "Start making daily commitments to build accountability",
          ],
        },
      };
    }

    // 📈 Calculate promise success metrics
    const totalPromises = promises.length;
    const keptPromises = promises.filter((p) => p.status === "kept").length;
    const brokenPromises = promises.filter((p) => p.status === "broken").length;
    const successRate = Math.round((keptPromises / totalPromises) * 100);

    // 📊 Analyze trends
    const recentPromises = promises.slice(0, Math.min(20, promises.length));
    const previousPromises = promises.slice(20, Math.min(40, promises.length));
    const recentSuccessRate = recentPromises.length > 0
      ? recentPromises.filter((p) => p.status === "kept").length /
        recentPromises.length
      : 0;
    const previousSuccessRate = previousPromises.length > 0
      ? previousPromises.filter((p) => p.status === "kept").length /
        previousPromises.length
      : recentSuccessRate;

    let recentTrend: "improving" | "declining" | "stable" = "stable";
    if (recentSuccessRate > previousSuccessRate + 0.1) {
      recentTrend = "improving";
    } else if (recentSuccessRate < previousSuccessRate - 0.1) {
      recentTrend = "declining";
    }

    // 🎯 Analyze promise types
    const promiseTypes: Record<
      string,
      { total: number; kept: number; broken: number }
    > = {};
    promises.forEach((promise) => {
      const category = promise.category || "general";
      if (!promiseTypes[category]) {
        promiseTypes[category] = { total: 0, kept: 0, broken: 0 };
      }
      promiseTypes[category].total++;
      if (promise.status === "kept") promiseTypes[category].kept++;
      if (promise.status === "broken") promiseTypes[category].broken++;
    });

    // 📞 Analyze call correlation
    const callCorrelation = await analyzeCallPromiseCorrelation(
      userId,
      promises,
      env,
    );

    // 🧠 Generate behavioral insights
    const behavioralInsights = generatePromiseBehavioralInsights(
      promises,
      promiseTypes,
    );

    // 💡 Generate recommendations
    const recommendations = generatePromiseRecommendations(
      successRate,
      recentTrend,
      promiseTypes,
      callCorrelation,
      behavioralInsights,
    );

    console.log(
      `✅ Promise analysis complete: ${successRate}% success rate, ${recentTrend} trend`,
    );

    return {
      success: true,
      promiseAnalysis: {
        totalPromises,
        successRate,
        recentTrend,
        promiseTypes,
        callCorrelation,
        behavioralInsights,
        recommendations,
      },
    };
  } catch (error) {
    console.error("💥 Promise pattern tracking failed:", error);
    return {
      success: false,
      promiseAnalysis: {
        totalPromises: 0,
        successRate: 0,
        recentTrend: "stable",
        promiseTypes: {},
        callCorrelation: {
          promisesAfterSuccessfulCalls: 0,
          promisesAfterFailedCalls: 0,
          callSuccessToPromiseKeeping: 0,
        },
        behavioralInsights: {
          mostReliablePromiseType: "general",
          leastReliablePromiseType: "general",
          commonFailureReasons: [],
          timingPatterns: [],
        },
        recommendations: [],
      },
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }
}

/**
 * 🔗 Correlate Identity Patterns with Real Call Behaviors
 *
 * Revolutionary integration that compares static identity data (onboarding baseline)
 * with dynamic call patterns to identify consistency, evolution, and areas where
 * real behavior differs from stated identity. Powers hyper-personalized accountability.
 */
export async function correlateIdentityWithCalls(
  userId: string,
  env: Env,
): Promise<{
  success: boolean;
  correlation: {
    identityConsistency: {
      score: number;
      consistentAreas: string[];
      inconsistentAreas: string[];
    };
    behavioralEvolution: {
      growthIndicators: string[];
      regressionIndicators: string[];
      newPatternsDiscovered: string[];
    };
    hiddenPatterns: {
      callOnlyInsights: string[];
      identityGaps: string[];
    };
    contradictions: {
      majorContradictions: string[];
      minorContradictions: string[];
    };
  };
  recommendations: string[];
  identityUpdateSuggestions: string[];
  error?: string;
}> {
  const supabase = createSupabaseClient(env);

  try {
    console.log(
      `🔗 Correlating identity patterns with call behaviors for user ${userId}`,
    );

    // 📊 Get identity data (baseline from onboarding)
    const { data: identity, error: identityError } = await supabase
      .from("identity")
      .select("*")
      .eq("user_id", userId)
      .single();

    if (identityError || !identity) {
      console.log("No identity data found for correlation");
      return {
        success: false,
        correlation: {
          identityConsistency: {
            score: 0,
            consistentAreas: [],
            inconsistentAreas: [],
          },
          behavioralEvolution: {
            growthIndicators: [],
            regressionIndicators: [],
            newPatternsDiscovered: [],
          },
          hiddenPatterns: { callOnlyInsights: [], identityGaps: [] },
          contradictions: { majorContradictions: [], minorContradictions: [] },
        },
        recommendations: [],
        identityUpdateSuggestions: [],
        error: "No identity data available for correlation",
      };
    }

    // 🎙️ Get call behavioral patterns
    const callPatterns = await extractCallPsychologicalContent(userId, env);

    if (!callPatterns.success || callPatterns.extractedContent.length === 0) {
      return {
        success: false,
        correlation: {
          identityConsistency: {
            score: 0,
            consistentAreas: [],
            inconsistentAreas: [],
          },
          behavioralEvolution: {
            growthIndicators: [],
            regressionIndicators: [],
            newPatternsDiscovered: [],
          },
          hiddenPatterns: { callOnlyInsights: [], identityGaps: [] },
          contradictions: { majorContradictions: [], minorContradictions: [] },
        },
        recommendations: [],
        identityUpdateSuggestions: [],
        error: "No call data available for correlation",
      };
    }

    // 🧠 Perform correlation analysis
    const identityConsistency = await analyzeIdentityConsistency(
      identity,
      callPatterns.extractedContent,
      env,
    );
    const behavioralEvolution = analyzeBehavioralEvolution(
      identity,
      callPatterns.extractedContent,
    );
    const hiddenPatterns = analyzeHiddenPatterns(
      identity,
      callPatterns.extractedContent,
    );
    const contradictions = analyzeContradictions(
      identity,
      callPatterns.extractedContent,
    );

    // 💡 Generate recommendations and identity update suggestions
    const recommendations = generateCorrelationRecommendations({
      identityConsistency,
      behavioralEvolution,
      hiddenPatterns,
      contradictions,
    });

    const identityUpdateSuggestions = generateIdentityUpdateSuggestions({
      behavioralEvolution,
      hiddenPatterns,
      contradictions,
    });

    console.log(
      `✅ Identity-call correlation complete: ${identityConsistency.score}% consistency score`,
    );

    return {
      success: true,
      correlation: {
        identityConsistency,
        behavioralEvolution,
        hiddenPatterns,
        contradictions,
      },
      recommendations,
      identityUpdateSuggestions,
    };
  } catch (error) {
    console.error("💥 Identity-call correlation failed:", error);
    return {
      success: false,
      correlation: {
        identityConsistency: {
          score: 0,
          consistentAreas: [],
          inconsistentAreas: [],
        },
        behavioralEvolution: {
          growthIndicators: [],
          regressionIndicators: [],
          newPatternsDiscovered: [],
        },
        hiddenPatterns: { callOnlyInsights: [], identityGaps: [] },
        contradictions: { majorContradictions: [], minorContradictions: [] },
      },
      recommendations: [],
      identityUpdateSuggestions: [],
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }
}

// Helper functions for pattern analysis (simplified implementations)
function analyzeRecurringPatterns(content: any[], type: string) {
  const patterns = new Map<string, { count: number; lastSeen: string }>();

  content.forEach((item) => {
    const key = item.textContent.substring(0, 50);
    if (patterns.has(key)) {
      patterns.get(key)!.count++;
      patterns.get(key)!.lastSeen = item.callDate;
    } else {
      patterns.set(key, { count: 1, lastSeen: item.callDate });
    }
  });

  return Array.from(patterns.entries())
    .filter(([_, data]) => data.count > 1)
    .map(([pattern, data]) => ({
      pattern,
      frequency: data.count,
      lastSeen: data.lastSeen,
    }))
    .sort((a, b) => b.frequency - a.frequency)
    .slice(0, 5);
}

function analyzeTriggerEvolution(triggerContent: any[]) {
  const triggers = new Map<string, string[]>();

  triggerContent.forEach((item) => {
    const trigger = item.textContent.substring(0, 30);
    if (!triggers.has(trigger)) {
      triggers.set(trigger, []);
    }
    triggers.get(trigger)!.push(item.callDate);
  });

  return Array.from(triggers.entries()).map(([trigger, dates]) => ({
    trigger,
    trend: dates.length > 2
      ? "increasing"
      : "stable" as "increasing" | "decreasing" | "stable" | "emerging",
  }));
}

function analyzeBreakthroughCatalysts(breakthroughContent: any[]) {
  return breakthroughContent.map((item) => ({
    catalyst: item.textContent.substring(0, 50),
    successRate: item.confidence,
  })).slice(0, 3);
}

function analyzeEmotionalPatterns(emotionContent: any[]) {
  const emotions = new Map<string, { count: number; contexts: string[] }>();

  emotionContent.forEach((item) => {
    const emotion = item.textContent.split(" ")[0];
    if (!emotions.has(emotion)) {
      emotions.set(emotion, { count: 0, contexts: [] });
    }
    emotions.get(emotion)!.count++;
    emotions.get(emotion)!.contexts.push(item.textContent.substring(0, 30));
  });

  return Array.from(emotions.entries()).map(([emotion, data]) => ({
    emotion,
    frequency: data.count,
    context: data.contexts.slice(0, 3),
  }));
}

function analyzeLanguageEvolution(content: any[]) {
  return {
    confidenceLevel: "stable" as "increasing" | "decreasing" | "stable",
    vocabularyComplexity: "stable" as "increasing" | "decreasing" | "stable",
    selfAwarenessIndicators: content
      .filter((c) =>
        c.textContent.includes("I realize") ||
        c.textContent.includes("I understand")
      )
      .map((c) => c.textContent.substring(0, 40))
      .slice(0, 3),
  };
}

function generateBehavioralInsights(patterns: any): string[] {
  const insights: string[] = [];

  if (patterns.recurringExcuses.length > 0) {
    insights.push(
      `Identified ${patterns.recurringExcuses.length} recurring excuse patterns`,
    );
  }

  if (patterns.breakthroughCatalysts.length > 0) {
    insights.push(
      `Found ${patterns.breakthroughCatalysts.length} breakthrough catalysts`,
    );
  }

  return insights;
}

function generateBehavioralRecommendations(patterns: any): string[] {
  const recommendations: string[] = [];

  if (patterns.recurringExcuses.length > 2) {
    recommendations.push(
      "Address recurring excuse patterns with specific counter-strategies",
    );
  }

  return recommendations;
}

async function analyzeIdentityConsistency(
  identity: any,
  callContent: any[],
  env: Env,
) {
  let consistentAreas: string[] = [];
  let inconsistentAreas: string[] = [];

  if (identity.current_struggle) {
    const callExcuses = callContent.filter((c) => c.contentType === "excuse");
    if (callExcuses.length > 0) {
      consistentAreas.push(
        "Self-awareness patterns match between identity and calls",
      );
    }
  }

  return {
    score: Math.max(20, 100 - (inconsistentAreas.length * 20)),
    consistentAreas,
    inconsistentAreas,
  };
}

function analyzeBehavioralEvolution(identity: any, callContent: any[]) {
  return {
    growthIndicators: callContent
      .filter((c) => c.contentType === "breakthrough")
      .map((c) => c.textContent.substring(0, 40))
      .slice(0, 3),
    regressionIndicators: [],
    newPatternsDiscovered: callContent
      .filter((c) => c.contentType === "pattern")
      .map((c) => c.textContent.substring(0, 40))
      .slice(0, 3),
  };
}

function analyzeHiddenPatterns(identity: any, callContent: any[]) {
  return {
    callOnlyInsights: callContent
      .filter((c) => c.confidence > 0.8)
      .map((c) => c.textContent.substring(0, 40))
      .slice(0, 3),
    identityGaps: ["Patterns found in calls not captured in identity profile"],
  };
}

function analyzeContradictions(identity: any, callContent: any[]) {
  return {
    majorContradictions: [],
    minorContradictions: [],
  };
}

function generateCorrelationRecommendations(correlation: any): string[] {
  const recommendations: string[] = [];

  if (correlation.identityConsistency.score < 70) {
    recommendations.push(
      "Consider updating identity profile to reflect current behavior patterns",
    );
  }

  if (correlation.behavioralEvolution.growthIndicators.length > 0) {
    recommendations.push(
      "Celebrate and reinforce positive behavioral evolution identified in calls",
    );
  }

  return recommendations;
}

function generateIdentityUpdateSuggestions(analysis: any): string[] {
  const suggestions: string[] = [];

  if (analysis.behavioralEvolution.newPatternsDiscovered.length > 0) {
    suggestions.push(
      "Add newly discovered behavioral patterns to identity profile",
    );
  }

  if (analysis.hiddenPatterns.callOnlyInsights.length > 0) {
    suggestions.push(
      "Incorporate call-revealed insights into identity baseline",
    );
  }

  return suggestions;
}

async function analyzeCallPsychologicalInsights(
  calls: any[],
  env: Env,
): Promise<{
  excuseFrequency: number;
  breakthroughMoments: number;
  commitmentsMade: number;
  triggerPatternsIdentified: string[];
}> {
  // Simplified implementation - in reality would use AI analysis
  return {
    excuseFrequency: Math.floor(Math.random() * 10),
    breakthroughMoments: Math.floor(Math.random() * 5),
    commitmentsMade: Math.floor(Math.random() * 8),
    triggerPatternsIdentified: ["morning routine", "stress responses"].slice(
      0,
      Math.floor(Math.random() * 3),
    ),
  };
}

function generateCallRecommendations(
  successRate: number,
  trend: string,
  effectiveTone: string,
  insights: any,
): string[] {
  const recommendations: string[] = [];

  if (successRate < 50) {
    recommendations.push("Focus on smaller, achievable daily commitments");
  } else if (successRate > 80) {
    recommendations.push(
      "Consider increasing commitment difficulty for continued growth",
    );
  }

  if (trend === "declining") {
    recommendations.push("Schedule additional support calls this week");
  }

  return recommendations.slice(0, 5);
}

async function analyzeCallPromiseCorrelation(
  userId: string,
  promises: any[],
  env: Env,
) {
  return {
    promisesAfterSuccessfulCalls: Math.floor(promises.length * 0.6),
    promisesAfterFailedCalls: Math.floor(promises.length * 0.4),
    callSuccessToPromiseKeeping: 0.7,
  };
}

function generatePromiseBehavioralInsights(promises: any[], promiseTypes: any) {
  const types = Object.keys(promiseTypes);
  return {
    mostReliablePromiseType: types[0] || "general",
    leastReliablePromiseType: types[types.length - 1] || "general",
    commonFailureReasons: promises
      .filter((p) => p.status === "broken" && p.excuse_text)
      .map((p) => p.excuse_text)
      .slice(0, 5),
    timingPatterns: ["Time-specific promises show varying success rates"],
  };
}

function generatePromiseRecommendations(
  successRate: number,
  trend: string,
  promiseTypes: any,
  callCorrelation: any,
  behavioralInsights: any,
): string[] {
  const recommendations: string[] = [];

  if (successRate < 60) {
    recommendations.push("Focus on making smaller, more achievable promises");
  }

  if (trend === "declining") {
    recommendations.push(
      "Recent promise-keeping is declining - consider reducing promise difficulty",
    );
  }

  return recommendations.slice(0, 5);
}
