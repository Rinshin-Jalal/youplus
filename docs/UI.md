# BigBruh UI Design System

## Design Philosophy

**BigBruh = Aggressive Accountability Through Psychological Reality Checks**

The BigBruh app employs a confrontational, uncompromising aesthetic designed to create urgency, eliminate excuses, and force users to face their commitments. The visual design serves the app's core purpose: aggressive accountability that can't be ignored.

### Core Principles:
- **Brutal & Direct**: No soft corners, no gentle colors, no comfort zones
- **Binary Thinking**: Black/white, success/failure, no middle ground
- **Psychological Impact**: Colors trigger confrontation (red = urgency, green = success)
- **Relentless Pressure**: Countdown timers, aggressive CTAs, no escape

---

## Color System

### Primary Colors

**Base Background:**
- `#000000` - Pure Black (Authority, power, seriousness)

**Text Colors:**
- `#FFFFFF` - Pure White (High contrast, maximum clarity)
- `#D1D5DB` - Gray-300 (Secondary labels on dark backgrounds)
- `#9CA3AF` - Gray-400 (Tertiary text)
- `#4B5563` - Gray-600 (Muted elements)

### Accent Colors

**Confrontation Red Family:**

1. **Primary Red (#EF4444 / red-500):**
   - Primary CTA buttons
   - Urgent warnings
   - Call-to-action elements
   - Failure states
   - Hover: #DC2626 (red-600)

2. **Crimson Red (#FF0033):**
   - Glitch effects
   - Extreme emphasis
   - Burn effects
   - Special visual effects

3. **Burn Orange (#FF4500):**
   - Secondary red family
   - Fire effects
   - Aggressive highlights

**Success Green Family:**

1. **Green (#4ADE80 / green-400):**
   - Success states
   - Positive metrics
   - Achievement indicators
   - Social proof

2. **Neon Green (#90FD0E):**
   - Glitch effects
   - Neon glow
   - Futuristic accents
   - Recording states

**Gray Scale:**
- `#111827` - Gray-900 (Hover states, near-black)
- `#1F2937` - Gray-800 (Dark borders)
- `#374151` - Gray-700 (Secondary text)
- `#4B5563` - Gray-600 (Tertiary text, icons)
- `#9CA3AF` - Gray-400 (Disabled states)
- `#D1D5DB` - Gray-300 (Light text on dark)
- `#F3F4F6` - Gray-100 (Light backgrounds)
- `#F9FAFB` - Gray-50 (Subtle backgrounds)

### Color Psychology Rules:
- **Red = Urgency/Confrontation** (CTAs, warnings, failures)
- **Green = Success/Achievement** (Wins, streaks, positive stats)
- **Black = Authority** (Power, seriousness, judgment)
- **White = Clarity** (Truth, stark reality, no hiding)

---

## Typography Hierarchy

### Font Stack

**Primary Font: Impact**
- All headings
- Hero text
- Emphasis statements
- Brand name

**Secondary Font: Inter**
- Body text (Bold - 700)
- UI labels (Bold - 700)
- Emphasis (Black - 900)
- Buttons (Black - 900)

### Typography Scale

**Hero Text (H1):**
```css
fontFamily: "Impact"
fontSize: 96px (mobile) / 128px (tablet) / 144px (desktop)
fontWeight: 900
letterSpacing: 0.15em
lineHeight: 0.85
textTransform: uppercase
color: #FFFFFF or #000000
```
*Usage: Landing page hero, main statements*

**Section Headers (H2):**
```css
fontFamily: "Impact"
fontSize: 48px (mobile) / 60px (desktop)
fontWeight: 900
letterSpacing: 0.15em
lineHeight: 1.0
textTransform: uppercase
```
*Usage: Section titles, major divisions*

**Subsection Headers (H3):**
```css
fontFamily: "Impact"
fontSize: 24px (mobile) / 32px (desktop)
fontWeight: 900
letterSpacing: 0.15em
lineHeight: 1.1
textTransform: uppercase
```
*Usage: Feature titles, card headers*

**Component Headers (H4):**
```css
fontFamily: "Impact"
fontSize: 20px
fontWeight: 900
letterSpacing: 0.1em
lineHeight: 1.2
textTransform: uppercase
```
*Usage: Small section headers*

**Large Body Text:**
```css
fontFamily: "Inter"
fontSize: 24px (mobile) / 30px (desktop)
fontWeight: 700
lineHeight: 1.4
```
*Usage: Hero descriptions, feature highlights*

**Medium Body Text:**
```css
fontFamily: "Inter"
fontSize: 20px
fontWeight: 700
lineHeight: 1.5
```
*Usage: Section descriptions*

**Regular Body Text:**
```css
fontFamily: "Inter"
fontSize: 16px (mobile) / 18px (desktop)
fontWeight: 700
lineHeight: 1.6
```
*Usage: Paragraphs, main content*

**Small Labels:**
```css
fontFamily: "Inter"
fontSize: 14px
fontWeight: 700
letterSpacing: 0.1em
lineHeight: 1.4
textTransform: uppercase
```
*Usage: Labels, captions, stat headers*

**Tiny Text:**
```css
fontFamily: "Inter"
fontSize: 12px
fontWeight: 700
lineHeight: 1.4
```
*Usage: Fine print, tertiary information*

### Typography Rules:
- **Impact**: All headings, always uppercase, 0.15em letter spacing
- **Inter Bold (700)**: Body text, UI elements
- **Inter Black (900)**: Buttons, strong emphasis, CTAs
- **Never use**: Regular, medium, or light weights
- **Letter Spacing**: Wide tracking (0.1-0.15em) for uppercase, normal for body
- **Line Height**: Tight (0.85-1.2) for headings, comfortable (1.4-1.6) for body

---

## Layout System

### Container Structure

**Main Container:**
```css
container: {
  flex: 1,
  backgroundColor: #000000,
  paddingTop: 60px (iOS) / 40px (Android)
}
```

**Content Container:**
```css
scrollView: {
  flex: 1,
  showsVerticalScrollIndicator: false
}

scrollContent: {
  paddingBottom: 30px (iOS) / 15px (Android)
}
```

**Centered Container:**
```css
maxWidth: 1280px (max-w-7xl)
marginHorizontal: auto
paddingHorizontal: 20px (mobile) / 24px (tablet)
```

### Spacing System

**Vertical Spacing:**
- Section padding: 64px (mobile) / 96px (desktop)
- Between components: 32-48px
- Between related elements: 16-24px
- Internal card padding: 32px

**Horizontal Spacing:**
- Screen margins: 16-20px
- Card padding: 32px
- Button padding: 32px horizontal, 16px vertical
- Grid gap: 48px

### Component Dimensions

**Hero Section:**
- paddingVertical: 128px (mobile) / 160px (desktop)
- paddingHorizontal: 20px

**Timer Card:**
- minHeight: 250px
- paddingVertical: 40px
- paddingHorizontal: 10px
- marginHorizontal: 20px
- marginVertical: 20px

**Feature Cards:**
- padding: 32px
- minHeight: auto
- border: 4px solid black
- gap: 48px (grid)

**Stat Cards:**
- width: 48% (2-column grid)
- padding: 16px
- minHeight: 130px
- marginBottom: 8px

---

## Component Patterns

### 1. Buttons

**Primary Button (CTA):**
```css
button: {
  backgroundColor: #EF4444,
  color: #FFFFFF,
  paddingHorizontal: 32px,
  paddingVertical: 16px,
  borderWidth: 2,
  borderColor: #EF4444,
  borderRadius: 0,
  fontFamily: "Inter",
  fontWeight: "900",
  fontSize: 18px,
  textTransform: "uppercase",
  letterSpacing: 0.1em
}

hover: {
  backgroundColor: #DC2626
}
```
**Usage**: Primary CTAs, "GET CALLED OUT" buttons, main actions

**Secondary Button:**
```css
button: {
  backgroundColor: #000000,
  color: #FFFFFF,
  paddingHorizontal: 32px,
  paddingVertical: 16px,
  borderWidth: 2,
  borderColor: #000000,
  borderRadius: 0,
  fontFamily: "Inter",
  fontWeight: "900",
  fontSize: 18px,
  textTransform: "uppercase",
  letterSpacing: 0.1em
}

hover: {
  backgroundColor: #111827
}
```
**Usage**: Secondary actions, navigation

**Tertiary Button:**
```css
button: {
  backgroundColor: #FFFFFF,
  color: #000000,
  paddingHorizontal: 32px,
  paddingVertical: 16px,
  borderWidth: 2,
  borderColor: #000000,
  borderRadius: 0,
  fontFamily: "Inter",
  fontWeight: "900",
  fontSize: 18px,
  textTransform: "uppercase",
  letterSpacing: 0.1em
}

hover: {
  backgroundColor: #F3F4F6
}
```
**Usage**: Light backgrounds, less emphasis

### 2. Cards

**Feature Card:**
```css
card: {
  backgroundColor: #FFFFFF,
  borderWidth: 4,
  borderColor: #000000,
  borderRadius: 0,
  padding: 32px
}

hover: {
  backgroundColor: #F9FAFB
}
```

**Structure:**
- Icon (40px, #EF4444)
- Title (Impact, 32px, uppercase, black)
- Subtitle (Inter Black, 18px, gray-700)
- Description (Inter Bold, 16px, gray-800)
- Detail list (red square bullets, Inter Bold, 14px)

**Callout Box:**
```css
callout: {
  backgroundColor: #000000,
  color: #FFFFFF,
  padding: 32px,
  maxWidth: 896px,
  marginHorizontal: auto
}
```

**Timer Card:**
```css
timerCard: {
  backgroundColor: #000000,
  borderRadius: 0,
  paddingVertical: 40px,
  paddingHorizontal: 10px,
  marginHorizontal: 20px,
  marginVertical: 20px,
  minHeight: 250px,
  alignItems: center,
  justifyContent: center
}
```

### 3. Input Fields

**Text Input:**
```css
input: {
  backgroundColor: #FFFFFF,
  color: #000000,
  borderWidth: 2,
  borderColor: #000000,
  borderRadius: 0,
  paddingHorizontal: 16px,
  paddingVertical: 12px,
  fontFamily: "Inter",
  fontWeight: "700",
  fontSize: 16px
}

focus: {
  borderColor: #EF4444,
  outline: 2px solid #EF4444
}
```

### 4. Highlights

**Text Highlight:**
```css
highlight: {
  backgroundColor: #000000,
  color: #FFFFFF,
  paddingHorizontal: 12px,
  paddingVertical: 8px,
  fontFamily: "Inter",
  fontWeight: "900",
  textTransform: "uppercase",
  letterSpacing: 0.1em,
  display: "inline-block"
}
```

**Red Highlight:**
```css
highlightRed: {
  backgroundColor: #EF4444,
  color: #FFFFFF,
  paddingHorizontal: 12px,
  paddingVertical: 8px,
  fontFamily: "Inter",
  fontWeight: "900",
  textTransform: "uppercase",
  letterSpacing: 0.1em
}
```

### 5. Metrics Display

**Large Metric:**
```css
metricNumber: {
  fontFamily: "Impact",
  fontSize: 128px (mobile) / 144px (desktop),
  fontWeight: "900",
  color: #000000,
  lineHeight: 1,
  letterSpacing: 0
}

metricLabel: {
  fontFamily: "Inter",
  fontSize: 14px,
  fontWeight: "900",
  color: #4B5563,
  textTransform: "uppercase",
  letterSpacing: 0.15em,
  marginTop: 8px
}
```

### 6. Section Labels

**Label:**
```css
label: {
  fontFamily: "Inter",
  fontSize: 12px,
  fontWeight: "900",
  color: #9CA3AF,
  textTransform: "uppercase",
  letterSpacing: 0.15em,
  marginBottom: 8px
}
```

---

## Animation System

### Core Principles
- **Speed**: 200-500ms (fast, aggressive)
- **Easing**: Linear or ease-out (no bounce)
- **Purpose**: Emphasis, urgency, confrontation

### Timer Pulse Animation

```javascript
const pulseAnimation = Animated.loop(
  Animated.sequence([
    Animated.timing(pulseValue, {
      toValue: 0.98,
      duration: 500,
      useNativeDriver: true,
    }),
    Animated.timing(pulseValue, {
      toValue: 1,
      duration: 500,
      useNativeDriver: true,
    }),
  ])
);
```

**Trigger**: Active on countdown timer
**Purpose**: Creates urgency and draws attention
**Speed**: Accelerates when under 1 hour

### Fade In Animation

```javascript
initial={{ opacity: 0, y: 20 }}
animate={{ opacity: 1, y: 0 }}
transition={{ duration: 0.5 }}
```

**Usage**: Section entrances, card reveals

### Stagger Children

```javascript
containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.2 }
  }
}

itemVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: {
    y: 0,
    opacity: 1,
    transition: { duration: 0.6 }
  }
}
```

**Usage**: Feature grids, FAQ items, list reveals

### Glitch Effect

```javascript
const glitchAnimation = Animated.loop(
  Animated.sequence([
    Animated.timing(glitchValue, {
      toValue: 1,
      duration: 100,
      useNativeDriver: true
    }),
    Animated.timing(glitchValue, {
      toValue: 0,
      duration: 2000,
      useNativeDriver: true
    }),
  ])
);
```

**Usage**: Aggressive emphasis, special effects
**Frequency**: Brief 100ms glitch every 2 seconds

### Hover Transitions

**Buttons:**
```css
transition: all 200ms ease-out
hover: background-color change + slight scale (optional)
```

**Cards:**
```css
transition: background-color 200ms ease-out
hover: background-color lightens
```

**Links:**
```css
transition: color 200ms ease-out
hover: color changes to #EF4444
```

---

## Special Effects

### 1. Glitch Text Effect

```css
.glitch-text {
  position: relative;
  color: #000;
  animation: glitch-1 0.5s infinite;
}

.glitch-text::before {
  content: attr(data-text);
  position: absolute;
  color: #ff0033;
  animation: glitch-1 0.5s infinite;
  clip: rect(0, 900px, 0, 0);
}

.glitch-text::after {
  content: attr(data-text);
  position: absolute;
  color: #90fd0e;
  animation: glitch-2 0.5s infinite;
  clip: rect(0, 900px, 0, 0);
}

@keyframes glitch-1 {
  0%, 100% { transform: translate(0); }
  33% { transform: translate(-2px, 2px); }
  66% { transform: translate(2px, -2px); }
}

@keyframes glitch-2 {
  0%, 100% { transform: translate(0); }
  33% { transform: translate(2px, -2px); }
  66% { transform: translate(-2px, 2px); }
}
```

**Usage**: Hero text, extreme emphasis (use sparingly)

### 2. Neon Glow

```css
.neon-glow {
  color: #90fd0e;
  text-shadow:
    0 0 5px #90fd0e,
    0 0 10px #90fd0e,
    0 0 15px #90fd0e,
    0 0 20px #90fd0e;
}
```

**Usage**: Futuristic accents, special callouts

### 3. Burn Effect

```css
.burn-effect {
  background: linear-gradient(45deg, #ff0033, #ff4500);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
```

**Usage**: Extreme emphasis, danger zones, failure states

---

## Psychological Design Elements

### 1. Urgency Indicators
- **Large countdown timers** (64px+ font)
- **Pulsing animations** on time-sensitive elements
- **Red color coding** for urgent actions
- **ALL CAPS text** for commands

### 2. Binary Visual Language
- **Black/white** backgrounds (no grays as primary)
- **Success/failure** color coding (green/red)
- **Sharp edges** (no rounded corners)
- **Hard contrasts** (no soft gradients)

### 3. Confrontational Messaging
- **Imperative language** ("GET CALLED OUT")
- **Direct statements** ("You failed. Again.")
- **No escape routes** (single dominant action per screen)
- **Aggressive CTAs** (red buttons, bold borders)

### 4. Authority Visual Cues
- **Pure black backgrounds** - convey seriousness
- **High contrast text** - no ambiguity
- **Wide letter spacing** - command presence
- **Uppercase labels** - authoritative tone
- **Bold borders** (2-4px) - strong boundaries

---

## Responsive Behavior

### Breakpoints

```css
mobile: < 640px
tablet: 640px - 1024px
desktop: > 1024px
```

### Typography Scaling

**Mobile → Desktop:**
- H1: 96px → 144px
- H2: 48px → 60px
- H3: 24px → 32px
- Body: 16px → 18px
- Large Body: 24px → 30px

### Layout Adaptations

**Grid:**
- Mobile: 1 column
- Tablet: 2 columns
- Desktop: 2 columns

**Spacing:**
- Mobile: 64px section padding
- Desktop: 96px section padding

**Platform:**
```javascript
paddingTop: Platform.OS === "ios" ? 60 : 40
paddingBottom: Platform.OS === "ios" ? 30 : 15
```

---

## Accessibility

### Color Contrast
- **Black (#000000) + White (#FFFFFF)** = 21:1 (WCAG AAA)
- **Red (#EF4444) + White (#FFFFFF)** = 4.54:1 (WCAG AA)
- **Gray-700 (#374151) + White (#FFFFFF)** = 9.8:1 (WCAG AAA)

### Touch Targets
- **Minimum 44px** for all interactive elements
- **Card-based interactions** for large touch zones
- **Clear visual feedback** on press/hover

### Font Sizes
- **Minimum 16px** for body text
- **Large sizes** (35px-64px) for critical information
- **High contrast** for readability

---

## Implementation Guidelines

### 1. Font Loading

Ensure fonts are properly loaded:
- **Impact** - System font (fallback: Arial Black)
- **Inter-Bold** (700)
- **Inter-Black** (900)

### 2. Color Consistency

Use exact hex values:
- Black: `#000000`
- White: `#FFFFFF`
- Red: `#EF4444` (red-500)
- Red Hover: `#DC2626` (red-600)
- Green: `#4ADE80` (green-400)
- Neon Green: `#90FD0E`
- Crimson: `#FF0033`

### 3. Animation Performance

- Use `useNativeDriver: true` for all animations
- Keep durations under 500ms for responsiveness
- Clean up animation loops in useEffect cleanup
- Avoid complex animations on large elements

### 4. Spacing Consistency

- Follow 8px grid system
- Use consistent margins/padding
- Maintain visual rhythm
- Align elements precisely

### 5. Border Styling

- Use 2-4px borders (bold, not thin)
- No rounded corners (borderRadius: 0)
- Solid colors only (no gradients)
- High contrast border colors

---

## Component Library Patterns

### Hero Section Pattern

```jsx
<View style={styles.heroSection}>
  <Text style={styles.heroTitle}>BIGBRUH SEES ALL.</Text>
  <Text style={styles.heroSubtitle}>
    Your AI Big Brother for The Great Lock-In.
  </Text>
  <TouchableOpacity style={styles.ctaButton}>
    <Text style={styles.ctaText}>GET CALLED OUT</Text>
  </TouchableOpacity>
</View>
```

### Feature Grid Pattern

```jsx
<View style={styles.featureGrid}>
  <View style={styles.featureCard}>
    <Icon name="phone" size={40} color="#EF4444" />
    <Text style={styles.featureTitle}>DAILY REALITY CHECK</Text>
    <Text style={styles.featureSubtitle}>One Call. No Escape.</Text>
    <Text style={styles.featureDescription}>
      BigBruh calls YOU. Binary response: Did it or Failed.
    </Text>
  </View>
</View>
```

### Timer Card Pattern

```jsx
<Animated.View style={[styles.timerCard, { transform: [{ scale: pulseValue }] }]}>
  <Text style={styles.timerLabel}>NEXT CALL IN</Text>
  <Text style={styles.timerValue}>3:45:12</Text>
  <Text style={styles.timerSubtext}>NO ESCAPE</Text>
</Animated.View>
```

### Stat Card Pattern

```jsx
<View style={styles.statsGrid}>
  <View style={[styles.statCard, { backgroundColor: '#C8E6C9', borderColor: '#88a88a' }]}>
    <Text style={styles.statValue}>24</Text>
    <Text style={styles.statLabel}>WINS STACKED</Text>
  </View>
  <View style={[styles.statCard, { backgroundColor: '#DC143C', borderColor: '#8B0000' }]}>
    <Text style={styles.statValue}>6</Text>
    <Text style={styles.statLabel}>EXCUSES MADE</Text>
  </View>
</View>
```

---

## Design Checklist

When creating components, ensure:

**Visual:**
- [ ] Uses brand colors (black, white, red-500, green-400)
- [ ] Typography is Impact (headings) or Inter Bold/Black (body)
- [ ] All headings are uppercase with 0.15em letter spacing
- [ ] Font weight is bold (700) or black (900)
- [ ] High contrast maintained (WCAG AA minimum)
- [ ] Borders are 2-4px thick (no thin borders)
- [ ] No rounded corners (borderRadius: 0)
- [ ] Red used for urgency/CTAs

**Content:**
- [ ] Voice is aggressive and confrontational
- [ ] Language is binary (success/failure, did/failed)
- [ ] No gentle or soft words
- [ ] Headlines are punchy (2-8 words)
- [ ] CTAs are imperative commands
- [ ] Copy is direct and specific

**Interaction:**
- [ ] Hover states defined
- [ ] Transitions are fast (200-500ms)
- [ ] Animations emphasize urgency
- [ ] Focus states are accessible
- [ ] Touch targets are 44px+
- [ ] Mobile responsive

**Brand:**
- [ ] Feels aggressive and uncompromising
- [ ] Reinforces accountability theme
- [ ] No warm, fuzzy elements
- [ ] Maintains brutalist aesthetic
- [ ] Consistent with BigBruh voice

---

## Future Considerations

### Dark Mode
Current design is dark-optimized. Light mode requires:
- Inverse color relationships
- Maintaining brand aggression
- Preserving contrast ratios
- Keeping psychological impact

### Component Extensions
Established patterns for:
- Card-based layouts
- Binary color coding
- Typography hierarchy
- Animation principles
- Aggressive CTAs

These patterns extend to:
- Onboarding screens
- Call interface
- History screens
- Settings pages

---

**Version 1.0 | BigBruh UI Design System**
**Brand:** BigBruh | Your AI Big Brother for The Great Lock-In

**STACK WINS. NOT EXCUSES.**
