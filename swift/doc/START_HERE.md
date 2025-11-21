# 🔥 BIGBRUH SWIFT - START HERE

**From zero to running app in 15 minutes. No bullshit.**

---

## ⚠️ BEFORE YOU START

**Close Xcode completely** if it's open (Cmd + Q)

**You need:**
- Xcode 15+ installed
- Apple Developer account (free or paid)
- Your Supabase credentials ready
- Your RevenueCat API key ready
- Your ElevenLabs API key ready

---

## 1️⃣ CREATE PROJECT (2 min)

### Open Xcode → File → New → Project

![Create New Project](https://docs-assets.developer.apple.com/published/1234/new-project.png)

1. **Platform**: iOS
2. **Template**: App
3. Click **Next**

### Project Settings:

```
Product Name:           BigBruh
Team:                   [YOUR TEAM - select from dropdown]
Organization Identifier: com.yourdomain
Bundle Identifier:      com.yourdomain.BigBruh
Interface:              SwiftUI
Language:               Swift
Storage:                None
Include Tests:          ❌ UNCHECK
```

### Save Location:
```
/Users/rinshin/Code/bigbruh/swift-ios-rewrite/
```

Click **Create**

⚠️ **If asked about Git**: Click "Don't Create"

---

## 2️⃣ CAPABILITIES (3 min)

### In Xcode Project Navigator (left sidebar):
1. Click **BigBruh** (blue icon at top)
2. Select **BigBruh** target (under "TARGETS", NOT "PROJECT")
3. Click **"Signing & Capabilities"** tab

### Add 3 Capabilities:

#### **Capability 1: Sign in with Apple**
- Click **"+ Capability"** button (top left)
- Type "sign in with apple"
- Double-click **"Sign in with Apple"**
- ✅ It appears in the list

#### **Capability 2: Push Notifications**
- Click **"+ Capability"** again
- Type "push notifications"
- Double-click **"Push Notifications"**
- ✅ It appears in the list

#### **Capability 3: Background Modes**
- Click **"+ Capability"** again
- Type "background modes"
- Double-click **"Background Modes"**
- ✅ Check these 4 boxes:
  - ✅ **Audio, AirPlay, and Picture in Picture**
  - ✅ **Voice over IP**
  - ✅ **Background fetch**
  - ✅ **Remote notifications**

**You should now see 3 capability boxes in the Signing & Capabilities tab.**

---

## 3️⃣ SWIFT PACKAGES (4 min)

### File → Add Package Dependencies...

⚠️ **NOT "Add Package Collection"** - use **"Add Package Dependencies"**

### Add Package 1: Supabase

```
Search Bar: https://github.com/supabase/supabase-swift
```

1. Paste URL, press Enter
2. Wait for package to load (~30 seconds)
3. Dependency Rule: **"Up to Next Major Version"** → `2.0.0`
4. Click **"Add Package"**
5. **Check these libraries** in the list:
   - ✅ Supabase
   - ✅ Auth
   - ✅ PostgREST
   - ✅ Storage
   - ✅ Realtime
6. Click **"Add Package"**

### Add Package 2: RevenueCat

```
Search Bar: https://github.com/RevenueCat/purchases-ios
```

1. Paste URL, press Enter
2. Wait for package to load
3. Dependency Rule: **"Up to Next Major Version"** → `5.0.0`
4. Click **"Add Package"**
5. **Check**: ✅ RevenueCat
6. Click **"Add Package"**

### Add Package 3: LiveKit (Optional - for VoIP)

```
Search Bar: https://github.com/livekit/client-sdk-swift
```

1. Paste URL, press Enter
2. Wait for package to load
3. Dependency Rule: **"Up to Next Major Version"** → `2.0.0`
4. Click **"Add Package"**
5. **Check**: ✅ LiveKit
6. Click **"Add Package"**

**Wait for "Resolving Package Graph" to complete** (watch top progress bar)

---

## 4️⃣ PERMISSIONS (1 min)

### Add Microphone Permission:

1. In Project Navigator (left sidebar), click **Info.plist** (might be under BigBruh folder)
2. Right-click anywhere in the plist → **"Add Row"**
3. In the new row:
   ```
   Key:   Privacy - Microphone Usage Description
   Type:  String
   Value: BigBruh needs microphone access for voice responses and accountability calls
   ```

**That's it for Info.plist!** Background modes were added automatically from Step 2.

---

## 5️⃣ ENVIRONMENT VARIABLES (2 min)

### Set up your API keys:

1. Click **scheme selector** at top (says "BigBruh > iPhone 15 Pro")
2. Select **"Edit Scheme..."**
3. Click **"Run"** (left sidebar - should already be selected)
4. Click **"Arguments"** tab (top)
5. Expand **"Environment Variables"** section
6. Click **"+"** button 4 times to add these:

```
SUPABASE_URL              https://yourproject.supabase.co
SUPABASE_ANON_KEY         eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
REVENUECAT_API_KEY        appl_XXXXXXXXXXXXXXXXXXXXXXXX
ELEVENLABS_API_KEY        sk_XXXXXXXXXXXXXXXXXXXXXXXX
```

**⚠️ Replace with YOUR actual keys!**

To get your keys:
- **Supabase**: https://app.supabase.com → Your Project → Settings → API
- **RevenueCat**: https://app.revenuecat.com → Your App → API Keys
- **ElevenLabs**: https://elevenlabs.io → Profile → API Key

Click **"Close"**

---

## 6️⃣ ADD SWIFT FILES (2 min)

### Copy existing Swift code into Xcode:

1. **Delete default files** in Xcode:
   - Right-click `ContentView.swift` → Delete → **"Move to Trash"**
   - Right-click `BigBruhApp.swift` → Delete → **"Move to Trash"**

2. **Add our Swift folder**:
   - Open **Finder**
   - Navigate to `/Users/rinshin/Code/bigbruh/swift-ios-rewrite/BigBruh/`
   - You should see folders: `App/`, `Core/`, `Features/`, `Models/`, `Shared/`

3. **Drag into Xcode**:
   - Select ALL folders (`App`, `Core`, `Features`, `Models`, `Shared`)
   - Drag them into Xcode's **BigBruh** folder (in Project Navigator)
   - **IMPORTANT**: In the popup dialog:
     - ✅ **Copy items if needed**
     - ✅ **Create groups** (NOT "Create folder references")
     - ✅ **Add to targets: BigBruh**
   - Click **Finish**

Your Project Navigator should now look like:
```
BigBruh/
  ├── App/
  ├── Core/
  ├── Features/
  ├── Models/
  ├── Shared/
  ├── Assets.xcassets
  ├── Preview Content/
  └── Info.plist
```

---

## 7️⃣ CREATE APP ENTRY POINT (1 min)

### Create BigBruhApp.swift:

1. Right-click **BigBruh** folder → **New File...**
2. Choose **"Swift File"**
3. Name it **`BigBruhApp.swift`**
4. Paste this code:

```swift
import SwiftUI

@main
struct BigBruhApp: App {
    @StateObject private var authService = AuthService.shared

    init() {
        // Configure app on launch
        Config.log("🔥 BigBruh launching...", category: "App")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.loading {
                    LoadingView()
                } else if authService.isAuthenticated {
                    if authService.user?.onboardingCompleted == true {
                        HomeView()
                    } else {
                        OnboardingView()
                    }
                } else {
                    AuthView()
                }
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var pulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.brutalBlack
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Text("YOU+")
                    .font(.headline)
                    .foregroundColor(.brutalRedLight)
                    .brutalStyle()
                    .scaleEffect(pulse)

                ProgressView()
                    .tint(.neonGreen)
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                pulse = 1.05
            }
        }
    }
}

// MARK: - Temporary Placeholder Views
struct OnboardingView: View {
    var body: some View {
        ZStack {
            Color.brutalBlack.ignoresSafeArea()
            VStack(spacing: Spacing.xl) {
                Text("ONBOARDING")
                    .font(.headline)
                    .foregroundColor(.neonGreen)
                    .brutalStyle()
                Text("Coming soon...")
                    .font(.bodyRegular)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.brutalBlack.ignoresSafeArea()
            VStack(spacing: Spacing.xl) {
                Text("HOME")
                    .font(.headline)
                    .foregroundColor(.neonGreen)
                    .brutalStyle()
                Text("Coming soon...")
                    .font(.bodyRegular)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}
```

5. Press **Cmd + S** to save

---

## 8️⃣ BUILD & RUN (1 min)

### Build the project:

1. **Select a simulator**:
   - Click scheme selector (top left)
   - Choose **iPhone 15 Pro** (or any recent iPhone)

2. **Build**:
   - Press **Cmd + B**
   - Wait for build to complete
   - Watch bottom status bar for progress

3. **Fix any errors** (if they appear):
   - Click error in Issue Navigator (left sidebar, triangle icon)
   - Most common: Missing imports = packages not added correctly
   - Go back to Step 3 if needed

4. **Run**:
   - Press **Cmd + R**
   - Simulator should launch
   - App should display **AuthView** with "Sign in with Apple" button

---

## ✅ SUCCESS CHECKLIST

You should see:
- ✅ Black background
- ✅ "YOU+" title in red
- ✅ "Sign in with Apple" button
- ✅ No build errors
- ✅ No runtime crashes

**Console output should show:**
```
[App] 🔥 BigBruh launching...
[Supabase] Supabase client initialized
[Auth] Initializing AuthService
[Auth] No existing session
```

---

## 🐛 TROUBLESHOOTING

### "Missing SUPABASE_URL environment variable"
→ Go back to **Step 5** - check environment variables in scheme

### "No such module 'Supabase'"
→ Go back to **Step 3** - packages not installed correctly
→ Try: File → Packages → Resolve Package Versions

### "Multiple commands produce Info.plist"
→ You created a duplicate Info.plist - delete any custom one
→ Use only Xcode's built-in Info.plist

### Build takes forever / stuck
→ Xcode → Clean Build Folder (Cmd + Shift + K)
→ Restart Xcode

### "Cannot find 'Color.brutalBlack' in scope"
→ Files weren't added correctly in **Step 6**
→ Make sure you selected "Create groups" not "Create folder references"

### Sign in with Apple button doesn't work on simulator
→ **This is normal!** Apple Sign In only works on real devices
→ App should still launch and show the button (just can't tap it)

---

## 🎯 WHAT YOU JUST BUILT

✅ Complete Xcode project with proper setup
✅ Theme system (colors, fonts, spacing, animations)
✅ Supabase authentication
✅ Storage managers (UserDefaults + Keychain)
✅ Networking layer
✅ Auth flow with Apple Sign In
✅ Data models ready for onboarding

**Next:** Build onboarding flow (45 steps across 9 phases)

---

## 📱 TEST ON REAL DEVICE

To test Apple Sign In:

1. Connect iPhone via USB
2. Select your iPhone in scheme selector
3. Trust your developer certificate on device
4. Press Cmd + R
5. Tap "Sign in with Apple"
6. Use Face ID / Touch ID
7. You're in!

---

## 🚀 NEXT STEPS

1. ✅ Verify app launches on simulator
2. Test on real device for Apple Sign In
3. Set up Supabase database tables
4. Configure RevenueCat products
5. Start building onboarding step views

**Files are in: `/Users/rinshin/Code/bigbruh/swift-ios-rewrite/BigBruh/`**

Check [FILES_CREATED.md](FILES_CREATED.md) for what's ready and what's next.

---

**Questions? Each Swift file has detailed comments explaining what it does.**

**Ready to build? Let's create the onboarding flow next! 🔥**
