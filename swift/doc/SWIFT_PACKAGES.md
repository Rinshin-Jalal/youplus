# 📦 SWIFT PACKAGE MANAGER (SPM) - COMPLETE PACKAGE LIST

## 🎯 ALL PACKAGES YOU NEED FOR BIGBRUH

Based on your React Native app dependencies, here are the **CORRECT** Swift package URLs:

---

## ✅ REQUIRED PACKAGES (Add These Now)

### 1. **Supabase Swift** (Auth + Database)
**What it replaces:** `@supabase/supabase-js`

```
https://github.com/supabase/supabase-swift
```

**Version:** `2.5.1` or later (use "Up to Next Major Version")

**Import in code:**
```swift
import Supabase
```

---

### 2. **RevenueCat Purchases** (Subscriptions)
**What it replaces:** `react-native-purchases`

```
https://github.com/RevenueCat/purchases-ios
```

**Version:** `5.15.0` or later

**Import in code:**
```swift
import RevenueCat
```

---

### 3. **LiveKit Swift SDK** (Voice/Video Calls)
**What it replaces:** `@livekit/react-native`

```
https://github.com/livekit/client-sdk-swift
```

**Version:** `2.3.0` or later

**Import in code:**
```swift
import LiveKit
```

---

## ⚠️ PACKAGES WE DON'T NEED (Native iOS Handles These)

### ❌ NO Swift Package Needed:
1. **Apple Sign-In** → Use native `AuthenticationServices` framework
2. **VoIP Push** → Use native `PushKit` framework
3. **CallKit** → Native framework (already in iOS)
4. **Audio Recording** → Use native `AVFoundation` framework
5. **Haptics** → Use native `UIKit` feedback generators
6. **Async Storage** → Use native `UserDefaults` or `Keychain`
7. **Notifications** → Use native `UserNotifications` framework

---

## 🤔 OPTIONAL PACKAGES (We'll Decide Later)

### 1. **KeychainAccess** (Better than UserDefaults for sensitive data)
**Use for:** Storing tokens, API keys securely

```
https://github.com/kishikawakatsumi/KeychainAccess
```

**Version:** `4.2.2` or later

**Import:**
```swift
import KeychainAccess
```

---

### 2. **Alamofire** (Network requests - Optional, URLSession works fine)
**Use for:** If you want nicer networking than URLSession

```
https://github.com/Alamofire/Alamofire
```

**Version:** `5.9.1` or later

**Import:**
```swift
import Alamofire
```

**⚠️ NOTE:** URLSession is built-in and works great. Only add if you want cleaner syntax.

---

## 🚫 11LABS - NO SWIFT PACKAGE EXISTS

**Problem:** No official 11Labs Swift SDK

**Solutions:**

### Option 1: Use Their REST API Directly (Recommended)
```swift
// You'll write this yourself using URLSession
class ElevenLabsService {
    let apiKey = "YOUR_KEY"
    let baseURL = "https://api.elevenlabs.io/v1"

    func synthesizeSpeech(text: String, voiceId: String) async throws -> Data {
        var request = URLRequest(url: URL(string: "\(baseURL)/text-to-speech/\(voiceId)")!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["text": text, "model_id": "eleven_monolingual_v1"]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}
```

### Option 2: Create Swift Wrapper (Advanced)
Create your own lightweight wrapper around their API. I can help with this later.

---

## 📝 HOW TO ADD PACKAGES IN XCODE (STEP-BY-STEP)

### For EACH package above:

1. **Open Your Xcode Project**
   - Should be at: `/Users/rinshin/Code/bigbruh/swift-ios-rewrite/bigbruhh/bigbruhh.xcodeproj`

2. **Go to Project Settings**
   - Click on "bigbruhh" (blue icon) in left sidebar (top level)
   - Make sure you're on the PROJECT, not target

3. **Add Package**
   - Click "Package Dependencies" tab at the top
   - Click the **"+"** button at bottom left

4. **Enter Package URL**
   - Paste the GitHub URL (e.g., `https://github.com/supabase/supabase-swift`)
   - Click "Add Package"

5. **Choose Version**
   - Select "Up to Next Major Version"
   - Click "Add Package" again

6. **Select Targets**
   - Check "bigbruhh" (your app target)
   - Click "Add Package"

7. **Wait for Resolution**
   - Xcode will download and resolve dependencies
   - You'll see progress in top bar
   - May take 1-2 minutes per package

8. **Verify Installation**
   - You should see the package under "Package Dependencies" in Project Navigator
   - Try importing: `import Supabase` in any Swift file

---

## 🎯 INSTALLATION ORDER (DO IN THIS ORDER)

### **Phase 1: Essential (Do Now)**
1. ✅ Supabase Swift
2. ✅ RevenueCat Purchases

### **Phase 2: For Calls (Week 5-6)**
3. ⏳ LiveKit Swift SDK

### **Phase 3: Optional (If Needed)**
4. ⏳ KeychainAccess (for secure storage)

---

## 🐛 TROUBLESHOOTING

### "Package not found" or "Invalid URL"
- ✅ Make sure URL is exact: `https://github.com/supabase/supabase-swift`
- ✅ No trailing slash
- ✅ Use `https://` not `git@`

### "Unable to resolve package dependencies"
- ✅ File → Packages → Reset Package Caches
- ✅ File → Packages → Update to Latest Package Versions
- ✅ Restart Xcode

### "No such module 'Supabase'"
- ✅ Build the project first: Cmd+B
- ✅ Make sure package is added to your target
- ✅ Check "Package Dependencies" tab shows the package

### Build takes forever
- ✅ First build downloads all dependencies (5-10 min)
- ✅ Subsequent builds are fast (<30 seconds)

---

## 📦 WHAT EACH PACKAGE GIVES YOU

### **Supabase Swift**
```swift
// What you get:
- auth.signIn()
- auth.signOut()
- auth.session
- from("table").select()
- from("table").insert()
- storage.from("bucket").upload()
```

### **RevenueCat**
```swift
// What you get:
- Purchases.configure()
- Purchases.shared.offerings()
- Purchases.shared.purchase(package:)
- Purchases.shared.restorePurchases()
- Purchases.shared.getCustomerInfo()
```

### **LiveKit**
```swift
// What you get:
- Room.connect()
- room.localParticipant?.setMicrophone(enabled:)
- room.disconnect()
- Track publishing/subscribing
```

---

## ✅ VERIFICATION CHECKLIST

After adding packages, verify:

- [ ] Xcode shows no errors in Package Dependencies tab
- [ ] You can build project (Cmd+B) with no errors
- [ ] You can import packages:
  ```swift
  import Supabase
  import RevenueCat
  ```
- [ ] No red underlines when you type the imports

---

## 🚀 NEXT STEP AFTER PACKAGES

Once packages are installed:

1. ✅ Create `Core/Networking/SupabaseClient.swift`
2. ✅ Create `Features/Authentication/Services/AuthService.swift`
3. ✅ Create your first view: `AuthView.swift`

I'll give you the exact code once packages are installed!

---

## 🆘 IF YOU GET STUCK

Common issues:

1. **"Xcode is unresponsive"** → Quit and reopen (package resolution can freeze UI)
2. **"Build failed"** → Clean Build Folder (Cmd+Shift+K), then rebuild
3. **"Package not found"** → Double-check URL is EXACT (copy-paste from above)

---

**Ready? Add these 2 packages now (Supabase + RevenueCat), then ping me! 🎯**
