# Viral Shareability Features API

Complete API documentation for You+ viral features: Future Self Messages, Shareable Content, Voice Clip Shares, Referrals, and Accountability Circles.

## Base URL

All viral endpoints are mounted at `/api/viral`

## Authentication

All endpoints (except `validateReferralCode`) require active subscription via `requireActiveSubscription` middleware.

---

## 1. Future Self Messages

### Create Future Self Message

Record a message to your future self.

**POST** `/api/viral/future-self/create`

**Body:**
```json
{
  "audio_url": "string",              // R2 URL where audio is stored
  "transcript": "string",             // Optional, auto-transcribed
  "user_prompt": "string",            // Question answered
  "reveal_duration_days": 30          // 30, 60, 90, or 180
}
```

**Response:**
```json
{
  "success": true,
  "message": {
    "id": "uuid",
    "user_id": "uuid",
    "audio_url": "string",
    "reveal_at": "2025-12-09T...",
    "context_snapshot": {
      "streak_days": 7,
      "trust_score": 85,
      "promises_kept": 12,
      "total_promises": 15
    }
  },
  "reveal_at": "2025-12-09T..."
}
```

### Get Future Self Messages

Get all messages for a user (revealed and unrevealed).

**GET** `/api/viral/future-self/:userId`

**Response:**
```json
{
  "success": true,
  "revealed": [...],
  "unrevealed": [...],
  "total": 5
}
```

### Reveal Future Self Message

Mark message as revealed and get comparison data.

**POST** `/api/viral/future-self/reveal/:messageId`

**Response:**
```json
{
  "success": true,
  "message": {...},
  "then": {
    "streak_days": 7,
    "trust_score": 85,
    "promises_kept": 12
  },
  "now": {
    "streak_days": 37,
    "trust_score": 92,
    "promises_kept": 42
  },
  "improvements": {
    "streak_change": 30,
    "trust_change": 7,
    "promises_change": 30
  }
}
```

### Update Share Permission

**PUT** `/api/viral/future-self/share/:messageId`

**Body:**
```json
{
  "share_permission": true
}
```

---

## 2. Shareable Content

### Generate Shareable Content

Create metadata for shareable content (actual rendering happens iOS-side).

**POST** `/api/viral/shareable/generate`

**Body:**
```json
{
  "content_type": "countdown",        // countdown|streak|transformation|confrontation|future_self_reveal
  "format": "image",                  // image|video
  "data_snapshot": {
    "streak_days": 30,
    "next_call_hours": 4,
    "next_call_minutes": 23
  },
  "template_id": "streak_milestone",
  "asset_url": "optional_r2_url"
}
```

**Response:**
```json
{
  "success": true,
  "content": {
    "id": "uuid",
    "content_type": "streak",
    "format": "image",
    "data_snapshot": {...},
    "early_adopter_number": 2847
  }
}
```

### Get Shareable Content

**GET** `/api/viral/shareable/:userId?type=streak&limit=10`

**Query Params:**
- `type`: Filter by content_type
- `limit`: Max results (default 20)

**Response:**
```json
{
  "success": true,
  "content": [...],
  "by_type": {
    "streak": [...],
    "countdown": [...]
  },
  "total": 15
}
```

### Track Share

Increment share count for analytics.

**POST** `/api/viral/shareable/track-share/:contentId`

**Response:**
```json
{
  "success": true,
  "content": {
    "id": "uuid",
    "shared_count": 5
  }
}
```

---

## 3. Voice Clip Shares

### Create Voice Clip

**POST** `/api/viral/voice-clips/create`

**Body:**
```json
{
  "audio_url": "string",
  "transcript": "string",
  "duration_seconds": 7,
  "clip_type": "question",            // question|excuse|victory|pattern|future_self|custom
  "livekit_session_id": "uuid",       // Optional
  "call_uuid": "string",              // Optional
  "ai_suggested": true,               // Optional
  "ai_confidence_score": 0.92,        // Optional
  "waveform_data": {...},             // Optional
  "caption_text": "string"            // Optional
}
```

**Response:**
```json
{
  "success": true,
  "clip": {
    "id": "uuid",
    "audio_url": "string",
    "transcript": "string",
    "clip_type": "question",
    "share_permission": false
  }
}
```

