# Liquid Glass Design Laws (WWDC 2025)

## MANDATORY COMPLIANCE - NO EXCEPTIONS

---

## I. DEFINITION OF LIQUID GLASS

**Article 1.1 - Material Definition**
Liquid Glass is a major new design material and unified design language for all Apple platforms (iOS, iPadOS, macOS) announced at WWDC 2025.

**Article 1.2 - Core Property**
Liquid Glass is a material that bends and shapes light and moves like liquid, mimicking the appearance of looking through real-life glass.

**Article 1.3 - System Integration**
Liquid Glass SHALL be implemented across system components including:
- Tab bars
- Buttons
- Menus
- Controls
- Toolbars

**Article 1.4 - Dynamic Behavior Requirements**
Liquid Glass MUST:
- Respond to gestures and touch with fluidity
- Morph and adapt when screen content changes (e.g., toolbar items)
- Switch between light mode and dark mode for content (text/symbols) based on background underneath
- Display subtle reflections of nearby UI elements
- Ensure maximum legibility at all times

---

## II. COLOR USAGE LAWS

**Article 2.1 - Sparingness Mandate**
Color MUST be used VERY SPARINGLY in Liquid Glass design language.

**Article 2.2 - PROHIBITED: Drowning Out Glass**
❌ **YOU SHALL NOT** use custom colors on Liquid Glass elements because:
- The system's dynamic legibility feature will be LOST
- Symbols and glyphs that change color based on content underneath will become STATIC
- If you set a color, it's STUCK and may become ILLEGIBLE

**Article 2.3 - PERMITTED: Focus Direction**
✅ **YOU SHALL** use color primarily to direct user attention to the primary action on a screen
- Example: Blue "view bag" button for primary CTA

**Article 2.4 - PERMITTED: Background Placement**
✅ **YOU SHALL** place significant color in the background content layer
❌ **YOU SHALL NOT** place color on liquid glass buttons or toolbar items

---

## III. IMPLEMENTATION LAWS

### Law 1: Use Built-in Components

**Article 3.1.1 - Component Mandate**
✅ **YOU MUST** use built-in Swift UI or UIKit components:
- Tab bar
- Toolbar
- Menu
- Slider

**Article 3.1.2 - Automatic Benefits**
By using built-in components, your app automatically receives:
- Cool morphing animations
- Animation updates
- Accessibility updates
- Future design updates FOR FREE

**Article 3.1.3 - Custom Component Prohibition**
❌ **YOU SHALL NOT** create custom components for Liquid Glass elements
- You will have to completely redo them whenever Apple changes the design
- You will lose all automatic updates

---

### Law 2: Glass Layering

**Article 3.2.1 - Floating Layer Concept**
✅ **YOU MUST** think of Liquid Glass elements as a control layer floating ABOVE your content
- Tab bars and toolbars float above content
- Content should shine through the glass from underneath

**Article 3.2.2 - Anti-Clutter Mandate**
❌ **YOU SHALL NOT** overdo the glass
- NO "glass on glass on glass"
- NO putting glass everywhere
- This destroys visual hierarchy and clutters the UI

**Article 3.2.3 - Content Primacy**
✅ **YOU MUST** let your content be the primary visual focus
- Glass is a supporting layer, not the main attraction

---

### Law 3: Toolbar Spacing and Grouping

**Article 3.3.1 - Spacing API Requirement**
✅ **YOU MUST** use the toolbar spacer API
✅ **YOU MUST** intelligently space out and group related toolbar buttons

**Article 3.3.2 - Icon Preference**
✅ **YOU SHOULD** use more icons than text in the new design language

**Article 3.3.3 - Grouping Prohibition**
❌ **YOU SHALL NOT** group a text label and an icon together
- Users may confuse it as a single button instead of two separate items
- This creates UX confusion

---

### Law 4: Concentricity (CRITICAL)

**Article 3.4.1 - Concentricity Definition**
Concentricity = Software's rounded corners and edges perfectly line up with the curve of the device hardware

**Article 3.4.2 - Alignment Mandate**
✅ **YOU MUST** ensure your content (cards, buttons, etc.) is concentric with the rest of the UI
- Content must feel cohesive and like it "belongs"
- All corner radii must align with the device and UI

**Article 3.4.3 - Capsule Shape Recommendation**
✅ **YOU SHOULD** use capsule shape for buttons
- Capsule shape naturally lends itself to concentricity
- It aligns perfectly with Apple's design language

**Article 3.4.4 - Misalignment Prohibition**
❌ **YOU SHALL NOT** have content where corner radii do not line up with the rest of the UI
- It will look "off"
- It will feel disconnected from the platform
- Users will subconsciously notice the misalignment

---

## IV. ENFORCEMENT

**Article 4.1 - Compliance Requirement**
ALL implementations of Liquid Glass MUST comply with these laws.

**Article 4.2 - Review Checklist**
Before shipping, verify:
- [ ] Using built-in components (Law 1)
- [ ] Glass is layered, not cluttered (Law 2)
- [ ] Toolbars are properly spaced (Law 3)
- [ ] All corners are concentric (Law 4)
- [ ] Color is used sparingly (Law 2.1)
- [ ] No custom colors on glass elements (Law 2.2)
- [ ] Primary actions use color for focus (Law 2.3)
- [ ] Significant color is in background layer (Law 2.4)

**Article 4.3 - Consequences of Non-Compliance**
Violation of these laws results in:
- Poor user experience
- App rejection from App Store review
- Loss of platform cohesion
- Accessibility failures
- Visual hierarchy destruction

---

## V. SUMMARY - THE GOLDEN RULES

1. **USE BUILT-IN COMPONENTS** - Don't reinvent the wheel
2. **LAYER THOUGHTFULLY** - Glass floats above content, don't overdo it
3. **SPACE INTELLIGENTLY** - Use toolbar spacer API, group wisely
4. **ALIGN CONCENTRICALLY** - All corners must line up with device and UI
5. **MINIMIZE COLOR ON GLASS** - Sparingly! Background only!

---

*Source: WWDC 2025 - Liquid Glass Design Language Session*
*Effective: iOS 26.0+ | iPadOS 26.0+ | macOS Tahoe 26.0+*

**THESE ARE LAWS, NOT SUGGESTIONS.**
