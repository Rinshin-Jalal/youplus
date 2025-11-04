# 🚨 FIX: "Failed to fetch offerings" Error

## Quick Fix (3 Steps - 2 Minutes)

### ✅ Step 1: Add StoreKit File to Xcode

1. Open Xcode: `bigbruhh.xcodeproj`
2. Drag `Products.storekit` into the project
3. Make sure "Add to target: bigbruhh" is checked

**OR if the file is already in Xcode:**
- Just verify it's in the Project Navigator (left sidebar)

---

### ✅ Step 2: Enable StoreKit Configuration

1. **Product** menu → **Scheme** → **Edit Scheme...**
2. Click **Run** (left sidebar)
3. Click **Options** tab (top)
4. Find **StoreKit Configuration** dropdown
5. Select **`Products`** (or `Products.storekit`)
6. Click **Close**

![Xcode Scheme Configuration](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)

---

### ✅ Step 3: Clean Build and Run

1. **Product** → **Clean Build Folder** (⌘ + Shift + K)
2. **Product** → **Run** (⌘ + R)
3. Complete onboarding
4. Tap **COMMIT**
5. **Paywall should now show products!**

---

## 🎯 What This Does

The `Products.storekit` file creates **local test products** for development:

- **bigbruh_599_week** - $5.99/week
- **bigbruhh_6899_sixmonth** - $89.99/6 months

When enabled in the scheme, RevenueCat fetches products from this file instead of App Store Connect.

---

## 🐛 Still Not Working?

### Try This:
```bash
1. Delete app from simulator
2. Xcode: Product → Clean Build Folder
3. Simulator: Device → Erase All Content and Settings
4. Build and run again
```

### Check This:
- ✅ `Products.storekit` is in Xcode project
- ✅ File is checked under target membership
- ✅ Scheme has StoreKit Configuration set
- ✅ Build succeeded without errors

---

## 📋 Match Product IDs

Make sure your **RevenueCat Dashboard** has these product IDs:

1. Go to https://app.revenuecat.com
2. Your app → **Products**
3. Create products:
   - `bigbruh_599_week`
   - `bigbruhh_6899_sixmonth`

4. Your app → **Offerings**
5. Create an offering with both products
6. Make it **current**

---

## 💡 Why This Happens

RevenueCat tries to fetch products from App Store Connect. Since this is development:
- App isn't in App Store yet
- No real products exist
- Need local StoreKit file for testing

**Solution:** StoreKit Configuration provides local test products.

---

## 🎉 After Fix

You should see:
```
✅ Offerings fetched: 2 packages
✅ Customer info fetched
```

And the paywall will display both subscription options!

---

## 📱 For Production Later

When ready for real App Store:

1. Create products in App Store Connect
2. Same IDs: `bigbruh_599_week`, `bigbruhh_6899_sixmonth`
3. In RevenueCat: Link to App Store Connect
4. For Release builds: **Disable** StoreKit Configuration

For now, keep StoreKit Configuration enabled for testing.
