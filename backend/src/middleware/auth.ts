/**
 * BigBruh MVP - Authentication Middleware
 */

import { Context, Next } from 'hono';
import { createClient } from '@supabase/supabase-js';
import { Env } from '../types';

export async function auth(c: Context<{ Bindings: Env }>, next: Next) {
  const authHeader = c.req.header('Authorization');
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ success: false, error: 'Missing or invalid authorization header' }, 401);
  }

  const token = authHeader.substring(7); // Remove 'Bearer ' prefix
  
  try {
    // Verify token with Supabase
    const supabase = createClient(c.env.SUPABASE_URL, c.env.SUPABASE_ANON_KEY);
    const { data: { user }, error } = await supabase.auth.getUser(token);
    
    if (error || !user) {
      return c.json({ success: false, error: 'Invalid token' }, 401);
    }

    // Add user to context
    c.set('userId', user.id);
    c.set('user', user);
    
    await next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    return c.json({ success: false, error: 'Authentication failed' }, 401);
  }
}

/**
 * Optional auth middleware - doesn't fail if no token, but adds user if present
 */
export async function optionalAuth(c: Context<{ Bindings: Env }>, next: Next) {
  const authHeader = c.req.header('Authorization');
  
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.substring(7);
    
    try {
      const supabase = createClient(c.env.SUPABASE_URL, c.env.SUPABASE_ANON_KEY);
      const { data: { user }, error } = await supabase.auth.getUser(token);
      
      if (!error && user) {
        c.set('userId', user.id);
        c.set('user', user);
      }
    } catch (error) {
      console.error('Optional auth error:', error);
      // Continue without auth
    }
  }
  
  await next();
}
