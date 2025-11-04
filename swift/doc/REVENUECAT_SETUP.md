# RevenueCat Setup Instructions

## 1. Install RevenueCat SDK via Xcode

### Option A: Swift Package Manager (Recommended)

1. Open Xcode project: `bigbruhh.xcodeproj`
2. Go to **File** → **Add Package Dependencies...**
3. Enter URL: `https://github.com/RevenueCat/purchases-ios.git`
4. Select version: **Latest** (4.x or 5.x)
5. Add both packages to target:
   - ✅ **RevenueCat** (required)
   - ✅ **RevenueCatUI** (required for native paywalls)

### Option B: CocoaPods

If using CocoaPods, add to `Podfile`:

```ruby
pod 'RevenueCat', '~> 5.0'
pod 'RevenueCatUI', '~> 5.0'
```

Then run:
```bash
pod install
```

---

## 2. Configure RevenueCat Dashboard

1. Go to [app.revenuecat.com](https://app.revenuecat.com)
2. Create a new app or select existing BigBruh app
3. Get your **iOS API Key** from **Settings** → **API Keys**
4. Create offerings and products:
   - Monthly plan (e.g., `$29.99/month`)
   - Yearly plan (e.g., `$199.99/year`)

---

## 3. Add API Key to Config

Your API key is already configured in `Config.swift`:

```swift
static let revenueCatAPIKey: String = {
    guard let key = Bundle.main.object(forInfoDictionaryKey: "PUBLIC_REVENUECAT_IOS_API_KEY") as? String else {
        fatalError("❌ Missing PUBLIC_REVENUECAT_IOS_API_KEY in Info.plist")
    }
    return key
}()
```

Make sure your `Config.xcconfig` or `Info.plist` has:
```
PUBLIC_REVENUECAT_IOS_API_KEY = appl_xxxxxxxxxxxxxxxxxx
```

---

## 4. Create Paywall in RevenueCat Dashboard

1. Go to **Paywalls** in RevenueCat dashboard
2. Create a new paywall
3. Choose a template (e.g., **Bold** or **Minimal**)
4. Customize colors, copy, and CTA buttons
5. Add your subscription packages
6. Publish the paywall

---

## 5. Test the Paywall

### Development Mode
In `DEBUG` builds, the app automatically grants subscription access:
- `RevenueCatService.swift` returns `isActive: true` and `isEntitled: true`
- No actual purchase required for testing UI flow

### Production/TestFlight Mode
- Use sandbox Apple ID for testing
- Or add yourself as a [tester in RevenueCat](https://www.revenuecat.com/docs/test-and-launch/sandbox)

---

## 6. Implementation Details

### Files Created

| File | Purpose |
|------|---------|
| `RevenueCatService.swift` | Singleton managing RevenueCat SDK, subscriptions |
| `RevenueCatPaywallView.swift` | Native paywall using RevenueCatUI's `PaywallView` |
| `PaywallView.swift` | Container managing navigation after purchase |

### Architecture

```
AlmostThereView (User taps COMMIT)
    ↓
PaywallView (source: "almost_there")
    ↓
RevenueCatPaywallView (RevenueCat native UI)
    ↓
[User purchases]
    ↓
HomeView (Navigate after successful purchase)
```

### Subscription State Management

```swift
@EnvironmentObject var revenueCat: RevenueCatService

// Check subscription status
if revenueCat.hasActiveSubscription {
    // User is subscribed
}

// Access subscription details
revenueCat.subscriptionStatus.productId
revenueCat.subscriptionStatus.expirationDate
revenueCat.subscriptionStatus.willRenew
```

---

## 7. Matching NRN Implementation

### React Native (nrn)
```tsx
import RevenueCatUI from "react-native-purchases-ui";

<RevenueCatUI.Paywall
  onPurchaseCompleted={() => router.push("/celebration")}
  onDismiss={() => handleDecline()}
/>
```

### SwiftUI (bigbruhh)
```swift
import RevenueCatUI

PaywallView(offering: offering)
    .onPurchaseCompleted { customerInfo in
        handlePurchaseComplete()
    }
    .onRequestedDismissal {
        handleDismiss()
    }
```

**Both use the same:**
- ✅ RevenueCat's native paywall UI (not custom)
- ✅ Offerings fetched from RevenueCat dashboard
- ✅ Same purchase callbacks
- ✅ Same subscription entitlement logic

---

## 8. Analytics & Tracking

Currently logs events to console. To integrate with PostHog:

```swift
private func trackEvent(_ eventName: String) {
    // TODO: Add PostHog integration
    PostHog.capture(eventName, properties: [
        "source": source,
        "user_name": onboardingData.userName ?? "N/A"
    ])
}
```

---

## 9. Development vs Production

### Development Mode (`#if DEBUG`)
- Always shows `isActive: true`
- No real purchase required
- Prints: `🔧 DEV MODE: Subscription always active`

### Production Mode
- Real RevenueCat API calls
- Checks actual entitlements
- Syncs with backend via `/api/settings/subscription-status`

---

## 10. User Flow

1. **Onboarding (45 steps)** → Completes
2. **Almost There View** → User taps **COMMIT**
3. **RevenueCat Paywall** → Native UI from dashboard
4. **Purchase** → User subscribes
5. **Home View** → Access granted
6. **Subscription Status** → Synced to backend

---

## 11. Testing Checklist

- [ ] Add RevenueCat SDK via SPM or CocoaPods
- [ ] Configure API key in `Info.plist`
- [ ] Create offerings in RevenueCat dashboard
- [ ] Build and run app
- [ ] Complete onboarding
- [ ] Tap **COMMIT** in Almost There
- [ ] See RevenueCat paywall
- [ ] Test purchase flow (sandbox)
- [ ] Verify navigation to Home after purchase
- [ ] Check subscription status in app

---

## 12. Troubleshooting

### "Missing API Key" error
Make sure `PUBLIC_REVENUECAT_IOS_API_KEY` is in `Info.plist`

### "No offerings available"
Check RevenueCat dashboard has published offerings

### "Failed to fetch offerings"
- Check API key is correct
- Check network connection
- Check RevenueCat dashboard status

### Purchase not registering
- Use sandbox Apple ID
- Check RevenueCat dashboard for transaction
- Check logs for purchase errors

---

## Resources

- [RevenueCat iOS SDK Docs](https://www.revenuecat.com/docs/getting-started/installation/ios)
- [RevenueCatUI Docs](https://www.revenuecat.com/docs/tools/paywalls)
- [Displaying Paywalls](https://www.revenuecat.com/docs/tools/paywalls/displaying-paywalls)
