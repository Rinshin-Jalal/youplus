import { Hono } from 'hono';
import { requireActiveSubscription } from '@/middleware/auth';

// Import onboarding handlers
import {
  postExtractOnboardingData,
  postOnboardingV3Complete,
} from './handlers/onboarding';
import { postConversionOnboardingComplete } from './handlers/conversion-complete';
import { postOnboardingAnalyzeVoice } from '../voice/handlers/voice';

const onboardingRouter = new Hono();

// V3 Onboarding Routes (Authenticated - ONLY after payment+signup)
onboardingRouter.post('/v3/complete', requireActiveSubscription, postOnboardingV3Complete);

// Conversion Onboarding Routes (Authenticated - New 42-step flow)
onboardingRouter.post('/conversion/complete', requireActiveSubscription, postConversionOnboardingComplete);

// Data Extraction Routes (Authenticated)
onboardingRouter.post('/extract-data', requireActiveSubscription, postExtractOnboardingData);

// Voice analysis for onboarding (Pre-auth onboarding)
onboardingRouter.post('/analyze-voice', postOnboardingAnalyzeVoice);

export default onboardingRouter;