### Get Voice Clips

**GET** `/api/viral/voice-clips/:userId?type=victory&shareable=true&limit=20`

**Query Params:**
- `type`: Filter by clip_type
- `shareable`: Filter by share_permission (true/false)
- `limit`: Max results (default 20)

### Get Suggested Clips

Get AI-suggested clips for sharing (high confidence, not yet shared).

**GET** `/api/viral/voice-clips/suggested/:userId`

**Response:**
```json
{
  "success": true,
  "suggested_clips": [...],
  "total": 3
}
```

### Update Voice Clip Permission

**PUT** `/api/viral/voice-clips/permission/:clipId`

**Body:**
```json
{
  "share_permission": true
}
```

**Response:**
```json
{
  "success": true,
  "clip": {
    "id": "uuid",
    "share_permission": true,
    "permission_granted_at": "2025-11-09T...",
    "shared_count": 1
  }
}
```

---

## 4. Referrals

### Create Referral

Send a "call out" to a friend.

**POST** `/api/viral/referrals/create`

**Body:**
```json
{
  "referred_email": "friend@example.com",
  "referred_phone": "+1234567890",    // Optional
  "message_template": "direct",       // direct|provocative|movement|custom
  "custom_message": "string",         // Optional (if template=custom)
  "attribution_source": "sms"         // sms|email|link|qr_code
}
```

**Response:**
```json
{
  "success": true,
  "referral": {
    "id": "uuid",
    "status": "sent",
    "created_at": "2025-11-09T..."
  },
  "referral_code": "YOU12345ABC"
}
```

### Get Referral Stats

**GET** `/api/viral/referrals/stats/:userId`

**Response:**
```json
{
  "success": true,
  "stats": {
    "total_sent": 10,
    "total_signed_up": 5,
    "total_active": 3,
    "conversion_rate": 50
  },
  "next_reward": {
    "tier": 10,
    "type": "founding_member",
    "progress": 5,
    "needed": 10
  },
  "recent_referrals": [...],
  "unlocked_rewards": [...]
}
```

### Get Referral Code

**GET** `/api/viral/referrals/code/:userId`

**Response:**
```json
{
  "success": true,
  "referral_code": "YOU12345ABC",
  "early_adopter_number": 2847,
  "share_url": "https://youplus.app/join?ref=YOU12345ABC"
}
```

### Validate Referral Code

**Public endpoint** - no auth required.

**POST** `/api/viral/referrals/validate`

**Body:**
```json
{
  "referral_code": "YOU12345ABC"
}
```

**Response:**
```json
{
  "success": true,
  "valid": true,
  "referrer_id": "uuid",
  "early_adopter_number": 2847
}
```

### Get Referral Rewards

**GET** `/api/viral/referrals/rewards/:userId`

**Response:**
```json
{
  "success": true,
  "current_referrals": 5,
  "rewards": [
    {
      "tier": 1,
      "type": "movement_starter",
      "name": "Movement Starter",
      "description": "Badge + early adopter display",
      "unlocked": true,
      "progress": 5
    },
    {
      "tier": 3,
      "type": "accountability_circle",
      "name": "Accountability Circle",
      "description": "Unlock circles feature",
      "unlocked": true,
      "progress": 5
    },
    {
      "tier": 5,
      "type": "custom_voice_prompts",
      "name": "Custom Voice Prompts",
      "description": "Personalize call questions",
      "unlocked": true,
      "progress": 5
    },
    {
      "tier": 10,
      "type": "founding_member",
      "name": "Founding Member",
      "description": "Lifetime priority features",
      "unlocked": false,
      "progress": 5
    }
  ]
}
```

---

## 5. Accountability Circles

### Create Accountability Circle

**Requires:** 3+ referral sign-ups

**POST** `/api/viral/circles/create`

**Body:**
```json
{
  "name": "My Circle"                 // Optional
}
```

**Response:**
```json
{
  "success": true,
  "circle": {
    "id": "uuid",
    "name": "My Circle",
    "created_by": "uuid",
    "is_active": true
  },
  "membership": {
    "id": "uuid",
    "share_streak": true,
    "share_trust_score": false,
    "share_call_status": false
  }
}
```

**Error if not enough referrals:**
```json
{
  "error": "Accountability circles require 3 referrals",
  "required_referrals": 3,
  "current_referrals": 1
}
```

