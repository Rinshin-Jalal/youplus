# 🚀 BIGBRUH SWIFT SETUP GUIDE

**Complete setup from scratch in 15 minutes**

---

## STEP 1: CREATE XCODE PROJECT

1. **Open Xcode** (make sure Xcode is fully closed first)

2. **Create New Project**:
   - File → New → Project
   - Choose **"App"** under iOS
   - Click **Next**

3. **Configure Project**:
   ```
   Product Name: BigBruh
   Team: [Select your Apple Developer team]
   Organization Identifier: com.yourcompany
   Bundle Identifier: com.yourcompany.BigBruh
   Interface: SwiftUI
   Language: Swift
   ☐ Use Core Data (UNCHECKED)
   ☐ Include Tests (UNCHECKED)
   ```

4. **Save Location**:
   - Navigate to `/Users/rinshin/Code/bigbruh/swift-ios-rewrite/`
   - Click **Create**
   - ⚠️ **DO NOT** create Git repository when prompted

---

## STEP 2: CONFIGURE CAPABILITIES

1. **Open BigBruh Target**:
   - Click on `BigBruh` project in left sidebar
   - Select `BigBruh` target (not the project)
   - Go to **"Signing & Capabilities"** tab

2. **Add Capabilities** (click "+ Capability" button):

   **a) Sign in with Apple**
   - Click "+ Capability"
   - Search for "Sign in with Apple"
   - Add it

   **b) Push Notifications**
   - Click "+ Capability"
   - Search for "Push Notifications"
   - Add it

   **c) Background Modes**
   - Click "+ Capability"
   - Search for "Background Modes"
   - Add it
   - ✅ Check these boxes:
     - ✅ Audio, AirPlay, and Picture in Picture
     - ✅ Voice over IP
     - ✅ Background fetch
     - ✅ Remote notifications

---

## STEP 3: ADD SWIFT PACKAGES

1. **Add Package Dependencies**:
   - File → Add Package Dependencies... (NOT "Add Package Collection")

2. **Add Each Package** (one at a time):

   **Package 1: Supabase**
   ```
   URL: https://github.com/supabase/supabase-swift
   Dependency Rule: Up to Next Major Version 2.0.0
   Add to Target: BigBruh
   ```

   **Package 2: RevenueCat**
   ```
   URL: https://github.com/RevenueCat/purchases-ios
   Dependency Rule: Up to Next Major Version 5.0.0
   Add to Target: BigBruh
   ```

   **Package 3: LiveKit (Optional - for VoIP calls)**
   ```
   URL: https://github.com/livekit/client-sdk-swift
   Dependency Rule: Up to Next Major Version 2.0.0
   Add to Target: BigBruh
   ```

3. **Wait for packages to resolve** (may take 2-3 minutes)

---

## STEP 4: CONFIGURE INFO.PLIST

1. **Open Info.plist**:
   - In Project Navigator, expand `BigBruh` folder
   - Click on `Info.plist`

2. **Add Required Keys** (Right-click → Add Row):

   **a) Microphone Permission**
   ```
   Key: Privacy - Microphone Usage Description
   Type: String
   Value: BigBruh needs microphone access for voice responses and calls
   ```

   **b) VoIP Background Mode** (Already added via Capabilities)

   **c) Audio Session Category** (Add if needed for calls)
   ```
   Key: UIBackgroundModes
   (This should already exist from Step 2)
   ```

---

## STEP 5: SET UP ENVIRONMENT VARIABLES

1. **Edit Scheme**:
   - Click on scheme selector (top left, says "BigBruh")
   - Select **"Edit Scheme..."**

2. **Add Environment Variables**:
   - Select **"Run"** on left sidebar
   - Click **"Arguments"** tab
   - Expand **"Environment Variables"** section
   - Click **"+"** to add each variable:

   ```
   Name: SUPABASE_URL
   Value: [Your Supabase project URL]

   Name: SUPABASE_ANON_KEY
   Value: [Your Supabase anon key]

   Name: REVENUECAT_API_KEY
   Value: [Your RevenueCat iOS key]

   Name: ELEVENLABS_API_KEY
   Value: [Your ElevenLabs API key]
   ```

3. Click **Close**

---

## STEP 6: ADD EXISTING SWIFT FILES

1. **Add the BigBruh folder**:
   - In Finder, navigate to `/Users/rinshin/Code/bigbruh/swift-ios-rewrite/BigBruh`
   - Drag the entire `BigBruh` folder into Xcode's Project Navigator
   - ⚠️ **IMPORTANT**: In the dialog that appears:
     - ✅ Check "Copy items if needed"
     - ✅ Select "Create groups" (NOT folders)
     - ✅ Add to target: BigBruh
   - Click **Finish**

2. **Delete default files**:
   - Delete `ContentView.swift` (we have our own)
   - Delete `BigBruhApp.swift` (we'll create a better one)

---

## STEP 7: CREATE APP ENTRY POINT

Create `BigBruhApp.swift` in the main BigBruh folder:

```swift
import SwiftUI

@main
struct BigBruhApp: App {
    @StateObject private var authService = AuthService.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.loading {
                    LoadingView()
                } else if authService.isAuthenticated {
                    if authService.user?.onboardingCompleted == true {
                        Text("HOME SCREEN (TODO)")
                    } else {
                        Text("ONBOARDING SCREEN (TODO)")
                    }
                } else {
                    AuthView()
                }
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.brutalBlack.ignoresSafeArea()
            ProgressView()
                .tint(.neonGreen)
                .scaleEffect(2)
        }
    }
}
```

---

## STEP 8: BUILD THE PROJECT

1. **Select Simulator**:
   - Click scheme selector (top left)
   - Choose iPhone 15 Pro or any recent iPhone

2. **Build**:
   - Press **Cmd + B** to build
   - Wait for build to complete

3. **Fix Any Errors**:
   - If you get import errors, check packages are installed
   - If you get missing file errors, ensure all files were added correctly

4. **Run**:
   - Press **Cmd + R** to run
   - App should launch showing the AuthView

---

## ✅ VERIFICATION CHECKLIST

- [ ] Xcode project created successfully
- [ ] All 3 capabilities added (Sign in with Apple, Push Notifications, Background Modes)
- [ ] All 3 packages installed (Supabase, RevenueCat, LiveKit)
- [ ] Info.plist has microphone permission
- [ ] Environment variables configured
- [ ] All Swift files added to project
- [ ] App builds without errors (Cmd + B)
- [ ] App runs on simulator (Cmd + R)
- [ ] AuthView displays correctly

---

## 🐛 COMMON ISSUES

**"Missing SUPABASE_URL"**
→ Check Step 5 - Environment variables must be set in scheme

**"No such module Supabase"**
→ File → Add Package Dependencies and add packages from Step 3

**"Multiple commands produce Info.plist"**
→ Don't create custom Info.plist, use Xcode's built-in one

**Build errors about missing files**
→ Make sure you added the BigBruh folder with "Create groups" option

---

## 📱 NEXT STEPS

Once setup is complete:
1. Test Apple Sign In on a real device (won't work on simulator)
2. Configure your Supabase project
3. Set up RevenueCat products
4. Start building onboarding flow

---

**Need help? Check the Swift files in `BigBruh/` folder - they're all documented!**
