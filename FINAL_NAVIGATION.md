# Final Navigation Architecture - GetDone
**Date**: September 30, 2026  
**Status**: Ready for Implementation

---

## Navigation Structure

### iPhone (3 Tabs)

```
Bottom Tab Bar:
├── 📅 Agenda (Time-blocked daily schedule)
├── 💬 Chat (AI assistant - DEFAULT)
└── 👤 Profile (Account, integrations, settings)
```

**Rationale**:
- **Chat as default**: Most interactions start with AI ("Add task...", "What's next?")
- **Agenda**: Visual overview of your day
- **Profile**: Keeps existing functionality (account management, integrations, settings)

---

### iPad

```
NavigationSplitView:

Sidebar (260pt, collapsible):
├── [Profile Card]
│   - User photo
│   - Name
│   - Email
│   
├── 📅 Agenda
├── 💬 Chat (DEFAULT)
│
├── [Divider]
│
├── Account & Settings
│   ├── Planning Preferences
│   ├── Integrations
│   │   ├── Google Account
│   │   ├── Magister
│   │   └── Google Classroom
│   ├── Notifications
│   └── Appearance

Detail View (fluid):
- Selected view content (Agenda or Chat)
- Full screen when sidebar collapsed

Optional: Chat Side Panel (320pt):
- When viewing Agenda, chat can slide in from right
- Split-screen: Agenda + Chat simultaneously
```

**Rationale**:
- Keeps existing profile card design (looks great!)
- Sidebar provides navigation + settings access
- Chat can be side-by-side with Agenda on iPad (desktop-class)

---

## Screen Details

### 1. Agenda Tab

**Purpose**: Visual time-blocked schedule for today

**Layout**:
```
┌─────────────────────────────────────────┐
│ Vandaag • Ma 30 Sep          [···] [+] │
├─────────────────────────────────────────┤
│ ━━━━━━●━━━━━━━━━ 47% voltooid         │
├─────────────────────────────────────────┤
│                                         │
│ ⏰ NU - 11:30                          │
│ ┌─────────────────────────────────┐   │
│ │ 11:00 - 12:00                   │   │
│ │ 📝 UI/Navigation onderzoek      │   │
│ │ ▓▓▓▓▓▓▓▓░░░░ 30 min left       │   │
│ │                     [Klaar ✓]   │   │
│ └─────────────────────────────────┘   │
│                                         │
│ 📋 STRAKS                              │
│ ┌─────────────────────────────────┐   │
│ │ 12:00 - 12:30  Lunch            │   │
│ └─────────────────────────────────┘   │
│ ┌─────────────────────────────────┐   │
│ │ 12:30 - 14:30  Wiskunde         │   │
│ └─────────────────────────────────┘   │
│                                         │
│ 📅 LATER VANDAAG (3) ▼                │
│                                         │
│ [💬 Vraag AI iets] [🌙 Morgen →]      │
└─────────────────────────────────────────┘
```

**Key Features**:
- Progress bar (% of day complete)
- Current task highlighted ("NU")
- Time blocks for each task
- Swipe gestures (right=done, left=options)
- Quick access to Chat ("Vraag AI iets")
- Tomorrow preview link

**Top-right Actions**:
- [···] Menu: Settings, view tomorrow, refresh schedule
- [+] Quick add (opens simple form, or tap to go to Chat)

---

### 2. Chat Tab (Default)

**Purpose**: AI command center for controlling everything

**Layout**:
```
┌─────────────────────────────────────────┐
│ GetDone AI                    [···][×] │
├─────────────────────────────────────────┤
│                                         │
│  [AI] Hoi! Wat kan ik voor je doen?   │
│      ┌─────────────────────────────┐   │
│      │ Wat moet ik vandaag doen?   │   │
│      │ Voeg een taak toe           │   │
│      │ Optimaliseer mijn dag       │   │
│      └─────────────────────────────┘   │
│                                         │
│  [User] Voeg taak toe om tandarts     │
│         te bellen morgen om 14u        │
│                                         │
│  [AI] ✓ Toegevoegd: "Bel tandarts"    │
│      Morgen (1 okt) om 14:00           │
│      ┌─────────────────────────────┐   │
│      │ 📅 14:00 - 14:30            │   │
│      │ ☎️ Bel tandarts             │   │
│      │ Persoonlijk                 │   │
│      │ [Bekijk in Agenda →]        │   │
│      └─────────────────────────────┘   │
│      Herinnering instellen?            │
│      [Ja] [Nee]                        │
│                                         │
│                                         │
│                        [Type hier...] ↑│
└─────────────────────────────────────────┘
    [🎤]              [Verstuur]
```

