# GetDone App - Research & Planning Document
**Date**: September 30, 2026  
**Status**: Strategic Planning Phase

---

## 1. App Development Principles

### 1.1 Core Philosophy
When developing an app, especially for productivity and task management, we must answer three fundamental questions:
1. **What problem does it solve?** (Value Proposition)
2. **How does it solve it?** (Functionality & Features)
3. **Why would users prefer it?** (User Experience & Design)

### 1.2 Key Development Principles
- **User-Centered Design**: Start with user needs, not technical capabilities
- **Simplicity First**: Remove friction at every step
- **Consistency**: Patterns should be predictable across the app
- **Accessibility**: Design for all users, including those with disabilities
- **Performance**: Fast, responsive, and reliable
- **Platform Native**: Leverage iOS/iPadOS patterns users already know

---

## 2. Problem Definition: What Should GetDone Solve?

### 2.1 The Universal Problem: Decision Fatigue & Task Overwhelm

Modern life bombards everyone with choices and obligations:
- **Work professionals**: Emails, meetings, deadlines, projects
- **Students**: Classes, assignments, exams, study time
- **Parents**: School pickups, appointments, household tasks
- **Freelancers**: Client work, invoicing, marketing, skill development
- **Everyone**: Personal errands, health, relationships, hobbies

**The Core Issue**: People waste mental energy deciding "What should I do next?" multiple times per day. This constant context-switching and prioritization drains productivity and creates anxiety.

### 2.2 GetDone's Primary Solution: AI-Powered Day Planning

**The Vision**: 
> Wake up → Open GetDone → See your entire day planned out → Just do what it says

**Not**: A task list where you still have to decide what to work on  
**But**: An intelligent daily schedule that tells you exactly what to do and when

### 2.3 Core Problems GetDone Should Solve

#### **Problem 1: Decision Fatigue**
**Pain Point**: Every day requires hundreds of micro-decisions:
- "What should I work on first?"
- "How long should I spend on this?"
- "Did I forget anything important?"
- "When should I take breaks?"

**GetDone's Solution**: **AI Day Planner**
- AI analyzes all your tasks, deadlines, and priorities
- Generates optimal daily schedule automatically
- No decisions needed - just follow the plan
- Adjusts in real-time as things change

#### **Problem 2: Fragmented Information**
**Pain Point**: Your tasks live in multiple places:
- Calendar events (meetings, appointments)
- Email (action items buried in threads)
- Work tools (Jira, Asana, Slack messages)
- School systems (Magister, Google Classroom)
- Personal notes (reminders, shopping lists)
- Mental notes (things you "should do")

**GetDone's Solution**: **Universal Integration Hub**
- Connect all data sources (calendar, email, work tools, school systems)
- AI extracts actionable tasks from all sources
- Single unified agenda view
- Works for any combination of integrations

#### **Problem 3: Unrealistic Planning**
**Pain Point**: People either:
- Over-schedule (8 hours of meetings + "just finish these 10 tasks")
- Under-schedule (forget about commute time, breaks, meal prep)
- Miss dependencies ("Can't start Task B until Task A is done")

**GetDone's Solution**: **Intelligent Time Management**
- AI considers realistic time blocks
- Accounts for energy levels (deep work vs. easy tasks)
- Respects focus time and break patterns
- Handles task dependencies and blocking events

#### **Problem 4: Lack of Execution Support**
**Pain Point**: Traditional to-do apps show what needs to be done but don't guide execution:
- No sense of urgency ("I'll do it later")
- Procrastination on hard tasks
- No accountability

**GetDone's Solution**: **Structured Execution**
- Time-blocked schedule creates urgency ("Math homework: 2:00 PM - 3:30 PM")
- AI prioritizes hard tasks during peak energy hours
- Progress tracking shows completion rates
- Gentle nudges when falling behind

---

## 3. How Should GetDone Solve These Problems?

### 3.1 The AI Planning Engine (Core Innovation)

This is what differentiates GetDone from every other productivity app.

