import SwiftUI

// MARK: - Smart Popover Modifier (Dynamic Position Logic)
struct AdaptivePopoverModifier<PopoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder let popoverContent: () -> PopoverContent
    
    @State private var arrowEdge: Edge = .top
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            updatePosition(proxy: proxy)
                        }
                        .onChange(of: proxy.frame(in: .global).minY) { _ in
                            updatePosition(proxy: proxy)
                        }
                }
            )
            .popover(isPresented: $isPresented, arrowEdge: arrowEdge) {
                popoverContent()
            }
    }
    
    private func updatePosition(proxy: GeometryProxy) {
        let frame = proxy.frame(in: .global)
        let screenHeight = UIScreen.screens.first?.bounds.height ?? 800
        
        if frame.midY > (screenHeight * 0.55) {
            arrowEdge = .bottom
        } else {
            arrowEdge = .top
        }
    }
}

extension View {
    func smartPopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(AdaptivePopoverModifier(isPresented: isPresented, popoverContent: content))
    }
}

// MARK: - PROFILE LOGIC & MAIN SCREEN

struct ProfileView: View {
    @ObservedObject var auth: WebGoogleAuthManager
    
    // MARK: - State for Confirmation Popup
    @State private var showLogoutConfirmation: Bool = false
    
    // MARK: - Persistent Settings (Are automatically saved)
    @AppStorage("aiShow") private var aiShow: String = "Motiverend"
    @AppStorage("productivityType") private var productivityType: String = "MorningMotivation"
    @AppStorage("bufferTijdMinuten") private var bufferMinutes: Int = 15
    @AppStorage("isMagisterLoggedIn") private var isMagisterLoggedIn: Bool = false
    @AppStorage("magister_voornaam") private var magisterFirstName: String = ""
    @AppStorage("magister_achternaam") private var magisterLastName: String = ""
    
    private var magisterFullName: String {
        let naam = "\(magisterFirstName) \(magisterLastName)".trimmingCharacters(in: .whitespaces)
        return naam.isEmpty ? "Magister User" : naam
    }
    
