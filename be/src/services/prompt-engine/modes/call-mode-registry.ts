import { TransmissionMood, UserContext } from "@/types/database";
import { CallModeConfig, CallModeFunction, CallModeResult } from "../types";
import { Env } from "@/index";
import {
  enhanceFirstMessageWithOnboardingData,
  enhancePromptWithOnboardingData,
} from "../enhancement/onboarding-enhancer";

// NEW: Import optimized template engine for better performance
import { OptimizedTemplateEngine } from "../templates/template-engine";

// Import individual mode functions - ONLY DAILY RECKONING
import { generateDailyReckoningMode } from "./daily-reckoning";

function buildPatternProfileBlock(profile: any): string {
  if (!profile) return "";
  const counts = profile.countsByType || {};
  const dom = profile.dominantEmotion || "neutral";
  const em = (profile.emergingPatterns || []).slice(0, 3);

  let s = "\n\n# Behavioral Profile (Nightly Snapshot)\n";
  s += `- Dominant emotion: ${dom}\n`;
  s += `- Counts: excuses=${counts.excuse || 0}, patterns=${
    counts.pattern || 0
  }, breakthroughs=${counts.breakthrough || 0}\n`;
  if (em.length) {
    s += "- Emerging patterns:\n";
    em.forEach((p: any, i: number) => {
      s += `  ${i + 1}. "${p.sampleText}" (7d=${p.recentCount}, base21=${
        p.baselineCount
      }, growth=${p.growthFactor}x)\n`;
    });
  }
  return s;
}

/**
 * Central registry - ONLY DAILY RECKONING MODE
 * BigBruh accountability system using single daily reckoning call
 */
const CALL_MODE_REGISTRY = {
  daily_reckoning: generateDailyReckoningMode, // ONLY call mode - BigBruh accountability
  // ALL OTHER MODES REMOVED - Only daily reckoning exists
} as const;

/**
 * Main entry point - automatically routes to correct mode function
 * Includes V3 onboarding data enhancement for advanced personalization
 *
 * NEW: Includes option to use optimized template engine for better performance
 */
export async function getPromptForCall(
  callType: string,
  userContext: UserContext,
  toneAnalysis: { recommended_mood: TransmissionMood },
  env: Env,
  useOptimizedEngine: boolean = false // NEW: Flag to enable optimized engine
): Promise<CallModeResult> {
  const tone = toneAnalysis.recommended_mood as TransmissionMood;

  // Force all calls to use daily_reckoning mode
  const forcedCallType = "daily_reckoning";
  console.log(`🚀 All calls redirected to BigBruh daily reckoning mode`);

  // Use Identity data directly for personalization
  let identityData: any = null;
  let relatedMemoriesBlock: string | null = null;
  try {
    // Use Identity data directly from userContext
    identityData = userContext.identity;
    if (identityData) {
      console.log(
        `📊 IDENTITY: Using direct identity data for enhancement: ${
          identityData.identity_name || "No name set"
        }`
      );
    }
    // Build related memories payload using today context
    try {
      // Super MVP: primary_excuse now in onboarding_context
      const context = userContext?.identity?.onboarding_context as any;
      const queryContext =
        userContext?.todayPromises?.[0]?.promise_text ||
        context?.favorite_excuse ||
        "morning routine";
      const { buildRelatedMemoriesPayload } = await import(
        "@/services/embedding-services/memory"
      );
      const payload = await buildRelatedMemoriesPayload(
        userContext.user.id,
        String(queryContext),
        env,
        0.7,
        5
      );
      // Format as minimal block
      const lines: string[] = [];
      lines.push(`# Related Memories (Top-3)`);
      payload.related_memories.forEach((m, i) => {
        lines.push(
          `- ${i + 1}. "${m.text}" (${m.date}${
            m.emotion ? ", emotion: " + m.emotion : ""
          })`
        );
      });
      lines.push(``);
      lines.push(`**Pattern Summary**: ${payload.pattern_summary}`);
      relatedMemoriesBlock = lines.join("\n");
    } catch (e) {
      console.warn("Related memories enrichment failed", e);
    }
  } catch (error) {
    console.error("Failed to extract onboarding data:", error);
  }

  // Always use daily reckoning mode
  const result = generateDailyReckoningMode(userContext, tone);

  // Enhance with Identity data if available
  if (identityData) {
    result.systemPrompt = enhancePromptWithOnboardingData(
      result.systemPrompt,
      identityData
    );
    result.firstMessage = enhanceFirstMessageWithOnboardingData(
      result.firstMessage,
      identityData,
      "daily_reckoning"
    );
    if (relatedMemoriesBlock) {
      result.systemPrompt += `\n\n${relatedMemoriesBlock}`;
    }
    // Append nightly pattern profile block (or insights fallback)
    try {
      const profile =
        (userContext as any)?.identityStatus?.pattern_profile ??
        (userContext as any)?.memoryInsights ??
        null;
      const block = buildPatternProfileBlock(profile);
      if (block) result.systemPrompt += block;
    } catch (_) {}
  }

  return result;
}

/**
 * Utility function to get all available call modes (useful for debugging and documentation)
 */
export function getAvailableCallModes(): string[] {
  return Object.keys(CALL_MODE_REGISTRY);
}

/**
 * Utility function to check if a call mode exists
 */
export function isValidCallMode(callType: string): boolean {
  return callType in CALL_MODE_REGISTRY;
}
