/* ═══════════════════════════════════════════════════════════════════════════════
 * 💾 MEMORY EMBEDDING OPERATIONS
 *
 * Core memory embedding CRUD operations for psychological content storage and retrieval.
 * ═══════════════════════════════════════════════════════════════════════════════ */

import { createSupabaseClient } from "@/utils/database";
import { Env } from "@/index";
import { generateEmbedding } from "./core";

// Simple env flag reader
function isEnabled(env: Env, key: string, defaultValue = true): boolean {
  const raw = (env as any)?.[key];
  if (raw === undefined || raw === null) return defaultValue;
  const val = String(raw).toLowerCase();
  return val === "true" || val === "1" || val === "yes";
}

function normalizeText(text: string): string {
  return text.trim().replace(/\s+/g, " ").toLowerCase();
}

async function computeSha256Hex(input: string): Promise<string> {
  // Prefer Web Crypto (Workers), fallback to Node crypto
  try {
    // @ts-ignore
    const subtle = crypto?.subtle;
    if (subtle) {
      const enc = new TextEncoder().encode(input);
      const hashBuffer = await subtle.digest("SHA-256", enc);
      const bytes = Array.from(new Uint8Array(hashBuffer));
      return bytes.map((b) => b.toString(16).padStart(2, "0")).join("");
    }
  } catch (_) {
    // ignore and fallback
  }
  const { createHash } = await import("crypto");
  return createHash("sha256").update(input).digest("hex");
}

/**
 * 📚 Retrieve All Psychological Memory Embeddings for User
 *
 * Fetches the complete psychological memory bank for a user, including all
 * embedded patterns, excuses, breakthroughs, and behavioral data. Used for
 * comprehensive pattern analysis and personalized accountability responses.
 *
 * @param userId - Target user's psychological memory bank
 * @param env - Database environment configuration
 * @returns Complete memory embedding records with vectors and metadata
 *
 * 🧠 Returned Data Structure:
 * • id, user_id, source_id - Record identifiers
 * • content_type - Pattern category (excuse, breakthrough, etc.)
 * • text_content - Original psychological text
 * • embedding - 1536-dimensional vector
 * • metadata - Additional context and timestamps
 */
export async function getMemoryEmbeddings(userId: string, env: Env) {
  const supabase = createSupabaseClient(env);

  console.log(`📚 Retrieving memory embeddings for user ${userId}`);

  const { data, error } = await supabase
    .from("memory_embeddings")
    .select("*")
    .eq("user_id", userId);

  if (error) {
    console.error("💥 Failed to retrieve memory embeddings:", error);
    throw error;
  }

  console.log(`✅ Retrieved ${data?.length || 0} memory embeddings`);
  return data;
}

/**
 * 💾 Create New Psychological Memory Embedding
 *
 * Generates and stores a new memory embedding for psychological content. Each
 * memory becomes searchable via semantic similarity, enabling the AI to reference
 * past patterns, excuses, breakthroughs for personalized accountability.
 *
 * @param userId - User who owns this psychological memory
 * @param sourceId - Source identifier (call_id, identity_record_id, etc.)
 * @param contentType - Memory category (excuse, breakthrough, trigger_moment, etc.)
 * @param textContent - Actual psychological text to embed and remember
 * @param env - Environment with database and OpenAI access
 * @returns Created memory embedding record with generated vector
 *
 * 🔮 Memory Creation Process:
 * 1. Generate 1536-dimensional embedding vector via OpenAI
 * 2. Store in memory_embeddings table with metadata
 * 3. Enable future semantic search and pattern recognition
 * 4. Return complete record for immediate use
 */
