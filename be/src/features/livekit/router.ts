import { Hono } from 'hono';
import {
  postInitiateLiveKitCall,
  getLiveKitCallStatus,
  postEndLiveKitCall,
} from './handlers/livekit-api';

const router = new Hono();

// LiveKit Call Management Routes
// POST /livekit/initiate - Initiate a new LiveKit call
router.post('/initiate', postInitiateLiveKitCall);

// GET /livekit/:callUUID - Get call status
router.get('/:callUUID', getLiveKitCallStatus);

// POST /livekit/:callUUID/end - End a call
router.post('/:callUUID/end', postEndLiveKitCall);

export default router;

