/* ═══════════════════════════════════════════════════════════════════════════════
 * 🧬 IDENTITY EXTRACTOR - SUPER MVP (DEPRECATED)
 *
 * ⚠️ DEPRECATED: This extractor is no longer needed in Super MVP.
 * Identity creation now happens directly in conversion-complete.ts during onboarding.
 *
 * Super MVP Approach:
 * - Onboarding conversion uploads voice files to R2
 * - Builds onboarding_context JSONB from all responses
 * - Inserts identity record with 12 columns directly
 * - No separate extraction step needed
 *
 * This file kept for backward compatibility but returns empty results.
 * ═══════════════════════════════════════════════════════════════════════════════ */

import { createSupabaseClient } from "@/features/core/utils/database";
import { Env } from "@/index";
import { Identity } from "@/types/database";

export class IntelligentIdentityExtractor {
  private env: Env;
  private supabase: any;

  constructor(env: Env) {
    this.env = env;
    this.supabase = createSupabaseClient(env);
  }

  /**
   * 🧠 IDENTITY EXTRACTION (Super MVP - DEPRECATED)
   *
   * ⚠️ DEPRECATED: Returns empty object. Identity creation now happens
   * in conversion-complete.ts during onboarding with Super MVP schema.
   *
   * Super MVP eliminates the need for separate extraction:
   * - All data collected during 42-step onboarding
   * - Voice recordings uploaded to R2
   * - onboarding_context JSONB built from responses
   * - Identity record inserted directly with 12 columns
   *
   * @deprecated Use conversion-complete.ts onboarding handler instead
   */
  async extractIdentityData(userId: string): Promise<Partial<Identity>> {
    console.log(
      `⚠️  DEPRECATED: IntelligentIdentityExtractor called for user ${userId}`
    );
    console.log(
      `   Identity creation now handled by conversion-complete.ts in Super MVP`
    );
    console.log(`   Returning empty object - no extraction needed`);

    // Super MVP: Identity already created by conversion-complete.ts
    // No extraction needed - return empty
    return {};
  }

  /**
   * 🔧 Extract Operational Fields (Super MVP - DEPRECATED)
   *
   * @deprecated No longer needed - conversion-complete.ts handles everything
   */
  private async extractOperationalFieldsDirectly(
    userId: string
  ): Promise<Partial<Identity>> {
    // Super MVP: Not needed - return empty
    return {};
  }

  /**
   * 💾 Extract and Save Identity (Super MVP - DEPRECATED)
   *
   * ⚠️ DEPRECATED: In Super MVP, identity is created during onboarding
   * completion by conversion-complete.ts. This method returns success
   * without doing anything to maintain backward compatibility.
   *
   * @deprecated Identity creation happens in conversion-complete.ts
   */
  async extractAndSaveIdentity(userId: string): Promise<{
    success: boolean;
    identity?: Partial<Identity>;
    fieldsExtracted?: number;
    aiAnalyzed?: boolean;
    error?: string;
  }> {
    console.log(
      `⚠️  DEPRECATED: extractAndSaveIdentity called for user ${userId}`
    );
    console.log(
      `   In Super MVP, identity is created by conversion-complete.ts during onboarding`
    );
    console.log(`   This extractor is no longer needed - returning success`);

    // Check if identity already exists (created by conversion-complete.ts)
    const { data: existingIdentity } = await this.supabase
      .from("identity")
      .select("id, name, daily_commitment")
      .eq("user_id", userId)
      .maybeSingle();

    if (existingIdentity) {
      console.log(`✅ Identity already exists for user ${userId} (Super MVP)`);
      return {
        success: true,
        identity: existingIdentity,
        fieldsExtracted: 0,
        aiAnalyzed: false,
      };
    }

    // Identity doesn't exist - this is OK, it will be created during onboarding completion
    console.log(
      `   No identity found yet - will be created during onboarding completion`
    );
    return {
      success: true,
      identity: {},
      fieldsExtracted: 0,
      aiAnalyzed: false,
    };
  }

  /**
   * 📝 Generate Summary (Super MVP - DEPRECATED)
   *
   * @deprecated Not used in Super MVP
   */
  private generateIntelligentSummary(identity: Partial<Identity>): string {
    return "Super MVP - Identity summary in onboarding_context JSONB";
  }
}

/* ═══════════════════════════════════════════════════════════════════════════════
 * 🏭 FACTORY FUNCTIONS & UTILITY METHODS
 * ═══════════════════════════════════════════════════════════════════════════════ */

/**
 * 🏭 Factory function to create identity extractor instance
 * @deprecated Use conversion-complete.ts onboarding handler instead
 */
export function createIntelligentIdentityExtractor(
  env: Env
): IntelligentIdentityExtractor {
  return new IntelligentIdentityExtractor(env);
}

/**
 * 🚀 Extract and save identity data (Super MVP - DEPRECATED)
 * @deprecated Identity creation handled by conversion-complete.ts
 */
export async function extractAndSaveIdentityIntelligent(
  userId: string,
  env: Env
) {
  const extractor = createIntelligentIdentityExtractor(env);
  return await extractor.extractAndSaveIdentity(userId);
}

// Legacy aliases for backward compatibility
export const createUnifiedIdentityExtractor = createIntelligentIdentityExtractor;
export const extractAndSaveIdentityUnified = extractAndSaveIdentityIntelligent;
export const UnifiedIdentityExtractor = IntelligentIdentityExtractor;
