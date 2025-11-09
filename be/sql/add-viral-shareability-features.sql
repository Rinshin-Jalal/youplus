/**
 * Viral Shareability Features Migration
 *
 * Adds tables and columns to support:
 * 1. Future Self Messages - Record messages to your future self
 * 2. Shareable Content - Algorithm-friendly social media formats
 * 3. Voice Clip Shares - Shareable voice moments from calls
 * 4. Confrontational Referral System - "Call out your friends"
 * 5. Early Adopter Numbering - User join sequence tracking
 *
 * Created: 2025-11-09
 * Feature Branch: claude/viral-shareability-features-011CUxjQhayADitKEWpS3Y1o
 */

-- ============================================================================
-- 1. Early Adopter Numbering (Extend Users Table)
-- ============================================================================
-- Add sequential numbering for "YOU+ MEMBER #2,847" branding

DO $$ BEGIN
  -- Add early adopter number column
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='users' AND column_name='early_adopter_number'
  ) THEN
    ALTER TABLE public.users ADD COLUMN early_adopter_number BIGINT;
  END IF;

  -- Add referral tracking
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='users' AND column_name='referred_by_user_id'
  ) THEN
    ALTER TABLE public.users ADD COLUMN referred_by_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='users' AND column_name='referral_code'
  ) THEN
    ALTER TABLE public.users ADD COLUMN referral_code TEXT UNIQUE;
  END IF;

END $$;

-- Create sequence for early adopter numbering
CREATE SEQUENCE IF NOT EXISTS early_adopter_sequence START WITH 1;

-- Create function to auto-assign early adopter numbers
CREATE OR REPLACE FUNCTION assign_early_adopter_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.early_adopter_number IS NULL THEN
    NEW.early_adopter_number := nextval('early_adopter_sequence');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger for new users
DROP TRIGGER IF EXISTS assign_early_adopter_trigger ON public.users;
CREATE TRIGGER assign_early_adopter_trigger
  BEFORE INSERT ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION assign_early_adopter_number();

-- Backfill existing users with numbers (ordered by created_at)
DO $$
DECLARE
  user_record RECORD;
BEGIN
  FOR user_record IN
    SELECT id FROM public.users
    WHERE early_adopter_number IS NULL
    ORDER BY created_at ASC
  LOOP
    UPDATE public.users
    SET early_adopter_number = nextval('early_adopter_sequence')
    WHERE id = user_record.id;
  END LOOP;
END $$;

-- Index for referral lookups
CREATE INDEX IF NOT EXISTS idx_users_referred_by ON public.users(referred_by_user_id);
CREATE INDEX IF NOT EXISTS idx_users_referral_code ON public.users(referral_code);

COMMENT ON COLUMN public.users.early_adopter_number IS 'Sequential join number for "YOU+ MEMBER #X" branding';
COMMENT ON COLUMN public.users.referred_by_user_id IS 'User who referred this user (for referral tracking)';
COMMENT ON COLUMN public.users.referral_code IS 'Unique referral code for this user to share';

-- ============================================================================
-- 2. Future Self Messages Table
-- ============================================================================
-- Users record messages to their future self, revealed on chosen date

CREATE TABLE IF NOT EXISTS public.future_self_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- User Reference
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

  -- Message Content
  audio_url TEXT NOT NULL,                    -- R2 storage URL
  transcript TEXT,                            -- Auto-transcribed
  user_prompt TEXT,                           -- What question they answered

  -- Timing
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reveal_at TIMESTAMPTZ NOT NULL,             -- User-chosen reveal date
  reveal_duration_days INT NOT NULL,          -- 30, 60, 90, 180

  -- Reveal Status
  revealed BOOLEAN DEFAULT false,
  revealed_at TIMESTAMPTZ,

  -- Shareability
  share_permission BOOLEAN DEFAULT false,     -- User opted to allow sharing
  share_count INT DEFAULT 0,                  -- How many times shared

  -- Context Snapshot (for comparison on reveal)
  context_snapshot JSONB,                     -- {streak, trust_score, promises_kept}

  -- Metadata
  metadata JSONB DEFAULT '{}'::jsonb,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
) TABLESPACE pg_default;