#### **Input Sources**
The AI should ingest tasks from:
1. **Calendar Events** (meetings, appointments, classes)
2. **Manual Tasks** (user-created to-dos)
3. **Integrated Systems**:
   - For students: Magister assignments, Google Classroom
   - For workers: Email action items, project management tools
   - For everyone: Reminders, notes with deadlines
4. **Recurring Patterns** (daily routines, habits)

#### **AI Planning Process**
```
[All Tasks & Events] 
        ↓
[AI Analysis]
- Deadlines & priorities
- Estimated duration
- Task dependencies
- User's peak productivity hours
- Required focus vs. easy tasks
- Fixed events (meetings, classes)
        ↓
[Optimized Daily Schedule]
- Time-blocked agenda
- Strategic task ordering
- Built-in breaks
- Buffer time for unexpected items
        ↓
[User Interface: Just Do It]
```

#### **Key AI Features**
1. **Time Estimation**: Learns how long tasks actually take you
2. **Priority Detection**: Understands urgent vs. important
3. **Energy Matching**: Deep work during focus hours, admin tasks when tired
4. **Auto-Rescheduling**: Missed a task? AI moves it to later today or tomorrow
5. **Workload Balancing**: Warns if day is overbooked, suggests delegation/deferring

### 3.2 Feature Architecture

#### **Tier 1: Core Features (Must Have for MVP)**

##### 1. **Agenda View (The Main Screen)**
This is 80% of the app experience.

**What it shows**:
- Today's date and current time
- **Time-blocked schedule** (e.g., "9:00 AM - 10:30 AM: Write report")
- Current task highlighted
- Upcoming tasks visible
- Completed tasks checked off

**Interactions**:
- Tap task to see details or mark complete
- Long-press to reschedule
- Pull to refresh (re-run AI planning)
- Quick add button for urgent tasks

##### 2. **AI Planning System**
- Daily auto-generation (runs every night for next day)
- Manual trigger ("Plan my day" button)
- Learning from completion patterns
- Smart rescheduling when things slip

##### 3. **Task Management**
- Quick add task (title, optional deadline, optional duration)
- Manual task list for non-scheduled items
- Mark tasks complete
- Task notes and subtasks

##### 4. **Calendar Integration**
- Import from iOS Calendar
- Show fixed events (meetings, classes) in agenda
- Block time around events (commute, prep)

##### 5. **Profile & Settings**
- Account management
- Integration connections
- Planning preferences (work hours, break duration)
- Notification settings

#### **Tier 2: Enhanced Features (Should Have)**

##### 6. **Smart Integrations** (Modular - Enable What You Use)
- **Student Mode**: Magister + Google Classroom
- **Work Mode**: Email scanning, Jira/Asana connectors
- **Parent Mode**: Family calendar, shared tasks
- Each integration is optional and can be toggled on/off

##### 7. **Intelligent Notifications**
- "Time to start: [Next Task]" alerts
- "Running behind schedule" warnings
- "Great progress today!" encouragement
- Daily summary ("Tomorrow you have 6 tasks")

##### 8. **Adaptive Learning**
- Track actual time spent vs. estimated
- Learn your productivity patterns
- Adjust future schedules based on performance
- Personal insights ("You work best 10 AM - 12 PM")

##### 9. **Focus Mode**
- Show only current task (hide overwhelming full list)
- Timer/Pomodoro integration
- Do Not Disturb integration
- Background music/ambient sound suggestions

#### **Tier 3: Advanced Features (Nice to Have)**

##### 10. **Multi-Day Planning**
- Weekly view with daily workload bars
- Long-term project breakdown (AI splits big projects into daily chunks)
- Deadline forecasting ("To finish on time, you need 2 hours/day")

##### 11. **AI Chat Assistant**
- Natural language task adding: "Remind me to call dentist tomorrow"
- Planning consultation: "When should I work on the presentation?"
- Workload negotiation: "This is too much, what can I defer?"

##### 12. **Collaboration & Delegation**
- Share tasks with family/team
- Assign tasks to others
- Shared calendars with smart merging

##### 13. **Analytics & Insights**
- Completion rate trends
- Time distribution by category
- Productivity heatmaps
- Monthly reports

### 3.3 Technical Architecture

