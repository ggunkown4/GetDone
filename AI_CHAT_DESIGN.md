# AI Chat Interface Design - GetDone Command Center
**Date**: September 30, 2026  
**Vision**: Chat-driven control interface - like Codex/Claude for the app

---

## Core Concept: Chat as Primary Interface

### The Vision

Instead of traditional UI navigation, users interact with GetDone through **conversational AI**:

```
User: "What do I need to do today?"
AI: "You have 5 tasks scheduled. Currently: UI research (30 min left). 
     Next: Lunch at 12:00. Want to see the full schedule?"

User: "Add task to call dentist tomorrow at 2pm"
AI: "✓ Added 'Call dentist' tomorrow at 14:00 (30 min duration). 
     Should I send you a reminder 10 minutes before?"

User: "I'm tired, can we reschedule the math homework?"
AI: "I can move 'Math homework' (2.5 hours) to tomorrow morning 
     at 9:00 when you're usually most focused. Reschedule?"

User: "Yes"
AI: "✓ Done. Your afternoon is now lighter - you'll finish by 5pm instead of 7pm."
```

### Why This Approach?

**Traditional apps**: Navigate → Find feature → Fill form → Submit  
**GetDone with AI**: Type what you want → Done

**Benefits**:
1. **Zero learning curve**: Everyone knows how to chat
2. **Natural language**: No need to learn UI locations
3. **Context-aware**: AI knows your schedule, patterns, preferences
4. **Proactive**: AI suggests improvements before you ask
5. **Conversational planning**: Negotiate schedule changes naturally
6. **Multi-modal**: Voice input, quick replies, rich cards

---

## Architecture: Chat + Visual Hybrid

### Not Pure Chat

GetDone is **NOT** ChatGPT with tasks. It's a **hybrid**:

1. **Visual Agenda** = Primary view (see your day at a glance)
2. **AI Chat** = Control layer (modify, ask questions, get insights)

```
┌─────────────────────────────────────────┐
│ Visual Layer (Agenda View)              │
│ - See time-blocked schedule             │
│ - Tap to mark done                      │
│ - Swipe to reschedule                   │
│ - Glanceable overview                   │
└─────────────────────────────────────────┘
                  ↕︎
┌─────────────────────────────────────────┐
│ Conversational Layer (AI Chat)          │
│ - Add tasks via natural language        │
│ - Ask questions about schedule          │
│ - Request changes/optimization          │
│ - Get insights and suggestions          │
└─────────────────────────────────────────┘
```

### Why Hybrid?

- **Visual** = Fast scanning ("What's next?")
- **Chat** = Complex operations ("Move all my meetings to afternoon")
- **Visual** = Confirmatory ("Did it work?")
- **Chat** = Exploratory ("What if I skip this task?")

---

## Navigation: Chat-First Architecture

### Option 1: Chat as Center Tab (Recommended)

```
iPhone Bottom Tabs (3):
├── 📅 Agenda (Visual schedule)
├── 💬 Chat (AI control center) ← DEFAULT
└── ⚙️ More (Settings)
```

**Rationale**: Chat is the "command center" - you talk to GetDone here, and it updates the Agenda. Most interactions start with chat.

### Option 2: Chat as Overlay (Alternative)

```
iPhone:
- Main: Agenda view (default)
- FAB (bottom-right): Opens chat overlay
- Chat slides up as modal sheet
- Dismiss to return to Agenda
```

**Rationale**: Chat is "always accessible" but doesn't take up tab space. Like Siri, but better.

### Option 3: Split View (iPad Only)

```
iPad Layout:
├── Sidebar (navigation)
├── Main: Agenda view
└── Right Panel: Chat (always visible, 320pt)
```

**Rationale**: On large screens, have both visual and chat simultaneously. Desktop-class experience.

### Recommendation: **Option 1 + Option 3**

- **iPhone**: Chat as center tab (most interactions start here)
- **iPad**: Split view (chat + agenda simultaneously)
- **Both**: FAB on Agenda view for quick access to chat