-- Indexes
CREATE INDEX idx_future_self_messages_user_id ON public.future_self_messages(user_id);
CREATE INDEX idx_future_self_messages_reveal_at ON public.future_self_messages(reveal_at) WHERE NOT revealed;
CREATE INDEX idx_future_self_messages_revealed ON public.future_self_messages(user_id, revealed);

-- RLS Policies
ALTER TABLE public.future_self_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own future self messages"
  ON public.future_self_messages FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own future self messages"
  ON public.future_self_messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own future self messages"
  ON public.future_self_messages FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own future self messages"
  ON public.future_self_messages FOR DELETE
  USING (auth.uid() = user_id);

COMMENT ON TABLE public.future_self_messages IS 'Messages users record to their future self, revealed after chosen duration';

-- ============================================================================
-- 3. Shareable Content Table
-- ============================================================================
-- Auto-generated social media content (streaks, countdowns, transformations)

CREATE TABLE IF NOT EXISTS public.shareable_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- User Reference
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

  -- Content Details
  content_type TEXT NOT NULL CHECK (
    content_type IN ('countdown', 'streak', 'transformation', 'confrontation', 'future_self_reveal')
  ),
  format TEXT NOT NULL CHECK (format IN ('image', 'video')),

  -- Asset Storage
  asset_url TEXT,                             -- R2 URL (if generated server-side)
  template_id TEXT,                           -- Which template was used

  -- Content Data
  data_snapshot JSONB NOT NULL,               -- All data needed to regenerate
  -- Example for streak: {streak_days: 30, early_adopter_number: 2847, trust_score: 87}
  -- Example for countdown: {next_call_hours: 4, next_call_minutes: 23, promise_text: "Code 30min"}

  -- Usage Tracking
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  shared_count INT DEFAULT 0,                 -- User tapped share
  view_count INT DEFAULT 0,                   -- If trackable via link

  -- Metadata
  metadata JSONB DEFAULT '{}'::jsonb,         -- {aspect_ratio, duration_sec, etc}

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
) TABLESPACE pg_default;

-- Indexes
CREATE INDEX idx_shareable_content_user_id ON public.shareable_content(user_id);
CREATE INDEX idx_shareable_content_type ON public.shareable_content(content_type, created_at DESC);
CREATE INDEX idx_shareable_content_shared ON public.shareable_content(shared_count DESC);

-- RLS Policies
ALTER TABLE public.shareable_content ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own shareable content"
  ON public.shareable_content FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own shareable content"
  ON public.shareable_content FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own shareable content"
  ON public.shareable_content FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own shareable content"
  ON public.shareable_content FOR DELETE
  USING (auth.uid() = user_id);

COMMENT ON TABLE public.shareable_content IS 'Auto-generated algorithm-friendly social media content';

-- ============================================================================
-- 4. Voice Clip Shares Table
-- ============================================================================
-- Shareable 5-10 second clips of user's own voice from calls

CREATE TABLE IF NOT EXISTS public.voice_clip_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- User Reference
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

  -- Call Reference (optional - might be from future self message)
  livekit_session_id UUID REFERENCES public.livekit_sessions(id) ON DELETE SET NULL,
  call_uuid TEXT,

  -- Clip Details
  audio_url TEXT NOT NULL,                    -- R2 URL for 5-10 sec clip
  transcript TEXT NOT NULL,                   -- What was said
  duration_seconds INT NOT NULL,

  -- Clip Type
  clip_type TEXT NOT NULL CHECK (
    clip_type IN ('question', 'excuse', 'victory', 'pattern', 'future_self', 'custom')
  ),

  -- AI Detection (if auto-suggested)
  ai_suggested BOOLEAN DEFAULT false,
  ai_confidence_score DECIMAL(3, 2),          -- 0.00 to 1.00

  -- Privacy & Sharing
  share_permission BOOLEAN DEFAULT false,      -- Explicit opt-in required
  permission_granted_at TIMESTAMPTZ,
  shared_count INT DEFAULT 0,
  view_count INT DEFAULT 0,

  -- Visual Metadata
  waveform_data JSONB,                        -- For visualization
  caption_text TEXT,                          -- Auto-generated caption

  -- Metadata
  metadata JSONB DEFAULT '{}'::jsonb,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
) TABLESPACE pg_default;

