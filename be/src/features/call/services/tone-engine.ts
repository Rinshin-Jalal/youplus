import {
  UserContext,
  UserPromise,
  BigBruhhTone,
  Identity,
} from "@/types/database";

/* ═══════════════════════════════════════════════════════════════════════════════
 * 🎭 YOU+ TONE ENGINE - PSYCHOLOGICAL MIRROR SYSTEM
 *
 * The heart of YOU+ AI accountability - analyzes user behavior patterns to
 * determine optimal psychological tone for maximum impact. Based on
 * performance trends, streak health, and collapse risk to deliver precisely
 * calibrated interventions that drive behavioral change.
 *
 * Core Philosophy: "The right mirror at right moment creates breakthrough"
 * ═══════════════════════════════════════════════════════════════════════════════ */

// 🎛️ Configuration for tone calculation algorithm
interface ToneConfig {
  weights: {
    performance: number; // 📊 How much recent success/failure matters (0-100)
    streak: number; // 🔥 How much alignment streak affects tone (0-100)
    collapse: number; // ⚠️ How much trust collapse risk matters (0-100)
  };
  thresholds: {
    encouragement: number; // 🌟 Score threshold for "Encouraging" tone
    intervention: number; // ⚔️ Score threshold for "Confrontational" intervention
    trendSignificance: number; // 📈 Minimum change to detect trend (0-1)
  };
  penalties: {
    consecutiveFailureBase: number; // 💥 Points lost per consecutive failure
    momentumAtRisk: number; // 🚨 Penalty when streak momentum at risk
    trendDeclining: number; // 📉 Penalty for declining performance trend
  };
  bonuses: {
    trendImproving: number; // 🚀 Bonus points for improving trend
  };
}

// 🎯 Default configuration - carefully tuned for optimal psychological impact
const DEFAULT_TONE_CONFIG: ToneConfig = {
  weights: {
    performance: 40, // 📊 Recent behavior is most predictive of current state
    streak: 30, // 🔥 Consistency matters for identity formation
    collapse: 30, // ⚠️ Trust collapse requires immediate intervention
  },
  thresholds: {
    encouragement: 30, // 🌟 Celebrate wins to reinforce identity
    intervention: -20, // ⚔️ Ruthless tone for significant failures
    trendSignificance: 0.2, // 📈 20% change needed to detect real trends
  },
  penalties: {
    consecutiveFailureBase: 10, // 💥 Each failure compounds to damage
    momentumAtRisk: 20, // 🚨 Lost momentum needs urgent attention
    trendDeclining: 15, // 📉 Declining trends require course correction
  },
  bonuses: {
    trendImproving: 15, // 🚀 Reward positive momentum to accelerate growth
  },
};

// 🧠 Structured reasoning factors for transparent AI decision-making
interface ReasoningFactor {
  factor: string; // 📝 What aspect we're analyzing (streak, trend, etc.)
  value: string | number; // 📊 The actual value that influenced to decision
}

// 🎭 Complete tone analysis with psychological insights and confidence metrics
interface ToneAnalysis {
  recommended_mood: BigBruhhTone; // 🎯 The optimal psychological mirror to show
  intensity: number; // 🔥 How intense intervention should be (0-1)
  reasoning: string; // 💭 Human-readable explanation of decision
  reasoningFactors: ReasoningFactor[]; // 📊 Data points that influenced to choice
  confidence_score: number; // 🎲 How confident we are in this recommendation
  dataQuality: "insufficient" | "partial" | "robust"; // 📈 Quality of input data
}

/* ═══════════════════════════════════════════════════════════════════════════════
 * 🚀 MAIN TONE CALCULATION ENGINE
 *
 * The master function that orchestrates all psychological analysis to determine
 * optimal tone. Processes performance patterns, streak health, and collapse
 * risk to deliver a scientifically-calibrated intervention strategy.
 * ═══════════════════════════════════════════════════════════════════════════════ */