---

## Chat Interface Design

### Layout (iPhone)

```
┌─────────────────────────────────────────┐
│ GetDone AI                    [···][×] │ ← Header
├─────────────────────────────────────────┤
│                                         │
│  [AI] What can I help you with?        │
│      ┌─────────────────────────────┐   │
│      │ Show today's schedule       │   │ ← Quick
│      │ Add a task                  │   │   actions
│      │ Optimize my day             │   │
│      └─────────────────────────────┘   │
│                                         │
│  [User] Add task to call dentist       │
│         tomorrow at 2pm                 │
│                                         │
│  [AI] ✓ Added "Call dentist"           │
│      Tomorrow (Oct 1) at 14:00         │
│      Duration: 30 minutes               │
│      ┌─────────────────────────────┐   │
│      │ 📅 14:00 - 14:30            │   │ ← Rich
│      │ ☎️ Call dentist             │   │   card
│      │ Personal                     │   │
│      │ [View in Agenda →]          │   │
│      └─────────────────────────────┘   │
│      Set a reminder? [Yes] [No]        │ ← Quick
│                                         │   reply
│  [User] Yes                             │
│                                         │
│  [AI] ✓ I'll remind you at 13:50       │
│                                         │
│                                         │
│                        [Typing...] ↑   │ ← Input
└─────────────────────────────────────────┘
    [🎤]              [Send]              ← Actions
```

### Key Components

#### 1. **Message Types**

**User Messages**:
- Text input
- Voice transcription
- Quick reply buttons

**AI Messages**:
- Text responses
- Rich cards (tasks, schedules)
- Quick action buttons
- Suggestions

#### 2. **Rich Cards**

When AI talks about tasks/schedules, show visual cards:

```swift
struct TaskCard: View {
    var task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: task.category.icon)
                    .foregroundColor(task.category.color)
            }
            
            Text(task.title)
                .font(.headline)
            
            if let notes = task.notes {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button("View in Agenda →") {
                // Navigate to Agenda and highlight this task
            }
            .font(.caption)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}
```

#### 3. **Quick Reply Buttons**

AI suggests common responses as tappable buttons:

```
AI: "Should I send you a reminder?"
    [Yes] [No] [10 min before] [Custom]
```

#### 4. **Typing Indicator**

Show when AI is "thinking":
```
[AI] ● ● ● (animated dots)
```

#### 5. **Voice Input**

Microphone button for voice input (like iPhone Messages):
- Tap to start recording
- Waveform animation while recording
- Automatic transcription
- Send or cancel

---

## AI Capabilities: What Can It Do?

### 1. Task Management

**Add Tasks**:
```
User: "Add task to write report by Friday"
User: "Remind me to call John tomorrow afternoon"
User: "I need to study for 3 hours this week"
```

**Modify Tasks**:
```
User: "Change the dentist appointment to 3pm"
User: "Make the report deadline next Monday"
User: "Mark math homework as done"
```

**Delete Tasks**:
```
User: "Cancel the gym session"
User: "Remove all shopping tasks"
```

### 2. Schedule Queries

**What's happening**:
```
User: "What's next?"
User: "What do I have tomorrow?"
User: "Show me next week's schedule"
User: "Do I have any meetings today?"
```

**Time availability**:
```
User: "When am I free this afternoon?"
User: "Can I fit a 2-hour task today?"
User: "What's my longest free block tomorrow?"
```

### 3. Planning & Optimization

**Reschedule**:
```
User: "I'm too tired for this, move it to tomorrow"
User: "Reschedule everything after 6pm to tomorrow"
User: "Swap the gym and study sessions"
```

**Optimize**:
```
User: "My day is too packed, what can I defer?"
User: "Plan my day better"
User: "When's the best time to work on the report?"
```

**Forecast**:
```
User: "Will I finish on time today?"
User: "Am I falling behind?"
User: "How many tasks do I usually complete?"
```

### 4. Insights & Analytics

