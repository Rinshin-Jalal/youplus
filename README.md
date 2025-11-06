# You+ Minimal MVP

## 🎯 Overview
You+ is a confrontational accountability app that uses AI voice calls to keep users disciplined. This MVP extracts psychological weapons through a 10-step onboarding and deploys them in daily accountability calls.

## 📁 Project Structure
```
youplus/
├── be/          (Cloudflare Workers + Hono + Supabase)
├── swift/       (Swift iOS app)
├── docs/        (Documentation)
└── README.md
```

## 🔥 Core Features
- **10-step onboarding** extracting psychological weapons
- **Daily AI calls** using user's own words against them
- **3-screen dashboard** (streaks, history, profile)
- **Call scheduling** with user's preferred time

## 🛠️ Tech Stack
- **Backend**: Cloudflare Workers + Hono
- **Database**: Supabase
- **Auth**: Supabase Auth (Apple ID)
- **AI Voice**: ElevenLabs
- **Frontend**: Swift (iOS)

## 📅 1-Week Sprint Plan
- **Day 1**: Setup + database migration
- **Day 2**: Backend core + ElevenLabs integration
- **Day 3**: Frontend onboarding flow
- **Day 4**: Call system + scheduling
- **Day 5**: Dashboard + UI
- **Day 6**: Integration + polish
- **Day 7**: Deployment + shipping

## 🚀 Quick Start
1. Set up Supabase database with migrations
2. Configure Cloudflare Workers
3. Run iOS app in Xcode
4. Complete onboarding and receive first call

## 💡 Key Innovation
Maximum psychological impact with minimum complexity - use user's own recorded words as weapons against their future weak self through daily AI calls they can't ignore.
