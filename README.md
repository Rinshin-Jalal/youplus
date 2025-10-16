# BigBruh - Psychological Accountability System

BigBruh is a confrontational accountability app that acts like an older brother who won't let you quit. Through an intensive 54-step psychological onboarding and daily voice calls, BigBruh extracts your deepest fears and uses them to keep you disciplined when motivation fails.

**Core Experience**: One daily call from BigBruh. No tracking dashboards, no gentle reminders - just raw accountability through AI-powered voice confrontations.

## Project Structure

This workspace contains three main components:

- **Frontend** (`rn/` folder) - React Native mobile app for iOS/Android
- **Backend** (`be/` folder) - Cloudflare Workers API server handling business logic
- **Documentation** (root level) - Project philosophy, branding, and user experience guidelines

---

## 📱 Frontend (React Native App)

The mobile app delivers the core experience: intensive psychological onboarding followed by daily accountability calls. The interface uses stark black/white contrast with neon accents, creating an aggressive yet caring presence that feels like having an older brother in your pocket.

### App Router Structure (`rn/app/`)

#### Public Routes (`(public)/`)

- **`index.tsx`** - Landing page that introduces users to BigBruh's no-nonsense philosophy and initiates the psychological assessment process
- **`onboarding.tsx`** - The intensive 54-step psychological transformation journey that extracts users' deepest truths, fears, and excuses to build a personalized enforcement profile
- **`+not-found.tsx`** - Error handling for invalid routes, maintaining the app's authoritative tone even when users get lost

#### Authentication Routes (`(auth)/`)

- **`auth.tsx`** - User login and registration screen that transitions users from anonymous onboarding to authenticated accountability
- **`processing.tsx`** - Background processing screen that handles data migration from temporary session storage to permanent user accounts after authentication
- **`signup.tsx`** - Account creation flow that captures user details while maintaining the app's confrontational personality

#### Main App Routes (`(app)/`)

- **`home.tsx`** - Main screen showing daily call status, win streaks, and current accountability state
- **`call.tsx`** - VoIP call interface for real-time conversations with BigBruh AI
- **`history.tsx`** - Record of past calls, excuse patterns, and success/failure history
- **`settings.tsx`** - Call preferences, intensity levels, and notification settings

#### Subscription Routes (`(purchase)/`)

- **`paywall.tsx`** - Subscription upgrade screen that explains the value of enhanced pressure and external judgment features
- **`celebration.tsx`** - Success screen after subscription purchase, reinforcing the commitment to the transformation process
- **`no-subscription.tsx`** - Graceful handling for users without active subscriptions, offering limited free tier access
- **`secret-plan.tsx`** - Special promotional offers and limited-time subscription deals

#### Development Routes (`(dev)/`)

- **`dev.tsx`** - Developer tools and testing interface for debugging app functionality and user flows

#### Special Routes

- **`almost-there.tsx`** - Transitional screen used during critical moments in the user journey, building anticipation
- **`_layout.tsx`** - Root layout component that provides global navigation, authentication state, and core app providers

### Core Components (`rn/components/`)

#### Onboarding Components (`onboarding/`)

- **`OnboardingV1.tsx`** through **`OnboardingV6.tsx`** - 54-step psychological assessment journey that extracts user fears, patterns, and commitments
- **`VoiceRecorder.tsx`** - Voice recording interface for confession-style responses
- **`SliderAssessment.tsx`** - Dual-slider psychological intensity ratings
- **`MultipleChoiceQuestion.tsx`** - Authority-driven selection for behavioral pattern capture
- **`TimePicker.tsx`** - Daily commitment window selection
- **Assessment Steps** - Specialized components for each phase of psychological profiling

#### 11Labs Integration (`11labs/`)

- **`VoicePreview.tsx`** - Preview interface for users to hear how BigBruh's AI voice will sound during interventions
- **`VoiceSelector.tsx`** - Voice customization options allowing users to choose their preferred tone of authority

#### UI Components