-- Indexes
CREATE INDEX idx_voice_clip_shares_user_id ON public.voice_clip_shares(user_id);
CREATE INDEX idx_voice_clip_shares_session ON public.voice_clip_shares(livekit_session_id);
CREATE INDEX idx_voice_clip_shares_type ON public.voice_clip_shares(clip_type, created_at DESC);
CREATE INDEX idx_voice_clip_shares_shared ON public.voice_clip_shares(share_permission, created_at DESC);

-- RLS Policies
ALTER TABLE public.voice_clip_shares ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own voice clips"
  ON public.voice_clip_shares FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own voice clips"
  ON public.voice_clip_shares FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own voice clips"
  ON public.voice_clip_shares FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own voice clips"
  ON public.voice_clip_shares FOR DELETE
  USING (auth.uid() = user_id);

COMMENT ON TABLE public.voice_clip_shares IS 'Shareable voice clips from calls - requires explicit user consent';

-- ============================================================================
-- 5. Referrals Table
-- ============================================================================
-- Track "call out your friends" referral system

CREATE TABLE IF NOT EXISTS public.referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Referrer
  referrer_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

  -- Referred Person
  referred_email TEXT,                        -- Email or identifier
  referred_phone TEXT,                        -- Phone number if shared
  referred_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,

  -- Referral Details
  referral_code TEXT,                         -- Code used (referrer's code)
  message_template TEXT,                      -- Which confrontational template used
  custom_message TEXT,                        -- If user wrote their own

  -- Status Tracking
  status TEXT DEFAULT 'sent' CHECK (
    status IN ('sent', 'viewed', 'signed_up', 'active_7_days', 'active_30_days')
  ),

  -- Timing
  sent_at TIMESTAMPTZ DEFAULT now(),
  viewed_at TIMESTAMPTZ,
  signed_up_at TIMESTAMPTZ,
  became_active_at TIMESTAMPTZ,

  -- Attribution
  attribution_source TEXT,                    -- 'sms', 'email', 'link', 'qr_code'

  -- Metadata
  metadata JSONB DEFAULT '{}'::jsonb,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
) TABLESPACE pg_default;

-- Indexes
CREATE INDEX idx_referrals_referrer ON public.referrals(referrer_user_id, status);
CREATE INDEX idx_referrals_referred_user ON public.referrals(referred_user_id);
CREATE INDEX idx_referrals_status ON public.referrals(status, created_at DESC);

-- RLS Policies
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own referrals"
  ON public.referrals FOR SELECT
  USING (auth.uid() = referrer_user_id OR auth.uid() = referred_user_id);

CREATE POLICY "Users can create referrals"
  ON public.referrals FOR INSERT
  WITH CHECK (auth.uid() = referrer_user_id);

CREATE POLICY "Users can update their own referrals"
  ON public.referrals FOR UPDATE
  USING (auth.uid() = referrer_user_id);

COMMENT ON TABLE public.referrals IS 'Confrontational referral system - "Call out your friends"';

-- ============================================================================
-- 6. Accountability Circles Table
-- ============================================================================
-- Groups of friends who opted into shared accountability

CREATE TABLE IF NOT EXISTS public.accountability_circles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Circle Details
  created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT,                                  -- Optional circle name

  -- Settings
  is_active BOOLEAN DEFAULT true,

  -- Metadata
  metadata JSONB DEFAULT '{}'::jsonb,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
) TABLESPACE pg_default;