export async function createMemoryEmbedding(
  userId: string,
  sourceId: string,
  contentType: string,
  textContent: string,
  env: Env,
  extraMetadata?: Record<string, any>,
) {
  const supabase = createSupabaseClient(env);

  console.log(
    `💾 Creating ${contentType} memory for user ${userId}: "${
      textContent.substring(0, 50)
    }..."`,
  );

  // Normalize only for hashing (do not alter stored text)
  const normalized = normalizeText(textContent);
  const textHash = await computeSha256Hex(normalized);

  // Idempotency: skip if same user+source+text_hash already stored
  try {
    const { data: existing, error: existingErr } = await supabase
      .from("memory_embeddings")
      .select("id")
      .eq("user_id", userId)
      .eq("source_id", sourceId)
      .contains("metadata", { text_hash: textHash });
    if (!existingErr && Array.isArray(existing) && existing.length > 0) {
      console.log("♻️ Skipping duplicate memory (hash match)");
      return { id: (existing[0] as any).id };
    }
  } catch (e) {
    console.warn("Duplicate check failed (continuing)", e);
  }

  // 🔮 Generate embedding vector for psychological content
  const embedding = await generateEmbedding(textContent, env);

  const { data, error } = await supabase
    .from("memory_embeddings")
    .insert({
      user_id: userId,
      source_id: sourceId,
      content_type: contentType,
      text_content: textContent,
      embedding,
      metadata: { // 📊 Additional context for accountability
        created_at: new Date().toISOString(),
        text_length: textContent.length,
        text_hash: textHash,
        ...(extraMetadata || {}),
      },
    })
    .select()
    .single();

  if (error) {
    console.error("💥 Failed to create memory embedding:", error);
    throw error;
  }

  console.log(`✅ Created ${contentType} memory embedding with ID: ${data.id}`);
  return data;
}

/**
 * 🔍 Search Psychological Memory Bank via Semantic Similarity
 *
 * Finds similar psychological patterns from user's memory bank using vector
 * similarity search. Powers accountability calls with personalized references
 * to past behaviors, excuses, breakthroughs, and commitments.
 *
 * @param userId - User's psychological memory bank to search
 * @param query - Current psychological content to match against memories
 * @param matchThreshold - Similarity threshold (0.7 = 70% similar, 0.8 = stricter)
 * @param matchCount - Maximum similar memories to return (default: 5)
 * @param env - Environment with database and OpenAI access
 * @returns Ranked array of similar memories with similarity scores
 *
 * 🎯 Accountability Use Cases:
 * • Query: "I'm too busy today" → Find: Similar excuse patterns
 * • Query: "I want to give up" → Find: Past breakthrough moments
 * • Query: Current behavior → Find: Previous commitment violations
 *
 * 📊 Similarity Thresholds:
 * • 0.9+ = Nearly identical (exact pattern match)
 * • 0.8+ = Very similar (strong pattern recognition)
 * • 0.7+ = Similar theme (useful for accountability)
 * • 0.6+ = Loosely related (broader pattern detection)
 */
export async function searchMemoryEmbeddings(
  userId: string,
  query: string,
  matchThreshold: number = 0.7,
  matchCount: number = 5,
  env: Env,
) {
  const supabase = createSupabaseClient(env);

  console.log(
    `🔍 Searching memories for user ${userId}: "${
      query.substring(0, 50)
    }..." (threshold: ${matchThreshold})`,
  );

  // 🔮 Generate query embedding for semantic comparison
  const queryEmbedding = await generateEmbedding(query, env);

  // 🎯 Call PostgreSQL RPC function for optimized vector similarity search
  const { data, error } = await supabase.rpc("match_memory_embeddings", {
    query_embedding: queryEmbedding,
    match_threshold: matchThreshold,
    match_count: matchCount,
    target_user_id: userId,
  });

  if (error) {
    console.error("💥 Memory search failed:", error);
    throw error;
  }

  console.log(
    `✅ Found ${
      data?.length || 0
    } similar memories above ${matchThreshold} threshold`,
  );
  return data;
}

/**
 * 🎯 Search Memories by Specific Content Types
 *
 * Specialized search that filters by psychological content types for targeted
 * accountability responses. Perfect for finding specific patterns like excuses,
 * breakthroughs, or trigger moments.
 *
 * @param userId - User's memory bank to search
 * @param query - Current psychological content to match
 * @param contentTypes - Array of content types to search within
 * @param matchThreshold - Similarity threshold (default: 0.7)
 * @param matchCount - Maximum results to return (default: 5)
 * @param env - Environment configuration
 * @returns Filtered and ranked similar memories by type
 *
 * 💡 Example Usage:
 * • searchPsychologicalPatterns(userId, "I'm too tired", ["excuse", "excuse_pattern"])
 * • searchPsychologicalPatterns(userId, "giving up", ["breakthrough", "vision"])
 * • searchPsychologicalPatterns(userId, "morning routine", ["trigger_moment", "commitment"])
 */
