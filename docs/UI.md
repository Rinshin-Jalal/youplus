# You+ UI Design System

## Design Philosophy

**You+ = Self-Confrontation Through Your Own Voice**

The You+ app employs a psychological accountability aesthetic designed to create urgency, self-awareness, and uncompromising honesty. The visual design serves the app's core purpose: making users face their failures through their own voice and take action.

### Core Principles:
- **Raw & Direct**: No soft corners, no gentle colors, no comfort
- **Future-Facing**: Black backgrounds, high contrast, sharp precision
- **Psychological Impact**: Colors trigger emotional responses (red = failure, green = keeping your word)
- **Urgency-Driven**: Timer prominence, your voice prominently displayed, countdown pressure

---

## Color System

### Primary Colors

**Base Background:**
- `#000000` - Pure Black (Authority phase, mystery, judgment)

**Text Colors:**
- `#FFFFFF` - Pure White (High contrast on black backgrounds)
- `#dddddd` - Light Gray (Secondary labels on black)
- `#bbbbbb` - Medium Gray (Section labels)
- `#CCCCCC` - Light Gray (Tertiary text)

### Viral Accent Colors

**Psychological Color Coding:**

1. **Blood Red Family:**
   - `#DC143C` - Blood Red (Broken promises, failures, urgency)
   - `#B22222` - Crimson Red (Assessment background, harsh judgment)
   - `#8B0000` - Dark Red (Borders, secondary accents)

2. **Success Green Family:**
   - `#C8E6C9` - Soft Green (Promises made, positive stats)
   - `#88a88a` - Green Border (Success state borders)

3. **Warning Yellow:**
   - `#FFD700` - Golden Yellow (Streak counter, achievement)
   - `#B8860B` - Dark Gold (Yellow borders)

4. **Authority Purple:**
   - `#8B00FF` - Deep Purple (Trust percentage, authority)
   - `#4B0082` - Dark Purple (Purple borders)

### Color Psychology Rules:
- **Red = Failure/Danger** (Broken promises, poor assessment)
- **Green = Success/Growth** (Promises made, positive streaks)
- **Yellow = Achievement** (Streaks, accomplishments)
- **Purple = Authority** (Trust level, judgment)

---

## Typography Hierarchy

### Font Stack
```
Primary: Inter-Bold
Secondary: Inter-Medium  
Emphasis: Inter-Black
```

### Typography Scale

**Hero Text (64px):**
```css
fontFamily: "Inter-Bold"
fontSize: 64
fontWeight: "900"
letterSpacing: 4
color: "#FFFFFF"
```
*Usage: Timer display, primary countdown*

**Large Values (48px):**
```css
fontFamily: "Inter-Bold"
fontSize: 48
fontWeight: "900"
letterSpacing: 2
```
*Usage: Stat values (promises, broken, streak, trust)*

**Assessment Text (35px):**
```css
fontFamily: "Inter-Black"
fontSize: 35
fontWeight: "900"
letterSpacing: 4
color: "#FFFFFF"
textAlign: "center"
```
*Usage: Current status assessment ("PATHETIC", "DECENT")*

**Greeting Text (25px):**
```css
fontFamily: "Inter-Medium"
fontSize: 25
fontWeight: "700"
letterSpacing: 1
color: "#FFFFFF"
```
*Usage: User greeting, motivational messages*

**Labels (12px):**
```css
fontFamily: "Inter-Medium"
fontSize: 12
fontWeight: "700"
letterSpacing: 1-2
```
*Usage: Stat labels, section headers*

### Typography Rules:
- **Inter-Bold**: Main content, values, timers
- **Inter-Medium**: Normal text, labels, descriptions
- **Inter-Black**: Emphasis, assessment text, critical messaging
- **Letter Spacing**: 1-4px for impact and readability
- **UPPERCASE**: All labels and stat text for authority

---

## Layout System

### Container Structure
```css
container: {
  flex: 1,
  backgroundColor: "#000000"
}

scrollView: {
  flex: 1
}

scrollContent: {
  paddingBottom: 20
}
```

### Spacing System
- **Horizontal Margins**: 16-20px from screen edges
- **Vertical Spacing**: 8-20px between elements
- **Card Padding**: 16px internal padding
- **Section Spacing**: 40px between major sections

### Component Dimensions

**Logo:**
- Width: 400px
- Height: 60px
- Resize: contain
- Alignment: center

**Hero Timer Card:**
- minHeight: 250px
- paddingVertical: 40px
- paddingHorizontal: 10px
- marginHorizontal: 20px
- marginVertical: 20px

**Assessment Card:**
- minHeight: 100px
- padding: 16px
- marginHorizontal: 16px
- marginBottom: 20px

**Stat Cards:**
- width: "48%" (2-column grid)
- minHeight: 130px
- padding: 16px
- marginBottom: 8px

---

## Component Patterns

### 1. Hero Timer Card
```css
heroCallCard: {
  backgroundColor: "#000000",
  borderRadius: 0,
  paddingVertical: 40,
  paddingHorizontal: 10,
  marginHorizontal: 20,
  marginVertical: 20,
  minHeight: 250,
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center"
}
```

**Purpose**: Primary focus element, countdown timer for next accountability call
**Visual Weight**: Largest element, centered, high contrast
**Animation**: Pulse effect for urgency