**Key Features**:
- Natural language input
- Quick action suggestions
- Rich cards (tasks, schedules)
- Quick reply buttons
- Voice input (🎤 button)
- Streaming responses (text appears word-by-word)
- Links to Agenda ("Bekijk in Agenda →")

**What you can ask**:
- "Wat moet ik doen vandaag?"
- "Voeg taak toe om..."
- "Verplaats de wiskunde naar morgen"
- "Wanneer ben ik vrij vandaag?"
- "Optimaliseer mijn dag"
- "Hoe productief was ik deze week?"
- "Verbind mijn Google Calendar"
- "Stel mijn werktijden in op 9-17"

---

### 3. Profile Tab

**Purpose**: Account management, integrations, settings

**Keep existing design** with these sections:

```
┌─────────────────────────────────────────┐
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  [Profile Photo]                │   │
│  │  Naam van Gebruiker             │   │
│  │  email@example.com              │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ACCOUNTS                               │
│  ┌─────────────────────────────────┐   │
│  │ 🔵 Google Account               │   │
│  │ Verbonden                       │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ 📚 Magister                     │   │
│  │ Niet verbonden                  │   │
│  └─────────────────────────────────┘   │
│                                         │
│  PLANNING                               │
│  ┌─────────────────────────────────┐   │
│  │ ⏰ Werktijden                   │   │
│  │ 9:00 - 17:00                    │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ ☕ Pauze voorkeuren             │   │
│  │ Elke 2 uur, 15 min              │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ 🧠 Focus tijden                 │   │
│  │ 10:00 - 12:00 (ochtend)         │   │
│  └─────────────────────────────────┘   │
│                                         │
│  APP                                    │
│  ┌─────────────────────────────────┐   │
│  │ 🔔 Notificaties                 │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ 🎨 Uiterlijk                    │   │
│  │ Donkere modus                   │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ ℹ️ Over GetDone                 │   │
│  │ Versie 1.0                      │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

**Sections**:

1. **Profile Card** (existing beautiful design)
   - Photo, name, email
   - Tappable to edit

2. **Accounts** (existing integrations)
   - Google Account (OAuth)
   - Magister
   - Google Classroom
   - Future: More integrations

3. **Planning** (NEW - essential for AI)
   - Work Hours (when to schedule tasks)
   - Break Preferences (frequency & duration)
   - Focus Times (when you're most productive)
   - AI uses these to plan your day

4. **App Settings**
   - Notifications
   - Appearance (dark/light mode)
   - About & Help

**Keep**:
- Existing glassmorphism design
- Profile card at top
- Account connection flows
- Settings organization

**Add**:
- Planning Preferences section (AI needs this)
- Link to chat: "Ask AI to configure" button

---

## Navigation Flow Examples

### Flow 1: Add Task via Chat (Most Common)

```
1. Open app → Chat tab (default)
2. Type: "Voeg taak toe om boodschappen te doen om 15u"
3. AI: "✓ Toegevoegd: Boodschappen, 15:00-15:30"
4. (Optional) Tap "Bekijk in Agenda" → Navigate to Agenda tab
```

**Time**: 5 seconds

---

### Flow 2: Check Schedule (Visual)

```
1. Open app → Swipe to Agenda tab (or already there)
2. See time-blocked schedule
3. Tap current task to see details
4. Swipe right to mark done
```

**Time**: 2 seconds

---

### Flow 3: Configure Settings

```
1. Open app → Swipe to Profile tab
2. Tap "Planning → Werktijden"
3. Set to 9:00 - 17:00
4. AI now schedules tasks within these hours
```

OR via Chat:

```
1. Open app → Chat tab
2. Type: "Stel mijn werktijden in op 9 tot 5"
3. AI: "✓ Werktijden ingesteld: 9:00-17:00"
```

---

### Flow 4: Connect Integration

```
1. Profile tab → Accounts → Magister
2. Tap "Verbinden"
3. Login flow
4. AI imports assignments automatically
```

OR via Chat:

```
1. Chat: "Verbind mijn Magister account"
2. AI: "Ik open de Magister login..."
3. Complete login
4. AI: "✓ Verbonden. 5 opdrachten geïmporteerd."
```

---

## Cross-Tab Integration

### From Agenda → Chat

**Button**: "💬 Vraag AI iets" at bottom of Agenda
- Taps opens Chat tab
- Pre-fills context: "Tell me about [current task]"

**Long-press task** → Context menu → "Ask AI"
- Opens Chat with: "Vertel me over [task name]"

---

### From Chat → Agenda

**Rich cards in Chat** have "Bekijk in Agenda →" button
- Navigates to Agenda tab
- Scrolls to task
- Highlights task briefly (glow effect)

**AI suggests**: "Wil je je agenda bekijken?"
- Quick reply button [Ja, laat zien]
- Opens Agenda tab

---

### From Chat → Profile

**AI detects missing settings**:
```
User: "Plan mijn dag"
AI: "Ik heb je werktijden nog niet. Stel ze nu in?"
    [Ga naar Instellingen]
