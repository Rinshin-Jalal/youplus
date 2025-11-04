// Simplified tone system (bloat elimination) - Keep 3 core tones for MVP
export type BigBruhhTone =
  | "Confrontational" // Default: Provocative but targeted (primary tone)
  | "ColdMirror" // Alternative: Detached, factual, guilt-inducing
  | "Encouraging"; // Fallback: Warm but identity-reinforcing

// Legacy type alias for backward compatibility
export type TransmissionMood = BigBruhhTone;

export interface User {
  id: string;
  created_at: string;
  updated_at: string;
  name: string;
  email: string;
  subscription_status: "active" | "trialing" | "cancelled" | "past_due";
  timezone: string;
  call_window_start?: string; // When calls start (e.g., "20:30")
  call_window_timezone?: string; // Timezone for call window
  voice_clone_id?: string;
  push_token?: string; // Keep in users table (one token per user)
  onboarding_completed: boolean;
  onboarding_completed_at?: string;
  schedule_change_count: number; // Max 2 per month
  voice_reclone_count: number; // Max 1 per month
  revenuecat_customer_id?: string;
}

export interface OnboardingData {
  responses: Record<string, any>;
  commitments: Record<string, any>;
  hunger_voice?: string;
  identity_gap?: string;
  defense_system?: string;
  voice_recordings: string[];
  activation_moment?: string;
  blueprint_response?: string;
  enemy_identification?: string;
  [key: string]: any; // Allow additional fields as onboarding evolves
}

// NEW: Intelligent Identity table - AI-extracted psychological insights
// V3 REDESIGN: Psychological weapons for brutal accountability calls
export interface Identity {
  // ═══════════════════════════════════════════════════════════════════════════════
  // SYSTEM FIELDS (unchanged)
  // ═══════════════════════════════════════════════════════════════════════════════
  id: string;
  user_id: string;
  name: string; // User's name
  identity_summary: string; // Auto-generated summary of psychological profile
  created_at: string;
  updated_at: string;

  // ═══════════════════════════════════════════════════════════════════════════════
  // DEPRECATED FIELDS (keep for backward compatibility, will be removed in V4)
  // ═══════════════════════════════════════════════════════════════════════════════
  daily_non_negotiable?: string; // DEPRECATED - use non_negotiable_commitment instead
  transformation_target_date?: string; // DEPRECATED - integrated into breaking_point_event

  // ═══════════════════════════════════════════════════════════════════════════════
  // PSYCHOLOGICAL WEAPON FIELDS (10 intense leverage points for personalized calls)
  // ═══════════════════════════════════════════════════════════════════════════════

  // WEAPON 1: SHAME TRIGGER
  // What makes them feel most ashamed/disgusted about themselves
  // Extracted from: physical_disgust_trigger, relationship_damage, fear_version
  // Used in calls: "Remember what you said about [shame_trigger]? Still true?"
  shame_trigger?: string;

  // WEAPON 2: FINANCIAL PAIN POINT
  // Specific money/career opportunity cost of their weakness
  // Extracted from: financial_consequence, parental_sacrifice, procrastination_focus
  // Used in calls: "You've lost [financial_pain_point] because you're weak"
  financial_pain_point?: string;

  // WEAPON 3: RELATIONSHIP DAMAGE
  // Exact person who gave up on them + when they noticed
  // Extracted from: relationship_damage, external_judge, disappointment_check
  // Used in calls: "[Person] stopped believing in you when [moment]. Prove them wrong today."
  relationship_damage_specific?: string;

  // WEAPON 4: BREAKING POINT EVENT
  // The catastrophic event that would FORCE them to change
  // Extracted from: breaking_point, urgency_mortality, fear_identity
  // Used in calls: "You said only [event] would make you change. Why wait?"
  breaking_point_event?: string;

  // WEAPON 5: SELF-SABOTAGE PATTERN
  // Their specific pattern of ruining success + emotional trigger + frequency
  // Extracted from: sabotage_method, emotional_quit_trigger, intellectual_excuse, quit_counter
  // Used in calls: "Day 3 and [emotion] hits. You quit. Like the last [number] times."
  self_sabotage_pattern?: string;

  // WEAPON 6: ACCOUNTABILITY HISTORY
  // Pattern of abandoning help + what actually works for them
  // Extracted from: accountability_graveyard, accountability_style, past_success_story
  // Used in calls: "You've quit [number] systems. This is [number]+1 unless you [what works]"
  accountability_history?: string;

  // ANCHOR 1: CURRENT SELF SUMMARY
  // Brutal honest assessment of who they are NOW (2-3 sentences max)
  // Extracted from: current_identity, core_struggle, daily_time_audit, biggest_lie
  // Used in calls: "You're still [current_self]. When does that change?"
  current_self_summary?: string;

  // ANCHOR 2: ASPIRATIONAL IDENTITY GAP
  // The GAP between who they want to be and who they are (the pain)
  // Extracted from: aspirated_identity, identity_goal, success_metric
  // Used in calls: "You want [aspiration] but you're [current]. That gap is killing you."
  aspirational_identity_gap?: string;

  // ANCHOR 3: NON-NEGOTIABLE COMMITMENT
  // Their ONE daily action + the consequence if they break it
  // Extracted from: daily_non_negotiable, failure_threshold, sacrifice_list
  // Used in calls: "Did you [action]? Yes or no. Strike [X] of [Y]."
  non_negotiable_commitment?: string;

  // WEAPON 7: WAR CRY OR DEATH VISION
  // Either their motivational phrase OR their nightmare future
  // Extracted from: war_cry, fear_identity, urgency_mortality
  // Used in calls: "Remember: [war_cry] or become [death_vision]"
  war_cry_or_death_vision?: string;

