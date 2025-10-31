/**
 * BigBruh MVP - Main Server
 * Cloudflare Workers + Hono + Supabase
 */

import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { auth, optionalAuth } from './middleware/auth';
import { onboardingRoutes } from './routes/onboarding';
import { callsRoutes } from './routes/calls';
import { dashboardRoutes } from './routes/dashboard';
import { authRoutes } from './routes/auth';
import { voipRoutes } from './routes/voip';
import { Env } from './types';

const app = new Hono<{ Bindings: Env }>();

// Middleware
app.use('*', logger());
app.use('*', cors({
  origin: ['*'], // Configure for your domains
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
}));

// Health check
app.get('/', (c) => {
  return c.json({
    success: true,
    message: 'BigBruh MVP API is running',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (c) => {
  return c.json({
    success: true,
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// Public routes (no auth required)
app.route('/api/auth', authRoutes);

// Protected routes (auth required)
app.use('/api/*', auth);
app.route('/api/onboarding', onboardingRoutes);
app.route('/api/calls', callsRoutes);
app.route('/api/dashboard', dashboardRoutes);
app.route('/api/voip', voipRoutes);

// Debug endpoint (development only)
app.get('/debug/env', optionalAuth, async (c) => {
  if (c.env.ENVIRONMENT !== 'development') {
    return c.json({ error: 'Debug endpoints only available in development' }, 404);
  }
  
  const debugToken = c.env.DEBUG_ACCESS_TOKEN;
  const providedToken = c.req.header('X-Debug-Token');
  
  if (debugToken && providedToken !== debugToken) {
    return c.json({ error: 'Invalid debug token' }, 401);
  }
  
  return c.json({
    environment: c.env.ENVIRONMENT,
    backend_url: c.env.BACKEND_URL,
    supabase_url: c.env.SUPABASE_URL ? 'configured' : 'missing',
    elevenlabs_voice_id: c.env.ELEVENLABS_VOICE_ID || 'default',
    user_id: c.get('userId') || 'none'
  });
});

// 404 handler
app.notFound((c) => {
  return c.json({
    success: false,
    error: 'Endpoint not found',
    message: 'The requested endpoint does not exist'
  }, 404);
});

// Error handler
app.onError((err, c) => {
  console.error('Server error:', err);
  return c.json({
    success: false,
    error: 'Internal server error',
    message: c.env.ENVIRONMENT === 'development' ? err.message : 'Something went wrong'
  }, 500);
});

export default app;