```
- Opens Profile tab → Planning section

---

## iPad-Specific Features

### Split View Option 1: Sidebar + Agenda

```
┌──────────────┬────────────────────────────────┐
│              │                                │
│  [Profile]   │  📅 Agenda View               │
│              │                                │
│  📅 Agenda   │  11:00 - 12:00                │
│  💬 Chat     │  UI Research                   │
│              │                                │
│  [Settings]  │  12:00 - 12:30                │
│              │  Lunch                         │
│              │                                │
└──────────────┴────────────────────────────────┘
```

### Split View Option 2: Sidebar + Chat

```
┌──────────────┬────────────────────────────────┐
│              │                                │
│  [Profile]   │  💬 Chat                      │
│              │                                │
│  📅 Agenda   │  [AI] Hoi! Wat kan ik doen?  │
│  💬 Chat     │                                │
│              │  [User] Wat moet ik doen?     │
│  [Settings]  │                                │
│              │  [AI] Je hebt 5 taken...      │
│              │                                │
└──────────────┴────────────────────────────────┘
```

### Split View Option 3: Triple (Future)

```
┌────────┬──────────────────┬────────────────┐
│        │                  │                │
│ [Nav]  │  📅 Agenda       │  💬 Chat      │
│        │                  │                │
│ Agenda │  NU: Research    │  Ask me...    │
│ Chat   │                  │                │
│        │  STRAKS: Lunch   │  [User] ...   │
│        │                  │                │
└────────┴──────────────────┴────────────────┘
```

Users work in Agenda, ask questions in Chat panel without losing context.

---

## Gestures & Shortcuts

### Universal Gestures

| Gesture | Action | Where |
|---------|--------|-------|
| Swipe right on task | Mark complete ✓ | Agenda |
| Swipe left on task | Options (reschedule, delete) | Agenda |
| Long-press task | Context menu (Ask AI, Edit, etc.) | Agenda |
| Pull down | Refresh/Re-plan | Agenda |
| Pull down | New conversation | Chat |

### Keyboard Shortcuts (iPad)

| Shortcut | Action |
|----------|--------|
| ⌘1 | Go to Agenda |
| ⌘2 | Go to Chat |
| ⌘3 | Go to Profile |
| ⌘N | New task (opens Chat) |
| ⌘/ | Focus Chat input |
| ⌘K | Quick actions menu |
| ⌘R | Refresh schedule |

---

## FAB (Floating Action Button) Discussion

### Option A: No FAB (Recommended)

**Rationale**: 
- Chat tab is default → Adding tasks is one tap away
- Agenda has [+] button in top-right
- Cleaner UI without floating button
- iOS doesn't typically use FABs (Android pattern)

### Option B: FAB on Agenda Only

If you want quick add from Agenda:
- Bottom-right corner FAB when on Agenda tab
- Tapping opens Chat tab with "Voeg taak toe..." pre-filled
- Or: Opens quick-add sheet (simple form)

**Recommendation**: Start without FAB. If users complain about "Can't add tasks from Agenda," add it later.

---

## Visual Design Consistency

### Maintain Current Strengths

✅ **Dark mode first**: Keep the beautiful dark glassmorphism  
✅ **Profile card**: Keep existing design in sidebar  
✅ **Color coding**: Keep category colors  
✅ **Smooth animations**: Keep .easeInOut transitions  
✅ **Material design**: Keep .regularMaterial cards  

### Add for Chat

- **Message bubbles**: Similar card style (glassmorphic)
- **User messages**: Right-aligned, slightly different tint
- **AI messages**: Left-aligned, with icon
- **Rich cards**: Same style as Agenda cards (consistency)

### Typography Scale

```swift
// Existing scale - keep it
.largeTitle    // Screen titles
.title         // Section headers ("NU", "STRAKS")
.headline      // Task titles
.body          // Descriptions
.caption       // Metadata

