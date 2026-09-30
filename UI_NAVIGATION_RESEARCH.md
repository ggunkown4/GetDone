# UI & Navigation Research - Real App Analysis
**Date**: September 30, 2026  
**Purpose**: Study proven navigation patterns from successful apps to inform GetDone's redesign

---

## Research Methodology

We'll analyze navigation patterns from best-in-class apps across categories:
1. **Productivity Apps**: Things 3, Todoist, Any.do, Microsoft To Do
2. **Calendar/Planning Apps**: Fantastical, Calendly, Google Calendar, Apple Calendar
3. **Focus/Time Apps**: Forest, Pomodoro apps, Structured
4. **AI-First Apps**: Notion, ChatGPT, Perplexity
5. **iPad-Optimized Apps**: GoodNotes, Notability, Apple Notes

For each app, we'll document:
- Navigation structure (tabs, sidebar, etc.)
- Main screen (what you see first)
- Information hierarchy
- Gesture patterns
- iPad vs iPhone differences

---

## 1. Things 3 (Gold Standard for Task Management)

### Platform: iOS/iPadOS/macOS
### Category: Task Management

#### **Navigation Structure**

**iPhone**:
```
Bottom Tabs (5):
├── Inbox (landing page)
├── Today
├── Upcoming
├── Anytime
└── Logbook
```

**iPad**:
```
Sidebar Navigation:
├── Inbox
├── Today
├── Upcoming
├── Anytime
├── Someday
├── Logbook
├── [Projects Section]
│   ├── Work
│   ├── Personal
│   └── [custom projects]
└── [Areas Section]
    ├── Health
    └── [custom areas]
```

#### **Key Design Decisions**

1. **Default View**: "Today" is the most logical default (what needs attention now)
2. **Hierarchy**: Temporal (Inbox → Today → Upcoming → Someday → Logbook)
3. **Sidebar Width**: ~280pt on iPad - perfect for scanning
4. **Color System**: Minimal - only accent colors for tags, no overwhelming colors
5. **Gestures**:
   - Swipe right: Complete task ✓
   - Swipe left: Delete/Move
   - Pull down: Quick Entry (from anywhere)
   - Long press: Context menu

#### **What Works**

✅ **Clear mental model**: Time-based organization everyone understands  
✅ **Quick capture**: Pull down gesture works from any screen  
✅ **Visual calm**: White/light gray, not overwhelming  
✅ **Keyboard shortcuts**: Power users can fly through tasks  
✅ **Persistent sidebar**: On iPad, always visible for quick navigation  

#### **What We Can Learn**

- Default to "most urgent" view (Today for them, Agenda for us)
- Use temporal hierarchy (Now → Today → Tomorrow → Later)
- Quick capture needs to be gesture-accessible from anywhere
- Sidebar should show structure but not overwhelm

---

## 2. Fantastical (Best Calendar UI)

### Platform: iOS/iPadOS/macOS
### Category: Calendar + Tasks

#### **Navigation Structure**

**iPhone**:
```
Bottom Tabs (3):
├── Day/Week/Month (toggle within)
├── Tasks
└── More (settings, etc.)
```

**iPad**:
```
Sidebar:
├── [Mini Month Calendar]
├── Day
├── Week  
├── Month
├── Year
├── Tasks
└── Settings

Detail View:
- Timeline (default)
- Shows multiple calendars merged
- Time blocks clearly visible
```

#### **Key Design Decisions**

1. **Timeline is King**: Full-screen vertical timeline with time blocks
2. **Density Control**: Zoom in/out to show more/less detail
3. **Natural Language Entry**: "Lunch with John tomorrow at 2pm" → parsed automatically
4. **Color Coding**: Each calendar source gets a color, shown as left border on events
5. **Now Indicator**: Red line shows current time (critical for glanceability)

#### **What Works**