```
┌─────────────────────────────────────┐
│         User Interface Layer        │
│  - Agenda View (Main)               │
│  - Task Entry                       │
│  - Settings                         │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│      AI Planning Engine             │
│  - Task Prioritization Algorithm    │
│  - Time Block Optimizer             │
│  - Machine Learning Model           │
│  - Rescheduling Logic               │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│      Business Logic Layer           │
│  - Task Manager                     │
│  - Calendar Sync                    │
│  - Integration Handlers             │
│  - User Preferences                 │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│      Data Layer                     │
│  - SwiftData (Local Persistence)    │
│  - CloudKit (Cross-Device Sync)     │
│  - Keychain (Credentials)           │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│      Integration Layer              │
│  - iOS Calendar                     │
│  - Modular Connectors:              │
│    * Magister (for students)        │
│    * Google Classroom (for students)│
│    * Email parsing (for workers)    │
│    * [Future integrations]          │
└─────────────────────────────────────┘
```

---

## 4. UI/UX Design Principles

### 4.1 Visual Design System

#### **Design Philosophy: Calm Confidence**
GetDone should feel like having a personal assistant who has everything under control. The UI should be:
- **Calming**: Reduce anxiety, not increase it
- **Confident**: "We've got this planned out"
- **Minimal**: Only show what matters right now
- **Trustworthy**: Reliable, predictable, professional

#### **Color Philosophy**
- **Dark Mode Default**: Reduces visual fatigue for all-day use
- **Accent Colors**: 
  - Primary Blue: Planning, productivity, trust
  - Green: Completed tasks, success states
  - Orange: Urgent/current task highlights
  - Red: Overdue/warning states (used sparingly)
- **Semantic Color Coding**: Categories get user-chosen colors (work, personal, study, etc.)

#### **Typography**
- **San Francisco (System Font)**: Native iOS feel
- **Hierarchy**:
  - Large Title: Current time/date
  - Title 1: Section headers ("Today", "This Week")
  - Headline: Task titles
  - Body: Task descriptions
  - Caption: Metadata (duration, category)

#### **Spacing & Layout**
- **Generous Whitespace**: No cramped feeling
- **Card-Based**: Each task is a clear, tappable card
- **Timeline Visualization**: Vertical timeline showing progression through day
- **Glanceable**: Key info visible without tapping

### 4.2 The Agenda View Design (Most Important Screen)

This is the heart of GetDone. Here's how it should look:

```
┌─────────────────────────────────────────────┐
│  Vandaag • 30 September              [···]  │
│  10:48 AM                                   │
├─────────────────────────────────────────────┤
│                                             │
│  ⏰ Nu                                      │
│  ┌─────────────────────────────────────┐   │
│  │ 10:30 - 11:30                       │   │
│  │ 📝 Plan vakantie                    │   │
│  │ ▓▓▓▓▓▓▓▓▓░░░ 45 min left           │   │
│  │                           [Done ✓]  │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  📋 Straks                                  │
│  ┌─────────────────────────────────────┐   │
│  │ 11:30 - 12:00                       │   │
│  │ 🥗 Lunch break                      │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ 12:00 - 14:00                       │   │
│  │ 💼 Work: Finish Q4 report           │   │
│  │ Focus time • High priority          │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ 14:00 - 15:00                       │   │
│  │ 🏃 Gym workout                      │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  📅 Later Today                             │
│  • 15:00 - 16:00  Boodschappen             │
│  • 16:00 - 17:30  Email responses          │
│  • 17:30 - 18:00  Dinner prep              │
│                                             │
│  ✨ 6 tasks planned • 2 completed           │
│                                             │
│  [+ Quick Add]           [Plan Tomorrow →] │
└─────────────────────────────────────────────┘
```

#### **Key Design Elements**

1. **Current Task Emphasis**
   - Larger card with progress bar
   - Orange accent color
   - Time remaining shown dynamically
   - Easy "Mark Done" button

2. **Timeline Flow**
   - Chronological top-to-bottom
   - Past tasks fade/compress
   - Current task highlighted
   - Future tasks visible but less prominent

3. **Time Blocks**
   - Every task shows start and end time
   - Visual time bar on left edge
   - Duration visible at a glance
   - Gaps between tasks are intentional (breaks)

