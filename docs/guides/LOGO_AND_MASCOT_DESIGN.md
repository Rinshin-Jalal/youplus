# App Logo Design System — Minimal Glyph

## 1. Core Concept
**You+ = Future You monitoring Present You.** The logo is a warning indicator: calm when honest, hostile when lying. Ultra-minimal, zero decoration.

---

## 2. App Logo Specifications

### 2.1 Required Sizes & Formats
- **App Store (iOS):** 1024×1024 pt — PNG, no transparency
- **Android:** 96×96 pt minimum — PNG, no transparency
- **Export sizes:** 1024, 512, 256, 128, 64, 32 px (all PNG)
- **Format:** PNG only for app stores (no SVG, no transparency)

### 2.2 Primary Symbol — "Future Pointer"
- **Shape:** Equilateral triangle with 12–16% corner radius
- **Dot:** Centered circle, 22–25% of triangle height
- **Metaphor:** Triangle = Future You (stable). Dot = Present You (monitored)
- **Readability test:** Must be recognizable at 32px (smallest app icon size)

### 2.3 Color System

**Base (Idle State):**
- Triangle: `#FFFFFF` (white)
- Dot: `#000000` (black)
- Background: `#000000` (black)

**State Colors (Dot only):**
- **Assessing:** `#FFFF00` (yellow) — caution, waiting
- **Approved:** `#39FF14` (neon green) — truth verified
- **Failed:** `#FF0033` (neon red) — lie detected
- **Lockdown:** `#FF0033` (red) — account breach

**Color Psychology Alignment:**
- Red = Urgency, confrontation, brutal honesty ✅
- Green = Growth, verification, success ✅
- Yellow = Warning, caution, pending judgment ✅
- Black/White = Binary truth, no gray areas ✅

### 2.4 Simplicity Rules
- ✅ Single symbol (triangle + dot)
- ✅ Maximum 2 colors at once (triangle + dot)
- ✅ No gradients (except optional neon glow on dot)
- ✅ No text in icon
- ✅ No decorative elements
- ✅ Works at 32px minimum

---

## 3. Logo Variations

### 3.1 App Icon (Primary)
- Triangle + dot only
- Black background
- White triangle
- State-based dot color
- **Use:** App Store, home screen, notifications

### 3.2 Wordmark Lockup (Secondary)
- Triangle + dot left
- `YOU+` text right (Bebas Neue / Inter Black)
- Uppercase, tracking 240–320
- **Use:** Splash screen, marketing, headers

### 3.3 Monogram Option
- `Y+` letters only (no symbol)
- Same typeface, same tracking
- **Use:** Favicon, tiny spaces, watermark

---

## 4. Mascot = Animated Glyph

The mascot **is the logo itself** — animated through state changes. No character, just behavior.

### 4.1 State Behaviors

| State | Visual | Animation | Duration | Use Case |
| --- | --- | --- | --- | --- |
| **Idle** | White triangle, black dot | None | — | Dashboard default |
| **Assessing** | White triangle, yellow dot | Dot pulses 0.85× → 1× | 140ms loop | Call prompt, check-in |
| **Approved** | White triangle, green dot | Dot expands 1.15× then settles | 200ms | Success toast, streak |
| **Failed** | White triangle, red dot | Dot shrinks 0.7× then restores | 180ms | Failure modal, alert |
| **Lockdown** | Red triangle, red dot | Static, no animation | — | Account breach |

### 4.2 Animation Rules
- Linear easing only (no bounce, no ease)
- Maximum duration: 220ms per action
- Optional: 1-frame RGB glitch on state change
- Never rotate triangle
- Never move dot outside center
- Sync haptic feedback with dot pulses

---

## 5. Competitor Analysis & Uniqueness

### 5.1 Stand Out Strategy
- **Most apps:** Blue logos (avoid blue)
- **Most apps:** Rounded corners (use sharp triangle)
- **Most apps:** Multiple colors (use 2-color max)
- **Most apps:** Complex symbols (use ultra-minimal)

