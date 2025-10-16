# Authentication System Feature

**Complete guide to how user authentication works in BIG BRUH.**

---

## 🎯 What is Authentication?

Authentication is how users **sign up**, **sign in**, and **stay logged in** across the app. BIG BRUH uses Supabase Auth for account management, supporting both **Sign in with Apple** and **Sign in with Google**.

The auth system handles everything from creating accounts to managing sessions to verifying users can access protected features.

---

## 📊 Database: `users` Table

**Key fields**:
- `id`: UUID (primary key, links to all other tables)
- `email`: User's email from auth provider
- `name`: Display name (extracted from onboarding)
- `subscription_status`: active/cancelled/past_due
- `timezone`: For call scheduling
- `call_window_start`: When evening calls happen
- `push_token`: For VoIP notifications

**References**:
- Type definition: [be/src/types/database.ts:15-32](../../be/src/types/database.ts#L15)
- Full schema: [DATABASE.md - Table 1](../DATABASE.md#table-1-users)

---

## 🏗️ How Authentication Works

### The Onboarding → Payment → Auth Flow

**BIG BRUH uses a unique flow**: Users complete onboarding BEFORE creating an account.

#### Why This Order?

1. **Commitment before payment**: User invests time in 45-step onboarding
2. **Psychological investment**: By the time they pay, they're committed
3. **No abandoned accounts**: Only paying users create accounts
4. **Better data**: Onboarding responses aren't tied to trial accounts that never convert

### Step-by-Step Flow

#### Phase 1: Anonymous Onboarding
**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Onboarding/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Onboarding/)

- User downloads app
- Starts 45-step onboarding flow
- **No account required yet**
- Responses stored locally on device
- User completes all steps including voice recordings

#### Phase 2: Payment
**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Paywall/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Paywall/)

- After completing onboarding, paywall appears
- RevenueCat handles subscription purchase
- User pays via App Store
- **Still no account created yet**

#### Phase 3: Authentication (Account Creation)
**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/)

**Now user creates account**:
1. iOS shows "Sign in with Apple" or "Sign in with Google"
2. User authenticates via provider
3. Supabase creates account in `users` table
4. JWT session token generated
5. Account linked to RevenueCat subscription

#### Phase 4: Data Submission
- iOS submits all 45 onboarding responses via `POST /onboarding/v3/complete`
- Backend processes data using authenticated user ID
- Identity extraction begins
- User ready for accountability calls

---

## 🔐 Frontend Authentication (iOS)

### AuthService
**Location**: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/Services/AuthService.swift](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/Services/AuthService.swift)

**Main responsibilities**:
1. Initialize Supabase client
2. Check for existing session on app launch
3. Handle Sign in with Apple
4. Handle Sign in with Google
5. Listen for auth state changes
6. Fetch user profile from database
7. Store session token securely
8. Auto-refresh expired tokens
9. Handle logout

### Sign in with Apple

**How it works**:
1. User taps "Continue with Apple"
2. iOS shows Apple ID prompt
3. User authenticates with Face ID/Touch ID
4. Apple returns identity token + authorization code
5. iOS sends to Supabase Auth
6. Supabase validates with Apple servers
7. Account created if new, or session returned if existing
8. User logged in

**Code flow**:
```
AuthService.signInWithApple()
  ↓
Apple Authentication Services
  ↓
Receive identity token
  ↓
supabase.auth.signInWithIdToken()
  ↓
Session created
  ↓
Fetch user profile
  ↓
User authenticated
```

