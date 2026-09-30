# How Professionals Use AI for App Design
**Date**: September 30, 2026  
**Context**: Real workflows from design & development teams

---

## The Truth: AI Assistants Don't Browse Visual Catalogs

### What Codex/Claude/Cursor ACTUALLY Do:

1. **Describe what you want** → AI generates code
2. **Show AI a screenshot** → AI analyzes and recreates
3. **Reference existing apps** → AI mimics the style
4. **Iterative refinement** → Build, view, adjust, repeat

**They DON'T**: Browse Dribbble, show you visual catalogs, or pick designs for you

---

## Professional Design Workflows with AI

### Workflow 1: Reference-Based Design (Most Common)

**Step 1**: Designer describes desired aesthetic
```
"I want GetDone to look like Apple Calendar mixed with Things 3:
- Dark mode with frosted glass cards
- Blue accent color
- Clean typography
- Minimal spacing
- Current task emphasized like 'Now Playing' in Apple Music"
```

**Step 2**: AI generates SwiftUI code based on description

**Step 3**: Run on iPad, see actual result

**Step 4**: Iterate based on what you see
```
"Make the glass more transparent"
"Increase spacing between cards"
"Make the blue more vibrant"
```

**Advantage**: Fast iteration, real results immediately

---

### Workflow 2: Screenshot Analysis (Very Effective)

**Step 1**: Find designs you like (manually browse Dribbble, real apps, etc.)

**Step 2**: Take screenshots

**Step 3**: Show screenshots to AI (if supported) or describe them

**Example**:
```
User: "I have a screenshot of Things 3 'Today' view. 
       Recreate this layout in SwiftUI for GetDone."

AI: [Analyzes screenshot]
    [Generates SwiftUI code matching the layout]

User: [Runs on iPad, sees result]
      "Good, but make cards taller and add glass effect"
```

**Advantage**: Precise visual reference

---

### Workflow 3: Component Library Approach (Systematic)

**Step 1**: Define design system verbally
```
Typography:
- Large Title: 34pt bold
- Title: 28pt bold  
- Headline: 17pt semibold
- Body: 17pt regular
- Caption: 12pt regular

Colors:
- Background: Pure black #000000
- Primary accent: Blue #007AFF
- Success: Green #34C759
- Warning: Orange #FF9500

Spacing:
- Small: 8pt
- Medium: 16pt
- Large: 24pt
- XLarge: 32pt

Glass:
- Cards: .ultraThinMaterial.glassEffect(.regular)
- Prominent: .regularMaterial.glassEffect(.prominent)
```

**Step 2**: AI generates reusable components

**Step 3**: Build screens using components

**Advantage**: Consistent, scalable, professional

---

### Workflow 4: Rapid Prototyping (Vibe Coding)

**Step 1**: Describe rough idea
```
"Create an agenda view with:
- Black background
- Scrollable list of glass cards
- Each card shows task name, time, category icon
- Current task is larger with orange accent"
```

**Step 2**: AI generates initial version

**Step 3**: Run on iPad immediately (vibe coding workflow!)

**Step 4**: Rapid iteration
```
"Add progress bar at top"
"Make glass more subtle"
"Current task should have animated border"
```

**Advantage**: See designs in real context (on actual device)

---

## Recommended Workflow for GetDone

### The "Define-Generate-Iterate" Method

Since you have the vibe coding setup (push to GitHub → iPad updates automatically), we should use **Workflow 4** combined with **Workflow 3**.

### Phase 1: Define Your Design System (We decide together)

**Instead of browsing catalogs, let's have a design conversation:**

I'll ask you questions, you answer with your preferences:

#### Question 1: Overall Vibe
What feeling should GetDone have?
- **A**: Minimal & Sophisticated (like Things 3, Apple Calendar)
- **B**: Vibrant & Energetic (colorful, gradients, dynamic)
- **C**: Professional & Serious (corporate, muted colors)
- **D**: Playful & Friendly (rounded, soft, illustrations)