4. **Minimal Cognitive Load**
   - Only show what you need to know now
   - "Later Today" section collapsed by default
   - Completed tasks move to bottom or archive

5. **Quick Actions**
   - Swipe right: Mark done
   - Swipe left: Reschedule
   - Tap: View details / edit
   - Long press: Quick menu (skip, delete, duplicate)

### 4.3 Interaction Patterns

#### **Core Gestures**
- **Pull to Refresh**: Re-run AI planning (if tasks changed)
- **Swipe Right on Task**: Mark complete ✓
- **Swipe Left on Task**: Options menu (reschedule, delete, skip)
- **Tap Task**: Expand details, add notes, edit
- **Long Press**: Context menu (quick actions)
- **Drag Task**: Manual reorder (overrides AI suggestion)

#### **Feedback Systems**
- **Haptics**: 
  - Success haptic on task completion
  - Warning haptic when falling behind
  - Gentle notification haptic for upcoming tasks
- **Animations**:
  - Task completion: Check mark animation + card fades away
  - Time progress: Smooth progress bar animation
  - Add task: Card slides in from bottom
  - Reschedule: Task fades out and reappears in new position
- **Sounds** (optional, user-controlled):
  - Subtle "ding" on completion
  - Calm chime for task start reminders

#### **Accessibility**
- **Dynamic Type**: Respect user font size (extra large for elderly users)
- **VoiceOver**: Every element properly labeled
  - "Mathematics homework, starts 2 PM, duration 90 minutes, button"
- **Voice Control**: "Mark task 3 complete"
- **Reduce Motion**: Disable parallax, use fades instead of slides
- **High Contrast**: Stronger borders in high contrast mode
- **Haptic Alternatives**: Visual cues for those who can't feel haptics

---

## 5. Navigation Architecture

### 5.1 Information Architecture

GetDone should be simple - the focus is the agenda. Most users should spend 90% of their time on one screen.

```
GetDone App
├── Agenda (Home - Default - 90% of usage)
│   ├── Today View (Default)
│   ├── Tomorrow Preview
│   └── Quick Add Task
│
├── Tasks (Task Library)
│   ├── All Tasks
│   ├── Unscheduled Tasks
│   ├── Completed Archive
│   └── Search
│
├── Calendar (Optional View)
│   ├── Week View
│   ├── Month View
│   └── Timeline View
│
├── Integrations (Modular - Only if needed)
│   ├── [Student]: Magister + Classroom
│   ├── [Work]: Email + Project Tools
│   └── [Family]: Shared Calendars
│
└── Profile & Settings
    ├── Account Info
    ├── Planning Preferences
    │   ├── Work Hours
    │   ├── Break Duration
    │   ├── Focus Time Preferences
    │   └── Task Duration Defaults
    ├── Integrations Setup
    ├── Notifications
    ├── Appearance
    └── About / Help
```

### 5.2 Platform-Specific Navigation

#### **iPad Layout**
NavigationSplitView remains a good choice, but simplified:

**Sidebar (Narrow - 240pt)**:
```
┌──────────────────┐
│  [Profile Pic]   │
│  Your Name       │
│                  │
│  📅 Agenda       │ ← Default, always selected on launch
│  📝 Tasks        │
│  🔗 Integrations │
│  ⚙️  Settings    │
│                  │
│  [+ Quick Add]   │
└──────────────────┘
```

**Detail View (Main)**:
- Full agenda or selected view
- Maximize screen real estate for schedule
- Toolbar with contextual actions

**Benefits**:
- Quick navigation while keeping agenda visible
- Efficient for large screen
- Professional multi-tasking feel

#### **iPhone Layout**
TabView is correct, but even simpler:

**Tab Bar (Bottom - 3-4 tabs max)**:
```
┌─────────────────────────────────────┐
│                                     │
│       Content Area                  │
│                                     │
│                                     │
│    [Agenda] [Tasks] [More]          │
└─────────────────────────────────────┘
```

**Rationale**:
- "Agenda" is home - most used
- "Tasks" for managing task library
- "More" contains Integrations + Settings
- Simple = fast navigation