**Why Apple Sign In**:
- Required by App Store if offering social login
- Users trust it (no password sharing)
- Fast (Face ID/Touch ID)
- Secure (Apple doesn't share email unless user allows)

### Sign in with Google

**How it works**:
1. User taps "Continue with Google"
2. iOS shows Google OAuth screen
3. User authenticates with Google account
4. Google returns ID token
5. iOS sends to Supabase Auth
6. Supabase validates with Google
7. Account created/session returned
8. User logged in

**Why Google Sign In**:
- Popular, users already have accounts
- Works cross-platform
- Reliable

### Session Management

**On app launch**:
```
AuthService.initialize()
  ↓
Check for existing session
  ↓
If session exists:
  - Validate JWT token
  - Check if expired
  - Auto-refresh if needed
  - Fetch user profile
  ↓
If no session:
  - Show authentication screens
```

**Session storage**:
- iOS stores JWT in secure keychain
- Token includes user ID, email, expiration
- Auto-refreshed before expiration
- Persists across app restarts

**State management**:
```swift
@Published var session: SupabaseSession? = nil
@Published var user: User? = nil
@Published var isAuthenticated = false
```

SwiftUI views observe these and automatically update when auth state changes.

### Auth State Changes

AuthService listens for events:
- `SIGNED_IN`: User just logged in
- `SIGNED_OUT`: User logged out
- `TOKEN_REFRESHED`: Token auto-renewed
- `USER_UPDATED`: Profile changed

**Why listen**:
- Update UI immediately
- Fetch fresh user profile
- Handle logout properly
- React to changes from other devices

---

## 🔐 Backend Authentication

### Authentication Middleware
**Location**: [be/src/middleware/auth.ts](../../be/src/middleware/auth.ts)

#### `requireAuth` Middleware

**Purpose**: Verify user is logged in.

**How it works**:
1. Extract JWT token from `Authorization` header
2. Validate token with Supabase Auth
3. Decode token to get user ID
4. Attach user ID to request context
5. If invalid → return 401 Unauthorized

**Used by**: Most protected routes.

**Example**:
```
GET /api/identity/:userId
  ↓
requireAuth middleware
  ↓
Check JWT token in header
  ↓
Valid? → Continue to handler
Invalid? → 401 Unauthorized
```

#### `requireActiveSubscription` Middleware

**Purpose**: Verify user has paid subscription.

**How it works**:
1. First runs `requireAuth` (must be logged in)
2. Fetches user record from `users` table
3. Checks `subscription_status` field
4. If "active" or "trialing" → allow access
5. If "cancelled" or "past_due" → return 403 Forbidden

**Used by**: All premium features (calls, identity, promises, etc.).

**Why separate from auth**:
- User can be logged in but subscription expired
- Different error codes (401 = not logged in, 403 = no access)
- Allows free tier features in future

### Authenticated User ID

**Function**: `getAuthenticatedUserId(context)`

**Purpose**: Extract user ID from validated JWT token.

**Used everywhere** protected routes need to know WHO is making the request:
```
const userId = getAuthenticatedUserId(c);

// Then use userId to:
// - Fetch their data
// - Create records
// - Verify ownership
```

**Security**: Users can only access their own data. Backend verifies userId in URL matches authenticated user.

---

## 🔗 How Auth Connects to Other Features

### 1. Onboarding Submission
- User must be authenticated before submitting onboarding
- `POST /onboarding/v3/complete` requires `requireActiveSubscription`
- User ID from JWT links onboarding data to account

### 2. Identity Access
- `GET /api/identity/:userId` requires auth + matching user ID
- Can't view other users' psychological profiles
- Identity records tied to authenticated user

### 3. Promise Management
- All promises linked to user via `user_id` foreign key
- Tool functions verify authenticated user owns promises
- Can't create/complete promises for other users

### 4. Call System
- Calls triggered for authenticated users with valid subscriptions
- VoIP push sent to user's registered `push_token`
- Call transcripts stored with user_id

### 5. Settings
- User can update their own timezone, call window, preferences
- Backend verifies request comes from authenticated user
- Changes saved to `users` table

---

## 🔒 Security Features

### JWT Token Security
- **Short-lived**: Tokens expire after 1 hour
- **Auto-refresh**: iOS auto-renews before expiration
- **Secure storage**: iOS stores in keychain (not user-accessible)
- **HTTPS only**: Tokens only sent over encrypted connections

### Middleware Protection
Every sensitive route protected by middleware:
```
app.get('/api/identity/:userId',
  requireActiveSubscription,  // Checks auth + subscription
  getCurrentIdentity           // Handler runs if auth passes
);
```

### Row-Level Security (Future)
- Supabase supports RLS (Row-Level Security)
- Can enforce "users can only see their own data" at database level
- Not currently enabled but recommended for production

### API Key Security
Backend uses environment variables for sensitive keys:
- `SUPABASE_SERVICE_ROLE_KEY`: Admin access to database
- `OPENAI_API_KEY`: AI services
- `ELEVENLABS_API_KEY`: Voice services
- `DEEPGRAM_API_KEY`: Transcription
- Never exposed to frontend

---

## 🔄 Session Lifecycle

### New User Journey
```
1. Download app
2. Complete onboarding (anonymous)
3. Pay via RevenueCat
4. Sign in with Apple/Google → Account created
5. Onboarding data submitted with user_id
6. Session token stored in keychain
7. User authenticated, can access all features
```

### Returning User Journey
```
1. Open app
2. AuthService checks keychain for token
3. Token found → Validate with Supabase
4. Token valid → Fetch user profile
5. User automatically logged in
6. If token expired → Auto-refresh
7. If refresh fails → Show login screen
```

### Logout Flow
```
1. User taps "Log Out" in settings
2. iOS calls supabase.auth.signOut()
3. Server-side session invalidated
4. Local token deleted from keychain
5. User state cleared
6. Redirect to welcome screen
```

---

## 🤔 Design Decisions

### Why Supabase Auth?
- Built on PostgreSQL (our database already there)
- Handles OAuth providers (Apple, Google)
- JWT tokens industry standard
- Auto-refresh handled by SDK
- RLS support for database security
- Free for our scale

### Why Not Firebase Auth?
- Already using Supabase for database
- Don't want to mix Google and Supabase backends
- Supabase simpler for Postgres integration

### Why Social Sign-In Only?
- **No email/password**: Reduces friction
- **No forgot password flow**: Fewer support issues
- **Higher security**: OAuth providers handle security
- **Faster**: Face ID faster than typing password
- **Better UX**: Users already logged into Apple/Google

### Why Subscription Check Separate?
- **Clearer errors**: "Not logged in" vs "Subscription expired"
- **Future flexibility**: Could have free tier with some features
- **Better UX**: Can show upgrade prompt vs login prompt
- **Metrics**: Track how many expired users try to use app

---

## 📁 Key File References

### Backend
- Auth middleware: [be/src/middleware/auth.ts](../../be/src/middleware/auth.ts)
- Security middleware: [be/src/middleware/security.ts](../../be/src/middleware/security.ts)
- User type: [be/src/types/database.ts:15-32](../../be/src/types/database.ts#L15)

### Frontend (iOS)
- AuthService: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/Services/AuthService.swift](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/Services/AuthService.swift)
- Authentication UI: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Authentication/)
- Paywall: [swift-ios-rewrite/bigbruhh/bigbruhh/Features/Paywall/](../../swift-ios-rewrite/bigbruhh/bigbruhh/Features/Paywall/)

### Related Documentation
- Database schema: [DATABASE.md](../DATABASE.md)
- API routes: [ROUTES.md](../ROUTES.md)

---

## 🎓 Common Questions

**Q: What happens if JWT expires during app use?**
A: AuthService auto-refreshes tokens in background. User doesn't notice.

**Q: Can users change their email?**
A: Not currently supported. Would need Supabase Auth update + handling across all linked data.

**Q: What if user signs in with Apple then later with Google?**
A: Two separate accounts created. Can't merge (by design - security). User should use same provider.

**Q: Where is password stored?**
A: No passwords. OAuth providers (Apple/Google) handle authentication. We only get tokens.

**Q: Can user access app without authentication?**
A: Only onboarding screens. All features require authentication + active subscription.

**Q: What data is sent to Apple/Google?**
A: Just their token. They validate and send back user ID + email. No BIG BRUH data shared with them.

---

*Last updated: 2025-01-11*
