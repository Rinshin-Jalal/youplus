/**
 * BigBruh MVP - Supabase Service
 */

import { createClient } from '@supabase/supabase-js';
import { Env } from '../types';

export function createSupabaseClient(env: Env) {
  return createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
}

export function createSupabaseAdminClient(env: Env) {
  return createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY);
}

// Database operations
export class SupabaseService {
  private supabase;
  private supabaseAdmin;

  constructor(env: Env) {
    this.supabase = createSupabaseClient(env);
    this.supabaseAdmin = createSupabaseAdminClient(env);
  }

  // User operations
  async getUserById(userId: string) {
    const { data, error } = await this.supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();
    
    if (error) throw error;
    return data;
  }

  async updateUser(userId: string, updates: Partial<any>) {
    const { data, error } = await this.supabase
      .from('users')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', userId)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  async createUser(userData: any) {
    const { data, error } = await this.supabase
      .from('users')
      .insert(userData)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  // Onboarding operations
  async saveOnboardingResponses(userId: string, responses: any) {
    const { data, error } = await this.supabase
      .from('onboarding')
      .insert({
        user_id: userId,
        responses: responses,
        completed_at: new Date().toISOString()
      })
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  async getOnboardingByUserId(userId: string) {
    const { data, error } = await this.supabase
      .from('onboarding')
      .select('*')
      .eq('user_id', userId)
      .single();
    
    if (error) throw error;
    return data;
  }

  // Identity operations
  async saveIdentity(userId: string, identityData: any) {
    const { data, error } = await this.supabase
      .from('identity')
      .upsert({
        user_id: userId,
        ...identityData,
        updated_at: new Date().toISOString()
      })
      .eq('user_id', userId)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  async getIdentityByUserId(userId: string) {
    const { data, error } = await this.supabase
      .from('identity')
      .select('*')
      .eq('user_id', userId)
      .single();
    
    if (error) throw error;
    return data;
  }

  // Call operations
  async saveCall(callData: any) {
    const { data, error } = await this.supabase
      .from('calls')
      .insert(callData)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  }

  async getCallsByUserId(userId: string, limit: number = 10) {
    const { data, error } = await this.supabase
      .from('calls')
      .select('*')
      .eq('user_id', userId)
      .order('call_time', { ascending: false })
      .limit(limit);
    
    if (error) throw error;
    return data;
  }

  async getCallByUserIdAndDate(userId: string, date: string) {
    const { data, error } = await this.supabase
      .from('calls')
      .select('*')
      .eq('user_id', userId)
      .eq('call_date', date)
      .single();
    
    return { data, error };
  }

  // Streak operations
  async getStreakByUserId(userId: string) {
    const { data, error } = await this.supabase
      .from('streaks')
      .select('*')
      .eq('user_id', userId)
      .single();
    
    if (error && error.code !== 'PGRST116') throw error;
    return data;
  }

  async updateStreak(userId: string, response: 'YES' | 'NO' | 'MISSED', callDate: string) {
    // First try to get existing streak
    const existingStreak = await this.getStreakByUserId(userId);
    
    if (!existingStreak) {
      // Create new streak record
      const { data, error } = await this.supabase
        .from('streaks')
        .insert({
          user_id: userId,
          current_streak: response === 'YES' ? 1 : 0,
          longest_streak: response === 'YES' ? 1 : 0,
          last_success_date: response === 'YES' ? callDate : null
        })
        .select()
        .single();
      
      if (error) throw error;
      return data;
    } else {
      // Update existing streak
      const { data, error } = await this.supabase
        .rpc('update_streak_after_call', {
          user_uuid: userId,
          call_response: response,
          call_date: callDate
        });
      
      if (error) throw error;
      return await this.getStreakByUserId(userId);
    }
  }

  // Dashboard operations
  async getDashboardData(userId: string) {
    const [user, identity, streak, recentCalls] = await Promise.all([
      this.getUserById(userId),
      this.getIdentityByUserId(userId),
      this.getStreakByUserId(userId),
      this.getCallsByUserId(userId, 7)
    ]);

    // Calculate success rate
    const totalCalls = recentCalls.length;
    const successfulCalls = recentCalls.filter(call => call.response === 'YES').length;
    const successRate = totalCalls > 0 ? (successfulCalls / totalCalls) * 100 : 0;

    return {
      user,
      identity,
      current_streak: streak?.current_streak || 0,
      longest_streak: streak?.longest_streak || 0,
      recent_calls: recentCalls,
      success_rate: Math.round(successRate),
      next_call_time: user?.call_time
    };
  }
}
