import { Hono } from 'hono';
import {
  postVoIPDebug,
  getVoIPDebugEvents,
  clearVoIPDebugEvents,
  getVoIPDebugSummary
} from './handlers/voip-debug';
import {
  initVoipSession,
  getVoipSessionPrompts
} from './handlers/voip-session';
import {
  testVoipCertificates,
  simpleVoipTest,
  advancedVoipTest,
  getVoipStatus,
  voipAck,
  getPendingCallStatusByUUID,
  getAllPendingCallsList,
  acknowledgeVoipCall
} from './handlers/voip-test';

const router = new Hono();

// VoIP Debug endpoints
router.post('/debug/voip', postVoIPDebug);
router.get('/debug/voip', getVoIPDebugEvents);
router.delete('/debug/voip', clearVoIPDebugEvents);
router.get('/debug/voip/summary', getVoIPDebugSummary);

// VoIP Session endpoints
router.post('/session/init', initVoipSession);
router.post('/session/prompts', getVoipSessionPrompts);

// VoIP Test endpoints
router.get('/test-certificates', testVoipCertificates);
router.post('/simple-test', simpleVoipTest);
router.post('/test', advancedVoipTest);
router.get('/status', getVoipStatus);
router.post('/ack', voipAck);
router.get('/debug/pending/:callUUID', getPendingCallStatusByUUID);
router.get('/debug/pending', getAllPendingCallsList);
router.post('/acknowledge', acknowledgeVoipCall);

export default router;