  // DEPRECATED: Backward compatibility fields (use consolidated fields above)
  war_cry?: string; // Use war_cry_or_death_vision instead
  aspirated_identity?: string; // Use aspirational_identity_gap instead
  primary_excuse?: string; // Use self_sabotage_pattern instead
  core_struggle?: string; // Use current_self_summary instead
  fear_identity?: string; // Use breaking_point_event or war_cry_or_death_vision instead
  sabotage_method?: string; // Use self_sabotage_pattern instead
  accountability_trigger?: string; // Use non_negotiable_commitment instead
  biggest_enemy?: string; // Use shame_trigger or relationship_damage_specific instead
}

// NEW: Identity Status table from schema.sql
export interface IdentityStatus {
  id: string;
  user_id: string;
  trust_percentage?: number;
  next_call_timestamp?: string;
  promises_made_count?: number;
  promises_broken_count?: number;
  current_streak_days?: number;
  last_updated?: string;
  memory_insights?: MemoryInsights;
  status_summary?: IdentityStatusSummary;
}

export interface IdentityStatusSummary {
  disciplineLevel: "CRISIS" | "GROWTH" | "STUCK" | "STABLE" | "UNKNOWN";
  disciplineMessage: string;
  notificationTitle: string;
  notificationMessage: string;
  generatedAt: string;
}

// NEW: Onboarding table from schema.sql (simple JSONB structure)
// Onboarding table stores all responses in JSONB format
export interface Onboarding {
  id: string;
  user_id?: string;
  responses: Record<string, any>; // All onboarding responses stored here
  created_at: string;
  updated_at: string;
}

// REMOVED: OnboardingResponseV3 table (bloat elimination)
// All onboarding data now stored in main onboarding table's JSONB responses column

export type PromiseStatus = "pending" | "kept" | "broken";
export type PromisePriority = "low" | "medium" | "high" | "critical";

export interface UserPromise {
  id: string;
  user_id: string;
  created_at: string;
  promise_date: string;
  promise_text: string;
  status: PromiseStatus;
  excuse_text?: string;
  promise_order: number;
  priority_level: PromisePriority;
  category: string;
  time_specific: boolean;
  target_time?: string;
  created_during_call: boolean;
  parent_promise_id?: string;
}

// Simplified to single call type (bloat elimination)
export type CallType = "daily_reckoning";

export interface CallRecording {
  id: string;
  user_id: string;
  created_at: string;
  call_type: CallType;
  audio_url: string;
  duration_sec: number;
  confidence_scores?: Record<string, any>;
  conversation_id?: string;
  status?: string;
  transcript_json?: Record<string, any>;
  transcript_summary?: string;
  cost_cents?: number;
  start_time?: string;
  end_time?: string;
  call_successful?: "success" | "failure" | "unknown";
  source?: "vapi" | "elevenlabs";

  // NEW: Retry tracking fields
  is_retry?: boolean; // Is this a retry attempt?
  retry_attempt_number?: number; // Which retry attempt (1, 2, 3)
  original_call_uuid?: string; // UUID of the original missed call
  retry_reason?: "missed" | "declined" | "failed";
  urgency?: "high" | "critical" | "emergency";
  acknowledged?: boolean; // Was this call answered?
  acknowledged_at?: string;
  timeout_at?: string; // When to consider it missed
}

// Memory embedding feature removed in bloat elimination
// Stub types for backward compatibility
export type ContentType = "excuse" | "craving" | "demon" | "echo" | "pattern" | "breakthrough";
export interface MemoryEmbedding {
  id: string;
  user_id: string;
  source_id: string;
  content_type: ContentType;
  text_content: string;
  embedding: number[];
  created_at: string;
  metadata: Record<string, any>;
}
export interface MemoryInsights {
  countsByType: Record<string, number>;
  topExcuseCount7d: number;
  emergingPatterns: Array<{
    sampleText: string;
    recentCount: number;
    baselineCount: number;
    growthFactor: number;
  }>;
}

export interface UserContext {
  user: User;
  todayPromises: UserPromise[];
  yesterdayPromises: UserPromise[];
  recentStreakPattern: UserPromise[];
  recentMemories: MemoryEmbedding[]; // Deprecated: kept empty for backward compatibility
  memoryInsights: MemoryInsights;
  identity: Identity | null;
  identityStatus: IdentityStatus | null;
  stats: {
    totalPromises: number;
    keptPromises: number;
    brokenPromises: number;
    successRate: number;
    currentStreak: number;
  };
}

// Complete database schema type for type-safe Supabase client
export interface Database {
  public: {
    Tables: {
      users: {
        Row: User;
        Insert: Omit<User, "id" | "created_at" | "updated_at">;
        Update: Partial<Omit<User, "id" | "created_at">>;
      };
      identity: {
        Row: Identity;
        Insert: Omit<Identity, "id" | "created_at" | "updated_at">;
        Update: Partial<Omit<Identity, "id" | "created_at">>;
      };
      identity_status: {
        Row: IdentityStatus;
        Insert: Omit<IdentityStatus, "id" | "last_updated">;
        Update: Partial<Omit<IdentityStatus, "id">>;
      };
      promises: {
        Row: UserPromise;
        Insert: Omit<UserPromise, "id" | "created_at">;
        Update: Partial<Omit<UserPromise, "id" | "created_at">>;
      };
      calls: {
        Row: CallRecording;
        Insert: Omit<CallRecording, "id" | "created_at">;
        Update: Partial<Omit<CallRecording, "id" | "created_at">>;
      };
      onboarding: {
        Row: Onboarding;
        Insert: Omit<Onboarding, "id" | "created_at" | "updated_at">;
        Update: Partial<Omit<Onboarding, "id" | "created_at">>;
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      [_ in never]: never;
    };
    Enums: {
      [_ in never]: never;
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
}
