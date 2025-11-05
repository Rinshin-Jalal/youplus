# Onboarding Tests & Integration Scripts

## Integration Scripts

### `onboarding-endpoint.integration.ts`

**Type**: Manual Integration Script (NOT automated test)

**Purpose**: Manually test the `/onboarding/v3/complete` endpoint against a running backend server.

**How to Use**:

1. **Start the backend server**:
   ```bash
   npm run dev
   # Server runs on http://localhost:8787
   ```

2. **Get an authentication token**:
   - Login to the app or use Supabase dashboard
   - Copy the JWT token from localStorage or API response
   - Open `onboarding-endpoint.integration.ts`
   - Set `CONFIG.AUTH_TOKEN` to your JWT token

3. **Run the integration script**:
   ```bash
   npx ts-node src/features/onboarding/tests/onboarding-endpoint.integration.ts
   ```

4. **What it tests**:
   - Complete onboarding flow with all response types
   - Voice recordings (base64 audio)
   - Text responses
   - Choice responses
   - Dual sliders
   - Time window picker
   - Backend response validation

**Note**: This is NOT run by `npm test` - it's excluded from Jest because:
- It requires a running backend server
- It requires a valid authentication token
- It makes actual API calls (not mocked)
- It's designed for manual testing during development

## Automated Tests (Coming Soon)

Proper unit and integration tests using Jest will be added here. These will:
- Use mocked dependencies
- Not require a running server
- Run automatically in CI/CD
- Test individual functions and modules

## Test Structure

```
tests/
├── README.md                              # This file
├── onboarding-endpoint.integration.ts     # Manual integration script
└── (future) onboarding.test.ts           # Automated unit tests
```

## Jest Configuration

Backend is configured with:
- ✅ TypeScript support via ts-jest
- ✅ Path alias mapping (@/ → src/)
- ✅ Integration scripts excluded (*.integration.ts)
- ✅ Passes with no tests (--passWithNoTests)

Run Jest: `npm test`