export function calculateOptimalTone(
  userContext: UserContext,
  config: ToneConfig = DEFAULT_TONE_CONFIG
): ToneAnalysis {
  const { recentStreakPattern, identityStatus } = userContext;

  // 📊 PHASE 1: Analyze recent behavioral patterns with graceful fallbacks
  const recentPerformance = analyzeRecentPerformance(
    recentStreakPattern || [],
    config
  );

  // 🔥 PHASE 2: Evaluate current streak momentum and strength
  const currentStreak = identityStatus?.current_streak_days ?? 0;
  const streakHealth = analyzeStreakHealth(currentStreak);

  // ⚠️ PHASE 3: Assess psychological collapse risk from streak breakdown
  // Super MVP: Use current_streak_days instead of removed trust_percentage
  const collapseScore = currentStreak === 0 ? 100 :  // No streak = critical collapse risk
                        currentStreak < 3 ? 70 :      // Fragile momentum = high risk
                        currentStreak < 7 ? 30 :      // Building strength = medium risk
                        0;                             // Strong streak = low risk
  const collapseRisk = analyzeCollapseRisk(collapseScore);

  // 🎯 PHASE 4: Calculate weighted psychological intervention score
  const {
    score: toneScore,
    reasoningFactors,
    intensity,
  } = calculateToneScore(recentPerformance, streakHealth, collapseRisk, config);

  // 🎭 PHASE 5: Generate final tone recommendation with reasoning
  return generateToneRecommendation(
    toneScore,
    recentPerformance,
    collapseRisk,
    reasoningFactors,
    intensity,
    config
  );
}

// 📊 Performance analysis results - foundation of tone decisions
interface PerformanceAnalysis {
  success_rate: number; // 🎯 Overall success rate (0-100%)
  recent_failures: number; // 💥 Count of recent broken promises
  consecutive_failures: number; // 🔥 Consecutive failures from most recent
  trend: "improving" | "declining" | "stable"; // 📈 Performance trajectory
}

// 📅 Helper to safely extract promise dates with fallback
function getPromiseDate(promise: UserPromise): Date {
  return new Date(promise.promise_date || promise.created_at);
}

/* ═══════════════════════════════════════════════════════════════════════════════
 * 📊 PERFORMANCE PATTERN ANALYZER
 *
 * Analyzes recent promise-keeping behavior to identify patterns that predict
 * psychological state. Tracks success rates, failure streaks, and behavioral
 * trends to inform tone selection.
 * ═══════════════════════════════════════════════════════════════════════════════ */
function analyzeRecentPerformance(
  recentPattern: UserPromise[],
  config: ToneConfig
): PerformanceAnalysis {
  // 🚀 COLD START: Handle users with no promise history yet
  if (recentPattern.length === 0) {
    return {
      success_rate: 0,
      recent_failures: 0,
      consecutive_failures: 0,
      trend: "stable", // 📊 No data = neutral baseline for new users
    };
  }

  // 📊 STEP 1: Calculate basic performance metrics
  const completed = recentPattern.filter((p) => p.status !== "pending");
  const kept = completed.filter((p) => p.status === "kept").length;
  const broken = completed.filter((p) => p.status === "broken").length;

  const success_rate =
    completed.length > 0
      ? (kept / completed.length) * 100 // 🎯 Percentage of promises kept
      : 0;
  const recent_failures = broken; // 💥 Total broken promises in recent period

  // 🔥 STEP 2: Calculate consecutive failure streak (most psychologically damaging)
  let consecutive_failures = 0;
  const sortedRecent = [...completed].sort((a, b) => {
    const dateA = getPromiseDate(a).getTime();
    const dateB = getPromiseDate(b).getTime();
    return dateB - dateA; // 📅 Sort by most recent first
  });

  // 💥 Count consecutive failures from most recent promise backwards
  for (const promise of sortedRecent) {
    if (promise.status === "broken") {
      consecutive_failures++; // 🚨 Each failure compounds psychological damage
    } else {
      break; // ✅ Stop at first success - streak is broken
    }
  }

  // 📈 STEP 3: Detect performance trend by comparing recent vs older behavior
  const midpoint = Math.floor(completed.length / 2);
  const recentHalf = completed.slice(0, midpoint); // 🕐 Most recent promises
  const olderHalf = completed.slice(midpoint); // 🕕 Earlier promises

  const recentSuccess =
    recentHalf.filter((p) => p.status === "kept").length /
    Math.max(recentHalf.length, 1); // 📊 Recent success rate
  const olderSuccess =
    olderHalf.filter((p) => p.status === "kept").length /
    Math.max(olderHalf.length, 1); // 📊 Historical success rate

  // 🎯 Determine if user is improving, declining, or stable
  let trend: "improving" | "declining" | "stable" = "stable";
  const trendThreshold = config.thresholds.trendSignificance;
  if (recentSuccess > olderSuccess + trendThreshold)
    trend = "improving"; // 🚀 Getting better
  else if (recentSuccess < olderSuccess - trendThreshold) trend = "declining"; // 📉 Getting worse

  return {
    success_rate,
    recent_failures,
    consecutive_failures,
    trend,
  };
}

