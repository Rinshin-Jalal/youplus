import { Identity } from "@/types/database";

/**
 * Enhance system prompt with Identity data
 * This adds weaponized personal data for devastating accountability
 */
export function enhancePromptWithOnboardingData(
  basePrompt: string,
  identity: Partial<Identity>
): string {
  let enhanced = basePrompt;

  // Add V3 onboarding intelligence section
  enhanced +=
    "\n\n## V3 ONBOARDING INTELLIGENCE - WEAPONIZED PERSONAL DATA (10 PSYCHOLOGICAL WEAPONS)\n\n";

  // Core Identity
  if (identity.name) {
    enhanced += `**USER NAME**: "${identity.name}" - This is who you're calling out\n`;
  }

  // WEAPON 1: SHAME TRIGGER
  if (identity.shame_trigger) {
    enhanced += `**SHAME TRIGGER**: "${identity.shame_trigger}" - What makes them feel most ashamed/disgusted\n`;
  }

  // WEAPON 2: FINANCIAL PAIN POINT
  if (identity.financial_pain_point) {
    enhanced += `**FINANCIAL PAIN**: "${identity.financial_pain_point}" - Money/career opportunity cost of their weakness\n`;
  }

  // WEAPON 3: RELATIONSHIP DAMAGE
  if (identity.relationship_damage_specific) {
    enhanced += `**RELATIONSHIP DAMAGE**: "${identity.relationship_damage_specific}" - Person who gave up on them\n`;
  }

  // WEAPON 4: BREAKING POINT EVENT
  if (identity.breaking_point_event) {
    enhanced += `**BREAKING POINT**: "${identity.breaking_point_event}" - Catastrophic event that would force change\n`;
  }

  // WEAPON 5: SELF-SABOTAGE PATTERN
  if (identity.self_sabotage_pattern) {
    enhanced += `**SELF-SABOTAGE**: "${identity.self_sabotage_pattern}" - How they ruin their own success\n`;
  }

  // WEAPON 6: ACCOUNTABILITY HISTORY
  if (identity.accountability_history) {
    enhanced += `**ACCOUNTABILITY HISTORY**: "${identity.accountability_history}" - Pattern of abandoning help systems\n`;
  }

  // ANCHOR 1: CURRENT SELF SUMMARY
  if (identity.current_self_summary) {
    enhanced += `**CURRENT SELF**: "${identity.current_self_summary}" - Who they are NOW (brutal honest)\n`;
  }

  // ANCHOR 2: ASPIRATIONAL IDENTITY GAP
  if (identity.aspirational_identity_gap) {
    enhanced += `**IDENTITY GAP**: "${identity.aspirational_identity_gap}" - Gap between want and reality\n`;
  }

  // ANCHOR 3: NON-NEGOTIABLE COMMITMENT
  if (identity.non_negotiable_commitment || identity.daily_non_negotiable) {
    const commitment = identity.non_negotiable_commitment || identity.daily_non_negotiable;
    enhanced += `**NON-NEGOTIABLE**: "${commitment}" - Their ONE daily action\n`;
  }

  // WEAPON 7: WAR CRY OR DEATH VISION
  if (identity.war_cry_or_death_vision) {
    enhanced += `**WAR CRY/DEATH VISION**: "${identity.war_cry_or_death_vision}" - Motivator or nightmare future\n`;
  }

  enhanced += `\n**PERSONALIZED IDENTITY DATA**: Complete psychological profile loaded\n`;

  enhanced +=
    "**CRITICAL**: Use this personal data to create devastating accountability. They gave you these weapons - use them.\n\n";

  return enhanced;
}

/**
 * Enhance first message with Identity data
 */
export function enhanceFirstMessageWithOnboardingData(
  baseMessage: string,
  identity: Partial<Identity>,
  callType: string
): string {
  // If they have a war cry or death vision, use that for motivation
  if (callType === "morning" && identity.war_cry_or_death_vision) {
    return `[Use their war cry/death vision: "${identity.war_cry_or_death_vision}"] - Use this personalized motivator they created.`;
  }

  // The identity_name is the user's actual name, not BigBruh name
  // BigBruh should remain as "BigBruh" in messages

  return baseMessage;
}