### Get Accountability Circles

**GET** `/api/viral/circles/:userId`

**Response:**
```json
{
  "success": true,
  "circles": [
    {
      "circle": {
        "id": "uuid",
        "name": "My Circle",
        "created_by": "uuid"
      },
      "membership": {
        "share_streak": true,
        "share_trust_score": false,
        "share_call_status": false,
        "joined_at": "2025-11-09T..."
      },
      "member_count": 5
    }
  ]
}
```

### Invite to Circle

**POST** `/api/viral/circles/invite`

**Body:**
```json
{
  "circle_id": "uuid",
  "invited_user_id": "uuid"
}
```

**Response:**
```json
{
  "success": true,
  "membership": {
    "id": "uuid",
    "circle_id": "uuid",
    "user_id": "uuid",
    "share_streak": true
  }
}
```

### Update Circle Privacy

**PUT** `/api/viral/circles/privacy/:circleId`

**Body:**
```json
{
  "share_streak": true,
  "share_trust_score": true,
  "share_call_status": false
}
```

**Response:**
```json
{
  "success": true,
  "membership": {
    "share_streak": true,
    "share_trust_score": true,
    "share_call_status": false
  }
}
```

### Get Circle Stats

**GET** `/api/viral/circles/stats/:circleId`

**Response:**
```json
{
  "success": true,
  "member_stats": [
    {
      "user_id": "uuid",
      "streak_days": 30,              // Only if share_streak=true
      "trust_score": 87,              // Only if share_trust_score=true
      "last_call_status": "completed" // Only if share_call_status=true
    }
  ],
  "circle_aggregates": {
    "total_members": 5,
    "avg_streak": 25,
    "active_this_week": 4
  }
}
```

---

## Database Tables

### future_self_messages
- Stores voice messages to future self
- Includes context snapshot for comparison
- Reveal scheduling and tracking

### shareable_content
- Tracks shareable content metadata
- Actual rendering happens iOS-side
- Share count analytics

### voice_clip_shares
- 5-10 second voice clips from calls
- Explicit consent required (share_permission)
- AI suggestion tracking

### referrals
- "Call out your friends" referral tracking
- Status progression: sent → signed_up → active_7_days → active_30_days
- Attribution source tracking

### accountability_circles
- Circle creation and management
- Member invitation system

### circle_members
- Junction table for circle membership
- Granular privacy controls (streak, trust score, call status)
- Opt-in/opt-out tracking

### referral_rewards
- Unlockable rewards at referral milestones
- Tier progression: 1, 3, 5, 10, 25

---

## User Schema Extensions

### users table additions:
- `early_adopter_number`: BIGINT - Sequential join number
- `referred_by_user_id`: UUID - Who referred this user
- `referral_code`: TEXT - Unique referral code

---

## Error Codes

- `400` - Bad Request (validation error)
- `403` - Forbidden (access denied or feature locked)
- `404` - Not Found
- `500` - Internal Server Error

---

## Next Steps for iOS Implementation

1. **Future Self Messages**:
   - Record audio during onboarding
   - Upload to R2
   - Call create endpoint
   - Show countdown timer
   - Handle reveal push notification
   - Generate share card

2. **Shareable Content**:
   - SwiftUI view generators for each content type
   - Snapshot to image
   - Share sheet integration
   - Track share via API

3. **Voice Clips**:
   - Extract clips from call recordings
   - AI moment detection (optional)
   - Preview UI with waveform
   - Explicit consent flow
   - Share with captions

4. **Referrals**:
   - Invite flow UI
   - Message template selection
   - SMS/email/link sharing
   - Stats dashboard
   - Rewards display

5. **Circles**:
   - Circle creation UI
   - Member invitation
   - Privacy settings
   - Circle stats view
   - Weekly reports

---

## Viral Metrics to Track

1. **Generation Rate**: % users who generate content
2. **Share Rate**: % who actually share externally
3. **Attribution**: Shares → views → downloads
4. **Retention Impact**: Do sharers retain better?
5. **Virality Coefficient**: Shares per active user

**Target KPIs:**
- Generation rate: >40%
- Share rate: >15%
- Attribution rate: >5%
- Virality coefficient: >0.3