    // MARK: - Helper for Clean & Safe Photo URL
    private var userPhotoURL: URL? {
        guard auth.isLoggedIn, !auth.userPicture.isEmpty else { return nil }
        var urlString = auth.userPicture.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlString.hasPrefix("http://") {
            urlString = urlString.replacingOccurrences(of: "http://", with: "https://")
        }
        return URL(string: urlString)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Header (Profile Photo & User Info / Login)
                    profileHeader
                    
                    // MARK: - Section 1: Settings & Preferences per Tab
                    SettingsCard(title: "SETTINGS & PREFERENCES") {
                        VStack(spacing: 0) {
                            
                            NavigationLink(destination: AgendaSettingsView()) {
                                MenuRowView(
                                    icon: "calendar.badge.clock",
                                    color: .blue,
                                    title: "Agenda",
                                    subtekst: "\(bufferMinutes) min buffer • \(productivityType)"
                                )
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                            
                            NavigationLink(destination: ChatSettingsView()) {
                                MenuRowView(
                                    icon: "bubble.left.and.bubble.right.fill",
                                    color: .purple,
                                    title: "Chat",
                                    subtekst: "AI Tone: \(aiShow)"
                                )
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                            
                            NavigationLink(destination: ResourcesSettingsView()) {
                                MenuRowView(
                                    icon: "folder.fill",
                                    color: .orange,
                                    title: "Resources",
                                    subtekst: "Drive & Magister sync"
                                )
                            }
                        }
                    }
                    
                    // MARK: - Section 2: Linked Accounts
                    SettingsCard(title: "LINKED ACCOUNTS") {
                        VStack(spacing: 0) {
                            
                            // Google Submenu Knop
                            NavigationLink(destination: GoogleAccountDetailView(auth: auth)) {
                                MenuRowView(
                                    icon: "g.circle.fill",
                                    color: .red,
                                    title: "Google"
                                ) {
                                    if auth.isLoggedIn {
                                        HStack(spacing: 6) {
                                            if let photoUrl = userPhotoURL {
                                                AsyncImage(url: photoUrl) { phase in
                                                    switch phase {
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                    default:
                                                        Image(systemName: "person.crop.circle.fill")
                                                            .resizable()
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                                .frame(width: 22, height: 22)
                                                .clipShape(Circle())
                                            } else {
                                                Image(systemName: "person.crop.circle.fill")
                                                    .resizable()
                                                    .frame(width: 22, height: 22)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Text(auth.userEmail)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                            
                            // Magister Submenu Knop
                            NavigationLink(destination: MagisterDetailView()) {
                                MenuRowView(
                                    icon: "graduationcap.fill",
                                    color: .orange,
                                    title: "Magister"
                                ) {
                                    if isMagisterLoggedIn {
                                        Text(magisterFullName)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: - Section 3: Diagnostics
                    SettingsCard(title: "DIAGNOSTICS") {
                        VStack(spacing: 0) {
                            NavigationLink(destination: DiagnostiekStatusView(auth: auth)) {
                                MenuRowView(
                                    icon: "waveform.path.ecg",
                                    color: .green,
                                    title: "Status",
                                    subtekst: "System & Connections"
                                )
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                            
                            NavigationLink(destination: DiagnosticsLogView()) {
                                MenuRowView(
                                    icon: "doc.text.fill",
                                    color: .gray,
                                    title: "Log",
                                    subtekst: "Console & Events"
                                )
                            }
                        }
                    }
                    
                    // MARK: - Section 4: Logout Button with Smart Popover
                    if auth.isLoggedIn {
                        Button(role: .destructive, action: {
                            showLogoutConfirmation = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Log Out")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                        }
                        .padding(.top, 8)
                        .smartPopover(isPresented: $showLogoutConfirmation) {
                            VStack(spacing: 16) {
                                VStack(spacing: 6) {
                                    Text("Are you sure?")
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("You will need to log in again to access your accounts and data.")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                VStack(spacing: 8) {
                                    Button(role: .destructive) {
                                        showLogoutConfirmation = false
                                        auth.logout()
                                    } label: {
                                        Text("Log Out")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(Color.red.opacity(0.15))
                                            .foregroundColor(.red)
                                            .cornerRadius(8)
                                    }
                                    
                                    Button(role: .cancel) {
                                        showLogoutConfirmation = false
                                    } label: {
                                        Text("Cancel")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .frame(width: 280)
                            .fixedSize(horizontal: false, vertical: true)
                            .presentationCompactAdaptation(.popover)
                        }
                    }
                    
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
        }
    }
    
    // MARK: - Header Subview
    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                if let photoUrl = userPhotoURL {
                    AsyncImage(url: photoUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        @unknown default:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                    }
                    .id(photoUrl.absoluteString)
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(spacing: 6) {
                Text(auth.isLoggedIn && !auth.userName.isEmpty ? auth.userName : "Log in")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                if auth.isLoggedIn && !auth.userEmail.isEmpty {
                    Text(auth.userEmail)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    VStack(spacing: 12) {
                        Text("Link your accounts to get started")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button(action: { auth.startGoogleLogin() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "g.circle.fill")
                                Text("Log in with Google")
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.orange)
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - SUBMENUS PER TAB

struct AgendaSettingsView: View {
    @AppStorage("productivityType") private var productivityType: String = "MorningMotivation"
    @AppStorage("dynamischHerplannen") private var dynamicReplanning: Bool = true
    @AppStorage("maxStudieUur") private var maxStudyHours: Double = 4.0
    @AppStorage("bufferTijdMinuten") private var bufferMinutes: Int = 15
    @AppStorage("inclusiefWeekend") private var includeWeekend: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Smart Planning").foregroundColor(.orange)) {
                Picker("Productivity Rhythm", selection: $productivityType) {
                    Text("MorningMotivation").tag("MorningMotivation")
                    Text("Afternoon Person").tag("Middagmens")
                    Text("Evening Person").tag("Avondmens")
                }
                
                Toggle("Dynamic Replanning", isOn: $dynamicReplanning)
                Toggle("Use weekend for study", isOn: $includeWeekend)
            }
            
            Section(header: Text("Times & Limits").foregroundColor(.orange)) {
                Stepper("Buffer between appointments: \(bufferMinutes) min", value: $bufferMinutes, in: 0...60, step: 5)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Max. study time per day")
                        Spacer()
                        Text("\(Int(maxStudyHours)) hrs").bold().foregroundColor(.orange)
                    }
                    Slider(value: $maxStudyHours, in: 1...8, step: 0.5)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Agenda Settings")
    }
}

struct ChatSettingsView: View {
    @AppStorage("aiShow") private var aiShow: String = "Motiverend"
    @AppStorage("ochtendBriefing") private var morningBriefing: Bool = true
    @AppStorage("avondEvaluatie") private var eveningEvaluation: Bool = true
    @AppStorage("aiServerURL") private var aiServerURL: String = ""
    @AppStorage("aiServerToken") private var aiServerToken: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("AI Persona").foregroundColor(.orange)) {
                Picker("AI Tone & Style", selection: $aiShow) {
                    Text("Motivating").tag("Motiverend")
                    Text("Direct & Business").tag("Direct & Zakelijk")
                    Text("Relaxed").tag("Relaxed")
                }
            }
            
            Section(header: Text("Local AI Server").foregroundColor(.orange)) {
                TextField("https://your-server.com", text: $aiServerURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                
                SecureField("API token", text: $aiServerToken)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            
            Section(header: Text("Automatic Messages").foregroundColor(.orange)) {
                Toggle("Receive Morning Briefing", isOn: $morningBriefing)
                Toggle("Receive Evening Evaluation", isOn: $eveningEvaluation)
            }
            
            Section(header: Text("Memory").foregroundColor(.orange)) {
                Button("Clear AI Chat History", role: .destructive) {
                }
            }
        }
        .navigationTitle("Chat Settings")
    }
}

struct ResourcesSettingsView: View {
    @AppStorage("syncDrive") private var syncDrive: Bool = true
    @AppStorage("syncClassroom") private var syncClassroom: Bool = true
    @AppStorage("compacteBronweergave") private var compactSourceView: Bool = false
    @AppStorage("resourcesOrder") private var resourcesOrderRaw: String = "drive,classroom"
    
    @State private var resourcesOrder: [String] = ["drive", "classroom"]
    
    var body: some View {
        Form {
            Section(header: Text("Order on Main Screen").foregroundColor(.orange)) {
                ForEach(Array(resourcesOrder.enumerated()), id: \.element) { index, bronKey in
                    HStack(spacing: 12) {
                        Image(systemName: bronKey == "drive" ? "folder.fill" : "graduationcap.fill")
                            .foregroundColor(bronKey == "drive" ? .blue : .orange)
                        
                        Text(bronKey == "drive" ? "Google Drive" : "Google Classroom")
                        
                        Spacer()
                        
                        // Arrow Up
                        Button(action: { moveUp(index: index) }) {
                            Image(systemName: "arrow.up")
                                .foregroundColor(index == 0 ? .gray.opacity(0.3) : .orange)
                        }
                        .buttonStyle(.borderless)
                        .disabled(index == 0)
                        
                        // Arrow Down
                        Button(action: { moveDown(index: index) }) {
                            Image(systemName: "arrow.down")
                                .foregroundColor(index == resourcesOrder.count - 1 ? .gray.opacity(0.3) : .orange)
                        }
                        .buttonStyle(.borderless)
                        .disabled(index == resourcesOrder.count - 1)
                    }
                }
                .onMove(perform: moveWithDrag)
            }
            
            Section(header: Text("Display & Sorting").foregroundColor(.orange)) {
                Toggle("Compact view", isOn: $compactSourceView)
            }
            
            Section(header: Text("Automatic Sync").foregroundColor(.orange)) {
                Toggle("Google Drive Folders Sync", isOn: $syncDrive)
                Toggle("Google Classroom Assignments Sync", isOn: $syncClassroom)
            }
            
            Section(header: Text("Maintenance").foregroundColor(.orange)) {
                Button("Refresh All Resources Cache", role: .destructive) {
                    // Cache clearing logic
                }
            }
        }
        .navigationTitle("Resources Settings")
        .toolbar {
            EditButton()
        }
        .onAppear {
            loadOrder()
        }
    }
    
    private func loadOrder() {
        let loaded = resourcesOrderRaw.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if !loaded.isEmpty && loaded.contains("drive") && loaded.contains("classroom") {
            resourcesOrder = loaded
        } else {
            resourcesOrder = ["drive", "classroom"]
        }
    }
    
    private func save() {
        resourcesOrderRaw = resourcesOrder.joined(separator: ",")
    }
    
    private func moveUp(index: Int) {
        guard index > 0 else { return }
        withAnimation {
            resourcesOrder.swapAt(index, index - 1)
            save()
        }
    }
    
    private func moveDown(index: Int) {
        guard index < resourcesOrder.count - 1 else { return }
        withAnimation {
            resourcesOrder.swapAt(index, index + 1)
            save()
        }
    }
    
    private func moveWithDrag(from source: IndexSet, to destination: Int) {
        resourcesOrder.move(fromOffsets: source, toOffset: destination)
        save()
    }
}


// MARK: - ACCOUNTS SUBMENU SCREENS

struct GoogleAccountDetailView: View {
    @ObservedObject var auth: WebGoogleAuthManager
    
    @State private var showLogoutConfirmation: Bool = false
    
    private var userPhotoURL: URL? {
        guard auth.isLoggedIn, !auth.userPicture.isEmpty else { return nil }
        var urlString = auth.userPicture.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlString.hasPrefix("http://") {
            urlString = urlString.replacingOccurrences(of: "http://", with: "https://")
        }
        return URL(string: urlString)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Account Status").foregroundColor(.orange)) {
                if auth.isLoggedIn {
                    HStack(spacing: 12) {
                        if let photoUrl = userPhotoURL {
                            AsyncImage(url: photoUrl) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure, .empty:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                @unknown default:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                            }
                            .id(photoUrl.absoluteString)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(auth.userName.isEmpty ? "Google User" : auth.userName)
                                .font(.headline)
                            Text(auth.userEmail)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(role: .destructive, action: {
                        showLogoutConfirmation = true
                    }) {
                        Text("Log Out of Google")
                    }
                    .smartPopover(isPresented: $showLogoutConfirmation) {
                        VStack(spacing: 16) {
                            VStack(spacing: 6) {
                                Text("Are you sure?")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                
                                Text("You will need to log in again to access your Google files and data.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            VStack(spacing: 8) {
                                Button(role: .destructive) {
                                    showLogoutConfirmation = false
                                    auth.logout()
                                } label: {
                                    Text("Log Out of Google")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color.red.opacity(0.15))
                                        .foregroundColor(.red)
                                        .cornerRadius(8)
                                }
                                
                                Button(role: .cancel) {
                                    showLogoutConfirmation = false
                                } label: {
                                    Text("Cancel")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .frame(width: 280)
                        .fixedSize(horizontal: false, vertical: true)
                        .presentationCompactAdaptation(.popover)
                    }
                } else {
                    Text("Log in to access Drive files and Classroom assignments.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: { auth.startGoogleLogin() }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Log in with Google")
                        }
                        .font(.headline)
                        .foregroundColor(.orange)
                    }
                }
            }
        }
        .navigationTitle("Google")
    }
}

struct MagisterDetailView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                MagisterSection()
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Magister")
    }
}

// MARK: - DIAGNOSTICS SUBMENU SCREENS

struct DiagnostiekStatusView: View {
    @ObservedObject var auth: WebGoogleAuthManager
    @AppStorage("isMagisterLoggedIn") private var isMagisterLoggedIn: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("AI Assistent").foregroundColor(.orange)) {
                HStack(spacing: 8) {
                    Circle().fill(Color.green).frame(width: 10, height: 10)
                    Text("AI Assistant Active")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            
            Section(header: Text("System Status").foregroundColor(.orange)) {
                HStack {
                    Text("App Versie")
                    Spacer()
                    Text("1.0.0").foregroundColor(.gray)
                }
                HStack {
                    Text("AI Engine")
                    Spacer()
                    Text("Active").foregroundColor(.green).bold()
                }
            }
            
            Section(header: Text("Connections").foregroundColor(.orange)) {
                HStack {
                    Text("Google API")
                    Spacer()
                    Text(auth.isLoggedIn ? "Connected" : "Not connected")
                        .foregroundColor(auth.isLoggedIn ? .green : .red)
                }
                HStack {
                    Text("Magister API")
                    Spacer()
                    Text(isMagisterLoggedIn ? "Connected" : "Not connected")
                        .foregroundColor(isMagisterLoggedIn ? .green : .red)
                }
            }
        }
        .navigationTitle("Status")
    }
}

struct LogEvent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

struct DiagnosticsLogView: View {
    @State private var consoleLogs: [String] = [
        "[SYSTEM] App started v1.0.0",
        "[AUTH] WebGoogleAuthManager initialized",
        "[NETWORK] Connection verified -> OK",
        "[AI Engine] Assistent status: Actief",
        "[CACHE] Data cache loaded"
    ]
    
    @State private var recentEvents: [LogEvent] = [
        LogEvent(title: "App started", description: "System successfully initialized."),
        LogEvent(title: "Google Auth Check", description: "Session checked.")
    ]
    
    private var logExportText: String {
        let logs = consoleLogs.isEmpty ? "None console logs." : consoleLogs.joined(separator: "\n")
        let events = recentEvents.isEmpty ? "No recent events." : recentEvents.map { "\($0.title): \($0.description)" }.joined(separator: "\n")
        return "=== CONSOLE LOGS ===\n\(logs)\n\n=== RECENT EVENTS ===\n\(events)"
    }
    
    var body: some View {
        Form {
            Section(header: Text("Console Log").foregroundColor(.orange)) {
                ScrollView(.horizontal, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 4) {
                        if consoleLogs.isEmpty {
                            Text("Console log is empty.")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.gray)
                        } else {
                            ForEach(consoleLogs, id: \.self) { log in
                                Text(log)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(8)
                }
                .frame(minHeight: 110, alignment: .topLeading)
                .background(Color.black.opacity(0.85))
                .cornerRadius(8)
            }
            
            Section(header: Text("Acties").foregroundColor(.orange)) {
                if !consoleLogs.isEmpty || !recentEvents.isEmpty {
                    ShareLink(item: logExportText) {
                        Label("Export Log", systemImage: "square.and.arrow.up")
                            .foregroundColor(.orange)
                    }
                } else {
                    Text("No log available to export")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Button(role: .destructive, action: clearLog) {
                    Label("Clear Log", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .disabled(consoleLogs.isEmpty && recentEvents.isEmpty)
            }
            
            Section(header: Text("Recent Events").foregroundColor(.orange)) {
                if recentEvents.isEmpty {
                    Text("No recent events.")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    ForEach(recentEvents) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.subheadline.bold())
                            Text(event.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("Log")
    }
    
    private func clearLog() {
        consoleLogs.removeAll()
        recentEvents.removeAll()
    }
}

// MARK: - HELPER VIEWS
struct SettingsCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .bold()
                .foregroundColor(.gray)
                .padding(.leading, 4)
            
            VStack(spacing: 12) {
                content
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
}

// Generic MenuRowView with support for custom trailing content
struct MenuRowView<TrailingContent: View>: View {
    let icoon: String
    let color: Color
    let title: String
    let trailingContent: TrailingContent
    
    init(icon: String, color: Color, title: String, @ViewBuilder trailingContent: () -> TrailingContent) {
        self.icoon = icoon
        self.color = color
        self.title = title
        self.trailingContent = trailingContent()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(color)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            trailingContent
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.gray.opacity(0.6))
        }
    }
}

// Extension for easy display with only a subtitle
extension MenuRowView where TrailingContent == Text {
    init(icon: String, color: Color, title: String, subtekst: String) {
        self.icon = icon
        self.color = color
        self.title = title
        self.trailingContent = Text(subtitle)
            .font(.caption)
            .foregroundColor(.gray)
    }
}

#Preview {
    let mockGoogleAuth = WebGoogleAuthManager()
    return ProfileView(auth: mockGoogleAuth)
}
