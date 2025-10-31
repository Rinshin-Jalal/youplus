/**
 * BigBruh MVP - Dashboard Routes
 */

import { Hono } from 'hono';
import { SupabaseService } from '../services/supabase';
import { ApiResponse } from '../types';

export const dashboardRoutes = new Hono();

/**
 * Get complete dashboard data
 */
dashboardRoutes.get('/', async (c) => {
  try {
    const userId = c.get('userId');
    const supabase = new SupabaseService(c.env);
    
    const dashboardData = await supabase.getDashboardData(userId);
    
    return c.json({
      success: true,
      data: dashboardData
    } as ApiResponse);
    
  } catch (error) {
    console.error('Dashboard error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Get user profile
 */
dashboardRoutes.get('/profile', async (c) => {
  try {
    const userId = c.get('userId');
    const supabase = new SupabaseService(c.env);
    
    const [user, identity] = await Promise.all([
      supabase.getUserById(userId),
      supabase.getIdentityByUserId(userId)
    ]);
    
    return c.json({
      success: true,
      data: {
        user,
        identity
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Profile error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Get streaks data
 */
dashboardRoutes.get('/streaks', async (c) => {
  try {
    const userId = c.get('userId');
    const supabase = new SupabaseService(c.env);
    
    const streak = await supabase.getStreakByUserId(userId);
    const recentCalls = await supabase.getCallsByUserId(userId, 30);
    
    // Calculate additional streak metrics
    const thisWeekCalls = recentCalls.filter(call => {
      const callDate = new Date(call.call_date);
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);
      return callDate >= weekAgo;
    });
    
    const thisWeekSuccess = thisWeekCalls.filter(call => call.response === 'YES').length;
    const thisWeekSuccessRate = thisWeekCalls.length > 0 ? (thisWeekSuccess / thisWeekCalls.length) * 100 : 0;
    
    return c.json({
      success: true,
      data: {
        current_streak: streak?.current_streak || 0,
        longest_streak: streak?.longest_streak || 0,
        last_success_date: streak?.last_success_date,
        this_week_success_rate: Math.round(thisWeekSuccessRate),
        this_week_calls: thisWeekCalls.length,
        this_week_success: thisWeekSuccess
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Streaks error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Update user settings
 */
dashboardRoutes.put('/settings', async (c) => {
  try {
    const userId = c.get('userId');
    const body = await c.req.json();
    
    const supabase = new SupabaseService(c.env);
    
    // Allowed settings to update
    const allowedUpdates = {
      call_time: body.call_time,
      timezone: body.timezone,
      name: body.name
    };
    
    // Remove undefined values
    Object.keys(allowedUpdates).forEach(key => {
      if (allowedUpdates[key as keyof typeof allowedUpdates] === undefined) {
        delete allowedUpdates[key as keyof typeof allowedUpdates];
      }
    });
    
    const updatedUser = await supabase.updateUser(userId, allowedUpdates);
    
    return c.json({
      success: true,
      message: 'Settings updated successfully',
      data: updatedUser
    } as ApiResponse);
    
  } catch (error) {
    console.error('Settings update error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Get psychological weapons (for user to see what we have on them)
 */
dashboardRoutes.get('/weapons', async (c) => {
  try {
    const userId = c.get('userId');
    const supabase = new SupabaseService(c.env);
    
    const identity = await supabase.getIdentityByUserId(userId);
    
    if (!identity) {
      return c.json({
        success: false,
        error: 'No psychological weapons found. Complete onboarding first.'
      } as ApiResponse, 404);
    }
    
    // Return top 5 most impactful weapons
    const topWeapons = [
      identity.financial_pain_point,
      identity.shame_trigger,
      identity.relationship_damage_specific,
      identity.self_sabotage_pattern,
      identity.current_self_summary
    ].filter(Boolean);
    
    return c.json({
      success: true,
      data: {
        top_weapons: topWeapons,
        total_weapons: Object.keys(identity).length,
        message: 'These are the psychological weapons we use against your weak self. They came from YOUR answers during onboarding.'
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Weapons error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});
