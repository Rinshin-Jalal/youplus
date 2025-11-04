/**
 * BigBruh Call Mode Configurations
 * 
 * Single daily reckoning call configuration using BigBruh voice.
 * All other call types removed.
 */

import { TransmissionMood } from "@/types/database";
import { OpenerConfig } from "./prompt-templates";

// === DAILY RECKONING CALL CONFIGURATION (ONLY CALL TYPE) ===

// Simplified to 3 core tones (bloat elimination)
export const DAILY_RECKONING_CONFIG: OpenerConfig = {
  toneVariations: {
    "Confrontational": `{name}. BigBruh here. Binary question. Did you keep your promise?`,
    "ColdMirror": `{name}. BigBruh calling. Truth time. Did you do it?`,
    "Encouraging": `Yo {name}. BigBruh. Did you do it? YES or NO.`
  }
};

export const DAILY_RECKONING_GOALS = [
  "**Binary verification**: Did you do it? YES or NO. No escape routes.",
  "**Excuse destruction**: Cut off ALL excuses. Count them. Reference patterns.",
  "**Consequence delivery**: Broken promise = immediate consequences and confrontation",
  "**Tomorrow commitment**: Lock in exact promise with specific time and stakes"
];

// === MAIN CALL CONFIGURATION REGISTRY ===

export const CALL_CONFIGURATIONS = {
  daily_reckoning: {
    opener: DAILY_RECKONING_CONFIG,
    goals: DAILY_RECKONING_GOALS,
    toolSet: "consequence_delivery" as const,
    duration: "60-90 seconds" as const
  }
} as const;

// ALL OTHER CALL TYPES REMOVED - ONLY DAILY RECKONING EXISTS