✅ **Time-blocked view**: Visual representation of "when things happen"  
✅ **Current time indicator**: Instantly know where you are in the day  
✅ **Smart parsing**: NLP makes entry fast  
✅ **Zoom levels**: Compact for overview, expanded for details  
✅ **Mini calendar**: Small month view in sidebar for date jumping  

#### **What We Can Learn**

- Timeline view with current time indicator is essential
- Color-coded left border (not full background) keeps it clean
- Natural language parsing drastically speeds up entry
- Mini calendar widget in sidebar helps orientation

---

## 3. Structured (AI Day Planner - Direct Competitor)

### Platform: iOS
### Category: AI-Powered Daily Planning

#### **Navigation Structure**

**iPhone Only** (no iPad version):
```
Single Screen:
- Today's timeline (default)
- Bottom toolbar:
  ├── Add Task
  ├── Settings
  └── More
```

#### **Key Design Decisions**

1. **Single-Screen Focus**: No tabs, no distractions - just today
2. **Visual Timeline**: Tasks shown in time blocks throughout day
3. **AI Suggestions**: "Best time to work on this?" prompt
4. **Drag-and-Drop**: Manually override AI by dragging tasks
5. **Color Bubbles**: Categories shown as colored circles

#### **What Works**

✅ **Radical simplicity**: One screen eliminates navigation decisions  
✅ **Timeline visualization**: Easy to see "what's happening when"  
✅ **Manual override**: AI suggests, but user has final say  
✅ **Current time tracking**: Shows where you are in schedule  

#### **What Doesn't Work**

❌ **No iPad version**: Missing huge opportunity  
❌ **Limited views**: Can't easily see tomorrow or next week  
❌ **No task library**: Hard to manage unscheduled tasks  

#### **What We Can Learn**

- Default to single-screen timeline for focus
- Allow manual drag-and-drop to override AI
- Show visual time blocks, not just list of tasks
- But... need more navigation for power users

---

## 4. Apple Calendar (System Standard)

### Platform: iOS/iPadOS (Native)
### Category: Calendar

#### **Navigation Structure**

**iPhone**:
```
Bottom Tabs (3):
├── Today (timeline)
├── Search
└── Calendars (toggle sources)

Top Toolbar:
- Month/Week/Day toggle
- [Today] button (quick return)
```

**iPad**:
```
Sidebar:
├── [Mini Month Calendar]
├── Today
├── Tomorrow  
├── Week
├── Month
├── Year
└── Calendars (sources)

Split View:
- Left: Selected view (day/week/month)
- Right: Event detail (when selected)
```

#### **Key Design Decisions**

1. **System Font**: San Francisco everywhere
2. **Red Accent**: "Today" indicator in red
3. **List + Timeline**: Can toggle between views
4. **Minimal Chrome**: No unnecessary UI elements
5. **Natural Date Navigation**: Swipe left/right to change days

#### **What Works**

✅ **System integration**: Works with all other iOS apps  
✅ **Speed**: Optimized to be instant  
✅ **Gestures**: Swipe navigation feels natural  
✅ **"Today" button**: Always one tap to get back to now  

#### **What We Can Learn**

- "Today" quick-return button is essential
- Swipe left/right for day navigation is intuitive
- System font choice (San Francisco) feels fast and native
- Red accent for "now" is universally understood

---

## 5. Notion (AI-Enhanced Workspace)

### Platform: iOS/iPadOS/Web
### Category: Notes + Tasks + AI

#### **Navigation Structure**

**iPhone**:
```
Bottom Tabs (4):
├── Home
├── Search
├── Updates
└── Settings
```

**iPad**:
```
Sidebar:
├── [Workspace Switcher]
├── Search
├── Updates
├── [Pages Section]
│   ├── Quick Notes
│   ├── Tasks
│   ├── Projects
│   └── [custom pages]
└── Settings

Multi-Column:
- Sidebar (240pt)
- Page list (300pt) [optional]
- Main content (fluid)
```

