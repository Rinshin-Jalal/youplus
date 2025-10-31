/**
 * BigBruh MVP - Onboarding Routes
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { SupabaseService } from '../services/supabase';
import { AICallsService } from '../services/ai-calls';
import { OnboardingResponse, ApiResponse } from '../types';

export const onboardingRoutes = new Hono();

// Validation schemas
const onboardingCompleteSchema = z.object({
  responses: z.record(z.any()),
  userName: z.string().optional(),
  callTime: z.string().optional(),
  timezone: z.string().optional()
});

/**
 * Complete onboarding and extract psychological weapons
 */
onboardingRoutes.post('/complete', async (c) => {
  try {
    const userId = c.get('userId');
    const body = await c.req.json();
    
    // Validate request
    const { responses, userName, callTime, timezone } = onboardingCompleteSchema.parse(body);
    
    const supabase = new SupabaseService(c.env);
    const aiCalls = new AICallsService(c.env);
    
    // Save onboarding responses
    await supabase.saveOnboardingResponses(userId, responses);
    
    // Extract psychological weapons
    const identity = await aiCalls.extractPsychologicalWeapons(userId, responses, c.env);
    await supabase.saveIdentity(userId, identity);
    
    // Update user with onboarding completion
    await supabase.updateUser(userId, {
      name: userName,
      call_time: callTime,
      timezone: timezone || 'UTC',
      onboarding_completed: true,
      onboarding_completed_at: new Date().toISOString()
    });
    
    // Initialize streaks
    await supabase.updateStreak(userId, 'YES', new Date().toISOString().split('T')[0]);
    
    return c.json({
      success: true,
      message: 'Onboarding completed successfully',
      data: {
        weapons_extracted: Object.keys(identity).length,
        onboarding_completed: true
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Onboarding completion error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Get onboarding status
 */
onboardingRoutes.get('/status', async (c) => {
  try {
    const userId = c.get('userId');
    const supabase = new SupabaseService(c.env);
    
    const user = await supabase.getUserById(userId);
    const onboarding = await supabase.getOnboardingByUserId(userId);
    
    return c.json({
      success: true,
      data: {
        onboarding_completed: user?.onboarding_completed || false,
        onboarding_completed_at: user?.onboarding_completed_at,
        has_responses: !!onboarding,
        response_count: onboarding ? Object.keys(onboarding.responses).length : 0
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Onboarding status error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Get onboarding step definitions
 */
onboardingRoutes.get('/steps', async (c) => {
  try {
    const steps = [
      {
        stepNumber: 1,
        type: 'warning',
        title: 'BIGBRUH WILL HURT YOU',
        description: 'This isn\'t friendly motivation. This is psychological warfare against your weak self. You\'ll hate every call. But you\'ll finally change. Still here?',
        dbField: 'acceptance_warning'
      },
      {
        stepNumber: 2,
        type: 'text',
        title: 'What should I call you?',
        description: '',
        dbField: 'identity_name'
      },
      {
        stepNumber: 3,
        type: 'voice',
        title: 'Biggest Lie',
        description: 'What\'s the BIGGEST LIE you tell yourself daily?',
        dbField: 'biggest_lie',
        minSeconds: 10
      },
      {
        stepNumber: 4,
        type: 'number',
        title: 'Financial Pain',
        description: 'How much MONEY have you lost this year due to your excuses?',
        dbField: 'financial_loss_amount'
      },
      {
        stepNumber: 5,
        type: 'voice',
        title: 'Opportunity Cost',
        description: 'What job/opportunity did you miss because you weren\'t ready?',
        dbField: 'opportunity_cost_voice',
        minSeconds: 8
      },
      {
        stepNumber: 6,
        type: 'choice',
        title: 'Relationship Damage',
        description: 'Who stopped believing in you?',
        dbField: 'relationship_damage_type',
        options: ['Mom/Dad', 'Partner/Spouse', 'Friends', 'Boss/Coworkers', 'Myself']
      },
      {
        stepNumber: 7,
        type: 'voice',
        title: 'When They Gave Up',
        description: 'When did I notice they gave up on me?',
        dbField: 'relationship_moment_voice',
        minSeconds: 8
      },
      {
        stepNumber: 8,
        type: 'voice',
        title: 'Physical Disgust',
        description: 'Look in the mirror RIGHT NOW. Record what disgusts you.',
        dbField: 'physical_disgust_voice',
        minSeconds: 8
      },
      {
        stepNumber: 9,
        type: 'slider',
        title: 'Physical Rating',
        description: 'Rate your current physical self',
        dbField: 'physical_disgust_rating',
        minValue: 1,
        maxValue: 10
      },
      {
        stepNumber: 10,
        type: 'voice',
        title: 'Daily Reality',
        description: 'Describe YESTERDAY hour by hour. Where did your time actually go?',
        dbField: 'daily_reality_voice',
        minSeconds: 12
      }
    ];
    
    return c.json({
      success: true,
      data: { steps }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Onboarding steps error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});
