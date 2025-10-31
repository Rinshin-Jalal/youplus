/**
 * BigBruh MVP - VoIP Routes
 * Handles VoIP push notifications and call scheduling
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { SupabaseService } from '../services/supabase';
import { AICallsService } from '../services/ai-calls';
import { ApiResponse } from '../types';

export const voipRoutes = new Hono();

// Validation schemas
const voipTokenSchema = z.object({
  token: z.string(),
  deviceType: z.enum(['ios', 'android']),
  deviceModel: z.string().optional(),
  osVersion: z.string().optional()
});

const callScheduleSchema = z.object({
  userId: z.string().uuid(),
  callTime: z.string(), // HH:MM format
  timezone: z.string(),
  callType: z.enum(['STANDARD', 'SHAME', 'EMERGENCY']).default('STANDARD')
});

/**
 * Register VoIP push token
 */
voipRoutes.post('/register-token', async (c) => {
  try {
    const userId = c.get('userId');
    const body = await c.req.json();
    
    // Validate request
    const { token, deviceType, deviceModel, osVersion } = voipTokenSchema.parse(body);
    
    const supabase = new SupabaseService(c.env);
    
    // Save VoIP token to user profile
    await supabase.updateUser(userId, {
      voip_push_token: token,
      voip_device_type: deviceType,
      voip_device_model: deviceModel,
      voip_os_version: osVersion,
      voip_token_updated_at: new Date().toISOString()
    });
    
    return c.json({
      success: true,
      message: 'VoIP token registered successfully'
    } as ApiResponse);
    
  } catch (error) {
    console.error('VoIP token registration error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Schedule daily call
 */
voipRoutes.post('/schedule-call', async (c) => {
  try {
    const body = await c.req.json();
    
    // Validate request
    const { userId, callTime, timezone, callType } = callScheduleSchema.parse(body);
    
    const supabase = new SupabaseService(c.env);
    
    // Update user call preferences
    await supabase.updateUser(userId, {
      call_time: callTime,
      timezone: timezone,
      call_type: callType,
      call_scheduled_at: new Date().toISOString()
    });
    
    // Schedule the call using your preferred scheduling service
    await scheduleVoIPCall(userId, callTime, timezone, callType, c.env);
    
    return c.json({
      success: true,
      message: 'Daily call scheduled successfully',
      data: {
        callTime,
        timezone,
        callType
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Call scheduling error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Trigger immediate call (for testing)
 */
voipRoutes.post('/trigger-call', async (c) => {
  try {
    const userId = c.get('userId');
    const callType = c.req.query('type') as 'STANDARD' | 'SHAME' | 'EMERGENCY' || 'STANDARD';
    
    const supabase = new SupabaseService(c.env);
    const aiCalls = new AICallsService(c.env);
    
    // Get user identity
    const identity = await supabase.getIdentityByUserId(userId);
    if (!identity) {
      return c.json({
        success: false,
        error: 'User identity not found. Complete onboarding first.'
      } as ApiResponse, 404);
    }
    
    // Get user's VoIP token
    const user = await supabase.getUserById(userId);
    if (!user?.voip_push_token) {
      return c.json({
        success: false,
        error: 'No VoIP token registered. Enable push notifications first.'
      } as ApiResponse, 400);
    }
    
    // Generate call
    const callData = await aiCalls.generateDailyCall(identity, callType);
    
    // Send VoIP push notification
    await sendVoIPPush(user.voip_push_token, {
      callId: generateCallId(),
      handle: 'BigBruh',
      script: callData.script,
      audioUrl: null, // Would be generated on-demand
      callType: callType
    });
    
    return c.json({
      success: true,
      message: 'Call triggered successfully',
      data: {
        callId: generateCallId(),
        script: callData.script,
        weapons_deployed: callData.weapons_deployed,
        estimated_duration: callData.estimated_duration
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Call trigger error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Get VoIP configuration
 */
voipRoutes.get('/config', async (c) => {
  try {
    const userId = c.get('userId');
    const supabase = new SupabaseService(c.env);
    
    const user = await supabase.getUserById(userId);
    
    return c.json({
      success: true,
      data: {
        hasVoipToken: !!user?.voip_push_token,
        deviceType: user?.voip_device_type,
        callTime: user?.call_time,
        timezone: user?.timezone,
        callType: user?.call_type || 'STANDARD',
        tokenUpdatedAt: user?.voip_token_updated_at
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('VoIP config error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Handle VoIP push notification delivery report
 */
voipRoutes.post('/push-delivery', async (c) => {
  try {
    const body = await c.req.json();
    const { callId, delivered, timestamp, error } = body;
    
    // Log delivery status for monitoring
    console.log('VoIP push delivery report:', {
      callId,
      delivered,
      timestamp,
      error
    });
    
    // TODO: Store delivery reports in database for analytics
    
    return c.json({
      success: true,
      message: 'Delivery report received'
    } as ApiResponse);
    
  } catch (error) {
    console.error('Push delivery report error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

// Helper functions

async function scheduleVoIPCall(
  userId: string,
  callTime: string,
  timezone: string,
  callType: string,
  env: any
): Promise<void> {
  // This would integrate with your preferred scheduling service
  // Options: Cron jobs, AWS EventBridge, Google Cloud Scheduler, etc.
  
  console.log(`Scheduling VoIP call for user ${userId} at ${callTime} ${timezone} (${callType})`);
  
  // Example: Store in database for cron job to process
  const supabase = new SupabaseService(env);
  await supabase.saveCall({
    user_id: userId,
    call_date: getNextCallDate(callTime, timezone),
    call_time: new Date().toISOString(),
    response: 'SCHEDULED',
    call_type: callType,
    created_at: new Date().toISOString()
  });
}

async function sendVoIPPush(token: string, payload: any): Promise<void> {
  // This would integrate with your push notification service
  // Options: Apple Push Notification Service, Firebase Cloud Messaging, etc.
  
  console.log('Sending VoIP push notification:', {
    token: token.substring(0, 10) + '...',
    payload
  });
  
  // For iOS, you'd use APNs with VoIP push type
  // For Android, you'd use FCM with high priority and notification channel
  
  // Example implementation for iOS:
  try {
    const apnsPayload = {
      aps: {
        alert: {
          title: 'BigBruh',
          body: 'Daily accountability call',
          'sound-1': 'default' // VoIP sound
        },
        'mutable-content': 1,
        'content-available': 1,
        'push-type': 'voip'
      },
      'call-id': payload.callId,
      'handle': payload.handle,
      'script': payload.script,
      'call-type': payload.callType
    };
    
    // Send to APNs (implement actual APNs client)
    console.log('APNs payload:', JSON.stringify(apnsPayload, null, 2));
    
  } catch (error) {
    console.error('Failed to send VoIP push:', error);
    throw error;
  }
}

function generateCallId(): string {
  return `call_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

function getNextCallDate(callTime: string, timezone: string): string {
  // Calculate next call date based on user's time and timezone
  const now = new Date();
  const [hours, minutes] = callTime.split(':').map(Number);
  
  // Create date in user's timezone
  const userDate = new Date(now.toLocaleString("en-US", { timeZone: timezone }));
  userDate.setHours(hours, minutes, 0, 0);
  
  // If time has passed today, schedule for tomorrow
  if (userDate <= now) {
    userDate.setDate(userDate.getDate() + 1);
  }
  
  return userDate.toISOString().split('T')[0];
}