#### **Key Design Decisions**

1. **Workspace Concept**: Top-level container for all your stuff
2. **Page-Based**: Everything is a page (including task databases)
3. **AI Integration**: Ask AI button in toolbar, context-aware
4. **Infinite Nesting**: Pages can contain pages infinitely
5. **Template System**: Start from templates for common use cases

#### **What Works**

✅ **Flexible structure**: Adapts to any workflow  
✅ **AI chat**: Sidebar chat for assistance without leaving context  
✅ **Rich content**: Mix tasks, notes, images, tables  
✅ **Multi-column on iPad**: Uses large screen effectively  

#### **What Doesn't Work**

❌ **Complexity**: Too many options for simple use cases  
❌ **Slow**: Web-based, feels laggy compared to native  
❌ **Overwhelming**: New users don't know where to start  

#### **What We Can Learn**

- AI assistance should be context-aware sidebar, not separate screen
- Multi-column layout on iPad maximizes screen space
- But: simplicity beats flexibility for focus apps

---

## 6. ChatGPT (AI-First Interface)

### Platform: iOS/iPadOS/Web
### Category: AI Assistant

#### **Navigation Structure**

**iPhone**:
```
Single Screen:
- Chat thread (main)
- Bottom: Input field (always visible)
- Top-right: Menu (history, settings)
```

**iPad**:
```
Sidebar:
├── New Chat
├── [Recent Chats]
│   ├── Today
│   ├── Yesterday
│   └── Previous 7 Days
└── Settings

Main:
- Chat thread
- Input always visible at bottom
```

#### **Key Design Decisions**

1. **Chat is Everything**: Entire interface is conversational
2. **Persistent Input**: Text field always visible, always ready
3. **Thread History**: Left sidebar shows past conversations
4. **Minimal UI**: Just chat bubbles and input, nothing else
5. **Gesture Submit**: Swipe up on input to send

#### **What Works**

✅ **Zero learning curve**: Everyone knows how to chat  
✅ **Always ready**: Input field always visible  
✅ **Fast**: Feels instant, streaming responses  
✅ **History management**: Easy to return to past conversations  

#### **What We Can Learn**

- If we add AI assistant, make it conversational
- Keep input always visible (like iOS Messages)
- Stream responses for perceived speed
- Organize history by recency (Today, Yesterday, etc.)

---

## 7. Apple Reminders (Simple Task Management)

### Platform: iOS/iPadOS (Native)
### Category: Simple To-Do

#### **Navigation Structure**

**iPhone**:
```
Main Screen:
├── [Search Bar]
├── Today (smart list)
├── Scheduled (smart list)
├── All (smart list)
├── Flagged (smart list)
├── [Custom Lists]
│   ├── Shopping
│   ├── Work
│   └── Personal
└── [+ New List]

Bottom Toolbar:
- Add Reminder
- [List actions]
```

**iPad**:
```
Sidebar:
├── Search
├── Today
├── Scheduled
├── All
├── Flagged
├── [Custom Lists]
└── [+ New List]

Multi-Column:
- Sidebar (lists)
- Reminder list
- Detail pane (when selected)
```

#### **Key Design Decisions**

1. **Smart Lists First**: Time-based lists (Today, Scheduled) at top
2. **Quick Add**: Always-visible button to add reminder
3. **Natural Language**: "Call mom tomorrow at 5pm" → parsed
4. **Rich Reminders**: Can add time, location, tags, subtasks
5. **3-Column on iPad**: List → Items → Detail

#### **What Works**

✅ **Smart lists**: Pre-built filters everyone needs  
✅ **Quick entry**: One tap to add  
✅ **Natural language**: Fast input  
✅ **Simple**: Doesn't try to do too much  
✅ **Deep linking**: Other apps can add reminders  

#### **What Doesn't Work**