### 5.2 Why This Works
- ✅ Unique geometric shape (triangle + dot combo)
- ✅ Bold color choice (neon red/green, not blue)
- ✅ Ultra-minimal (stands out in crowded app stores)
- ✅ State-based behavior (interactive, not static)
- ✅ Brutal aesthetic (confrontational, not friendly)

---

## 6. Design Testing Checklist

### 6.1 Size Testing
- [ ] Readable at 32px (smallest icon size)
- [ ] Readable at 64px (standard icon size)
- [ ] Readable at 1024px (App Store preview)
- [ ] Works on black background
- [ ] Works on white background (inverted version)

### 6.2 Color Testing
- [ ] 7:1 contrast ratio (WCAG AA)
- [ ] Visible in grayscale
- [ ] State colors distinguishable
- [ ] No color bleeding at small sizes

### 6.3 Placement Testing
- [ ] Stands out among competitor icons
- [ ] Works in App Store grid
- [ ] Works in notification badges
- [ ] Works as watermark
- [ ] Works in header (small size)

---

## 7. Deliverables

### 7.1 App Icon Assets
- **1024×1024px** PNG (App Store master)
- **512×512px** PNG (high-res fallback)
- **256×256px** PNG (standard)
- **128×128px** PNG (medium)
- **64×64px** PNG (small)
- **32×32px** PNG (minimum)

**Versions needed:**
- Idle (black dot)
- Assessing (yellow dot)
- Approved (green dot)
- Failed (red dot)
- Lockdown (red triangle + dot)

### 7.2 Logo Mark Assets
- **SVG master** (vector, scalable)
- **PNG exports** (1024, 512, 256, 128, 64, 32)
- Black-on-white version
- White-on-black version

### 7.3 Wordmark Assets
- Horizontal lockup (triangle + `YOU+`)
- Stacked lockup (triangle above `YOU+`)
- Monogram (`Y+` only)
- SVG + PNG exports

### 7.4 Motion Assets
- Lottie/JSON animations for:
  - Dot pulse (assessing state)
  - Dot expand (approved state)
  - Dot shrink (failed state)
  - RGB glitch (state transitions)

### 7.5 Usage Guide
- Minimum sizes
- Clear space rules (0.5× triangle height)
- Color specifications
- Animation timing
- State mapping

---

## 8. Implementation Roadmap

### Phase 1: Design
1. Sketch triangle + dot proportions
2. Test at 32px minimum size
3. Build vector master in Figma
4. Export all size variants
5. Create state color versions

### Phase 2: Testing
1. Place among competitor icons
2. Test on device (iOS + Android)
3. Verify contrast ratios
4. Test animations
5. Get user feedback

### Phase 3: Integration
1. Add to `Assets.xcassets`
2. Replace `HeaderLogoBar` text with logo
3. Hook state colors to app events
4. Implement animations (Lottie/SwiftUI)
5. Update App Store assets

---

## 9. Brand Voice Alignment

**Logo communicates:**
- ✅ Brutal honesty (red = confrontation)
- ✅ Binary truth (black/white, no gray)
- ✅ Future authority (triangle = stable, watching)
- ✅ Present accountability (dot = you, monitored)
- ✅ No escape (dot trapped in triangle)

**Copy pairings:**
- "FUTURE YOU IS WATCHING."
- "DOT = TRUTH STATUS."
- "NO ESCAPE FROM YOURSELF."

---

## 10. Do's & Don'ts

### ✅ DO
- Keep it ultra-minimal (triangle + dot only)
- Use state colors for meaning (red = fail, green = success)
- Test at smallest size (32px)
- Export PNG for app stores (no transparency)
- Maintain 7:1 contrast ratio
- Use linear animations (no bounce)

### ❌ DON'T
- Add decorative elements
- Use gradients (except optional neon glow)
- Put text in the icon
- Use blue (too common)
- Make it friendly or cute
- Rotate the triangle
- Move dot outside center

---

The logo is a **warning light**, not a mascot. It's always on, always judging. Triangle + dot + your conscience.