-- Indexes
CREATE INDEX idx_accountability_circles_creator ON public.accountability_circles(created_by);

-- RLS Policies
ALTER TABLE public.accountability_circles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view their circles"
  ON public.accountability_circles FOR SELECT
  USING (
    auth.uid() = created_by OR
    EXISTS (
      SELECT 1 FROM public.circle_members
      WHERE circle_id = id AND user_id = auth.uid()
    )
  );

CREATE POLICY "Creators can create circles"
  ON public.accountability_circles FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Creators can update their circles"
  ON public.accountability_circles FOR UPDATE
  USING (auth.uid() = created_by);

COMMENT ON TABLE public.accountability_circles IS 'Groups of friends with shared accountability visibility';

-- ============================================================================
-- 7. Circle Members Table
-- ============================================================================
-- Junction table for circle membership with privacy settings

CREATE TABLE IF NOT EXISTS public.circle_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- References
  circle_id UUID NOT NULL REFERENCES public.accountability_circles(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

  -- Privacy Settings (what this user shares with circle)
  share_streak BOOLEAN DEFAULT true,
  share_trust_score BOOLEAN DEFAULT false,
  share_call_status BOOLEAN DEFAULT false,    -- ✅/❌ for last call

  -- Status
  is_active BOOLEAN DEFAULT true,

  -- Timing
  joined_at TIMESTAMPTZ DEFAULT now(),
  left_at TIMESTAMPTZ,

  -- Metadata
  metadata JSONB DEFAULT '{}'::jsonb,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  -- Constraints
  UNIQUE(circle_id, user_id)
) TABLESPACE pg_default;

-- Indexes
CREATE INDEX idx_circle_members_circle ON public.circle_members(circle_id, is_active);
CREATE INDEX idx_circle_members_user ON public.circle_members(user_id, is_active);

-- RLS Policies
ALTER TABLE public.circle_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view circle memberships"
  ON public.circle_members FOR SELECT
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.circle_members cm
      WHERE cm.circle_id = circle_id AND cm.user_id = auth.uid() AND cm.is_active = true
    )
  );

CREATE POLICY "Users can join circles"
  ON public.circle_members FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own membership"
  ON public.circle_members FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can leave circles"
  ON public.circle_members FOR DELETE
  USING (auth.uid() = user_id);

COMMENT ON TABLE public.circle_members IS 'Circle membership with granular privacy controls';

-- ============================================================================
-- 8. Referral Rewards Table
-- ============================================================================
-- Track unlocked rewards from referrals

CREATE TABLE IF NOT EXISTS public.referral_rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- User Reference
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

  -- Reward Details
  reward_type TEXT NOT NULL CHECK (
    reward_type IN (
      'movement_starter',           -- 1 referral
      'accountability_circle',      -- 3 referrals
      'custom_voice_prompts',       -- 5 referrals
      'founding_member',            -- 10 referrals
      'legendary_caller'            -- 25 referrals
    )
  ),
  reward_tier INT NOT NULL,                   -- 1, 3, 5, 10, 25

  -- Status
  unlocked BOOLEAN DEFAULT false,
  unlocked_at TIMESTAMPTZ,

  -- Referral Count at Unlock
  referral_count_at_unlock INT,

  -- Metadata
  metadata JSONB DEFAULT '{}'::jsonb,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  -- Constraints
  UNIQUE(user_id, reward_type)
) TABLESPACE pg_default;

-- Indexes
CREATE INDEX idx_referral_rewards_user ON public.referral_rewards(user_id, unlocked);
CREATE INDEX idx_referral_rewards_tier ON public.referral_rewards(reward_tier, unlocked_at DESC);

-- RLS Policies
ALTER TABLE public.referral_rewards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own rewards"
  ON public.referral_rewards FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own rewards"
  ON public.referral_rewards FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own rewards"
  ON public.referral_rewards FOR UPDATE
  USING (auth.uid() = user_id);