❌ **No time blocking**: Just lists, no schedule view  
❌ **Limited planning**: Can't see workload distribution  

#### **What We Can Learn**

- Smart lists (Today, Tomorrow, Unscheduled) should be built-in
- Quick add button should be omnipresent
- Natural language parsing is table stakes
- 3-column layout on iPad is Apple's standard

---

## 8. Forest (Focus Timer)

### Platform: iOS/Android
### Category: Focus/Productivity

#### **Navigation Structure**

**iPhone**:
```
Bottom Tabs (4):
├── Forest (main timer screen)
├── Timeline (past sessions)
├── Statistics
└── Profile
```

**Main Screen**:
```
- Large tree visual (grows during focus)
- Time picker
- [Plant] button (start focus)
- Tag selector (what you're working on)
```

#### **Key Design Decisions**

1. **Visual Metaphor**: Tree grows = you stay focused
2. **Single Action**: One big button to start focus session
3. **Gamification**: Collect trees, unlock species
4. **Timeline View**: Past sessions shown as forest
5. **Tags**: Quick categorization without complexity

#### **What Works**

✅ **Clear action**: "Plant a tree" = start focus session  
✅ **Visual reward**: Growing tree is satisfying  
✅ **Simple**: Just timer + category, nothing else  
✅ **Motivation**: Gamification keeps users engaged  

#### **What We Can Learn**

- Focus mode should be one-tap action
- Visual feedback makes progress tangible
- Simplicity wins for focus tools
- Timeline view of past work is motivating

---

## 9. GoodNotes (iPad-First App)

### Platform: iPadOS (iPad-first, iPhone secondary)
### Category: Note-Taking

#### **Navigation Structure**

**iPad (Primary)**:
```
Sidebar (collapsible):
├── Documents
│   ├── Recent
│   ├── Starred
│   └── [Folders]
└── Settings

Main View:
- Grid of notebook covers (default)
- Or: List view

Within Notebook:
- Full-screen canvas
- Toolbar at top
- Floating palette (optional)
```

#### **Key Design Decisions**

1. **Document Library First**: Shows all notebooks like physical shelf
2. **Full-Screen Focus**: When in notebook, no chrome visible
3. **Collapsible Sidebar**: Hide for full canvas, show for navigation
4. **Gesture-Heavy**: Pinch, zoom, two-finger swipe all do things
5. **Apple Pencil First**: Designed for stylus, keyboard secondary

#### **What Works**

✅ **Visual library**: See all documents at once  
✅ **Full-screen mode**: Maximize canvas when working  
✅ **Gesture navigation**: Feels native to iPad  
✅ **Quick access toolbar**: Most-used tools always visible  

#### **What We Can Learn**

- Collapsible sidebar gives flexibility (focus vs. navigation)
- Visual representation (covers, thumbnails) aids memory
- Full-screen mode removes distractions
- Toolbar should contain most-used actions only

---

## 10. Apple Notes (System Baseline)

### Platform: iOS/iPadOS (Native)
### Category: Note-Taking

#### **Navigation Structure**

**iPhone**:
```
Hierarchical Navigation:
Folders → Note List → Note Content

Bottom Toolbar:
- New Folder
- New Note
- Delete
```

**iPad**:
```
3-Column Layout:
├── Sidebar (Folders) [240pt]
├── Note List [320pt]  
└── Note Content [fluid]

Collapsible:
- Hide sidebar for 2-column
- Hide list for full-screen note
```

#### **Key Design Decisions**

1. **3-Column Standard**: Apple's iPad template for content apps
2. **Collapsible Columns**: Buttons to hide sidebar/list
3. **iCloud Sync**: Seamless across devices
4. **Rich Text**: Formatting without complexity
5. **Quick Note**: iPadOS shortcut from corner swipe

#### **What Works**