**Badge System**:
- Agenda tab: Show count of remaining tasks today
- Tasks tab: Show count of unscheduled tasks

### 5.3 Navigation Flow Patterns

#### **Primary Flow: Daily Use**
```
Launch App → Agenda (Today) → See Current Task → Tap "Done" → Next Task Appears
```
This should take 2 seconds maximum.

#### **Secondary Flow: Adding Task**
```
Agenda → Quick Add Button → Enter Task → (Optional: Set Deadline) → Save → AI Re-plans
```

#### **Setup Flow: First Launch**
```
Welcome → Create Account → Set Work Hours → Connect Calendar → (Optional: Add Integrations) → AI Generates First Schedule → Done!
```

---

## 6. The AI Planning Algorithm (Conceptual)

This is the "secret sauce" of GetDone. Here's how it should work:

### 6.1 Input Collection

**Fixed Events** (highest priority, cannot be moved):
- Calendar meetings
- Classes/lectures
- Appointments
- Commute blocks

**Tasks** (flexible, AI decides when):
- User-created tasks
- Integration-imported tasks (Magister homework, etc.)
- Recurring tasks
- Each has:
  - Title
  - Deadline (optional)
  - Estimated duration (user-set or AI-learned)
  - Priority (high/medium/low or AI-inferred)
  - Category (work, personal, study, etc.)
  - Dependencies (optional: "Can't start B until A is done")

**User Preferences**:
- Work hours (e.g., 9 AM - 5 PM on weekdays)
- Break preferences (e.g., 15 min every 2 hours)
- Focus time blocks (e.g., "Deep work best 10 AM - 12 PM")
- Energy curve (morning person vs. night owl)

### 6.2 Planning Algorithm

```python
# Pseudocode for AI Planning Engine

def plan_day(date, tasks, fixed_events, user_prefs):
    schedule = []
    
    # Step 1: Block out fixed events
    for event in fixed_events:
        schedule.add_block(event.start_time, event.end_time, event.title, fixed=True)
    
    # Step 2: Add buffer time around fixed events
    for event in fixed_events:
        if event.requires_prep:
            schedule.add_block(event.start_time - 15min, event.start_time, "Prep for " + event.title)
        if event.requires_commute:
            schedule.add_block(event.end_time, event.end_time + commute_duration, "Commute/Transition")
    
    # Step 3: Sort tasks by priority
    priority_order = sort_tasks_by_urgency_and_importance(tasks, date)
    
    # Step 4: Assign tasks to available time slots
    available_slots = find_free_blocks(schedule, user_prefs.work_hours)
    
    for task in priority_order:
        # Find best time slot for this task
        best_slot = None
        
        # Prioritize focus work during peak energy hours
        if task.requires_focus and user_prefs.peak_hours:
            best_slot = find_slot_during(available_slots, user_prefs.peak_hours, task.duration)
        
        # Otherwise find any suitable slot
        if not best_slot:
            best_slot = find_first_available_slot(available_slots, task.duration)
        
        # If no slot today, defer to tomorrow
        if not best_slot:
            defer_task(task, date + 1)
            continue
        
        # Schedule the task
        schedule.add_block(best_slot.start, best_slot.start + task.duration, task.title)
        available_slots.remove(best_slot)
        
        # Add break after long tasks
        if task.duration > 90_minutes:
            schedule.add_block(best_slot.start + task.duration, best_slot.start + task.duration + 15min, "Break")
    
    # Step 5: Add buffer time and breaks
    schedule = insert_micro_breaks(schedule, every=2_hours, duration=15_minutes)
    
    return schedule
```

### 6.3 Machine Learning Component (Future)

Over time, the AI should learn:
- How long tasks *actually* take you (vs. your estimates)
- Your productivity patterns (when you work fastest)
- Task completion rates (which tasks you procrastinate on)
- Optimal break timing for you personally

This data feeds back into the planning algorithm to create increasingly accurate schedules.

---

## 7. Current Implementation Assessment

### 7.1 What Needs to Change

Given the corrected vision, here's what needs to happen:

#### **Major Pivot Required**