// Add for Chat
.title2        // Chat header "GetDone AI"
.body          // Message text
.caption       // Timestamps
```

---

## State Management

### App-Wide State

```swift
@main
struct GetDoneApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

@MainActor
class AppState: ObservableObject {
    // Navigation
    @Published var selectedTab: Tab = .chat  // Default to Chat
    @Published var sidebarVisible: Bool = true  // iPad
    
    // Data
    @Published var tasks: [Task] = []
    @Published var scheduledBlocks: [ScheduledBlock] = []
    @Published var chatMessages: [ChatMessage] = []
    
    // Managers
    let aiManager = AIManager()
    let planningEngine = PlanningEngine()
    let googleAuth = WebGoogleAuthManager()
    let magisterManager = MagisterManager()
    
    // Methods
    func navigateTo(_ tab: Tab, highlightTask: Task? = nil) {
        selectedTab = tab
        if let task = highlightTask {
            // Scroll to and highlight task
        }
    }
}

enum Tab: String {
    case agenda = "Agenda"
    case chat = "Chat"
    case profile = "Profiel"
}
```

---

## Implementation Checklist

### Phase 1: Navigation Structure (Week 1)

- [ ] Update ContentView to 3-tab layout
- [ ] Set Chat as default tab
- [ ] Keep existing Profile view
- [ ] Add empty Agenda view skeleton
- [ ] Add empty Chat view skeleton
- [ ] Test tab switching

### Phase 2: Agenda View (Week 2)

- [ ] Time-blocked card layout
- [ ] Progress bar
- [ ] Current task highlighting ("NU")
- [ ] Swipe gestures
- [ ] Mock data for testing
- [ ] "Vraag AI iets" button → navigates to Chat

### Phase 3: Chat View (Week 3-4)

- [ ] Chat UI (messages, input, send)
- [ ] OpenAI/Claude integration
- [ ] Basic function calling
- [ ] Rich cards
- [ ] "Bekijk in Agenda" navigation
- [ ] Voice input

### Phase 4: Profile Updates (Week 5)

- [ ] Add Planning Preferences section
- [ ] Work Hours picker
- [ ] Break Preferences
- [ ] Focus Times
- [ ] Link to chat: "Vraag AI om te configureren"

### Phase 5: Integration (Week 6)

- [ ] Cross-tab navigation
- [ ] Shared state management
- [ ] Deep linking (Chat → Agenda → specific task)
- [ ] Unified task model
- [ ] Data persistence

### Phase 6: iPad Layout (Week 7)

- [ ] NavigationSplitView with sidebar
- [ ] Profile card in sidebar
- [ ] Collapsible sidebar
- [ ] Optional: Chat side panel
- [ ] Keyboard shortcuts

### Phase 7: Polish (Week 8)

- [ ] Animations
- [ ] Haptics
- [ ] Accessibility
- [ ] Error states
- [ ] Loading states
- [ ] Empty states

---

## Summary

**Navigation: 3 tabs**
- 📅 Agenda (visual schedule)
- 💬 Chat (AI control center, DEFAULT)
- 👤 Profile (existing design + planning preferences)

**Default experience**: 
Open app → Chat tab → Ask AI anything → See results in Agenda

**Visual experience**: 
Swipe to Agenda → See time-blocked day → Swipe to complete tasks

**Configuration**: 
Profile tab → Planning section → Set preferences (or ask Chat)

**iPad**: 
Sidebar navigation + Profile card + Split-view capable

**Next step**: Start implementing! Begin with 3-tab structure.