interface StreakHealthAnalysis {
  strength: "weak" | "moderate" | "strong";
  momentum: "building" | "maintaining" | "at_risk";
}

function analyzeStreakHealth(alignmentStreak: number): StreakHealthAnalysis {
  let strength: "weak" | "moderate" | "strong";
  let momentum: "building" | "maintaining" | "at_risk";

  // Determine strength based on streak length
  if (alignmentStreak <= 3) strength = "weak";
  else if (alignmentStreak <= 14) strength = "moderate";
  else strength = "strong";

  // Determine momentum (this would ideally use trend data)
  if (alignmentStreak === 0) momentum = "at_risk";
  else if (alignmentStreak <= 7) momentum = "building";
  else momentum = "maintaining";

  return { strength, momentum };
}

interface CollapseRiskAnalysis {
  level: "low" | "medium" | "high" | "critical";
  intervention_needed: boolean;
}

function analyzeCollapseRisk(collapseScore: number): CollapseRiskAnalysis {
  let level: "low" | "medium" | "high" | "critical";
  let intervention_needed: boolean;

  if (collapseScore <= 25) {
    level = "low";
    intervention_needed = false;
  } else if (collapseScore <= 50) {
    level = "medium";
    intervention_needed = false;
  } else if (collapseScore <= 75) {
    level = "high";
    intervention_needed = true;
  } else {
    level = "critical";
    intervention_needed = true;
  }

  return { level, intervention_needed };
}

interface ToneScoreResult {
  score: number;
  reasoningFactors: ReasoningFactor[];
  intensity: number;
}

function calculateToneScore(
  performance: PerformanceAnalysis,
  streak: StreakHealthAnalysis,
  collapse: CollapseRiskAnalysis,
  config: ToneConfig
): ToneScoreResult {
  let score = 0;
  const reasoningFactors: ReasoningFactor[] = [];

  // Performance weight (configurable)
  let performanceContribution = 0;
  if (performance.success_rate >= 80)
    performanceContribution = config.weights.performance;
  else if (performance.success_rate >= 60)
    performanceContribution = config.weights.performance * 0.5;
  else if (performance.success_rate >= 40) performanceContribution = 0;
  else performanceContribution = -config.weights.performance * 0.5;

  score += performanceContribution;
  reasoningFactors.push({
    factor: "success_rate",
    value: Math.round(performance.success_rate),
  });

  // Consecutive failures penalty (configurable)
  const failurePenalty =
    performance.consecutive_failures * config.penalties.consecutiveFailureBase;
  score -= failurePenalty;
  if (performance.consecutive_failures > 0) {
    reasoningFactors.push({
      factor: "consecutive_failures",
      value: performance.consecutive_failures,
    });
  }

  // Trend adjustment (configurable)
  if (performance.trend === "improving") {
    score += config.bonuses.trendImproving;
    reasoningFactors.push({ factor: "trend", value: "improving" });
  } else if (performance.trend === "declining") {
    score -= config.penalties.trendDeclining;
    reasoningFactors.push({ factor: "trend", value: "declining" });
  }

  // Streak health weight (configurable)
  let streakContribution = 0;
  if (streak.strength === "strong") streakContribution = config.weights.streak;
  else if (streak.strength === "moderate")
    streakContribution = config.weights.streak * 0.5;
  score += streakContribution;

  if (streak.momentum === "at_risk") {
    score -= config.penalties.momentumAtRisk;
    reasoningFactors.push({ factor: "streak_momentum", value: "at_risk" });
  }

  // Collapse risk weight (configurable)
  let collapseContribution = 0;
  if (collapse.level === "low") collapseContribution = config.weights.collapse;
  else if (collapse.level === "medium")
    collapseContribution = config.weights.collapse * 0.33;
  else if (collapse.level === "high")
    collapseContribution = -config.weights.collapse * 0.33;
  else collapseContribution = -config.weights.collapse; // critical

  score += collapseContribution;
  if (collapse.level !== "low") {
    reasoningFactors.push({ factor: "collapse_risk", value: collapse.level });
  }

  const clampedScore = Math.max(-100, Math.min(100, score));

  // Calculate intensity based on score magnitude and critical factors
  const baseIntensity = Math.abs(clampedScore) / 100;
  const criticalFactors = [
    collapse.intervention_needed ? 0.3 : 0,
    performance.consecutive_failures >= 3 ? 0.2 : 0,
    performance.consecutive_failures >= 5 ? 0.3 : 0, // Escalation
  ].reduce((sum, factor) => sum + factor, 0);

  const intensity = Math.min(1, baseIntensity + criticalFactors);

  return { score: clampedScore, reasoningFactors, intensity };
}