1. **Agenda View Redesign**
   - Current: Shows weekly calendar with manual plans
   - Needed: Time-blocked daily schedule generated by AI
   - Add: Current task highlighting, progress tracking

2. **AI Planning Engine** ⚠️ **MISSING - HIGHEST PRIORITY**
   - This is the core differentiator
   - Must be built from scratch
   - Consider:
     - Local AI (Core ML model) for privacy
     - Cloud AI (OpenAI, Anthropic) for power
     - Hybrid approach (local for simple, cloud for complex)

3. **Task Management System**
   - Current: MagisterItems are school-specific
   - Needed: Generic Task model usable by anyone
   - Must support: deadline, duration, priority, category, dependencies

4. **Integration Architecture**
   - Current: Magister + Google are hardcoded
   - Needed: Modular plugin system
   - Each integration is optional (toggle on/off in settings)

5. **Remove Student-Specific Branding**
   - Current: Entire app feels like a school tool
   - Needed: Universal productivity app that *includes* student features
   - Dutch text is fine (localization can come later)

#### **High Priority Changes**

6. **Data Model Refactor**
   - Create universal `Task` model
   - Separate `Integration` protocol
   - MagisterItem becomes an Integration implementation
   - Add `ScheduledBlock` model for AI-generated agenda

7. **Profile View**
   - Add "Planning Preferences" section
   - Work hours configuration
   - Focus time preferences
   - Integration toggles

8. **Notification System**
   - "Next task starts in 5 minutes"
   - "You're behind schedule - want to reschedule?"
   - Daily plan ready notification

#### **Medium Priority**

9. **Onboarding Flow**
   - Welcome screen explaining the AI planning concept
   - Work hours setup
   - Calendar connection
   - Optional integration setup

10. **Task Entry UX**
    - Quick add should be super fast
    - Smart parsing: "Call dentist tomorrow 2pm" → extracts time
    - Deadline picker
    - Duration picker (with smart suggestions)

11. **Chat/Bronnen Removal or Repurpose**
    - Current Chat tab is unclear - remove or make it the AI assistant
    - Bronnen (Resources) is student-specific - make it generic "Files" or remove

### 7.2 What to Keep ✅

1. **NavigationSplitView + TabView architecture** - works great
2. **Dark mode glassmorphism design** - beautiful, keep it
3. **Color coding system** - perfect for categories
4. **Profile card in sidebar** - nice personal touch
5. **Google OAuth flow** - functional, keep it
6. **Keychain storage** - secure, keep it

---

## 8. Recommended Roadmap

### Phase 1: MVP - Core Planning Experience (4-6 weeks)

**Goal**: Ship a working AI day planner for personal use

- [ ] **Refactor Data Models**
  - Create universal `Task` model
  - Add `ScheduledBlock` model
  - SwiftData persistence

- [ ] **Build AI Planning Engine**
  - Basic algorithm (no ML yet)
  - Input: tasks + calendar events
  - Output: time-blocked schedule
  - Handle task prioritization

- [ ] **Redesign Agenda View**
  - Time-blocked schedule UI
  - Current task highlighting
  - Mark done interaction
  - Manual reschedule

- [ ] **Calendar Integration**
  - Import iOS Calendar events
  - Mark as fixed blocks in schedule

- [ ] **Task Management**
  - Quick add task flow
  - Task list view (unscheduled tasks)
  - Edit/delete tasks
  - Duration and deadline pickers

- [ ] **Basic Settings**
  - Work hours configuration
  - Planning preferences

- [ ] **Onboarding**
  - First-launch setup flow
  - Work hours setup
  - Generate first schedule

**Success Criteria**: You can add tasks, AI plans your day, you follow the schedule

---

### Phase 2: Intelligence & Polish (3-4 weeks)

**Goal**: Make the AI smarter and UX delightful

