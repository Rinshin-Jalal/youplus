# Quick Start - RevenueCat Paywall

## 🚀 Get Running in 3 Steps

### Step 1: Install RevenueCat SDK (5 minutes)

**Using Xcode (Recommended):**

1. Open `bigbruhh.xcodeproj`
2. **File** → **Add Package Dependencies...**
3. Paste: `https://github.com/RevenueCat/purchases-ios.git`
4. Click **Add Package**
5. Select **both** packages:
   - ✅ `RevenueCat`
   - ✅ `RevenueCatUI`
6. Add to target: `bigbruhh`

### Step 2: Configure Dashboard (10 minutes)

1. Go to https://app.revenuecat.com
2. Create/select your **BigBruh** app
3. Get **iOS API Key** from **Settings** → **API Keys**
4. Make sure `Config.xcconfig` or `Info.plist` has:
   ```
   PUBLIC_REVENUECAT_IOS_API_KEY = appl_xxxxxxxxxx
   ```
5. Create **Offerings**:
   - Product 1: Monthly ($29.99/mo)
   - Product 2: Yearly ($199.99/yr)
6. Create a **Paywall** template
7. Publish it

### Step 3: Test (2 minutes)

1. Build and run app
2. Complete onboarding (or use debug button to skip)
3. Tap **COMMIT** on Almost There screen
4. See RevenueCat paywall
5. In **DEBUG** mode: Subscription auto-granted (no purchase needed)

---

## ✅ Done!

Your paywall is ready. The implementation:
- ✅ Matches NRN architecture exactly
- ✅ Uses native RevenueCatUI components
- ✅ Has dev mode bypass for testing
- ✅ Tracks analytics events
- ✅ Accesses onboarding data

---

## Testing Without Purchase

In **DEBUG** builds, subscription is automatically active:

```swift
#if DEBUG
// RevenueCatService.swift automatically returns:
subscriptionStatus = SubscriptionStatus(
    isActive: true,
    isEntitled: true,
    productId: "dev_override_premium"
)
#endif
```

You can navigate through the entire flow without making a real purchase.

---

## File Overview

| File | What It Does |
|------|--------------|
| `RevenueCatService.swift` | Manages SDK, subscriptions |
| `RevenueCatPaywallView.swift` | Native paywall UI component |
| `PaywallView.swift` | Navigation wrapper |
| `AlmostThereView.swift` | Shows paywall when user taps COMMIT |
| `OnboardingDataManager.swift` | Stores completed onboarding data |

---

## Common Issues

### "Missing API Key"
Add to `Info.plist`:
```xml
<key>PUBLIC_REVENUECAT_IOS_API_KEY</key>
<string>appl_xxxxxxxxxxxxxx</string>
```

### "No offerings available"
Create offerings in RevenueCat dashboard and publish paywall

### Purchase not working
Use **sandbox Apple ID** in Settings → App Store → Sandbox Account

---

## Resources

- Full setup: `REVENUECAT_SETUP.md`
- Implementation details: `PAYWALL_IMPLEMENTATION_SUMMARY.md`
- RevenueCat docs: https://www.revenuecat.com/docs
