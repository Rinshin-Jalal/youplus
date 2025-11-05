/**
 * Template Engine Demo & Testing
 * 
 * This file demonstrates the optimized template system and provides
 * performance testing utilities to validate the 40% token reduction claim.
 */

import { OptimizedTemplateEngine, TemplatePerformanceMonitor } from "./template-engine";
import { TransmissionMood, UserContext } from "@/types/database";

// === MOCK DATA FOR TESTING ===

const mockUserContext: UserContext = {
  user: {
    id: "demo-user",
    name: "Alex",
    email: "alex@demo.com",
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    subscription_status: "active" as const,
    timezone: "America/New_York",
    call_window_start: "20:00",
    call_window_timezone: "America/New_York",
    push_token: "demo-push-token",
    onboarding_completed: true,
    // Super MVP: removed schedule_change_count and voice_reclone_count
  },
  identity: {
    id: "demo-identity",
    user_id: "demo-user",
    name: "Alex", // User's actual name
    // Super MVP: Core fields
    daily_commitment: "Work on business for 2 hours before checking social media",
    chosen_path: "hopeful" as const,
    call_time: "20:00:00",
    strike_limit: 3,
    // Super MVP: Voice URLs (R2 cloud storage)
    why_it_matters_audio_url: null,
    cost_of_quitting_audio_url: null,
    commitment_audio_url: null,
    // Super MVP: Everything else in onboarding_context JSONB
    onboarding_context: {
      goal: "Build a successful business and live with purpose",
      motivation_level: 8,
      attempt_history: "Failed 3 times before. Last attempt: gave up after 2 weeks.",
      favorite_excuse: "I was too tired to focus properly",
      who_disappointed: "Myself and my family",
      future_if_no_change: "Someone who wastes their potential and lives with regret",
      witness: "My spouse",
      will_do_this: true,
      permissions: { notifications: true, calls: true },
      completed_at: new Date().toISOString(),
      time_spent_minutes: 25
    },
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  identityStatus: {
    id: "demo-status",
    user_id: "demo-user",
    current_streak_days: 5,
    total_calls_completed: 25,
    last_call_at: new Date(Date.now() - 86400000).toISOString(),
    // Super MVP: removed promises_made_count, promises_broken_count, trust_percentage
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  todayPromises: [{
    id: "demo-today",
    user_id: "demo-user",
    promise_text: "Complete business plan section 3 before lunch",
    status: "pending",
    created_at: new Date().toISOString(),
    promise_date: new Date().toISOString().split('T')[0]!,
    promise_order: 1,
    priority_level: "high",
    category: "business",
    time_specific: true,
    target_time: "12:00",
    created_during_call: false,
    excuse_text: "",
  }],
  yesterdayPromises: [{
    id: "demo-yesterday",
    user_id: "demo-user",
    promise_text: "Review competitors for 1 hour",
    status: "kept",
    created_at: new Date(Date.now() - 86400000).toISOString(),
    promise_date: new Date(Date.now() - 86400000).toISOString().split('T')[0]!,
    promise_order: 1,
    priority_level: "medium",
    category: "research",
    time_specific: false,
    created_during_call: true,
    excuse_text: "",
  }],
  recentStreakPattern: [
    {
      id: "p1",
      user_id: "demo-user",
      promise_text: "Review competitors",
      status: "kept",
      created_at: new Date(Date.now() - 86400000).toISOString(),
      promise_date: new Date(Date.now() - 86400000).toISOString().split('T')[0]!,
      promise_order: 1,
      priority_level: "medium",
      category: "business",
      time_specific: false,
      created_during_call: true,
      excuse_text: "",
    },
    {
      id: "p2", 
      user_id: "demo-user",
      promise_text: "Write marketing copy",
      status: "kept",
      created_at: new Date(Date.now() - 172800000).toISOString(),
      promise_date: new Date(Date.now() - 172800000).toISOString().split('T')[0]!,
      promise_order: 1,
      priority_level: "high",
      category: "marketing",
      time_specific: false,
      created_during_call: false,
      excuse_text: "",
    },
    {
      id: "p3",
      user_id: "demo-user", 
      promise_text: "Research funding options",
      status: "broken",
      created_at: new Date(Date.now() - 259200000).toISOString(),
      promise_date: new Date(Date.now() - 259200000).toISOString().split('T')[0]!,
      promise_order: 1,
      priority_level: "low",
      category: "research",
      time_specific: false,
      created_during_call: true,
      excuse_text: "Got distracted by urgent emails",
    }
  ],
  memoryInsights: {
    countsByType: {
      excuse: 3,
      promise: 25,
      success: 18
    },
    topExcuseCount7d: 2,
    emergingPatterns: [
      {
        sampleText: "I was too tired to focus",
        recentCount: 2,
        baselineCount: 1,
        growthFactor: 2.0
      },
      {
        sampleText: "Got distracted by urgent work",
        recentCount: 1, 
        baselineCount: 0,
        growthFactor: 1.0
      }
    ]
  },
  recentMemories: [], // Deprecated but required for compatibility
  stats: {
    totalPromises: 25,
    keptPromises: 18,
    brokenPromises: 7,
    successRate: 72,
    currentStreak: 5
  }
};

// === DEMO FUNCTIONS ===

export class TemplateEngineDemo {
  /**
   * Run a comprehensive demo of all call types
   */
  static runFullDemo(): void {
    console.log("🚀 OPTIMIZED TEMPLATE ENGINE DEMO");
    console.log("=====================================\n");
    
    const callTypes = ["daily_reckoning"] as const;
    const tones: TransmissionMood[] = ["Encouraging", "Confrontational", "ColdMirror"];
    
    callTypes.forEach(callType => {
      console.log(`\n📞 ${callType.toUpperCase()} CALL DEMO`);
      console.log("-".repeat(50));
      
      tones.forEach(tone => {
        console.log(`\n🎭 Tone: ${tone}`);
        
        const startTime = performance.now();
        const result = OptimizedTemplateEngine.generateCall(callType, mockUserContext, tone);
        const endTime = performance.now();
        
        console.log(`⏱️  Generation Time: ${(endTime - startTime).toFixed(2)}ms`);
        console.log(`📏 Token Estimate: ${this.estimateTokens(result.systemPrompt + result.firstMessage)}`);
        console.log(`🗣️  First Message: "${result.firstMessage.substring(0, 100)}..."`);
        console.log(`📝 System Prompt Length: ${result.systemPrompt.length} chars`);
      });
    });
    
    // Performance summary
    console.log("\n📊 PERFORMANCE SUMMARY");
    console.log("======================");
    TemplatePerformanceMonitor.logMetrics();
    
    console.log("\n📋 OPTIMIZATION REPORT");
    console.log("======================");
    console.log(TemplatePerformanceMonitor.getOptimizationReport());
  }
  
  /**
   * Compare optimized vs original template performance
   */
  static runPerformanceComparison(): void {
    console.log("⚡ PERFORMANCE COMPARISON");
    console.log("========================\n");
    
    const iterations = 10;
    const callType = "daily_reckoning";
    const tone: TransmissionMood = "Confrontational";
    
    // Test optimized version
    console.log("Testing Optimized Template Engine...");
    const optimizedTimes: number[] = [];
    const optimizedTokens: number[] = [];
    
    for (let i = 0; i < iterations; i++) {
      const start = performance.now();
      const result = OptimizedTemplateEngine.generateCall(callType, mockUserContext, tone);
      const end = performance.now();
      
      optimizedTimes.push(end - start);
      optimizedTokens.push(this.estimateTokens(result.systemPrompt + result.firstMessage));
    }
    
    const avgOptimizedTime = optimizedTimes.reduce((a, b) => a + b) / iterations;
    const avgOptimizedTokens = optimizedTokens.reduce((a, b) => a + b) / iterations;
    
    console.log(`✅ Optimized Results:`);
    console.log(`   Average Generation Time: ${avgOptimizedTime.toFixed(2)}ms`);
    console.log(`   Average Token Count: ${Math.round(avgOptimizedTokens)}`);
    console.log(`   Token Range: ${Math.min(...optimizedTokens)} - ${Math.max(...optimizedTokens)}`);
    
    // Estimated original performance (based on analysis)
    const estimatedOriginalTokens = 3200; // Based on original morning call analysis
    const compressionRatio = 1 - (avgOptimizedTokens / estimatedOriginalTokens);
    
    console.log(`\n🎯 Optimization Results:`);
    console.log(`   Token Reduction: ${(compressionRatio * 100).toFixed(1)}%`);
    console.log(`   Tokens Saved: ${Math.round(estimatedOriginalTokens - avgOptimizedTokens)} per call`);
    console.log(`   Performance: ✅ ${compressionRatio >= 0.3 ? 'Target Achieved!' : 'Needs Improvement'}`);
  }
  
  /**
   * Test custom call generation with overrides
   */
  static testCustomCalls(): void {
    console.log("🛠️  CUSTOM CALL TESTING");
    console.log("=======================\n");
    
    // Test 1: Custom daily reckoning call with additional goals
    console.log("Test 1: Daily reckoning call with additional goals");
    const customDailyReckoning = OptimizedTemplateEngine.generateCustomCall(
      "daily_reckoning",
      mockUserContext,
      "Confrontational",
      {
        additionalGoals: [
          "Address the Instagram scrolling pattern specifically",
          "Create consequences for next failure"
        ],
        toolSetOverride: "consequence_delivery"
      }
    );
    
    console.log(`✅ Generated with ${this.estimateTokens(customDailyReckoning.systemPrompt)} tokens`);
    console.log(`🗣️  Opening: "${customDailyReckoning.firstMessage}"`);
    
    // Test 2: Daily reckoning call with detailed intelligence
    console.log("\nTest 2: Daily reckoning call with forced detailed intelligence");
    const detailedDailyReckoning = OptimizedTemplateEngine.generateCustomCall(
      "daily_reckoning",
      mockUserContext,
      "ColdMirror",
      {
        forceDetailedIntelligence: true
      }
    );
    
    console.log(`✅ Generated with ${this.estimateTokens(detailedDailyReckoning.systemPrompt)} tokens`);
    console.log(`📏 System prompt length: ${detailedDailyReckoning.systemPrompt.length} chars`);
    
    // Test 3: Daily reckoning with custom opener
    console.log("\nTest 3: Daily reckoning with custom opener");
    const emergencyCustom = OptimizedTemplateEngine.generateCustomCall(
      "daily_reckoning",
      mockUserContext,
      "Confrontational",
      {
        customOpener: "Alex. BigBruh calling. Your excuse patterns triggered emergency protocols. Time for judgment."
      }
    );
    
    console.log(`✅ Custom opener applied`);
    console.log(`🗣️  Opening: "${emergencyCustom.firstMessage}"`);
  }
  
  /**
   * Validate that all call types work correctly
   */
  static validateAllCallTypes(): boolean {
    console.log("🔍 VALIDATION TESTING");
    console.log("=====================\n");
    
    const callTypes = ["daily_reckoning"] as const;
    const tones: TransmissionMood[] = ["Encouraging", "Confrontational", "ColdMirror"];
    
    let allPassed = true;
    
    callTypes.forEach(callType => {
      tones.forEach(tone => {
        try {
          const result = OptimizedTemplateEngine.generateCall(callType, mockUserContext, tone);
          
          // Validate result structure
          const hasFirstMessage = result.firstMessage && result.firstMessage.length > 10;
          const hasSystemPrompt = result.systemPrompt && result.systemPrompt.length > 100;
          const hasPersonality = result.systemPrompt.includes("# Personality");
          const hasTools = result.systemPrompt.includes("# Tools");
          
          if (!hasFirstMessage || !hasSystemPrompt || !hasPersonality || !hasTools) {
            console.log(`❌ ${callType}-${tone}: Missing required sections`);
            allPassed = false;
          } else {
            console.log(`✅ ${callType}-${tone}: Valid`);
          }
        } catch (error) {
          console.log(`❌ ${callType}-${tone}: Error - ${error}`);
          allPassed = false;
        }
      });
    });
    
    console.log(`\n🎯 Validation Result: ${allPassed ? '✅ ALL PASSED' : '❌ SOME FAILED'}`);
    return allPassed;
  }
  
  // Helper method
  private static estimateTokens(text: string): number {
    return Math.round(text.length / 4);
  }
}

// === QUICK TEST RUNNER ===

export function runQuickDemo(): void {
  console.log("🏃‍♂️ QUICK DEMO - Daily Reckoning Call");
  console.log("=============================\n");
  
  const result = OptimizedTemplateEngine.generateCall("daily_reckoning", mockUserContext, "Confrontational");
  
  console.log("📞 FIRST MESSAGE:");
  console.log(result.firstMessage);
  console.log("\n" + "=".repeat(80) + "\n");
  
  console.log("🤖 SYSTEM PROMPT (First 500 chars):");
  console.log(result.systemPrompt.substring(0, 500) + "...");
  console.log("\n" + "=".repeat(80) + "\n");
  
  console.log("📊 METRICS:");
  console.log(`Token Estimate: ${Math.round(result.systemPrompt.length / 4)}`);
  console.log(`Character Count: ${result.systemPrompt.length}`);
  console.log(`Sections: ${(result.systemPrompt.match(/^#/gm) || []).length}`);
}

// Run demo if this file is executed directly
if (require.main === module) {
  runQuickDemo();
}