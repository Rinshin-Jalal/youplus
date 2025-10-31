/**
 * BigBruh MVP - Type Definitions
 */

export interface Env {
  // Supabase configuration
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
  SUPABASE_SERVICE_ROLE_KEY: string;
  
  // AI configuration
  OPENAI_API_KEY: string;
  ELEVENLABS_API_KEY: string;
  ELEVENLABS_VOICE_ID: string;
  
  // Environment
  ENVIRONMENT: string;
  BACKEND_URL: string;
  
  // Cloudflare R2
  AUDIO_BUCKET: R2Bucket;
  
  // Optional
  DEBUG_ACCESS_TOKEN?: string;
}

// User types
export interface User {
  id: string;
  email?: string;
  name?: string;
  call_time?: string;
  timezone?: string;
  onboarding_completed: boolean;
  onboarding_completed_at?: string;
  created_at: string;
  updated_at: string;
}

// Onboarding types
export interface OnboardingStep {
  stepNumber: number;
  type: 'warning' | 'text' | 'voice' | 'number' | 'choice' | 'slider' | 'time';
  title: string;
  description: string;
  dbField: string;
  minValue?: number;
  maxValue?: number;
  minSeconds?: number;
  options?: string[];
}

export interface OnboardingResponse {
  stepNumber: number;
  type: string;
  value: any;
  dbField: string;
  timestamp: string;
  voiceUri?: string;
  duration?: number;
}

export interface OnboardingData {
  user_id: string;
  responses: Record<string, OnboardingResponse>;
  completed_at: string;
}

// Identity types (psychological weapons)
export interface Identity {
  id: string;
  user_id: string;
  
  // 10 Core weapons from onboarding
  biggest_lie?: string;
  financial_loss_amount?: number;
  opportunity_cost_voice?: string;
  relationship_damage_type?: string;
  relationship_moment_voice?: string;
  physical_disgust_voice?: string;
  physical_disgust_rating?: number;
  daily_reality_voice?: string;
  time_vampire_type?: string;
  quit_trigger_emotion?: string;
  intellectual_excuse_voice?: string;
  accountability_graveyard_count?: number;
  accountability_trigger_type?: string;
  daily_non_negotiable?: string;
  mortality_urgency_voice?: string;
  war_cry_voice?: string;
  
  // AI-generated insights
  shame_trigger?: string;
  financial_pain_point?: string;
  relationship_damage_specific?: string;
  breaking_point_event?: string;
  self_sabotage_pattern?: string;
  accountability_history?: string;
  current_self_summary?: string;
  aspirational_identity_gap?: string;
  non_negotiable_commitment?: string;
  war_cry_or_death_vision?: string;
  
  created_at: string;
  updated_at: string;
}

// Call types
export interface Call {
  id: string;
  user_id: string;
  call_date: string;
  call_time: string;
  response: 'YES' | 'NO' | 'MISSED';
  weapons_used?: string[];
  call_duration_seconds?: number;
  call_type: 'STANDARD' | 'SHAME' | 'EMERGENCY';
  created_at: string;
}

export interface CallRequest {
  user_id: string;
  call_type?: 'STANDARD' | 'SHAME' | 'EMERGENCY';
  weapons_to_deploy?: string[];
}

export interface CallGeneration {
  script: string;
  weapons_deployed: string[];
  estimated_duration: number;
}

// Streak types
export interface Streak {
  id: string;
  user_id: string;
  current_streak: number;
  longest_streak: number;
  last_success_date?: string;
  created_at: string;
  updated_at: string;
}

// API Response types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

// Dashboard types
export interface DashboardData {
  user: User;
  identity: Identity;
  current_streak: number;
  longest_streak: number;
  recent_calls: Call[];
  success_rate: number;
  next_call_time?: string;
}