✅ **3-column = clarity**: Folder → List → Content is intuitive  
✅ **Collapsible**: Adapt to focus (writing) vs. browsing (finding)  
✅ **Fast**: Native performance  
✅ **System integration**: Quick Note, Siri, Shortcuts  

#### **What We Can Learn**

- 3-column is Apple's recommended pattern for content apps
- Columns should collapse for different modes
- System integration (Siri, Shortcuts, Widgets) adds huge value

---

## Analysis: Common Patterns Across Best Apps

### 1. **Navigation Hierarchy**

**Time-Based Apps** (Calendar, Things, Structured):
```
Now → Today → Tomorrow → This Week → Later
```

**Content-Based Apps** (Notes, Notion):
```
All Items → Category/Folder → Individual Item
```

**Chat-Based Apps** (ChatGPT):
```
New → Recent (Today, Yesterday) → Archive
```

### 2. **Platform-Specific Standards**

#### **iPhone**:
- **Bottom Tab Bar**: 3-5 tabs max
- **Modal Sheets**: For creation/editing flows
- **Swipe Gestures**: Left/right for navigation, actions
- **Bottom Input**: Text fields at bottom (like Messages)

#### **iPad**:
- **Sidebar Navigation**: 240-280pt wide
- **Multi-Column**: 2-3 column layouts
- **Collapsible UI**: Hide/show based on task
- **Split View Support**: Work with other apps side-by-side

### 3. **Quick Capture Patterns**

Every successful productivity app has **instant capture**:

| App | Quick Add Method |
|-----|------------------|
| Things 3 | Pull down from anywhere |
| Fantastical | Natural language in nav bar |
| Reminders | "+" button always visible |
| Notion | "+" button in toolbar |
| ChatGPT | Input always at bottom |
| Structured | "+" button in timeline |

**Lesson**: Quick add must be:
- Accessible from any screen
- Visible without searching
- Fast (< 5 seconds to create)

### 4. **Current Context Indicators**

Time-based apps all show "where you are now":

- **Visual**: Red line (Calendar), highlighted card (Things)
- **Positional**: Scroll to current time automatically
- **Temporal**: "Today" badge, "Now" label
- **Progress**: Percentage of day complete

### 5. **Color Strategy**

**Minimal Apps** (Things, Reminders):
- Mostly white/gray
- Color only for accents (tags, priorities)
- Reduces cognitive load

**Colorful Apps** (Fantastical, Notion):
- Each category/calendar gets color
- Shown as left border or dot, not full background
- User-customizable

**Lesson**: Color-code categories, but keep it subtle

### 6. **Gesture Language**

Universal gestures across productivity apps:

| Gesture | Action |
|---------|--------|
| Swipe right | Complete/Done |
| Swipe left | Delete/More options |
| Long press | Context menu |
| Pull to refresh | Sync/Reload |
| Pinch | Zoom (calendar density) |
| Two-finger swipe | Navigate back |

---

## Recommendations for GetDone Navigation

Based on this research, here's what GetDone should implement:

### **iPhone Navigation**

```
Bottom Tabs (3):
├── 📅 Agenda (Default - 80% of usage)
│   - Time-blocked schedule for today
│   - Current task highlighted
│   - Progress bar showing day completion
│
├── ✓ Tasks (Task library)
│   - Smart Lists:
│     • Unscheduled
│     • Tomorrow
│     • Later
│     • Completed
│
└── ⚙️ More
    - Settings
    - Integrations
    - Profile
    - About
```

**Rationale**:
- 3 tabs = simple (not overwhelming)
- Agenda first = default view
- Tasks for power users who need task library
- "More" hides complexity

### **iPad Navigation**

```
Sidebar (collapsible, 260pt):
├── [Profile Card - compact]
│   - Name + Photo
│   - Quick settings button
│
├── 📅 Agenda (Default)
├── ✓ Tasks
├── 📊 Insights (Future)
├── 🔗 Integrations
└── ⚙️ Settings

Main View (fluid width):
- Selected view content
- Toolbar with contextual actions

Optional Detail Pane (360pt):
- Task details when selected
- 3-column: Sidebar → Content → Detail
```

