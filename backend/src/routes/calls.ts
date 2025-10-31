/**
 * BigBruh MVP - Calls Routes
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { SupabaseService } from '../services/supabase';
import { AICallsService } from '../services/ai-calls';
import { ApiResponse } from '../types';

export const callsRoutes = new Hono();

// Validation schemas
const callResponseSchema = z.object({
  response: z.enum(['YES', 'NO', 'MISSED']),
  call_duration_seconds: z.number().optional(),
  weapons_used: z.array(z.string()).optional()
});

/**
 * Generate and return daily call audio
 */
callsRoutes.get('/generate', async (c) => {
  try {
    const userId = c.get('userId');
    const callType = c.req.query('type') as 'STANDARD' | 'SHAME' | 'EMERGENCY' || 'STANDARD';
    
    const supabase = new SupabaseService(c.env);
    const aiCalls = new AICallsService(c.env);
    
    // Get user identity for psychological weapons
    const identity = await supabase.getIdentityByUserId(userId);
    if (!identity) {
      return c.json({
        success: false,
        error: 'User identity not found. Please complete onboarding first.'
      } as ApiResponse, 404);
    }
    
    // Get failure count for shame calls
    const recentCalls = await supabase.getCallsByUserId(userId, 7);
    const failureCount = recentCalls.filter(call => call.response === 'NO').length;
    
    // Generate call with audio
    const callData = await aiCalls.generateDailyCall(identity, callType, failureCount);
    
    return c.json({
      success: true,
      data: {
        script: callData.script,
        weapons_deployed: callData.weapons_deployed,
        estimated_duration: callData.estimated_duration,
        // Note: Audio is returned as base64 in real implementation
        audio_base64: 'base64_audio_data_here'
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Call generation error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Save call response
 */
callsRoutes.post('/response', async (c) => {
  try {
    const userId = c.get('userId');
    const body = await c.req.json();
    
    // Validate request
    const { response, call_duration_seconds, weapons_used } = callResponseSchema.parse(body);
    
    const supabase = new SupabaseService(c.env);
    
    // Save call record
    const callData = {
      user_id: userId,
      call_date: new Date().toISOString().split('T')[0],
      call_time: new Date().toISOString(),
      response,
      call_duration_seconds,
      weapons_used: weapons_used || [],
      call_type: 'STANDARD'
    };
    
    await supabase.saveCall(callData);
    
    // Update streaks
    await supabase.updateStreak(userId, response, callData.call_date);
    
    return c.json({
      success: true,
      message: 'Call response saved successfully',
      data: {
        response,
        call_date: callData.call_date
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Call response error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Get call history
 */
callsRoutes.get('/history', async (c) => {
  try {
    const userId = c.get('userId');
    const limit = parseInt(c.req.query('limit') || '10');
    
    const supabase = new SupabaseService(c.env);
    const calls = await supabase.getCallsByUserId(userId, limit);
    
    return c.json({
      success: true,
      data: {
        calls,
        total: calls.length
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Call history error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Get today's call status
 */
callsRoutes.get('/today', async (c) => {
  try {
    const userId = c.get('userId');
    const today = new Date().toISOString().split('T')[0];
    
    const supabase = new SupabaseService(c.env);
    const { data: existingCall, error } = await supabase.getCallByUserIdAndDate(userId, today);
    
    let callStatus = 'PENDING';
    let callData = null;
    
    if (!error && existingCall) {
      callStatus = 'COMPLETED';
      callData = existingCall;
    }
    
    return c.json({
      success: true,
      data: {
        date: today,
        status: callStatus,
        call: callData
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Today call status error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Schedule call (webhook for external scheduling systems)
 */
callsRoutes.post('/schedule', async (c) => {
  try {
    const userId = c.get('userId');
    const body = await c.req.json();
    
    // This would integrate with your scheduling system
    // For now, we'll just log the request
    
    console.log('Call scheduled for user:', userId, 'with data:', body);
    
    return c.json({
      success: true,
      message: 'Call scheduled successfully'
    } as ApiResponse);
    
  } catch (error) {
    console.error('Call scheduling error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});