### 2. Assessment Card
```css
assessmentCard: {
  backgroundColor: "#B22222",
  borderWidth: 2,
  borderColor: "#dd2a2a",
  borderRadius: 10,
  padding: 16,
  marginHorizontal: 16,
  marginBottom: 20,
  minHeight: 100,
  flexDirection: "column",
  justifyContent: "center"
}
```

**Purpose**: Shows current performance assessment
**Psychology**: Red background creates anxiety/urgency
**Content**: Harsh assessment words ("PATHETIC", "DISAPPOINTING")

### 3. Stat Cards Grid
```css
statsGrid: {
  flexDirection: "row",
  flexWrap: "wrap",
  justifyContent: "space-between"
}

statCard: {
  borderRadius: 10,
  padding: 16,
  width: "48%",
  minHeight: 130,
  marginBottom: 8,
  flexDirection: "column",
  justifyContent: "space-between",
  alignItems: "flex-start",
  borderWidth: 3
}
```

**Layout**: 2x2 grid, 48% width each
**Color Coding**: Each stat has unique background color based on meaning
**Content**: Large number value + uppercase label

### 4. Section Labels
```css
Label: {
  fontFamily: "Inter-Medium",
  fontSize: 12,
  color: "#bbbbbb",
  marginBottom: 8,
  marginTop: 8,
  letterSpacing: 2,
  paddingHorizontal: 16
}
```

**Purpose**: Section dividers, organizational hierarchy
**Style**: Small, muted, spaced for clarity

---

## Animation System

### Timer Pulse Animation
```javascript
const pulseLoop = Animated.loop(
  Animated.sequence([
    Animated.timing(timerPulse, {
      toValue: 0.98,
      duration: isUnderOneHour ? 500 : 1000,
      useNativeDriver: true,
    }),
    Animated.timing(timerPulse, {
      toValue: 1,
      duration: isUnderOneHour ? 500 : 1000,
      useNativeDriver: true,
    }),
  ])
);
```

**Trigger**: Accelerates when under 1 hour remaining
**Purpose**: Creates urgency and draws attention to countdown

### Glitch Animation
```javascript
const glitchLoop = Animated.loop(
  Animated.sequence([
    Animated.timing(glitchAnimation, { 
      toValue: 1, 
      duration: 100, 
      useNativeDriver: true 
    }),
    Animated.timing(glitchAnimation, { 
      toValue: 0, 
      duration: 2000, 
      useNativeDriver: true 
    }),
  ])
);
```

**Purpose**: Subtle psychological effect on assessment text
**Frequency**: Brief 100ms glitch every 2 seconds

---

## Psychological Design Elements

### 1. Timer Prominence
- **Largest element** on screen (64px font)
- **Central positioning** - impossible to miss
- **Pulsing animation** - increases pressure as time decreases
- **High contrast** white on black for maximum visibility

### 2. Color Psychology Implementation
- **Red for Failures**: Broken promises card uses blood red (#DC143C)
- **Green for Success**: Promise count uses soft green (#C8E6C9)
- **Yellow for Achievement**: Streaks use golden yellow (#FFD700)
- **Purple for Authority**: Trust percentage uses deep purple (#8B00FF)

### 3. Harsh Assessment Language
- "PATHETIC" - for poor performance
- "DISAPPOINTING" - for below average
- "MEDIOCRE" - for average performance
- "IMPROVING" - for progress
- "DECENT" - for good performance

### 4. Authority Visual Cues
- **Pure black background** - conveys seriousness
- **High contrast text** - no ambiguity
- **Military-style spacing** - precise, disciplined
- **Uppercase labels** - commanding presence

---

## Responsive Behavior

### Platform Adaptations
```css
paddingTop: Platform.OS === "ios" ? 60 : 40
paddingBottom: Platform.OS === "ios" ? 30 : 15
```

### ScrollView Implementation
- **showsVerticalScrollIndicator: false** - Clean appearance
- **contentContainerStyle** - Proper bottom padding
- **Flex layout** - Adapts to content height

---

## Accessibility Considerations

### Color Contrast
- **Black (#000000) + White (#FFFFFF)** = Perfect contrast ratio
- **Colored backgrounds + appropriate text** = High readability
- **Large font sizes** (35px-64px) for critical information

### Touch Targets
- **Minimum 44px** touch areas for buttons
- **Card-based interaction** - Large touch zones
- **Clear visual feedback** on press

---

## Implementation Guidelines

### 1. Font Loading
Ensure Inter font family is properly loaded:
- Inter-Bold
- Inter-Medium  
- Inter-Black

### 2. Color Consistency
Use exact hex values - no variations or approximations

### 3. Animation Performance
- Use `useNativeDriver: true` for all animations
- Keep animation durations under 1000ms for responsiveness
- Clean up animation loops in useEffect cleanup

### 4. Spacing Consistency
- Follow 8px grid system for spacing
- Use consistent margins/padding across components
- Maintain visual rhythm through aligned elements

---

## Future Considerations

### Dark Mode
Current design is already dark-optimized. Light mode would require:
- Inverse color relationships
- Maintaining psychological color meanings
- Preserving contrast ratios

### Component Library Extension
This home page establishes patterns for:
- Card-based layouts
- Viral color coding system
- Typography hierarchy
- Animation principles

These patterns should be extended consistently across other app screens.