**Rationale**:
- Follows Apple 3-column pattern
- Sidebar shows structure without overwhelming
- Collapsible for focus mode
- Detail pane for task editing without modal

### **Quick Add (Universal)**

**Multiple access points**:
1. **Floating Action Button** (FAB): Bottom-right corner, always visible
2. **Keyboard Shortcut**: ⌘N (iPad with keyboard)
3. **Pull Down Gesture**: From Agenda view (like Things)
4. **Siri**: "Add task to GetDone"

**Quick Add Sheet**:
```
┌─────────────────────────────────┐
│  Nieuwe taak                    │
├─────────────────────────────────┤
│                                 │
│  [Text Input - Large]           │
│  "Wat moet er gedaan worden?"   │
│                                 │
│  ⏱️  Duur: [1u 30m ▼]          │
│  📅  Deadline: [Geen ▼]         │
│  🏷️  Categorie: [Persoonlijk ▼]│
│                                 │
│  [Annuleer]  [Toevoegen →]     │
└─────────────────────────────────┘
```

### **Agenda View (Main Screen)**

Based on Fantastical + Structured patterns:

```
┌─────────────────────────────────────────┐
│ Vandaag • Ma 30 Sep          [···] [+] │
├─────────────────────────────────────────┤
│ ━━━━━━●━━━━━━━━━ 47% voltooid         │ ← Progress bar
├─────────────────────────────────────────┤
│                                         │
│ ⏰ NU - 11:30                          │
│ ┌─────────────────────────────────┐   │
│ │ 11:00 - 12:00                   │   │ ← Current task
│ │ 📝 UI/Navigation onderzoek      │   │   (larger, highlighted)
│ │ ▓▓▓▓▓▓▓▓░░░░ 48 min resterend  │   │
│ │                     [Klaar ✓]   │   │
│ └─────────────────────────────────┘   │
│                                         │
│ 📋 STRAKS                              │
│ ┌─────────────────────────────────┐   │
│ │ 12:00 - 12:30  Lunch            │   │
│ └─────────────────────────────────┘   │
│ ┌─────────────────────────────────┐   │
│ │ 12:30 - 14:30  Wiskunde huiswerk│   │
│ │ 🏫 School • Hoge prioriteit     │   │
│ └─────────────────────────────────┘   │
│                                         │
│ 📅 LATER VANDAAG (4) ▼                │ ← Collapsible
│                                         │
│ [🌙 Morgen bekijken →]                 │
│                                         │
└─────────────────────────────────────────┘
   [📅 Agenda] [✓ Taken] [⚙️ Meer]      ← Tab bar
```

### **Key Features**:

1. **Progress Indicator**: Visual bar showing % of day complete
2. **Current Time Section**: "NU" with large card
3. **Time Blocks**: Every task shows start/end time
4. **Collapsible Sections**: "Later Today" hides by default
5. **Quick Actions**: 
   - Swipe right on task: Mark done
   - Swipe left on task: Reschedule
   - Tap task: Show detail
   - Long press: Context menu
6. **Tomorrow Preview**: Quick link to see tomorrow's plan

### **Gestures (Following Standards)**:

| Gesture | Action |
|---------|--------|
| Swipe right on task | Mark complete ✓ |
| Swipe left on task | Options (reschedule, delete) |
| Long press task | Context menu |
| Pull down | Quick add task |
| Tap progress bar | See full day overview |
| Tap "Later Today" | Expand/collapse |

---

## Design System Decisions

### **Typography** (Following Apple Notes/Reminders)

```swift
// Title hierarchy
.largeTitle       // Main screen title "Vandaag"
.title            // Section headers "NU", "STRAKS"
.headline         // Task titles
.body             // Task descriptions
.caption          // Metadata (time, category)
```