- **`BoxCard.tsx`** - Standard container component for displaying information in the app's bold, high-contrast design
- **`TabBar.tsx`** - Bottom navigation component that maintains consistent branding across all app sections
- **`BrutalRealityMirror.tsx`** - Specialized component for displaying harsh but truthful feedback about user behavior

### Business Logic Services (`rn/services/`)

- **`OnboardingDataPush.ts`** - Secure transmission of psychological assessment data to backend
- **`tools.ts`** - Integration layer for external services and APIs

### Custom Hooks (`rn/hooks/`)

#### VoIP Functionality (`voip/`)

- **`useVoipListener.ts`** - Manages incoming daily accountability calls
- **`useRitualCallHandling.ts`** - Handles daily call flow and user responses
- **`useVoipToken.ts`** - Manages VoIP push notification tokens for background calls
- **`useCallEvents.ts`** - Processes call events and user interactions

#### Subscription Management

- **`useRevenueCat.ts`** - Integrates with RevenueCat for subscription management and feature gating

### Configuration and Context (`rn/`)

- **`config/appStore.ts`** - App-wide configuration settings and constants
- **`contexts/AuthContext.tsx`** - Global authentication state management across all app components
- **`lib/api.ts`** - HTTP client for communicating with backend APIs
- **`lib/supabase.ts`** - Database client for user data and authentication
- **`lib/analytics.ts`** - User behavior tracking and analytics integration
- **`styles/colors.ts`** - Centralized color palette maintaining the app's aggressive, high-contrast aesthetic
- **`types/onboarding.ts`** - TypeScript definitions for the complex onboarding data structures
- **`types/reviews.ts`** - Type definitions for user feedback and review systems
- **`utils/fileUtils.ts`** - File handling utilities for audio recordings and user uploads
- **`utils/storeReviewUtils.ts`** - Utilities for managing in-app review prompts and ratings

### Native Modules (`rn/modules/`)

- **`expo-voip-push-token-v2/`** - Custom native module for handling VoIP push notifications on iOS and Android devices

### Screens (`rn/screens/`)

- **`CallScreen.tsx`** - Full-screen interface for managing active voice calls and interventions
- **`PaywallThreshold.tsx`** - Subscription threshold screen that appears when free users reach certain limits
- **`SignupScreen.tsx`** - Alternative signup flow used in specific user journey contexts

---

## ⚙️ Backend (Cloudflare Workers)

The backend is a serverless API built on Cloudflare Workers using Hono framework, handling psychological assessment processing, daily call scheduling, and AI-powered conversation management.

### Core API (`be/src/`)

#### Main Entry Point

- **`index.ts`** - Main server file that sets up all API routes and middleware

#### Authentication & Security (`middleware/`)

- **`auth.ts`** - Authentication middleware that verifies user identity and permissions
- **`security.ts`** - Security middleware handling input validation and attack prevention

#### API Routes (`routes/`)

##### User Management

- **`identity.ts`** - User profile management, preferences, and identity-related operations
- **`user.ts`** - Core user account operations including creation, updates, and deletion

##### Onboarding System

- **`onboarding.ts`** - Handles the complex 54-step psychological assessment process and data storage
- **`post-payment.ts`** - Processes subscription-related events and user status updates

##### Voice & Communication

- **`11labs-call-init.ts`** - Initializes voice calls using ElevenLabs AI voice technology
- **`voice.ts`** - Voice-related operations including recording storage and processing
- **`call-log.ts`** - Records and retrieves history of accountability interventions
- **`calls.ts`** - Manages active call sessions and real-time voice interactions

##### Tool Integration

- **`tool.ts`** - Integration with external tools and services for enhanced functionality
- **`tool-handlers/`** - Collection of specialized handlers for different tool integrations

##### Triggers & Automation

- **`triggers.ts`** - Automated system triggers for scheduled interventions and reminders

##### Payment & Subscriptions

- **`subscription-notifications.ts`** - Handles subscription lifecycle events and notifications

##### External Integrations

