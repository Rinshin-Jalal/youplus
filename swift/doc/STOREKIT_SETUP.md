# StoreKit Configuration Setup (Fix "No Products" Error)

## ❌ The Error You're Seeing

```
ERROR: There's a problem with your configuration. None of the products
registered in the RevenueCat dashboard could be fetched from App Store
Connect (or the StoreKit Configuration file if one is being used).
```

**Cause:** You need to set up local products for testing in Xcode.

---

## ✅ Solution: Use StoreKit Configuration File

### Step 1: Add StoreKit File to Xcode (REQUIRED)

1. Open Xcode project: `bigbruhh.xcodeproj`
2. In Project Navigator, find the file: **`Products.storekit`** (already created)
3. If it's not visible:
   - Right-click on `bigbruhh` folder in Xcode
   - **Add Files to "bigbruhh"...**
   - Select `Products.storekit`
   - ✅ Check "Add to target: bigbruhh"
   - Click **Add**

### Step 2: Enable StoreKit Testing

1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme...**
2. Select **Run** in the left sidebar
3. Go to **Options** tab
4. Find **StoreKit Configuration**
5. Select: **`Products.storekit`**
6. Click **Close**

### Step 3: Verify Products

1. In Xcode, open `Products.storekit`
2. You should see two subscriptions:
   - **bigbruh_599_week** - $5.99/week
   - **bigbruhh_6899_sixmonth** - $89.99/6 months

---

## 🎯 Quick Test (After Setup)

1. **Clean Build Folder**: ⌘ + Shift + K
2. **Build and Run**: ⌘ + R
3. Complete onboarding
4. Tap **COMMIT** on Almost There screen
5. You should now see the paywall with products!

---

## 📝 Match Product IDs with RevenueCat Dashboard

**IMPORTANT:** The product IDs in `Products.storekit` must match your RevenueCat dashboard:

### In StoreKit File (Products.storekit):
```json
"productID" : "bigbruh_599_week"
"productID" : "bigbruhh_6899_sixmonth"
```

### In RevenueCat Dashboard:
1. Go to https://app.revenuecat.com
2. Navigate to your app → **Products**
3. Make sure you have products with these EXACT IDs:
   - `bigbruh_599_week`
   - `bigbruhh_6899_sixmonth`

If your RevenueCat products have different IDs, either:
- **Option A:** Update `Products.storekit` to match RevenueCat
- **Option B:** Update RevenueCat products to match `Products.storekit`

---

## 🔍 Alternative: Create StoreKit File from Scratch

If you prefer to create your own:

1. **File** → **New** → **File...**
2. Search for **StoreKit Configuration File**
3. Name it: `Products`
4. Click **Create**
5. Add subscription group:
   - Click **+** → **Add Subscription Group**
   - Name: "BigBruh Subscriptions"
6. Add subscriptions:
   - Click **+** under the group → **Add Subscription**
   - **Product ID:** `bigbruh_599_week`
   - **Price:** $5.99
   - **Duration:** 1 Week
   - **Display Name:** BigBruh Weekly

   - Click **+** again → **Add Subscription**
   - **Product ID:** `bigbruhh_6899_sixmonth`
   - **Price:** $89.99
   - **Duration:** 6 Months
   - **Display Name:** BigBruh 6 Months

---

## 🧪 Testing Purchases Locally

With StoreKit Configuration enabled:

### Test Purchase Flow
1. Run app in simulator
2. Complete onboarding
3. See paywall with products
4. Tap on a plan
5. Sandbox purchase dialog appears
6. Click **Subscribe**
7. No real money charged (it's local testing)

### Debug Purchase State
In Xcode while app is running:
- **Debug** → **StoreKit** → **Transaction Manager**
- See all test transactions
- Can manually expire/renew subscriptions

### Test Restore
- Make a test purchase
- Uninstall and reinstall app
- Tap "Restore Purchases" in paywall
- Subscription should be restored

---

## 🔧 Troubleshooting

### "Products still not showing"
1. Make sure StoreKit Configuration is selected in scheme
2. Clean build folder (⌘ + Shift + K)
3. Restart Xcode
4. Build and run again

### "Product IDs don't match"
Check that `Products.storekit` product IDs exactly match:
1. RevenueCat dashboard products
2. App Store Connect products (if using real products)

### "Configuration error persists"
Try this order:
1. Delete app from simulator
2. Clean build folder
3. Reset simulator (**Device** → **Erase All Content and Settings**)
4. Build and run

---

## 📱 For Production (Real App Store)

When ready for production:

1. Create products in **App Store Connect**:
   - Go to https://appstoreconnect.apple.com
   - Your app → **Subscriptions**
   - Create subscriptions with same IDs: `bigbruh_599_week`, `bigbruhh_6899_sixmonth`

2. Add products to **RevenueCat Dashboard**:
   - Same product IDs
   - Link to App Store Connect

3. In Xcode scheme:
   - For **Debug**: Use StoreKit Configuration
   - For **Release**: Disable StoreKit Configuration (uses real App Store)

---

## 🎯 Current Product Configuration

Your `Products.storekit` file includes:

| Product ID | Price | Duration | Description |
|------------|-------|----------|-------------|
| `bigbruh_599_week` | $5.99 | 1 Week | BigBruh weekly accountability calls |
| `bigbruhh_6899_sixmonth` | $89.99 | 6 Months | BigBruh 6-month - Best value |

**Subscription Group:** BigBruh Subscriptions

---

## ✅ Checklist

- [ ] `Products.storekit` file added to Xcode project
- [ ] File is added to target `bigbruhh`
- [ ] Scheme configured to use `Products.storekit`
- [ ] Product IDs match RevenueCat dashboard
- [ ] Clean build and run
- [ ] Paywall shows products
- [ ] Test purchase works

---

## 📚 Resources

- [Apple StoreKit Testing Docs](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)
- [RevenueCat Testing Guide](https://www.revenuecat.com/docs/test-and-launch/sandbox)
- [Why Are Offerings Empty?](https://rev.cat/why-are-offerings-empty)
