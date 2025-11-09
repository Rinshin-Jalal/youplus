import { Hono } from 'hono';
import { requireActiveSubscription } from '@/middleware/auth';

// Import viral feature handlers
import {
  createFutureSelfMessage,
  getFutureSelfMessages,
  revealFutureSelfMessage,
  updateSharePermission,
} from './handlers/future-self';

import {
  generateShareableContent,
  getShareableContent,
  trackShare,
} from './handlers/shareable-content';

import {
  createVoiceClip,
  getVoiceClips,
  updateVoiceClipPermission,
  getSuggestedClips,
} from './handlers/voice-clips';

import {
  createReferral,
  getReferralStats,
  getUserReferralCode,
  validateReferralCode,
  getReferralRewards,
} from './handlers/referrals';

import {
  createAccountabilityCircle,
  getAccountabilityCircles,
  inviteToCircle,
  updateCirclePrivacy,
  getCircleStats,
} from './handlers/circles';

const viralRouter = new Hono();

// ============================================================================
// Future Self Messages Routes
// ============================================================================
viralRouter.post('/future-self/create', requireActiveSubscription, createFutureSelfMessage);
viralRouter.get('/future-self/:userId', requireActiveSubscription, getFutureSelfMessages);
viralRouter.post('/future-self/reveal/:messageId', requireActiveSubscription, revealFutureSelfMessage);
viralRouter.put('/future-self/share/:messageId', requireActiveSubscription, updateSharePermission);

// ============================================================================
// Shareable Content Routes
// ============================================================================
viralRouter.post('/shareable/generate', requireActiveSubscription, generateShareableContent);
viralRouter.get('/shareable/:userId', requireActiveSubscription, getShareableContent);
viralRouter.post('/shareable/track-share/:contentId', requireActiveSubscription, trackShare);

// ============================================================================
// Voice Clip Shares Routes
// ============================================================================
viralRouter.post('/voice-clips/create', requireActiveSubscription, createVoiceClip);
viralRouter.get('/voice-clips/:userId', requireActiveSubscription, getVoiceClips);
viralRouter.get('/voice-clips/suggested/:userId', requireActiveSubscription, getSuggestedClips);
viralRouter.put('/voice-clips/permission/:clipId', requireActiveSubscription, updateVoiceClipPermission);

// ============================================================================
// Referral System Routes
// ============================================================================
viralRouter.post('/referrals/create', requireActiveSubscription, createReferral);
viralRouter.get('/referrals/stats/:userId', requireActiveSubscription, getReferralStats);
viralRouter.get('/referrals/code/:userId', requireActiveSubscription, getUserReferralCode);
viralRouter.post('/referrals/validate', validateReferralCode);  // Public - for signup
viralRouter.get('/referrals/rewards/:userId', requireActiveSubscription, getReferralRewards);

// ============================================================================
// Accountability Circles Routes
// ============================================================================
viralRouter.post('/circles/create', requireActiveSubscription, createAccountabilityCircle);
viralRouter.get('/circles/:userId', requireActiveSubscription, getAccountabilityCircles);
viralRouter.post('/circles/invite', requireActiveSubscription, inviteToCircle);
viralRouter.put('/circles/privacy/:circleId', requireActiveSubscription, updateCirclePrivacy);
viralRouter.get('/circles/stats/:circleId', requireActiveSubscription, getCircleStats);

export default viralRouter;
