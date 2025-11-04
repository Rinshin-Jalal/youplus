# 🧪 Onboarding Endpoint Test Suite

Comprehensive type-safe testing for the `/api/onboarding/v3/complete` endpoint.

## 🚀 Quick Start

### 1. Install Dependencies (if needed)
```bash
npm install tsx
```

### 2. Configure Test
Edit `onboarding-endpoint.test.ts` and set:
```typescript
const CONFIG = {
  AUTH_TOKEN: "YOUR_AUTH_TOKEN_HERE", // Get from login or Supabase
  API_URL: "http://localhost:8787",   // Your backend URL
  USER_ID: "test-user-123",           // Optional
};
```

### 3. Run Tests
```bash
npx tsx src/features/onboarding/tests/onboarding-endpoint.test.ts
```

## 🔑 Getting Your Auth Token

### Option 1: From Browser (Easy)
1. Login to your app in browser
2. Open DevTools → Console
3. Run: `localStorage.getItem('supabase.auth.token')`
4. Copy the JWT token

### Option 2: From API Response
1. Make a login request to your auth endpoint
2. Extract the `access_token` from response
3. Use that as `AUTH_TOKEN`

### Option 3: Create Test User (Best for CI/CD)
```typescript
// Add to test file
async function getTestAuthToken(): Promise<string> {
  const response = await fetch(`${CONFIG.API_URL}/api/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: "test@example.com",
      password: "test-password"
    })
  });
  const data = await response.json();
  return data.access_token;
}
```

## 📋 Test Scenarios

### ✅ 1. Minimal Valid Onboarding
Tests bare minimum required fields:
- User name
- Call time
- Basic state fields

**Expected Result:** Should succeed with minimal data

### ✅ 2. Complete Onboarding (All Response Types)
Tests all 21 steps with:
- 5 voice responses (base64 audio)
- 8 text responses
- 4 choice responses
- 1 dual sliders (comma-separated string `"7,9"`)
- 1 time window picker (string `"20:30-21:00"`)
- 1 long press
- Push token & device metadata

**Expected Result:** Should succeed and extract all fields

### ⚠️ 3. Edge Case: Missing Call Time
Tests behavior when `evening_call_time` is missing

**Expected Result:** Should succeed but log "NOT FOUND" for call time

### ⚠️ 4. Edge Case: Invalid Dual Sliders Format
Tests invalid slider value: `"invalid_format"` instead of `"7,9"`

**Expected Result:** Should log error but continue processing

### ⚠️ 5. Edge Case: Invalid Voice Format
Tests voice response without `data:audio/` prefix

**Expected Result:** Should log error but continue processing

## 🔍 What to Look For

### Success Indicators
- ✅ Response status: `200`
- ✅ `success: true`
- ✅ `totalSteps` matches sent responses
- ✅ `identityExtraction.success: true`
- ✅ `identityExtraction.fieldsExtracted > 0`

### Backend Logs to Check
```bash
# Start backend with logs
npm run dev

# Look for these in logs:
📞 Found evening_call_time in step 37
✅ Extracted call time (string format): 20:30, window: 20:30-21:00
📊 Slider 1: 7 / 10
📊 Slider 2: 9 / 10
📦 Base64 audio data: ✅ (123456 chars)
```

### Extraction Summary
```
📊 === EXTRACTION SUMMARY ===
👤 User Name: John Doe
🌍 Timezone: America/New_York
📞 Call Time: 20:30
⏰ Call Window: 20:30-21:00
📋 === END EXTRACTION SUMMARY ===
```

## 🎯 Type Safety

All test data is **fully type-safe** with TypeScript:

```typescript
// ✅ Type-safe response builders
createVoiceResponse(stepId, dbField, duration)
createTextResponse(text, dbField?)
createChoiceResponse(choice, dbField?)
createDualSlidersResponse(slider1, slider2, dbField)
createTimeWindowResponse(start, end, dbField)

// ✅ Type-safe payload structure
interface OnboardingCompleteRequest {
  state: OnboardingState;
  pushToken?: string;
  deviceMetadata?: DeviceMetadata;
}

