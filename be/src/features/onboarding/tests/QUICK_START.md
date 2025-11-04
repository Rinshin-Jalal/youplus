# 🚀 QUICK START - Get Auth Token in 2 Minutes

## Method 1: Using the Helper Script (EASIEST) ⭐

### Step 1: Configure
Open `get-auth-token.ts` and fill in:

```typescript
const CONFIG = {
  // Get these from Supabase Dashboard → Settings → API
  SUPABASE_URL: "https://your-project.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGc...",

  // Your test user credentials
  TEST_EMAIL: "your-email@example.com",
  TEST_PASSWORD: "your-password",
};
```

### Step 2: Run
```bash
npx tsx be/src/features/onboarding/tests/get-auth-token.ts
```

### Step 3: Copy Token
It will print your token - copy it and paste into `onboarding-endpoint.test.ts`!

---

## Method 2: From Your App (FASTEST) ⚡

If you have the app running:

### In Browser DevTools Console:
```javascript
// If using localStorage
localStorage.getItem('supabase.auth.token')

// Or get from Supabase client
const { data: { session } } = await window.supabase.auth.getSession()
console.log(session.access_token)
```

### In Swift/iOS App:
```swift
// Add this temporary code to print token
let session = try? await AuthService.shared.getSession()
print("🔑 Auth Token:", session?.accessToken ?? "No token")
```

Copy the printed token!

---

## Method 3: Create New Test User via Supabase Dashboard

### Step 1: Go to Supabase Dashboard
1. Open https://supabase.com/dashboard
2. Select your project
3. Go to **Authentication** → **Users**

### Step 2: Create Test User
1. Click **Add user** → **Create new user**
2. Email: `test@example.com`
3. Password: `TestPassword123!`
4. Auto Confirm: ✅ (check this!)
5. Click **Create user**

### Step 3: Get Token
Now use Method 1 with these credentials:
```typescript
TEST_EMAIL: "test@example.com",
TEST_PASSWORD: "TestPassword123!",
```

---

## Method 4: Using Backend API Directly

If you have a login endpoint:

```bash
# Make login request
curl -X POST http://localhost:8787/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "your-password"
  }'

# Response will contain access_token
{
  "access_token": "eyJhbGc...",
  "user": { ... }
}
```

---

## 🎯 Where to Find Supabase Credentials

### SUPABASE_URL
1. Go to https://supabase.com/dashboard
2. Select your project
3. **Settings** → **API**
4. Copy **Project URL** (looks like `https://abcdefg.supabase.co`)

### SUPABASE_ANON_KEY
1. Same page (**Settings** → **API**)
2. Copy **anon** key under **Project API keys**
3. It starts with `eyJhbGc...`

---

## ✅ Test It Works

Once you have the token:

1. Open `onboarding-endpoint.test.ts`
2. Paste token in CONFIG:
```typescript
const CONFIG = {
  AUTH_TOKEN: "eyJhbGc...", // <-- Paste here
  API_URL: "http://localhost:8787",
};
```

3. Run test:
```bash
npx tsx be/src/features/onboarding/tests/onboarding-endpoint.test.ts
```

4. Should see:
```
✅ TEST PASSED: 1. Minimal Valid Onboarding
   - Total Steps: 2
   - Identity Extraction: SUCCESS
```

---

## 🐛 Troubleshooting

### "Invalid JWT" Error
- Token expired (valid for ~1 hour)
- Run `get-auth-token.ts` again to get fresh token

### "User not found" Error
- User doesn't exist in your Supabase
- Create user via Dashboard (Method 3)

### "Email not confirmed" Error
- In Supabase Dashboard: Authentication → Settings
- Disable "Enable email confirmations"
- OR manually confirm user in Users table

### "Connection refused" Error
- Backend not running
- Start it: `npm run dev` in `/be` folder

---

## 💡 Pro Tips

### For CI/CD
Use service role key instead of user token:
```typescript
// In test file
const CONFIG = {
  AUTH_TOKEN: process.env.SUPABASE_SERVICE_ROLE_KEY,
  // ...
};
```

### Token Expires?
Set up auto-refresh:
```typescript
// In get-auth-token.ts
supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'TOKEN_REFRESHED') {
    console.log('New token:', session?.access_token);
  }
});
```

### Multiple Test Users?
Create them in Supabase Dashboard and store credentials in `.env.test`:
```bash
TEST_USER_1_EMAIL=test1@example.com
TEST_USER_1_PASSWORD=password1
TEST_USER_2_EMAIL=test2@example.com
TEST_USER_2_PASSWORD=password2
```

---

## 🎉 You're Ready!

Now run your tests:
```bash
npx tsx be/src/features/onboarding/tests/onboarding-endpoint.test.ts
```

Check logs in backend terminal to see the extraction working! 🔥