COMMENT ON TABLE public.referral_rewards IS 'Unlockable rewards for referral milestones';

-- ============================================================================
-- 9. Update Timestamp Triggers
-- ============================================================================

-- Apply updated_at triggers to all new tables
CREATE TRIGGER update_future_self_messages_updated_at
  BEFORE UPDATE ON public.future_self_messages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shareable_content_updated_at
  BEFORE UPDATE ON public.shareable_content
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_voice_clip_shares_updated_at
  BEFORE UPDATE ON public.voice_clip_shares
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_referrals_updated_at
  BEFORE UPDATE ON public.referrals
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_accountability_circles_updated_at
  BEFORE UPDATE ON public.accountability_circles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_circle_members_updated_at
  BEFORE UPDATE ON public.circle_members
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_referral_rewards_updated_at
  BEFORE UPDATE ON public.referral_rewards
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 10. Helper Functions
-- ============================================================================

-- Function to get user's referral stats
CREATE OR REPLACE FUNCTION get_user_referral_stats(p_user_id UUID)
RETURNS TABLE (
  total_sent INT,
  total_signed_up INT,
  total_active INT,
  next_reward_tier INT,
  next_reward_type TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::INT as total_sent,
    COUNT(*) FILTER (WHERE status IN ('signed_up', 'active_7_days', 'active_30_days'))::INT as total_signed_up,
    COUNT(*) FILTER (WHERE status IN ('active_7_days', 'active_30_days'))::INT as total_active,
    CASE
      WHEN COUNT(*) FILTER (WHERE status IN ('signed_up', 'active_7_days', 'active_30_days')) >= 25 THEN 50
      WHEN COUNT(*) FILTER (WHERE status IN ('signed_up', 'active_7_days', 'active_30_days')) >= 10 THEN 25
      WHEN COUNT(*) FILTER (WHERE status IN ('signed_up', 'active_7_days', 'active_30_days')) >= 5 THEN 10
      WHEN COUNT(*) FILTER (WHERE status IN ('signed_up', 'active_7_days', 'active_30_days')) >= 3 THEN 5
      WHEN COUNT(*) FILTER (WHERE status IN ('signed_up', 'active_7_days', 'active_30_days')) >= 1 THEN 3
      ELSE 1
    END::INT as next_reward_tier,
    CASE
      WHEN COUNT(*) FILTER (WHERE status IN ('signed_up', 'active_7_days', 'active_30_days')) >= 25 THEN 'legendary_caller'
      WHEN COUNT(*) FILTER (WHERE status IN ('signed_up', 'active_7_days', 'active_30_days')) >= 10 THEN 'founding_member'
      WHEN COUNT(*) FILTER (WHERE status IN ('signed_up', 'active_7_days', 'active_30_days')) >= 5 THEN 'custom_voice_prompts'
      WHEN COUNT(*) FILTER (WHERE status IN ('signed_up', 'active_7_days', 'active_30_days')) >= 3 THEN 'accountability_circle'
      WHEN COUNT(*) FILTER (WHERE status IN ('signed_up', 'active_7_days', 'active_30_days')) >= 1 THEN 'movement_starter'
      ELSE 'movement_starter'
    END::TEXT as next_reward_type
  FROM public.referrals
  WHERE referrer_user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_user_referral_stats IS 'Returns referral statistics and next reward tier for user';

-- ============================================================================
-- Migration Complete
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ VIRAL SHAREABILITY FEATURES COMPLETE';
  RAISE NOTICE '========================================';
  RAISE NOTICE '   - Early adopter numbering added';
  RAISE NOTICE '   - Future self messages table created';
  RAISE NOTICE '   - Shareable content table created';
  RAISE NOTICE '   - Voice clip shares table created';
  RAISE NOTICE '   - Referrals table created';
  RAISE NOTICE '   - Accountability circles tables created';
  RAISE NOTICE '   - Referral rewards table created';
  RAISE NOTICE '   - Helper functions created';
  RAISE NOTICE '========================================';
END $$;
