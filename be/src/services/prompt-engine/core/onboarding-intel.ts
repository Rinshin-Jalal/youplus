/**
 * ════════════════════════════════════════════════════════════════════════════════
 * 🔥 PSYCHOLOGICAL WEAPONS INTELLIGENCE BUILDER - V3
 * ════════════════════════════════════════════════════════════════════════════════
 *
 * Transforms identity psychological weapons into brutal, actionable intelligence
 * for AI accountability calls. Each weapon is formatted for maximum impact.
 *
 * PHILOSOPHY:
 * - These are WEAPONS, not therapy notes
 * - Every line should be usable directly in a confrontational call
 * - Intensity over politeness
 * - Specificity over generalization
 *
 * REDESIGNED: V3 - Focus on 10 psychological weapons instead of 23 generic fields
 * ════════════════════════════════════════════════════════════════════════════════
 */

import { Identity, MemoryInsights } from "@/types/database";

/**
 * Builds brutal intelligence profile from psychological weapons
 *
 * @param identity - Psychological weapons extracted from onboarding
 * @param memoryInsights - Behavioral patterns from call/interaction history
 * @returns Formatted intelligence string for prompt injection in calls
 */
export function buildOnboardingIntelligence(
  identity: Identity | null,
  memoryInsights?: MemoryInsights | null
): string {
  if (!identity) {
    return "**INSUFFICIENT DATA**: No psychological profile available - user needs onboarding completion.\n\n---\n\n";
  }

  let intelligence = "# 🎯 PSYCHOLOGICAL WEAPONS PROFILE\n\n";

  const i = identity; // Short alias for readability

  // ═══════════════════════════════════════════════════════════════════════════════
  // IDENTITY ANCHORS (Who they are vs who they want to be)
  // ═══════════════════════════════════════════════════════════════════════════════

  intelligence += `**User Name**: ${i.name}\n\n`;

  if (i.current_self_summary) {
    intelligence += `## WHO THEY ARE NOW (Reality Mirror)\n`;
    intelligence += `"${i.current_self_summary}"\n`;
    intelligence += `*Use this: Call them out on reality vs promises*\n\n`;
  }

  if (i.aspirational_identity_gap) {
    intelligence += `## THE GAP (Cognitive Dissonance Weapon)\n`;
    intelligence += `"${i.aspirational_identity_gap}"\n`;
    intelligence += `*Use this: Highlight the painful distance between want and reality*\n\n`;
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // PRIMARY WEAPONS (Core psychological leverage points)
  // ═══════════════════════════════════════════════════════════════════════════════

  intelligence += `## 🔪 PRIMARY WEAPONS\n\n`;

  if (i.shame_trigger) {
    intelligence += `### SHAME TRIGGER\n`;
    intelligence += `"${i.shame_trigger}"\n`;
    intelligence += `*Deploy when: They're making excuses or avoiding the mirror*\n`;
    intelligence += `*Hit: "Remember what you said disgusts you? Still true today?"*\n\n`;
  }

  if (i.financial_pain_point) {
    intelligence += `### FINANCIAL PAIN\n`;
    intelligence += `"${i.financial_pain_point}"\n`;
    intelligence += `*Deploy when: They say money doesn't matter or they'll start tomorrow*\n`;
    intelligence += `*Hit: "That's [amount] you'll never see again. How much more?"*\n\n`;
  }

  if (i.relationship_damage_specific) {
    intelligence += `### RELATIONSHIP DAMAGE\n`;
    intelligence += `"${i.relationship_damage_specific}"\n`;
    intelligence += `*Deploy when: They think only they're affected by their failure*\n`;
    intelligence += `*Hit: "[Person] gave up on you. Prove them wrong today or prove them right."*\n\n`;
  }

  if (i.self_sabotage_pattern) {
    intelligence += `### SABOTAGE PATTERN (Predictive Weapon)\n`;
    intelligence += `"${i.self_sabotage_pattern}"\n`;
    intelligence += `*Deploy when: You see the pattern starting (Day 3-5 typically)*\n`;
    intelligence += `*Hit: "Here it comes. [Emotion] hitting? Don't do what you did the last [X] times."*\n\n`;
  }

  if (i.breaking_point_event) {
    intelligence += `### BREAKING POINT (Urgency Weapon)\n`;
    intelligence += `"${i.breaking_point_event}"\n`;
    intelligence += `*Deploy when: They're being complacent about timeline*\n`;
    intelligence += `*Hit: "You said only [event] would make you change. Why wait for catastrophe?"*\n\n`;
  }

  if (i.accountability_history) {
    intelligence += `### ACCOUNTABILITY HISTORY (Positioning Weapon)\n`;
    intelligence += `"${i.accountability_history}"\n`;
    intelligence += `*Deploy when: They're resisting calls or trying to ghost*\n`;
    intelligence += `*Hit: "This is attempt #[X+1]. You've quit every other system. This one's different?"*\n\n`;
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // OPERATIONAL ANCHOR (Daily commitment tracking)
  // ═══════════════════════════════════════════════════════════════════════════════

  if (i.non_negotiable_commitment) {
    intelligence += `## ⚔️ NON-NEGOTIABLE COMMITMENT\n`;
    intelligence += `"${i.non_negotiable_commitment}"\n`;
    intelligence += `*Ask EVERY call: "Did you [action]? Yes or no. No stories."*\n\n`;
  } else if (i.daily_non_negotiable) {
    // Fallback to deprecated field if new one doesn't exist
    intelligence += `## ⚔️ DAILY NON-NEGOTIABLE\n`;
    intelligence += `"${i.daily_non_negotiable}"\n`;
    intelligence += `*Ask EVERY call: "Did you do it? Yes or no."*\n\n`;
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // MOTIVATIONAL ANCHOR (War cry or death vision)
  // ═══════════════════════════════════════════════════════════════════════════════

  if (i.war_cry_or_death_vision) {
    intelligence += `## 🔥 WAR CRY / DEATH VISION\n`;
    intelligence += `"${i.war_cry_or_death_vision}"\n`;
    intelligence += `*Deploy when: They need final push or ultimate fear reminder*\n`;
    intelligence += `*Use as closing or opening hammer*\n\n`;
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // SUMMARY PROFILE (Quick reference)
  // ═══════════════════════════════════════════════════════════════════════════════

  if (i.identity_summary) {
    intelligence += `## 📋 PROFILE SUMMARY\n`;
    intelligence += `${i.identity_summary}\n\n`;
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // BEHAVIORAL MEMORY INSIGHTS (If available)
  // ═══════════════════════════════════════════════════════════════════════════════

  if (memoryInsights && memoryInsights.emergingPatterns && memoryInsights.emergingPatterns.length > 0) {
    intelligence += `## 🔍 EMERGING PATTERNS (Recent Behavior)\n`;
    memoryInsights.emergingPatterns.forEach((pattern, index) => {
      intelligence += `${index + 1}. "${pattern.sampleText}" - ${pattern.recentCount} occurrences\n`;
    });
    intelligence += `*Use these: Call out repeated excuses and patterns*\n\n`;
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // CALL STRATEGY SUMMARY
  // ═══════════════════════════════════════════════════════════════════════════════

  intelligence += `## 🎯 CALL STRATEGY\n`;
  intelligence += `1. Start with reality check: Current self vs promises\n`;
  intelligence += `2. Deploy primary weapon based on their recent behavior\n`;
  intelligence += `3. Ask about non-negotiable: Yes/No only\n`;
  intelligence += `4. Predict and prevent sabotage pattern if Day 3-5\n`;
  intelligence += `5. Close with war cry or death vision reminder\n`;
  intelligence += `6. No therapy. No excuses. Just confrontation and commitment.\n\n`;

  intelligence += `---\n\n`;
  return intelligence;
}

// Alias for backward compatibility
export const generateOnboardingIntelligence = buildOnboardingIntelligence;