- **`elevenlabs-webhooks.ts`** - Webhook handlers for ElevenLabs voice service events
- **`rc-webhooks.ts`** - RevenueCat webhook handlers for subscription management
- **`vapi.ts`** - Integration with Vapi for additional voice functionality
- **`token-init-push.ts`** - Push notification token management for mobile devices

##### Developer & Debug

- **`prompt-engine-demo.ts`** - Demonstration interface for testing AI prompt engineering
- **`voip-debug.ts`** - Debugging tools for VoIP call functionality
- **`voip-test.ts`** - Testing utilities for voice call systems
- **`health.ts`** - Health check endpoint for monitoring system status

##### Advanced Features

- **`mirror.ts`** - Psychological mirror functionality for reflecting user behavior patterns
- **`promises.ts`** - User promise and commitment tracking system
- **`settings.ts`** - User preference and configuration management

##### AI Content Generation

- **`brutal-daily.ts`** - Generates daily confrontational content and interventions
- **`brutal-reality.ts`** - Creates personalized reality-check messages
- **`ai-brutal-reality.ts`** - Advanced AI system for generating psychological interventions

### Business Logic Services (`be/src/services/`)

The services folder contains specialized business logic modules:

##### AI & Voice Services

- **`ai/`** - Core AI processing for generating personalized interventions
- **`voice/`** - Voice synthesis and processing services
- **`elevenlabs/`** - ElevenLabs integration for AI voice generation
- **`cartesia/`** - Alternative voice synthesis provider
- **`openai/`** - OpenAI integration for advanced AI features

##### Data Processing

- **`onboarding/`** - Onboarding data processing and psychological profile generation
- **`subscription/`** - Subscription management and billing logic
- **`analytics/`** - User behavior analytics and reporting

##### Communication

- **`email/`** - Email service for external accountability notifications
- **`push/`** - Push notification services for mobile devices
- **`sms/`** - SMS services for additional communication channels

##### System Management

- **`health/`** - System health monitoring and diagnostics
- **`logging/`** - Centralized logging and error tracking
- **`rate-limiting/`** - API rate limiting and abuse prevention

##### User Management

- **`auth/`** - Authentication and authorization services
- **`user/`** - User account management and profile services

### Data Layer (`be/src/`)

#### Database Integration

- **`types/database.ts`** - Database schema definitions and type safety
- **`utils/database.ts`** - Database connection and query utilities

#### File Processing

- **`utils/onboardingFileProcessor.ts`** - Processes uploaded files during onboarding (voice recordings, documents)
- **`utils/uuid.ts`** - Unique identifier generation utilities

---

## 📚 Documentation Files

### Core Philosophy

- **`readme.md`** - Main project overview explaining BigBruh's psychological enforcement approach
- **`brand.md`** - Comprehensive branding guidelines covering visual design, tone of voice, and user experience principles
- **`daily-flow.md`** - Detailed explanation of the daily accountability enforcement loop
- **`cursor.md`** - Development guidelines and technical context for the codebase

### Architecture Documentation

- **`be/ARCHITECTURE_BACKEND.md`** - Backend system architecture and technical decisions
- **`rn/ARCHITECTURE_FRONTEND.md`** - Frontend architecture and component organization
- **`be/TODO_PACKAGE_OPTIMIZATION.md`** - Backend performance optimization tasks and priorities

---

## 🎯 How It Works

BigBruh operates on a simple but powerful system:

1. **Intensive Onboarding**: 54-step psychological assessment extracts user fears, behavioral patterns, and commitment triggers
2. **Daily Accountability Call**: One call per day from BigBruh AI using user's own psychology against them
3. **Binary Response System**: Simple ✅ Did it / ❌ Failed tracking with immediate confrontational feedback
4. **Excuse Pattern Recognition**: System remembers and replays user's recurring excuses to prevent repetition

**The Core Loop**: BigBruh calls → User admits success/failure → System responds with personalized confrontation or reinforcement → Cycle repeats daily

No gentle tracking, no motivational quotes, no complex dashboards. Just raw accountability through psychological pressure that prevents users from quitting when discipline is hardest.