**Patterns**:
```
User: "When am I most productive?"
User: "How long do I usually spend on homework?"
User: "What day of the week am I least productive?"
```

**Progress**:
```
User: "How many tasks did I complete this week?"
User: "Show my productivity trends"
User: "Am I improving?"
```

### 5. Integration Control

**Connect services**:
```
User: "Connect my Google Calendar"
User: "Import my Magister assignments"
User: "Show me classroom tasks"
```

**Manage integrations**:
```
User: "Stop syncing Magister"
User: "Refresh calendar events"
User: "What integrations are active?"
```

### 6. Settings & Preferences

**Configure**:
```
User: "Set my work hours to 9am-5pm"
User: "I prefer breaks every 2 hours"
User: "Don't schedule anything before 8am"
```

**Notifications**:
```
User: "Turn off reminder notifications"
User: "Remind me 15 minutes before tasks"
User: "Only notify for high priority tasks"
```

---

## AI Personality & Tone

### Principles

1. **Helpful, not chatty**: Get to the point
2. **Confident, not pushy**: Suggest, don't command
3. **Understanding, not judgmental**: Support, don't criticize
4. **Efficient, not robotic**: Warm but concise

### Examples

**✅ Good**:
```
AI: "You have 3 tasks left today. Math homework (2h) is the biggest. 
     Start now? You'll finish by 6pm."
```

**❌ Too chatty**:
```
AI: "Hey there! I hope you're having a great day! So I was looking at 
     your schedule and I noticed you have some tasks remaining..."
```

**✅ Good**:
```
AI: "✓ Rescheduled to tomorrow morning. Your evening is now free."
```

**❌ Too robotic**:
```
AI: "Task has been moved to 2026-10-01 09:00:00 UTC. Operation successful."
```

**✅ Good (when user is behind)**:
```
AI: "You're running 30 min behind. Want me to adjust the rest of your day?"
```

**❌ Judgmental**:
```
AI: "You're late again. You need to manage your time better."
```

### Emotional Intelligence

AI should recognize context:

**When user is overwhelmed**:
```
User: "I can't do all of this today"
AI: "I understand. Let's defer 2 tasks to tomorrow. That'll cut your 
     workload to 4 hours - much more manageable. Sound good?"
```

**When user is behind schedule**:
```
AI: "Running late isn't the end of the world. Let's reschedule the 
     afternoon to give you breathing room."
```

**When user accomplishes a lot**:
```
AI: "🎉 7 tasks done today - that's your best week yet! Tomorrow 
     looks lighter (4 tasks)."
```

---

## Technical Architecture

### AI Backend Options

#### Option 1: Cloud AI (Recommended for MVP)

**OpenAI GPT-4o** or **Anthropic Claude**:
- API-based
- Powerful reasoning
- Natural language understanding
- Context-aware responses

**Pros**:
✅ Sophisticated understanding  
✅ Fast development  
✅ Handles complex queries  
✅ Regular improvements  

**Cons**:
❌ Requires internet  
❌ API costs  
❌ Privacy considerations  
❌ Latency (1-2 seconds)  

**Implementation**:
```swift
class AIManager: ObservableObject {
    @Published var messages: [Message] = []
    private let apiKey = "..." // Secure storage
    
    func send(_ userMessage: String) async {
        // Add user message to chat
        messages.append(Message(text: userMessage, isUser: true))
        
        // Build context
        let context = buildContext()
        
        // Call API
        let response = await callOpenAI(
            message: userMessage,
            context: context,
            functions: availableFunctions // Tool calling
        )
        
        // Parse response
        if let action = response.functionCall {
            // Execute action (add task, reschedule, etc.)
            await executeAction(action)
        }
        
        // Add AI response
        messages.append(Message(text: response.text, isUser: false))
    }
    
    func buildContext() -> String {
        """
        Current time: \(Date.now)
        Today's schedule: \(todaysTasks.summary)
        User preferences: \(userPreferences.summary)
        Recent patterns: \(analytics.summary)
        """
    }
}
```

