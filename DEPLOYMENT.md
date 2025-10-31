# BigBruh MVP - Deployment Guide

## 🚀 Quick Deployment

This guide covers deploying the BigBruh MVP to production in under 30 minutes.

## 📋 Prerequisites

- Node.js 18+
- Swift 5.9+
- Xcode 15+
- Cloudflare account
- Supabase account
- ElevenLabs account

## 🗄️ Database Setup (Supabase)

### 1. Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create new project
3. Note your project URL and anon key

### 2. Run Database Migrations
```bash
# Connect to your Supabase project SQL editor
# Run each migration file in order:

cd database/migrations

# Run in Supabase SQL Editor:
\i 001_create_users_table.sql
\i 002_create_onboarding_table.sql
\i 003_create_calls_table.sql
\i 004_create_identity_table.sql
\i 005_create_streaks_table.sql
\i 006_create_mvp_schema_complete.sql
```

### 3. Configure Supabase Auth
1. Go to Authentication > Settings
2. Enable Apple provider (if using iOS)
3. Configure your Apple Sign In credentials

## ⚙️ Backend Setup (Cloudflare Workers)

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment Variables
```bash
# Copy example file
cp .env.example .env

# Edit .env with your values:
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
ELEVENLABS_API_KEY=your_elevenlabs_key
ELEVENLABS_VOICE_ID=adam
ENVIRONMENT=production
```

### 3. Set Cloudflare Secrets
```bash
# Set secrets (never commit these to git)
wrangler secret put SUPABASE_URL
wrangler secret put SUPABASE_ANON_KEY
wrangler secret put SUPABASE_SERVICE_ROLE_KEY
wrangler secret put ELEVENLABS_API_KEY
wrangler secret put ELEVENLABS_VOICE_ID
wrangler secret put OPENAI_API_KEY
```

### 4. Deploy Backend
```bash
# Deploy to production
npm run deploy

# Or test locally first
npm run dev
```

### 5. Note Your Backend URL
After deployment, note your Workers URL (e.g., `https://bigbruh-mvp-backend.your-subdomain.workers.dev`)

## 📱 Frontend Setup (Swift iOS)

### 1. Configure Backend URL
Edit `frontend/Sources/BigBruhMVP/Config/Config.swift`:
```swift
static let backendURL = "https://your-backend-url.workers.dev"
```

### 2. Update Supabase Config
Ensure your Supabase URL and keys are correct in `Config.swift` (reuse existing ones).

### 3. Open in Xcode
```bash
cd frontend
open Package.swift
```

### 4. Build and Test
1. Select your target device/simulator
2. Build and run the app
3. Test complete user flow

## 🔄 End-to-End Testing

### 1. Test User Registration
1. Open app
2. Sign up with email/password
3. Verify user creation in Supabase

### 2. Test Onboarding
1. Complete all 10 onboarding steps
2. Verify data saves to `onboarding` table
3. Verify psychological weapons extract to `identity` table

### 3. Test Call Generation
1. Go to Home screen
2. Tap "START CALL"
3. Verify call script generates with user's weapons
4. Test YES/NO response saving

### 4. Test Dashboard
1. Check streaks update correctly
2. Verify call history displays
3. Test profile settings

## 🐛 Common Issues & Fixes

### Backend Issues
- **CORS errors**: Check CORS middleware in `src/index.ts`
- **Database connection**: Verify Supabase URL and keys
- **ElevenLabs errors**: Check API key and voice ID

### Frontend Issues
- **Auth failures**: Verify Supabase config in `Config.swift`
- **Network errors**: Check backend URL in `Config.swift`
- **Build errors**: Ensure Swift packages resolve correctly

### Database Issues
- **Migration failures**: Run migrations in order
- **RLS errors**: Check Row Level Security policies
- **Missing data**: Verify foreign key relationships

## 📊 Monitoring

### Backend Health
```bash
# Check health endpoint
curl https://your-backend-url.workers.dev/health
```

### Database Monitoring
- Use Supabase Dashboard
- Monitor `calls` table for activity
- Check user onboarding completion rates

### Error Tracking
- Check Cloudflare Workers logs
- Monitor Xcode console for iOS errors
- Set up error reporting (optional)

## 🚀 Production Checklist

- [ ] Supabase project created and migrations run
- [ ] Backend deployed and secrets configured
- [ ] Frontend configured with correct URLs
- [ ] Test complete user flow end-to-end
- [ ] Verify call generation works
- [ ] Check dashboard functionality
- [ ] Test error scenarios
- [ ] Monitor initial user activity

## 📈 Scaling Considerations

### Backend
- Cloudflare Workers auto-scale
- Monitor request limits
- Consider caching for frequent requests

### Database
- Supabase auto-scales
- Monitor connection limits
- Archive old call data if needed

### Frontend
- iOS App Store submission
- Consider TestFlight beta testing
- Monitor crash reports

## 💡 Next Steps

After MVP deployment:
1. Add push notifications for calls
2. Implement actual ElevenLabs voice playback
3. Add more sophisticated AI call personalization
4. Expand psychological weapon extraction
5. Add analytics and user insights

## 🆘 Support

If you encounter issues:
1. Check this guide for common fixes
2. Review Cloudflare Workers logs
3. Check Supabase dashboard
4. Verify Xcode console output
5. Test components individually

---

**Deployment Time**: ~30 minutes
**Cost**: ~$0-50/month (depending on usage)
**Maintenance**: Minimal (auto-scaling infrastructure)