- [ ] **Enhanced AI Planning**
  - Learn from actual task duration
  - Detect productivity patterns
  - Auto-reschedule missed tasks
  - Workload balancing (don't overbook)

- [ ] **Notifications**
  - Task start reminders
  - Behind schedule alerts
  - Daily plan ready notification
  - Configurable quiet hours

- [ ] **Improved Agenda UX**
  - Progress bar for current task
  - Time remaining live updates
  - Swipe gestures
  - Haptic feedback

- [ ] **Focus Mode**
  - Show only current task
  - Timer integration
  - Do Not Disturb trigger

- [ ] **Multi-Day View**
  - Tomorrow preview
  - Weekly workload overview

---

### Phase 3: Integrations (2-3 weeks per integration)

**Goal**: Add modular connectors for different user types

- [ ] **Integration Framework**
  - Plugin architecture
  - Toggle on/off per integration
  - Settings UI per integration

- [ ] **Student Mode** (For you personally)
  - Magister connector (migrate existing code)
  - Google Classroom connector
  - Auto-import assignments as tasks

- [ ] **Work Mode** (Future)
  - Email action item extraction
  - Calendar sync (already have this)
  - Slack message parsing

- [ ] **Family Mode** (Future)
  - Shared family calendar
  - Task delegation

---

### Phase 4: AI Assistant (4-6 weeks)

**Goal**: Natural language interface

- [ ] **Chat Interface**
  - Repurpose existing ChatView
  - Connect to AI backend (OpenAI, Claude, local)

- [ ] **Natural Language Task Entry**
  - "Remind me to call John tomorrow at 2"
  - "I need to finish the report by Friday, will take 4 hours"

- [ ] **Planning Consultation**
  - "When should I work on the presentation?"
  - "This is too much for today, what should I defer?"

- [ ] **Smart Suggestions**
  - "You have 3 hours of focus work but only scheduled 1 hour"
  - "You usually work out Tuesday mornings, add it?"

---

### Phase 5: Advanced Features (Ongoing)

- [ ] Analytics dashboard
- [ ] Collaboration/sharing
- [ ] Widgets (home screen, lock screen)
- [ ] Apple Watch app
- [ ] Siri shortcuts
- [ ] Machine learning for duration prediction

---

## 9. Success Metrics

### Core Metrics
- **Planning Accuracy**: 80%+ of tasks fit in realistic schedule
- **Completion Rate**: 70%+ of planned tasks get done
- **Time to Schedule**: AI generates plan in < 3 seconds
- **User Retention**: 60% daily active users (DAU)

### User Experience
- **App Launch to Agenda**: < 1 second
- **Add Task Flow**: < 10 seconds
- **Perceived AI Quality**: Users feel it "understands" their needs

### Technical
- **Sync Reliability**: 99%+ successful data syncs
- **Battery Impact**: < 5% battery drain per day
- **Crash Rate**: < 0.5% sessions

---

## 10. Conclusion: The GetDone Vision (Corrected)

**GetDone is an AI-powered day planner that eliminates decision fatigue.**

Instead of staring at a to-do list wondering "What should I do next?", GetDone users wake up to a perfectly planned day. The AI has already decided:
- What to work on
- When to work on it
- How long to spend
- When to take breaks

**It's for everyone:**
- **Students**: AI plans study time around classes (Magister/Classroom integrated)
- **Professionals**: AI plans work tasks around meetings (Email/Calendar integrated)
- **Parents**: AI plans errands around kids' schedules (Family calendar integrated)
- **Anyone**: AI plans personal tasks around life (Manual task entry)

**The UX is stupidly simple:**
1. Add your tasks (or connect integrations that do it automatically)
2. AI plans your day every night
3. Wake up, open app, do what it says

**It succeeds where other productivity apps fail:**
- ❌ Todoist: Shows tasks but doesn't tell you when to do them
- ❌ Calendar apps: Shows events but not actionable tasks
- ❌ Notion: Powerful but requires manual organization
- ✅ GetDone: Automatically creates an executable daily schedule

**The design philosophy:**
- Calm (reduces anxiety)
- Confident (AI has it figured out)
- Minimal (only show what matters now)
- Fast (2 seconds to see today's plan)

**The tagline:**
> "Don't think. Just Get Done."

---

**Next Steps**:
1. ✅ Correct the vision (done with this document)
2. 🎯 Prototype the AI planning algorithm
3. 🎨 Design new Agenda view mockup
4. 💻 Refactor data models
5. 🚀 Build MVP

