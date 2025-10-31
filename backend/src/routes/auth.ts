/**
 * BigBruh MVP - Auth Routes
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { createClient } from '@supabase/supabase-js';
import { SupabaseService } from '../services/supabase';
import { ApiResponse } from '../types';

export const authRoutes = new Hono();

// Validation schemas
const signUpSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  name: z.string().optional()
});

const signInSchema = z.object({
  email: z.string().email(),
  password: z.string()
});

/**
 * Sign up new user
 */
authRoutes.post('/signup', async (c) => {
  try {
    const body = await c.req.json();
    const { email, password, name } = signUpSchema.parse(body);
    
    const supabase = createClient(c.env.SUPABASE_URL, c.env.SUPABASE_ANON_KEY);
    const supabaseService = new SupabaseService(c.env);
    
    // Create auth user
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          name: name || email.split('@')[0]
        }
      }
    });
    
    if (authError || !authData.user) {
      return c.json({
        success: false,
        error: authError?.message || 'Failed to create account'
      } as ApiResponse, 400);
    }
    
    // Create user profile
    await supabaseService.createUser({
      id: authData.user.id,
      email: authData.user.email,
      name: name || authData.user.user_metadata?.name || email.split('@')[0],
      onboarding_completed: false
    });
    
    return c.json({
      success: true,
      message: 'Account created successfully',
      data: {
        user: authData.user,
        session: authData.session
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Signup error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Sign in user
 */
authRoutes.post('/signin', async (c) => {
  try {
    const body = await c.req.json();
    const { email, password } = signInSchema.parse(body);
    
    const supabase = createClient(c.env.SUPABASE_URL, c.env.SUPABASE_ANON_KEY);
    
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password
    });
    
    if (authError || !authData.user) {
      return c.json({
        success: false,
        error: authError?.message || 'Invalid credentials'
      } as ApiResponse, 401);
    }
    
    return c.json({
      success: true,
      message: 'Signed in successfully',
      data: {
        user: authData.user,
        session: authData.session
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Signin error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Sign out user
 */
authRoutes.post('/signout', async (c) => {
  try {
    const supabase = createClient(c.env.SUPABASE_URL, c.env.SUPABASE_ANON_KEY);
    
    const { error } = await supabase.auth.signOut();
    
    if (error) {
      return c.json({
        success: false,
        error: error.message
      } as ApiResponse, 500);
    }
    
    return c.json({
      success: true,
      message: 'Signed out successfully'
    } as ApiResponse);
    
  } catch (error) {
    console.error('Signout error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Get current user
 */
authRoutes.get('/me', async (c) => {
  try {
    const authHeader = c.req.header('Authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return c.json({
        success: false,
        error: 'Missing authorization header'
      } as ApiResponse, 401);
    }
    
    const token = authHeader.substring(7);
    const supabase = createClient(c.env.SUPABASE_URL, c.env.SUPABASE_ANON_KEY);
    
    const { data: { user }, error } = await supabase.auth.getUser(token);
    
    if (error || !user) {
      return c.json({
        success: false,
        error: 'Invalid token'
      } as ApiResponse, 401);
    }
    
    const supabaseService = new SupabaseService(c.env);
    const userProfile = await supabaseService.getUserById(user.id);
    
    return c.json({
      success: true,
      data: {
        auth: user,
        profile: userProfile
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Get current user error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});

/**
 * Refresh session
 */
authRoutes.post('/refresh', async (c) => {
  try {
    const body = await c.req.json();
    const { refresh_token } = body;
    
    if (!refresh_token) {
      return c.json({
        success: false,
        error: 'Refresh token required'
      } as ApiResponse, 400);
    }
    
    const supabase = createClient(c.env.SUPABASE_URL, c.env.SUPABASE_ANON_KEY);
    
    const { data: authData, error: authError } = await supabase.auth.refreshSession({
      refreshToken: refresh_token
    });
    
    if (authError || !authData.user) {
      return c.json({
        success: false,
        error: authError?.message || 'Failed to refresh session'
      } as ApiResponse, 401);
    }
    
    return c.json({
      success: true,
      message: 'Session refreshed successfully',
      data: {
        user: authData.user,
        session: authData.session
      }
    } as ApiResponse);
    
  } catch (error) {
    console.error('Refresh session error:', error);
    return c.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    } as ApiResponse, 500);
  }
});
