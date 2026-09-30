# GetDone Design Constraints & Requirements
**Date**: September 30, 2026  
**Status**: Pre-curation requirements

---

## Fixed Design Decisions

### 1. Glassmorphism: Apple's Native `.glassEffect`

**Requirement**: Use SwiftUI's native `.glassEffect` for all glassmorphism

**What is `.glassEffect`?**
- New in iOS 18 (WWDC 2024)
- Apple's official "liquid glass" material system
- Dynamic frosted glass with depth and vibrancy
- Adapts to content behind it
- More sophisticated than `.regularMaterial` / `.ultraThinMaterial`

**SwiftUI Usage**:
```swift
// Background glass effect
.background(.thinMaterial.glassEffect())

// Or on specific views
Rectangle()
    .foregroundStyle(.ultraThinMaterial)
    .glassEffect()
```

**Variants**:
```swift
.glassEffect(.regular)  // Standard glass
.glassEffect(.prominent) // More pronounced effect
.glassEffect(.thin)      // Subtle glass
```

**Benefits**:
✅ Native iOS feel (Apple's design language)  
✅ Performance optimized by system  
✅ Automatic light/dark mode adaptation  
✅ Respects accessibility settings (reduce transparency)  
✅ "Liquid" feel - more dynamic than old materials  

**Apply to**:
- Task cards
- Chat message bubbles
- Profile card
- Settings cards
- Modal sheets
- Toolbar backgrounds

---

## Design Constraints Summary

### Must Use:
1. ✅ **`.glassEffect`** for all glassmorphism (no custom blur effects)
2. ✅ **Dark mode first** (but support light mode)
3. ✅ **San Francisco** font (system font, Apple native)
4. ✅ **SF Symbols** for icons (Apple's icon system)

### Should Use:
- Native SwiftUI components where possible
- Apple's Human Interface Guidelines
- iOS standard gestures (swipe, long-press, etc.)
- Dynamic Type (respects user font size preferences)

### Avoid:
- ❌ Custom blur effects (use `.glassEffect` instead)
- ❌ Non-native components (unless absolutely necessary)
- ❌ Android Material Design patterns (this is iOS-first)
- ❌ Overly complex animations (iOS prefers subtle)

---

## Updated Curation Focus

Given the `.glassEffect` constraint, I'll curate designs that:

1. **Feature glass/frosted materials** heavily
   - Modern iOS 18 aesthetic
   - "Liquid glass" look
   - Layered depth

2. **Demonstrate proper use of materials**
   - Glass cards floating on dark backgrounds
   - Content showing through glass
   - Proper contrast and readability

3. **Show Apple's design language**
   - Native iOS patterns
   - SF Symbols integration
   - System fonts and spacing

4. **Exemplify dark mode excellence**
   - Black backgrounds with glass overlays
   - Proper color contrast
   - Vibrant accent colors on dark

---

## Example: GetDone Card with `.glassEffect`

```swift
struct TaskCard: View {
    var task: Task
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(task.category.color)
                .frame(width: 4)
            
            // Icon
            Image(systemName: task.icon)
                .font(.title3)
                .foregroundStyle(task.category.color)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                
                Text(task.time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Action
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .glassEffect(.regular)  // ← Apple's liquid glass
        }
    }
}
```

**Result**: Beautiful frosted glass card that:
- Shows content slightly through the glass
- Has dynamic blur based on what's behind
- Adapts to dark/light mode automatically
- Feels native and premium

---

## Color Strategy with Glass

Since we're using `.glassEffect`, color strategy becomes important:

### Background Colors:
```swift
// Deep backgrounds let glass shine
Color.black               // Pure black (OLED-friendly)
Color(.systemBackground)  // Adaptive system background
LinearGradient(...)       // Subtle gradients behind glass
```

### Glass Tints:
```swift
// Subtle tints on glass for hierarchy
.fill(.ultraThinMaterial)  // Most transparent
.fill(.thinMaterial)       // Subtle
.fill(.regularMaterial)    // Standard
.fill(.thickMaterial)      // Most opaque
```

### Accent Colors (Pop through glass):
```swift
// Vibrant colors work well with glass
.blue       // Primary actions
.green      // Success/completion
.orange     // Current/urgent
.red        // Warnings
.purple     // Categories
```

---

## What I'll Look For in Curation

### ✅ Good Examples:
- Apps using frosted glass materials extensively
- Dark backgrounds with layered glass cards
- Proper contrast (text readable on glass)
- Depth hierarchy (multiple glass layers)
- Vibrant accent colors
- Native iOS feel

### ❌ Avoid:
- Flat designs without depth
- Light-mode-only designs
- Heavy solid colors (no transparency)
- Non-iOS patterns
- Custom blur that doesn't look like Apple's

---

## Design System Preview (What We'll Build)

Based on `.glassEffect` constraint:

### Component Hierarchy:
```
Level 0: Background
├─ Pure black or dark gradient
│
Level 1: Primary Glass Cards
├─ .ultraThinMaterial.glassEffect(.regular)
├─ Task cards, chat bubbles, sections
│
Level 2: Nested Glass Elements
├─ .thinMaterial.glassEffect(.thin)
├─ Buttons inside cards, nested content
│
Level 3: Prominent Elements
├─ .regularMaterial.glassEffect(.prominent)
├─ Modals, sheets, focused elements
```

### Visual Weight:
- Background: Black (0% opacity)
- L1 Glass: ~10-20% opacity frosted
- L2 Glass: ~20-30% opacity frosted
- L3 Glass: ~30-40% opacity frosted
- Text: 100% white (with hierarchy via opacity)

---

## Ready for Curation

Now that we've established:
✅ Apple's native `.glassEffect` for all glass  
✅ Dark mode first  
✅ Native iOS components  
✅ SF Symbols & San Francisco font  

I'll curate designs that showcase these principles beautifully.

**Say "Start curation" and I'll compile the list!**

