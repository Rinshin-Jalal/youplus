import { Hono } from 'hono';
import { requireActiveSubscription } from '@/middleware/auth';

// Import identity handlers
import {
  getCurrentIdentity,
  getIdentityStats,
  updateFinalOath,
  updateIdentity,
  updateIdentityStatus,
} from './handlers/identity';

const identityRouter = new Hono();

// Identity Routes (Subscription Required)
identityRouter.get('/:userId', requireActiveSubscription, getCurrentIdentity);
identityRouter.put('/:userId', requireActiveSubscription, updateIdentity);
identityRouter.put('/status/:userId', requireActiveSubscription, updateIdentityStatus);
identityRouter.put('/final-oath/:userId', requireActiveSubscription, updateFinalOath);
identityRouter.get('/stats/:userId', requireActiveSubscription, getIdentityStats);

export default identityRouter;