#### Option 2: On-Device AI (Future)

**Apple Intelligence (iOS 18+)** or **Core ML**:
- Local processing
- Private by design
- No internet required
- Instant responses

**Pros**:
✅ Privacy (data never leaves device)  
✅ Fast (< 100ms)  
✅ No API costs  
✅ Works offline  

**Cons**:
❌ Limited reasoning (smaller models)  
❌ Requires iOS 18+  
❌ Complex setup  
❌ May not handle complex queries  

#### Option 3: Hybrid (Best Long-Term)

- Simple queries → On-device (fast, private)
- Complex queries → Cloud (powerful)
- User choice in settings

### Function Calling (Tool Use)

AI needs to execute actions, not just chat. Use **function calling**:

```typescript
// Available functions AI can call
const functions = [
  {
    name: "add_task",
    description: "Add a new task to the schedule",
    parameters: {
      title: "string",
      deadline: "ISO date (optional)",
      duration: "minutes (optional)",
      category: "work|personal|school|health",
      priority: "low|medium|high"
    }
  },
  {
    name: "reschedule_task",
    description: "Move a task to a different time",
    parameters: {
      task_id: "string",
      new_time: "ISO datetime"
    }
  },
  {
    name: "complete_task",
    description: "Mark a task as done",
    parameters: {
      task_id: "string"
    }
  },
  {
    name: "get_schedule",
    description: "Retrieve schedule for a date range",
    parameters: {
      start_date: "ISO date",
      end_date: "ISO date"
    }
  },
  {
    name: "optimize_schedule",
    description: "Re-plan the day for better efficiency",
    parameters: {
      date: "ISO date"
    }
  },
  {
    name: "get_analytics",
    description: "Get productivity insights",
    parameters: {
      metric: "completion_rate|time_distribution|patterns",
      period: "day|week|month"
    }
  }
]
```

**Flow**:
1. User: "Add task to call dentist tomorrow at 2pm"
2. AI decides to call `add_task` function
3. AI extracts parameters:
   ```json
   {
     "title": "Call dentist",
     "deadline": "2026-10-01T14:00:00Z",
     "duration": 30,
     "category": "personal"
   }
   ```
4. App executes function
5. AI responds: "✓ Added 'Call dentist' tomorrow at 14:00"

### Context Management

AI needs context about the user:

```swift
struct AIContext {
    // Current state
    var currentTime: Date
    var todaysTasks: [Task]
    var tomorrowsTasks: [Task]
    var unscheduledTasks: [Task]
    
    // User preferences
    var workHours: TimeRange
    var breakPreferences: BreakPreferences
    var focusHours: [TimeRange]
    
    // Historical patterns
    var avgCompletionRate: Double
    var productiveHours: [Int] // Hours of day when most productive
    var avgTaskDuration: [String: TimeInterval] // By category
    
    // Recent context (conversation memory)
    var recentMessages: [Message] // Last 10 messages
    var recentActions: [Action] // Last 5 actions
    
    func serialize() -> String {
        // Convert to text prompt for AI
    }
}
```

### Streaming Responses

