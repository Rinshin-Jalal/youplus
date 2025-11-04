# 🎯 Testing Summary - Everything You Need

## 📁 Files Created

### 1. **onboarding-endpoint.test.ts** - Main Test File
Full type-safe test suite with 5 test scenarios

### 2. **get-auth-token.ts** - Auth Token Helper
Easy script to get Supabase auth token

### 3. **QUICK_START.md** - Quick Guide
4 methods to get auth token in 2 minutes

### 4. **README.md** - Full Documentation
Complete testing guide with examples

---

## 🚀 How to Run Tests (2 Steps)

### Step 1: Get Auth Token

**Method A - Using Helper Script (EASIEST):**
```bash
# 1. Edit get-auth-token.ts and set:
SUPABASE_URL: "https://your-project.supabase.co"
SUPABASE_ANON_KEY: "eyJhbGc..."
TEST_EMAIL: "your-email@example.com"
TEST_PASSWORD: "your-password"

# 2. Run it
npx tsx be/src/features/onboarding/tests/get-auth-token.ts

# 3. Copy the printed token
```

**Method B - From Browser (FASTEST if app is running):**
```javascript
// DevTools Console
localStorage.getItem('supabase.auth.token')
// Copy the token
```

**Method C - From Supabase Dashboard:**
1. Go to https://supabase.com/dashboard → Your Project
2. Authentication → Users → Add user
3. Create: test@example.com / TestPassword123!
4. Check "Auto Confirm"
5. Use Method A with these credentials

### Step 2: Run Tests

```bash
# 1. Edit onboarding-endpoint.test.ts
const CONFIG = {
  AUTH_TOKEN: "paste-token-here",
  API_URL: "http://localhost:8787",
};

# 2. Make sure backend is running
cd be
npm run dev

# 3. Run tests (in another terminal)
npx tsx be/src/features/onboarding/tests/onboarding-endpoint.test.ts
```

---

## 📊 What Gets Tested

### Test 1: Minimal Valid Onboarding ✅
- User name + Call time only
- Verifies basic extraction works

### Test 2: Complete Onboarding ✅
- All 21 steps with different types:
  - 5 voice responses (base64 audio)
  - 8 text responses
  - 4 choice responses
  - 1 dual sliders (`"7,9"` string format)
  - 1 time window (`"20:30-21:00"` string format)
  - 1 long press
- Verifies full data extraction

### Test 3-5: Edge Cases ⚠️
- Missing call time
- Invalid slider format
- Invalid voice format
- Verifies error handling

---

## 🔍 What to Check

### In Test Output
```
✅ TEST PASSED: 2. Complete Onboarding (All Response Types)
   - Total Steps: 21
   - Files Processed: 5
   - Identity Extraction: SUCCESS
   - Fields Extracted: 12
```

### In Backend Logs
```
📞 Found evening_call_time in step 37
✅ Extracted call time (string format): 20:30, window: 20:30-21:00

📊 Slider 1: 7 / 10
📊 Slider 2: 9 / 10

📦 Base64 audio data: ✅ (123456 chars)

📊 === EXTRACTION SUMMARY ===
👤 User Name: John Doe
🌍 Timezone: America/New_York
📞 Call Time: 20:30
⏰ Call Window: 20:30-21:00
```

---

## 🎯 Type Safety Features

All test data is **fully type-checked**:

```typescript
// ✅ Valid - compiles
createDualSlidersResponse(7, 9, ["motivation_fear_intensity"])

// ❌ Error - TypeScript catches
createDualSlidersResponse("seven", 9, ["motivation_fear_intensity"])
// Error: Argument of type 'string' is not assignable to 'number'
```

**Response types are enforced:**
```typescript
type ResponseType =
  | "voice"
  | "text"
  | "choice"
  | "dual_sliders"
  | "time_window_picker"
  | "long_press_activate"
  | "explanation"
  | "timezone_selection";
```

---

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| `AUTH_TOKEN` error | Run `get-auth-token.ts` or use QUICK_START.md |
| Connection refused | Start backend: `npm run dev` in /be folder |
| 401 Unauthorized | Token expired - get new one (valid 1 hour) |
| Email not confirmed | Disable in Supabase: Auth → Settings → Email confirmations |
| User not found | Create in Supabase Dashboard: Auth → Users → Add user |

---

## 🔧 Customization

### Add Your Own Test
```typescript
function createMyTest(): OnboardingCompleteRequest {
  return {
    state: {
      currentStep: 45,
      responses: {
        "3": createTextResponse("Custom Name", ["identity_name"]),
        "11": createDualSlidersResponse(8, 10, ["fear", "desire"]),
        "37": createTimeWindowResponse("19:00", "20:00", ["evening_call_time"]),
        // Add more...
      },
      totalResponses: 3,
      progressPercentage: 100,
      startedAt: new Date().toISOString(),
      lastSavedAt: new Date().toISOString(),
      isCompleted: true,
      completedAt: new Date().toISOString(),
      userName: "Custom Name",
      userTimezone: "America/Los_Angeles",
    },
  };
}

// Add to main()
await runTest("My Custom Test", createMyTest());
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `onboarding-endpoint.test.ts` | Main test file - run this |
| `get-auth-token.ts` | Get Supabase auth token easily |
| `QUICK_START.md` | 4 methods to get auth token |
| `README.md` | Full testing documentation |
| `TESTING_SUMMARY.md` | This file - quick overview |

---

## ✨ What Was Fixed

The tests validate these backend fixes:

1. ✅ **Time Window Parsing**
   - Now accepts string format `"20:30-21:00"` from Swift
   - Falls back to object format for compatibility

2. ✅ **Dual Sliders Parsing**
   - Now parses comma-separated string `"7,9"` from Swift
   - Extracts both slider values correctly

3. ✅ **Better Error Logging**
   - Shows db_field mapping for all responses
   - Logs extraction summary with all key values
   - Error messages when extraction fails

---

## 🎉 You're All Set!

1. Get token using any method in QUICK_START.md
2. Paste in test file CONFIG
3. Run: `npx tsx be/src/features/onboarding/tests/onboarding-endpoint.test.ts`
4. Check logs for extraction working correctly! 🔥