### **Colors** (Following Things 3 + Fantastical)

```swift
// Base
Background: .black (dark mode) / .white (light mode)
Card: .regularMaterial (glassmorphism)
Text: .primary (white/black adaptive)

// Semantic
Current: .orange (urgent, now)
Success: .green (completed)
Warning: .yellow (deadline approaching)
Error: .red (overdue)

// Categories (user-customizable)
Work: .blue
Personal: .purple
School: .cyan
Health: .pink
```

### **Spacing** (Following Apple HIG)

```swift
// Padding
Card padding: 16pt
Section spacing: 24pt
Inter-element: 12pt

// Corner radius
Cards: 12pt
Buttons: 10pt
Sheets: 16pt (top corners)
```

---

## Final Navigation Architecture

### **Information Architecture**

```
GetDone App
│
├── 📅 Agenda (Home/Default)
│   ├── Today View (default)
│   │   ├── Progress indicator
│   │   ├── Current task (NU)
│   │   ├── Upcoming (STRAKS)
│   │   └── Later Today (collapsible)
│   ├── Tomorrow Preview
│   └── [Quick Add - FAB]
│
├── ✓ Tasks (Task Library)
│   ├── Smart Lists
│   │   ├── Unscheduled
│   │   ├── Tomorrow
│   │   ├── This Week
│   │   └── Someday
│   ├── Categories
│   │   ├── Work
│   │   ├── Personal
│   │   └── School
│   └── Completed Archive
│
└── ⚙️ More
    ├── Profile
    ├── Planning Settings
    │   ├── Work Hours
    │   ├── Break Preferences
    │   └── Focus Times
    ├── Integrations
    │   ├── Calendar (iOS)
    │   ├── [Student Mode]
    │   │   ├── Magister
    │   │   └── Google Classroom
    │   └── [Future integrations]
    ├── Notifications
    ├── Appearance
    └── About/Help
```

---

## Implementation Priority

### Phase 1: Core Navigation (Week 1)
1. ✅ Research complete (this document)
2. ⬜ Create new navigation structure (3 tabs)
3. ⬜ Build Agenda view skeleton
4. ⬜ Add Quick Add FAB
5. ⬜ Implement swipe gestures

### Phase 2: Agenda View (Week 2)
1. ⬜ Time-blocked card layout
2. ⬜ Current task highlighting
3. ⬜ Progress indicator
4. ⬜ Collapsible sections
5. ⬜ Tomorrow preview

### Phase 3: Tasks View (Week 3)
1. ⬜ Smart lists (Unscheduled, Tomorrow, etc.)
2. ⬜ Search functionality
3. ⬜ Filter by category
4. ⬜ Archive view

### Phase 4: Polish (Week 4)
1. ⬜ Haptic feedback
2. ⬜ Animations
3. ⬜ Dark mode refinement
4. ⬜ Accessibility labels
5. ⬜ iPad 3-column layout

---

## Conclusion

**What we learned from the best apps**:

1. **Simplicity wins**: 3 tabs on iPhone, collapsible sidebar on iPad
2. **Time-based hierarchy**: Now → Today → Tomorrow → Later
3. **Quick capture is critical**: FAB, pull-down gesture, natural language
4. **Current context matters**: Show "where you are now" prominently
5. **Gestures follow standards**: Swipe right = done, swipe left = options
6. **3-column on iPad**: Apple's standard for content apps
7. **Collapsible UI**: Adapt between focus and navigation modes

**GetDone's navigation should**:
- Default to Agenda (time-blocked today view)
- Use 3 tabs on iPhone (Agenda, Tasks, More)
- Use collapsible sidebar on iPad (3-column capable)
- Feature FAB for quick add (bottom-right)
- Follow iOS gesture standards
- Show progress and current time prominently

**Next step**: Implement the new navigation structure in SwiftUI.

