import { Hono } from 'hono';
import { requireAuth } from '@/middleware/auth';
import {
  triggerMorningCallsAdmin,
  triggerEveningCallsAdmin,
  triggerUserCallAdmin,
  triggerVoipPushAdmin,
  processScheduledCallsAdmin,
  processRetryQueueAdmin,
  triggerOnboardingCallAdmin
} from './handlers/triggers';

const router = new Hono();

// Manual Trigger Routes (high security risk - token protected)
// Development/admin only - protected by debugProtection middleware in index.ts

// Trigger morning calls for all users
router.post('/morning', requireAuth, triggerMorningCallsAdmin);

// Trigger evening calls for all users
router.post('/evening', requireAuth, triggerEveningCallsAdmin);

// Trigger a call for a specific user
router.post('/user/:userId/:callType', requireAuth, triggerUserCallAdmin);

// Send immediate VoIP push with custom payload
router.post('/voip', requireAuth, triggerVoipPushAdmin);

// Trigger onboarding call for testing
router.post('/onboarding/:userId', triggerOnboardingCallAdmin);

// Process scheduled calls
router.post('/scheduled-calls', requireAuth, processScheduledCallsAdmin);

// Process retry queue
router.post('/retry-queue', requireAuth, processRetryQueueAdmin);

export default router;