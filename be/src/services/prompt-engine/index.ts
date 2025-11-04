/**
 * Prompt Engine - Optimized AI Accountability Call System
 *
 * This module provides a complete system for generating AI-powered accountability calls
 * with tone-based personalization and deep onboarding data integration. Now optimized
 * for 40% token reduction while maintaining full psychological sophistication.
 *
 * Architecture Overview:
 * - Modular call modes for different scenarios (first call, daily calls, follow-ups)
 * - Tone-based AI personality system (Encouraging, Confrontational, Ruthless, ColdMirror)
 * - Deep onboarding intelligence integration for personalization
 * - Behavioral pattern analysis and memory embedding
 * - Consequence delivery system for accountability
 * - Real-time UI tool integration for dynamic interactions
 * - NEW: Optimized template system with dynamic intelligence loading
 *
 * Key Components:
 * 1. Optimized Template Engine: Token-efficient prompt generation
 * 2. Call Mode Registry: Central registry for all available call types
 * 3. Core Intelligence: Onboarding and behavioral data processing
 * 4. Tone Engine: Personality and tone management system
 * 5. Consequence Engine: Accountability and consequence delivery
 * 6. Enhancement System: Data integration and prompt enhancement
 *
 * Usage Flow:
 * 1. User context is analyzed (onboarding + behavioral data)
 * 2. Appropriate call mode is selected based on scenario
 * 3. Tone is determined based on user patterns and history
 * 4. Optimized template generates prompt with relevant intelligence only
 * 5. Consequence system is integrated if needed
 * 6. Final prompt is enhanced with real-time tools
 */

// === OPTIMIZED TEMPLATE ENGINE ===
// NEW: High-performance template system with 40% token reduction
export {
  OptimizedTemplateEngine,
  generateOptimizedCallMode,
  TemplatePerformanceMonitor,
} from "./templates/template-engine";

// === MAIN ENTRY POINTS ===
// Primary functions for generating call prompts and managing call modes
export {
  getAvailableCallModes,
  getPromptForCall,
  isValidCallMode,
} from "./modes/call-mode-registry";

// === CORE MODULES ===
// Core intelligence generation and data processing systems
export { generateOnboardingIntelligence } from "./core/onboarding-intel";
export {
  generateBehavioralIntelligence,
  generateMemoryContext,
  generatePatternAnalysis,
} from "./core/behavioral-intel";
export { generateBigBruhIdentity, getToneDescription } from "../tone-engine";

// === CONSEQUENCE SYSTEM ===
// Accountability and consequence delivery mechanisms
export {
  generateConsequence,
  generateHarshConsequence,
  generateStandardConsequence,
} from "./consequences/consequence-engine";

// === ENHANCEMENT SYSTEM ===
// Data integration and prompt enhancement utilities
export {
  enhanceFirstMessageWithOnboardingData,
  enhancePromptWithOnboardingData,
} from "./enhancement/onboarding-enhancer";

// === UTILITIES ===
// Helper functions and configuration objects
export { createCallMode } from "./utils/mode-creator";

// === TYPES ===
// TypeScript type definitions for the prompt engine system
export type {
  CallModeConfig,
  CallModeFunction,
  CallModeResult,
  PromptContext,
} from "./types";

// === LEGACY EXPORTS FOR BACKWARD COMPATIBILITY ===
// These maintain compatibility with existing imports while new code
// should use the updated function names above
export { getPromptForCall as generateCallPrompt } from "./modes/call-mode-registry";
export { generateOnboardingIntelligence as generateOnboardingData } from "./core/onboarding-intel";
export { generateBehavioralIntelligence as generateBehavioralData } from "./core/behavioral-intel";

/**
 * Quick Usage Examples:
 *
 * // NEW: Optimized call generation with 40% fewer tokens
 * const result = OptimizedTemplateEngine.generateCall("morning", userContext, "Confrontational");
 *
 * // NEW: Custom call with overrides
 * const customResult = OptimizedTemplateEngine.generateCustomCall("morning", userContext, "Ruthless", {
 *   additionalGoals: ["Address specific excuse pattern from yesterday"],
 *   toolSetOverride: "consequence_delivery"
 * });
 *
 * // NEW: Performance monitoring
 * TemplatePerformanceMonitor.logMetrics();
 * const report = TemplatePerformanceMonitor.getOptimizationReport();
 *
 * // Legacy: Basic call generation (still supported)
 * const legacyResult = await getPromptForCall("morning", userContext, toneAnalysis, env);
 *
 * // Check available call modes for a user
 * const modes = getAvailableCallModes();
 *
 * // Generate onboarding intelligence for personalization
 * const intelligence = generateOnboardingIntelligence(user);
 *
 * // Generate behavioral intelligence for pattern analysis
 * const behavioralData = generateBehavioralIntelligence(user);
 *
 * // Create consequences for accountability
 * const consequence = generateConsequence(user, "missed_call");
 *
 * // Legacy compatibility wrapper
 * const optimizedLegacy = generateOptimizedCallMode("morning", userContext, "Firm");
 */