#### Question 2: Glass Depth
How prominent should the glass effect be?
- **A**: Subtle (barely noticeable, very transparent)
- **B**: Medium (noticeable but not overwhelming)
- **C**: Prominent (clearly frosted, Apple Vision Pro style)

#### Question 3: Color Strategy
What colors should dominate?
- **A**: Monochrome (black, white, gray + one accent)
- **B**: Dual-tone (two accent colors + neutrals)
- **C**: Vibrant (multiple bright colors)
- **D**: Natural (greens, blues, earth tones)

#### Question 4: Spacing Philosophy
How should content breathe?
- **A**: Tight (information dense, compact)
- **B**: Balanced (standard iOS spacing)
- **C**: Spacious (lots of whitespace, minimal)

#### Question 5: Typography Weight
How bold should text be?
- **A**: Light & Airy (thin weights, delicate)
- **B**: Balanced (standard weights)
- **C**: Bold & Strong (heavy weights, impactful)

#### Question 6: Current Task Emphasis
How should "now" stand out?
- **A**: Size (make it bigger)
- **B**: Color (bright accent)
- **C**: Animation (pulse, glow)
- **D**: All of the above

---

### Phase 2: Generate Initial Design

Based on your answers, I'll:
1. Create complete design system (colors, typography, spacing)
2. Generate SwiftUI components
3. Build example screens
4. You push to GitHub → See on iPad in seconds

---

### Phase 3: Rapid Iteration

You tell me what to adjust:
- "Glass too subtle, make it more frosted"
- "Blue is too bright, tone it down"
- "Cards need more spacing"
- "Current task needs to pop more"

I update code → You push → See instantly on iPad → Repeat

---

## Alternative: Show Me Your Current App

**Even Better Approach**:

Since GetDone already exists with ProfielView that has a nice glassmorphic design:

**Option A**: Use current design as baseline
```
You: "I like the current profile card design, use that style everywhere"
Me: Extract design tokens from ProfielView, apply globally
You: See updated app on iPad
```

**Option B**: Evolve current design
```
You: "Keep profile card style but make it [more vibrant/more minimal/etc]"
Me: Adjust parameters, regenerate components
You: Compare old vs new on iPad
```

---

## Let's Choose an Approach

### Recommendation: Quick Design Questionnaire + Generate

**Time**: 10 minutes of questions → 30 minutes of generation → Live on iPad

**Process**:
1. You answer 6 design questions above (takes 2 minutes)
2. I create complete design system
3. I generate all components in SwiftUI
4. You push to GitHub
5. iPad updates automatically
6. We iterate based on what you see

**VS browsing catalogs**:
- No broken links
- No guessing what you like
- See real results immediately
- Iterate in real context (your iPad)
- Actually buildable code

---

## What Real Designers Do

**Truth**: Professional designers rarely show developers visual catalogs.

**They do this instead**:

1. **Design in Figma** → Hand off to developers
2. **Reference existing apps**: "Make it like Apple Calendar"
3. **Describe with words**: "Minimal, glass, dark, blue accent"
4. **Iterate on real builds**: Design in code, not mockups

**With vibe coding, you're already doing #4** - the best method!

---

## My Recommendation

**Skip the catalog browsing. Let's build and iterate.**

### Next Steps:

**Option 1**: Answer the 6 design questions above
- I generate complete design system
- We build it together
- See results on iPad immediately

**Option 2**: Extract from current app
- I analyze your existing ProfielView
- Extract color, spacing, glass style
- Apply consistently everywhere

**Option 3**: Reference existing apps you like
- Tell me: "Make it like [App Name]"
- I recreate that aesthetic in SwiftUI
- We refine until perfect

**Which option sounds best to you?**

I recommend **Option 1** (design questions) because it's:
- Fast (10 minutes)
- Personalized to YOUR taste
- Produces immediate code
- Perfect for vibe coding workflow

---

**Let's skip the broken catalog and just build!** 🚀

What do you say? Want to answer the 6 design questions and get started?