For better UX, stream AI responses (don't wait for full completion):

```swift
func sendStreaming(_ message: String) async {
    let stream = await openAI.streamResponse(message)
    
    var accumulatedText = ""
    for await chunk in stream {
        accumulatedText += chunk
        
        // Update UI in real-time
        await MainActor.run {
            if messages.last?.isUser == false {
                messages[messages.count - 1].text = accumulatedText
            } else {
                messages.append(Message(text: accumulatedText, isUser: false))
            }
        }
    }
}
```

Users see text appear word-by-word (like ChatGPT). Feels faster and more natural.

---

## Message History & Persistence

### Chat History

Store conversation history for:
1. **Context continuity**: "What did I ask about earlier?"
2. **Learning**: Improve suggestions based on past interactions
3. **Reference**: "What did AI suggest last week?"

**Storage**:
```swift
@Model
class ChatMessage {
    var id: UUID
    var text: String
    var isUser: Bool
    var timestamp: Date
    var attachments: [MessageAttachment]? // Rich cards, etc.
    var functionCalls: [FunctionCall]? // What actions were executed
    
    init(text: String, isUser: Bool) {
        self.id = UUID()
        self.text = text
        self.isUser = isUser
        self.timestamp = Date()
    }
}
```

**Organization** (like ChatGPT):
```
Chat History:
├── Today
│   ├── "Plan my morning"
│   └── "Add dentist appointment"
├── Yesterday
│   └── "Reschedule homework"
└── Last 7 Days
    └── "How productive was I?"
```

### Clearing History

**Privacy option**:
- "Clear chat history" in settings
- "Start new conversation" button
- Auto-delete old conversations (optional)

---

## Voice Integration

### Voice Input

**Tap & Hold to Record** (like WhatsApp):
```
[🎤] ← Press and hold
     ~~~~~~~~~~~ (waveform animation)
     Release to send, swipe up to cancel
```

**Always-Listening Mode** (optional, privacy toggle):
```
"Hey GetDone, add task..."
```

### Voice Output (Future)

AI can speak responses:
- Text-to-speech for hands-free use
- Toggle in settings
- Useful while driving, exercising, etc.

---

## Smart Suggestions & Proactive AI

### Proactive Notifications

AI doesn't just respond - it **initiates** conversations:

**Morning briefing**:
```
[AI] Good morning! You have 6 tasks today (4 hours total).
     Start with the report (2h) while you're fresh?
```

**Mid-day check-in**:
```
[AI] You're ahead of schedule 🎉 Want to tackle tomorrow's 
     homework now while you have momentum?
```

**Evening review**:
```
[AI] 5 out of 6 tasks done today! The math homework (30 min) 
     can wait until tomorrow morning. Good work!
```

**Behind schedule alert**:
```
[AI] Running 1 hour behind. I can reschedule the gym session 
     to tomorrow so you finish the report on time. Should I?
```

### Contextual Suggestions

**In Agenda view**, show AI suggestions as cards:

```
┌─────────────────────────────────────┐
│ ⏰ NU                               │
│ 11:00 - 12:00  UI Research          │
├─────────────────────────────────────┤
│ 💡 AI Suggestion                    │
│ You usually take a break after 2h.  │
│ Add a 15-min break after this task? │
│ [Yes] [No] [Ask AI]                 │
└─────────────────────────────────────┘
```

**Smart defaults**:
When adding a task, AI suggests:
- Duration (based on similar past tasks)
- Best time to do it (based on energy patterns)
- Category (based on keywords)
- Priority (based on deadline urgency)

```
User: "Add task to write blog post"

AI pre-fills:
- Duration: 90 min (you usually take this long for blog posts)
- Best time: Tomorrow 10:00 AM (your most creative hour)
- Category: Work
- Priority: Medium

[Confirm] [Adjust] [Ask AI for better time]
```

---

## UI States & Flows

### Empty State (First Open)

```
┌─────────────────────────────────────┐
│                                     │
│        ✨ GetDone AI ✨            │
│                                     │
│  I'm your AI planning assistant.    │
│  I'll help you manage tasks,        │
│  optimize your schedule, and        │
│  get more done with less stress.    │
│                                     │
│  Try asking:                        │
│  ┌─────────────────────────────┐   │
│  │ What can you do?            │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ Add task to call mom        │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ Plan my day                 │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### Loading State

```
[AI] ● ● ● (animated)
     Thinking...
```

### Error State

```
[AI] ⚠️ Couldn't process that. Try rephrasing or ask:
     "What can you help me with?"
     
     [Retry] [Reset Conversation]
```

### Action Confirmation

```
[AI] ✓ Task added: "Call dentist"
     📅 Tomorrow at 14:00
     
     [View in Agenda] [Undo]
```

---

## Integration with Visual UI

### Bi-Directional Navigation

**From Chat → Agenda**:
```
AI: "Here's your schedule:"
    [Task Card with "View in Agenda →" button]
    
    → Tap button → Navigate to Agenda tab → Scroll to task → Highlight
```

**From Agenda → Chat**:
```
Agenda View:
- Long-press task → Context menu → "Ask AI about this"
- Tap FAB → Chat opens with context: "Tell me about [task name]"
```

### Unified Actions

Same action, multiple entry points:

**Add Task**:
1. Chat: "Add task to..."
2. Agenda: FAB → Quick add form
3. Voice: "Hey GetDone, add task..."
4. Widget: Tap "+" button

All routes update the same data model → Changes reflect everywhere.

### Consistent Feedback

When AI modifies something:
- Update visual UI immediately
- Show confirmation in chat
- Haptic feedback
- Optional undo button

---

## Implementation Roadmap

### Phase 1: Basic Chat (Week 1-2)

- [ ] Chat UI (messages, input, send)
- [ ] OpenAI/Claude integration
- [ ] Basic function calling (add_task, get_schedule)
- [ ] Message history persistence
- [ ] Simple context building

**Deliverable**: Can add tasks and query schedule via chat

### Phase 2: Rich Interactions (Week 3-4)

- [ ] Rich cards (task cards, schedule cards)
- [ ] Quick reply buttons
- [ ] Voice input (speech-to-text)
- [ ] Streaming responses
- [ ] Error handling

**Deliverable**: Polished chat experience with rich media

### Phase 3: Intelligence (Week 5-6)

- [ ] Smart suggestions
- [ ] Proactive notifications
- [ ] Analytics queries
- [ ] Schedule optimization
- [ ] Learning from patterns

**Deliverable**: AI feels smart and helpful

### Phase 4: Advanced Features (Week 7-8)

- [ ] Multi-turn conversations
- [ ] Complex queries (bulk actions)
- [ ] Integration management via chat
- [ ] Settings control via chat
- [ ] Voice output (TTS)

**Deliverable**: Full AI assistant capabilities

### Phase 5: Polish & Optimization (Week 9-10)

- [ ] Reduce latency
- [ ] Improve accuracy
- [ ] Better error messages
- [ ] Accessibility
- [ ] iPad split-view chat

**Deliverable**: Production-ready AI chat

---

## Privacy & Security

### Considerations

1. **Data sent to AI**:
   - Task titles, descriptions, deadlines
   - Schedule information
   - User preferences
   - Conversation history

2. **Privacy options**:
   - Local AI mode (on-device only)
   - Don't send sensitive task details
   - Clear history option
   - Anonymous usage

3. **Transparency**:
   - Settings page explaining what data is sent
   - Toggle: "Use cloud AI" vs "Local only"
   - API usage dashboard

---

## Success Metrics

### Engagement

- **Chat usage**: % of users who send >= 1 message/day
- **Message frequency**: Avg messages per session
- **Feature discovery**: % of users who discover features via chat vs UI

### Effectiveness

- **Task completion**: Do AI-scheduled tasks get done more often?
- **User satisfaction**: NPS score for AI interactions
- **Time saved**: Avg time to complete actions (chat vs traditional UI)

### AI Quality

- **Function calling accuracy**: % of queries that trigger correct function
- **Response relevance**: User thumbs up/down rating
- **Error rate**: % of "I don't understand" responses

---

## Conclusion

**GetDone's AI chat is not a gimmick - it's the primary interface.**

Users should feel like they have a **personal planning assistant** who:
- Understands their schedule and habits
- Suggests improvements proactively
- Executes actions instantly
- Learns and adapts over time

**The goal**: Users prefer typing "Add task..." to clicking through a form.

**The test**: Can a new user accomplish everything without touching the visual UI? (Yes, but the visual UI makes it better.)

---

**Next Steps**:
1. Choose AI backend (OpenAI GPT-4o recommended for MVP)
2. Design chat UI in SwiftUI
3. Implement function calling
4. Build context management
5. Test with real usage scenarios
6. Iterate based on feedback

