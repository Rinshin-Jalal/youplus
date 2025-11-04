# iOS 26 Liquid Glass & Concentric Design Guide

## Overview

iOS 26 introduces **Liquid Glass** - a new translucent material system announced at WWDC 2025. This guide covers the official SwiftUI APIs and proper implementation patterns.

---

## 1. Basic Glass Effect

### Simple Usage
```swift
Text("Hello")
    .padding()
    .glassEffect()
```

**Default behavior**: Applies glass effect within a **capsule shape** behind content

### Custom Shape
```swift
Text("Custom Glass")
    .padding()
    .glassEffect(in: .rect(cornerRadius: 16.0))
```

**Available shapes**:
- `.capsule` (default)
- `.rect(cornerRadius: X)`
- `.ellipse`
- `.circle`

---

## 2. Interactive Glass (iOS Controls)

For **buttons** and **interactive elements**, add `.interactive()`:

```swift
Button {
    print("Tapped")
} label: {
    Text("Touch Me")
        .padding()
}
.glassEffect(.regular.tint(.orange).interactive())
```

**Interactive behaviors**:
- ✨ **Scaling** on touch
- 🎯 **Bouncing** animation
- ✨ **Shimmering** effect

---

## 3. Glass Tinting

Apply accent colors to glass:

```swift
Text("Tinted Glass")
    .padding()
    .glassEffect(.regular.tint(.red))
```

**Tint styles**:
- `.regular.tint(Color)`
- `.prominent.tint(Color)` (stronger effect)

---

## 4. GlassEffectContainer

**Why?** Glass cannot sample other glass. Use container to group multiple glass elements.

```swift
GlassEffectContainer {
    VStack {
        Text("First Glass")
            .padding()
            .glassEffect()

        Text("Second Glass")
            .padding()
            .glassEffect()
    }
}
```

**Benefits**:
- Consistent visual results
- Shared sampling region
- Prevents glass-on-glass conflicts

---

## 5. Concentric Rectangles

### What is Concentric?

**Concentric corners** = Inner and outer shapes share the same center, creating visually consistent nested appearance.

### ConcentricRectangle API

```swift
VStack {
    Text("Concentric Content")
        .padding()
}
.background {
    ConcentricRectangle(cornerRadius: 20, inset: 16)
        .fill(.blue)
}
```

### How It Works

- **Calculates corner radius** based on container's shape
- **Subtracts padding** from parent radius
- **Matches device curvature** when using `.ignoresSafeArea()`

### Shape Protocol Method

```swift
.background(
    .rect(corners: .concentric(inset: 16))
        .fill(.blue)
)
```

---

## 6. Advanced: Glass Transitions

Use `.glassEffectID()` for morphing between glass elements:

```swift
@Namespace private var glassNamespace

GlassEffectContainer {
    if isExpanded {
        Text("Expanded")
            .glassEffect()
            .glassEffectID("content", in: glassNamespace)
    } else {
        Text("Collapsed")
            .glassEffect()
            .glassEffectID("content", in: glassNamespace)
    }
}
```

**Result**: Smooth morphing animation between states

---

## 7. Device Corner Matching

When extending to screen edges:

```swift
ZStack {
    Color.blue.ignoresSafeArea()

    Text("Content")
        .padding()
        .background(
            ConcentricRectangle(cornerRadius: 40, inset: 20)
                .fill(.white)
        )
}
```

**Behavior**: ConcentricRectangle automatically matches iPhone/iPad rounded corners

---

## 8. Best Practices

### ✅ DO
- Use `.glassEffect()` for single glass elements
- Use `GlassEffectContainer` when grouping multiple glass
- Add `.interactive()` to buttons/controls
- Use `ConcentricRectangle` for nested shapes
- Tint glass with accent colors for emphasis

### ❌ DON'T
- Don't apply glass to another glass element (use container)
- Don't create custom blur/gradient implementations
- Don't use fixed corner radius for nested elements (use concentric)
- Don't skip `.interactive()` on touchable glass

---

## 9. Platform Availability

```swift
@available(iOS 26.0, macOS 26.0, *)
struct MyView: View {
    var body: some View {
        Text("Glass")
            .glassEffect()
    }
}
```

**Available on**:
- iOS 26+
- iPadOS 26+
- macOS Tahoe 26+
- watchOS 26+
- tvOS 26+

**Release**: September 2025

---

## 10. Common Patterns

### Glass Card
```swift
VStack(alignment: .leading) {
    Text("Title")
        .font(.headline)
    Text("Description")
        .font(.caption)
}
.padding()
.glassEffect(in: .rect(cornerRadius: 16))
```

### Glass Button
```swift
Button("Action") {
    // action
}
.padding(.horizontal, 20)
.padding(.vertical, 12)
.glassEffect(.regular.tint(.blue).interactive())
```

### Concentric Container
```swift
ZStack {
    // Outer container
    RoundedRectangle(cornerRadius: 24)
        .fill(.blue)

    // Inner concentric content
    Text("Content")
        .padding()
        .background(
            ConcentricRectangle(cornerRadius: 24, inset: 16)
                .fill(.white)
        )
}
```

---

## References

- [WWDC 2025 Session 323](https://developer.apple.com/videos/play/wwdc2025/323/)
- [Apple Developer Documentation - Liquid Glass](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [ConcentricRectangle API](https://developer.apple.com/documentation/swiftui/concentricrectangle)