// ✅ Type-safe response validation
interface OnboardingCompleteResponse {
  success: boolean;
  message?: string;
  totalSteps?: number;
  filesProcessed?: number;
  identityExtraction?: IdentityExtractionResult;
}
```

## 🛠️ Customizing Tests

### Add Your Own Test Scenario
```typescript
function createMyCustomTest(): OnboardingCompleteRequest {
  const now = new Date().toISOString();

  return {
    state: {
      currentStep: 45,
      responses: {
        "3": createTextResponse("Custom Name", ["identity_name"]),
        "37": createTimeWindowResponse("21:00", "22:00", ["evening_call_time"]),
        // Add more responses...
      },
      totalResponses: 2,
      progressPercentage: 100,
      startedAt: now,
      lastSavedAt: now,
      isCompleted: true,
      completedAt: now,
      userName: "Custom Name",
      userTimezone: "America/Los_Angeles",
    },
  };
}

// Add to main()
await runTest("My Custom Test", createMyCustomTest());
```

### Test Specific Step
```typescript
function testStep11Only(): OnboardingCompleteRequest {
  const base = createMinimalOnboarding();
  base.state.responses["11"] = createDualSlidersResponse(8, 10, [
    "motivation_fear_intensity",
    "motivation_desire_intensity"
  ]);
  return base;
}
```

## 🐛 Debugging Tips

### Enable Verbose Logging
Backend logs are already very detailed. To see more:
```bash
# Backend
LOG_LEVEL=debug npm run dev

# Test file
console.log("📦 Payload:", JSON.stringify(payload, null, 2));
```

### Check Database After Test
```sql
-- Check if onboarding was saved
SELECT * FROM onboarding WHERE user_id = 'your-user-id';

-- Check if identity was extracted
SELECT * FROM identity WHERE user_id = 'your-user-id';

-- Check if user was updated
SELECT onboarding_completed, call_window_start
FROM users WHERE id = 'your-user-id';
```

### Test Individual Helpers
```typescript
// Test response builders directly
const voice = createVoiceResponse(2, ["voice_commitment"], 10);
console.log(voice);

const sliders = createDualSlidersResponse(7, 9, ["fear", "desire"]);
console.log(sliders);
```

## 🚨 Common Issues

### Issue: `AUTH_TOKEN` Error
**Solution:** Set a valid JWT token in `CONFIG.AUTH_TOKEN`

### Issue: Network Error / Connection Refused
**Solution:** Make sure backend is running on `CONFIG.API_URL`

### Issue: 401 Unauthorized
**Solution:** Token expired or invalid - get a fresh token

### Issue: 400 Bad Request
**Solution:** Check payload structure matches types

### Issue: Identity Extraction Failed
**Solution:**
- Check OpenAI API key is set in backend
- Check backend logs for detailed error
- Voice data might be invalid base64

## 📊 Expected Output

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║              🧪 ONBOARDING ENDPOINT TEST SUITE                           ║
║                                                                           ║
║  Testing: POST /api/onboarding/v3/complete                               ║
║  API URL: http://localhost:8787                                          ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

================================================================================
🧪 TEST: 1. Minimal Valid Onboarding
================================================================================

📊 Response Status: 200
📦 Response Data: {
  "success": true,
  "message": "Onboarding completed successfully",
  "completedAt": "2025-01-15T10:30:00.000Z",
  "totalSteps": 2,
  "filesProcessed": 0,
  "processingWarnings": null,
  "identityExtraction": {
    "success": true,
    "fieldsExtracted": 3
  }
}

✅ TEST PASSED: 1. Minimal Valid Onboarding
   - Total Steps: 2
   - Files Processed: 0
   - Identity Extraction: SUCCESS
   - Fields Extracted: 3

... [more tests] ...

================================================================================
🎉 ALL TESTS COMPLETE
================================================================================
```

## 🎓 Further Testing

### Load Testing
```bash
# Install k6
brew install k6

# Create load test script
k6 run load-test.js --vus 10 --duration 30s
```

### Integration Tests
Consider adding to your CI/CD pipeline:
```yaml
# .github/workflows/test.yml
- name: Run Onboarding Tests
  run: npx tsx src/features/onboarding/tests/onboarding-endpoint.test.ts
```

### Unit Tests
For individual functions, consider Jest:
```bash
npm install --save-dev jest @types/jest
```

## 📚 Related Files

- `/be/src/features/onboarding/handlers/onboarding.ts` - Main endpoint
- `/be/src/features/identity/services/unified-identity-extractor.ts` - Identity extraction
- `/swift/bigbruhh/Features/Onboarding/Services/OnboardingDataPush.swift` - Swift data sender