function generateToneRecommendation(
  toneScore: number,
  performance: PerformanceAnalysis,
  collapse: CollapseRiskAnalysis,
  reasoningFactors: ReasoningFactor[],
  intensity: number,
  config: ToneConfig
): ToneAnalysis {
  let recommended_mood: BigBruhhTone;
  let reasoning: string;
  let confidence_score: number;
  let dataQuality: "insufficient" | "partial" | "robust";

  // Assess data quality based on actual promise data
  const hasAnyData = reasoningFactors.some(
    (f) =>
      f.factor === "success_rate" && typeof f.value === "number" && f.value > 0
  );
  const factorCount = reasoningFactors.length;

  if (!hasAnyData || factorCount === 0) {
    dataQuality = "insufficient";
  } else if (factorCount < 3) {
    dataQuality = "partial";
  } else {
    dataQuality = "robust";
  }

  // Handle cold start case first
  if (dataQuality === "insufficient") {
    recommended_mood = "Confrontational";
    reasoning =
      "Insufficient data - starting with provocative challenge to establish baseline";
    confidence_score = 0.5;
  }
  // Determine tone based on score, critical factors, and YOU+ taxonomy
  else if (
    collapse.intervention_needed ||
    performance.consecutive_failures >= 5
  ) {
    recommended_mood = "ColdMirror";
    reasoning = collapse.intervention_needed
      ? `Critical collapse risk (${collapse.level}) - detached intervention needed`
      : `${performance.consecutive_failures} consecutive failures - cold reality check required`;
    confidence_score = 0.95;
  } else if (
    performance.consecutive_failures >= 3 ||
    toneScore <= config.thresholds.intervention
  ) {
    recommended_mood = "Confrontational";
    reasoning =
      performance.consecutive_failures >= 3
        ? `${performance.consecutive_failures} consecutive failures require direct intervention`
        : `Poor performance pattern (score: ${toneScore}) needs firm accountability`;
    confidence_score = 0.9;
  } else if (toneScore >= config.thresholds.encouragement) {
    recommended_mood = "Encouraging";
    reasoning = `Strong performance (${performance.success_rate.toFixed(
      0
    )}% success) deserves identity reinforcement`;
    confidence_score = 0.8;
  } else {
    recommended_mood = "Confrontational";
    reasoning = `Moderate performance requires provocative challenge to break through`;
    confidence_score = 0.75;
  }

  // Adjust confidence based on data quality
  const dataQualityMultiplier =
    dataQuality === "robust" ?1.0 : dataQuality === "partial" ? 0.8 : 0.6;
  confidence_score *= dataQualityMultiplier;

  return {
    recommended_mood,
    intensity,
    reasoning,
    reasoningFactors,
    confidence_score: Math.round(confidence_score * 100) / 100,
    dataQuality,
  };
}

// Simplified tone intensity order (bloat elimination)
const TONE_INTENSITY_ORDER: BigBruhhTone[] = [
  "Encouraging",
  "Confrontational",
  "ColdMirror",
];

function getToneIntensityLevel(tone: BigBruhhTone): number {
  return TONE_INTENSITY_ORDER.indexOf(tone);
}