export async function searchPsychologicalPatterns(
  userId: string,
  query: string,
  contentTypes: string[],
  matchThreshold: number = 0.7,
  matchCount: number = 5,
  env: Env,
) {
  const supabase = createSupabaseClient(env);

  console.log(
    `🎯 Searching ${contentTypes.join(", ")} patterns for: "${
      query.substring(0, 50)
    }..."`,
  );

  // 🔮 Generate query embedding
  const queryEmbedding = await generateEmbedding(query, env);

  // 🎯 Search with content type filtering
  const { data, error } = await supabase.rpc("match_memory_embeddings", {
    query_embedding: queryEmbedding,
    match_threshold: matchThreshold,
    match_count: matchCount * 2, // Get more results for filtering
    target_user_id: userId,
  });

  if (error) {
    console.error("💥 Pattern search failed:", error);
    throw error;
  }

  // 🔍 Filter by requested content types and limit results
  const filteredResults = data
    .filter((result: any) => contentTypes.includes(result.content_type))
    .slice(0, matchCount);

  console.log(
    `✅ Found ${filteredResults.length} matching ${
      contentTypes.join("/")
    } patterns`,
  );
  return filteredResults;
}

/**
 * 🧩 Build a compact payload for prompt enrichment from Top-K related memories
 * Returns a small object with related_memories and a one-line pattern_summary
 */
export async function buildRelatedMemoriesPayload(
  userId: string,
  query: string,
  env: Env,
  matchThreshold: number = 0.7,
  matchCount: number = 5,
): Promise<{
  related_memories: Array<{ text: string; date: string; emotion?: string }>;
  pattern_summary: string;
}> {
  const results = await searchMemoryEmbeddings(
    userId,
    query,
    matchThreshold,
    matchCount,
    env,
  );

  const related_memories: Array<
    { text: string; date: string; emotion?: string }
  > = (results || [])
    .slice(0, 3)
    .map((r: any) => {
      const meta = r.metadata || {};
      const date: string =
        (meta.call_date || r.created_at || new Date().toISOString()).slice(
          0,
          10,
        );
      const emotion: string | undefined = meta.emotion || meta.tone_used ||
        undefined;
      return { text: r.text_content, date, emotion };
    });

  // Simple summary: dominant type + brief phrasing
  const typeCounts: Record<string, number> = {};
  (results || []).forEach((r: any) => {
    const t = String(r.content_type || "pattern");
    typeCounts[t] = (typeCounts[t] || 0) + 1;
  });
  const topType =
    Object.entries(typeCounts).sort((a, b) => b[1] - a[1])[0]?.[0] || "pattern";

  let pattern_summary = "Relevant past situations detected.";
  if (topType === "excuse") {
    pattern_summary =
      "User repeats similar excuse patterns in comparable contexts.";
  } else if (topType === "breakthrough") {
    pattern_summary =
      "Past breakthroughs in similar contexts can be leveraged now.";
  } else {pattern_summary =
      "Recurring behavioral patterns align with today's context.";}

  return { related_memories, pattern_summary };
}

/**
 * 📊 Get Memory Insights (Processed Data Instead of Raw Embeddings)
 *
 * Instead of exposing raw memory embeddings to UserContext, this function returns
 * processed insights, statistics, and behavioral indicators while protecting
 * sensitive psychological content.
 *
 * @param userId - User to analyze memory patterns for
 * @param env - Environment configuration
 * @returns Processed insights without raw memory content
 *
 * 🛡️ Privacy Protection:
 * • No raw psychological text content exposed
 * • Statistical summaries instead of specific memories
 * • Behavioral trend indicators without specific examples
 * • Count-based metrics for accountability patterns
 */