export function shouldOverrideTone(
  currentMood: BigBruhhTone,
  recommendedMood: BigBruhhTone,
  confidenceScore: number,
  allowCollapseOverride: boolean = false
): boolean {
  // Don't override if confidence is too low
  if (confidenceScore < 0.6) return false;

  // Always override for critical interventions (collapse spike)
  if (
    allowCollapseOverride &&
    recommendedMood === "ColdMirror" &&
    confidenceScore > 0.85
  ) {
    return true;
  }

  // Apply hysteresis: only allow one-step changes to prevent whiplash
  const currentLevel = getToneIntensityLevel(currentMood);
  const recommendedLevel = getToneIntensityLevel(recommendedMood);
  const stepDifference = Math.abs(recommendedLevel - currentLevel);

  // Allow one-step changes if confident enough
  if (stepDifference === 1 && confidenceScore > 0.75) return true;

  // Only allow larger jumps for high-confidence critical situations
  if (stepDifference > 1 && confidenceScore > 0.9 && allowCollapseOverride)
    return true;

  return false;
}

/**
 * Generates Future You identity version based on tone and identity data
 *
 * This function creates a personalized identity description that AI
 * will adopt during call. The identity varies based on selected
 * tone, creating different psychological approaches to accountability.
 *
 * Identity Mapping:
 * - Encouraging/Kind: Your future self who succeeded (supportive but honest)
 * - Confrontational/Firm: Your disciplined future self (authoritative)
 * - Ruthless: Your no-bullshit future self (intense, direct)
 * - ColdMirror/Ascension: Your transcended future self (visionary)
 *
 * @param identity User's identity data (currently unused but available for further personalization)
 * @param tone The selected tone for this call
 * @returns String description of AI's identity for this call
 */
export function generateBigBruhIdentity(
  identity: Identity | null,
  tone: BigBruhhTone
): string {
  const identityMap = {
    Encouraging: `Future You, your older self who made it through`,
    Kind: `Future You, your older self who made it through`,
    Confrontational: `Future You, your disciplined older self`,
    Firm: `Future You, your disciplined older self`,
    Ruthless: `Future You, your no-bullshit older self`,
    ColdMirror: `Future You, your brutally honest older self`,
    Ascension: `Future You, your brutally honest older self`,
  };
  return (
    identityMap[tone as keyof typeof identityMap] ||
    `Future You, your accountable older self`
  );
}

/**
 * Returns tone-specific speaking style descriptions for ElevenLabs
 *
 * This function provides detailed speaking style instructions that are
 * sent to ElevenLabs to control of AI's voice characteristics and
 * speaking patterns. Each tone has distinct vocal characteristics.
 *
 * Speaking Style Characteristics:
 * - Encouraging/Kind: Warm, gentle pauses, supportive language
 * - Confrontational/Firm: Direct, authoritative, strategic emphasis
 * - Ruthless: Intense, sharp pauses, visceral language
 * - ColdMirror/Ascension: Expansive, inspiring pauses, transcendent language
 *
 * @param tone The selected tone for this call
 * @returns Detailed speaking style description for ElevenLabs voice generation
 */
// Simplified tone descriptions (bloat elimination) - only 3 core tones
export function getToneDescription(tone: BigBruhhTone): string {
  switch (tone) {
    case "Encouraging":
      return `warm and encouraging yet uncompromisingly honest, with gentle pauses and supportive affirmations like "I understand..." and "I've been exactly where you are."`;
    case "Confrontational":
      return `direct and authoritative with strategic emphasis, using declarative statements and purposeful pauses like "Listen carefully..." and "Here's what's actually happening."`;
    case "ColdMirror":
      return `detached and factual with measured pauses, using mirror-like reflection phrases like "Let's look at what actually happened" and "The facts speak for themselves."`;
    default:
      return `balanced and professional with clear boundaries and fact-based observations`;
  }
}

export function generateToneChangeReason(
  oldMood: BigBruhhTone,
  newMood: BigBruhhTone,
  analysis: ToneAnalysis
): string {
  const intensityDescription =
    analysis.intensity > 0.8
      ? "high"
      : analysis.intensity > 0.5
      ? "moderate"
      : "low";
  return `Tone shifted from ${oldMood} to ${newMood} (${intensityDescription} intensity): ${
    analysis.reasoning
  } (confidence: ${(analysis.confidence_score * 100).toFixed(0)}%)`;
}