export async function getMemoryInsights(
  userId: string,
  env: Env,
): Promise<{
  memoryStats: {
    totalMemories: number;
    recentMemories: number; // Last 7 days
    contentTypeBreakdown: Record<string, number>;
    weeklyTrend: "increasing" | "decreasing" | "stable";
  };
  behavioralIndicators: {
    excuseFrequency: "high" | "moderate" | "low";
    breakthroughMoments: number;
    patternStrength: "strong" | "moderate" | "weak";
    emotionalTrend: "positive" | "negative" | "neutral";
  };
  accountabilitySignals: {
    recurringPatternCount: number;
    lastMemoryDate: string | null;
    criticalThemesCount: number;
    growthIndicators: number;
  };
  systemHealth: {
    memorySystemActive: boolean;
    lastProcessedAt: string;
    dataQualityScore: number; // 0-100
  };
}> {
  const supabase = createSupabaseClient(env);
  
  console.log(`📊 Generating memory insights for user ${userId}`);

  // Fetch all memory embeddings for analysis
  const { data: memories, error } = await supabase
    .from("memory_embeddings")
    .select("id, content_type, created_at, metadata")
    .eq("user_id", userId)
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Failed to fetch memories for insights:", error);
    throw error;
  }

  const now = new Date();
  const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  const fourteenDaysAgo = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000);

  // 📈 Calculate memory statistics
  const totalMemories = memories?.length || 0;
  const recentMemories = memories?.filter(m => 
    new Date(m.created_at) > sevenDaysAgo
  ).length || 0;
  const previousWeekMemories = memories?.filter(m => {
    const date = new Date(m.created_at);
    return date > fourteenDaysAgo && date <= sevenDaysAgo;
  }).length || 0;

  // Content type breakdown
  const contentTypeBreakdown: Record<string, number> = {};
  memories?.forEach(memory => {
    const type = memory.content_type || "unknown";
    contentTypeBreakdown[type] = (contentTypeBreakdown[type] || 0) + 1;
  });

  // Weekly trend analysis
  let weeklyTrend: "increasing" | "decreasing" | "stable" = "stable";
  if (recentMemories > previousWeekMemories * 1.2) {
    weeklyTrend = "increasing";
  } else if (recentMemories < previousWeekMemories * 0.8) {
    weeklyTrend = "decreasing";
  }

  // 🧠 Behavioral indicators
  const excuseCount = contentTypeBreakdown["excuse"] || 0;
  const breakthroughCount = contentTypeBreakdown["breakthrough"] || 0;
  const patternCount = contentTypeBreakdown["pattern"] || 0;

  const excuseFrequency: "high" | "moderate" | "low" = 
    excuseCount > 10 ? "high" : excuseCount > 3 ? "moderate" : "low";
  
  const patternStrength: "strong" | "moderate" | "weak" = 
    patternCount > 15 ? "strong" : patternCount > 5 ? "moderate" : "weak";

  // Emotional trend analysis (simplified - would use sentiment analysis in production)
  const positiveTypes = ["breakthrough", "vision", "commitment", "sacred_oath"];
  const negativeTypes = ["excuse", "excuse_pattern", "self_deception"];
  
  const positiveCount = positiveTypes.reduce((sum, type) => 
    sum + (contentTypeBreakdown[type] || 0), 0);
  const negativeCount = negativeTypes.reduce((sum, type) => 
    sum + (contentTypeBreakdown[type] || 0), 0);
  
  const emotionalTrend: "positive" | "negative" | "neutral" = 
    positiveCount > negativeCount * 1.5 ? "positive" :
    negativeCount > positiveCount * 1.5 ? "negative" : "neutral";

  // 🎯 Accountability signals
  const recurringPatternCount = Math.max(excuseCount, patternCount);
  const lastMemoryDate = memories?.[0]?.created_at || null;
  const criticalThemesCount = Object.keys(contentTypeBreakdown).length;
  const growthIndicators = breakthroughCount + (contentTypeBreakdown["vision"] || 0);

  // 🛠️ System health
  const dataQualityScore = Math.min(100, Math.max(0, 
    (totalMemories * 10) + (criticalThemesCount * 15) - (excuseCount * 2)
  ));

  const insights = {
    memoryStats: {
      totalMemories,
      recentMemories,
      contentTypeBreakdown,
      weeklyTrend,
    },
    behavioralIndicators: {
      excuseFrequency,
      breakthroughMoments: breakthroughCount,
      patternStrength,
      emotionalTrend,
    },
    accountabilitySignals: {
      recurringPatternCount,
      lastMemoryDate,
      criticalThemesCount,
      growthIndicators,
    },
    systemHealth: {
      memorySystemActive: totalMemories > 0,
      lastProcessedAt: new Date().toISOString(),
      dataQualityScore,
    },
  };

  console.log(`✅ Generated memory insights: ${totalMemories} memories, ${recentMemories} recent, ${criticalThemesCount} themes`);
  
  return insights;
}
