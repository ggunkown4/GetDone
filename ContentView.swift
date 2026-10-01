import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var auth = WebGoogleAuthManager()
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var selectedOption: String? = "Agenda"
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    @State private var isChatOpen: Bool = false
    @State private var isFilesOpen: Bool = false
    
    var body: some View {
        let safeSelection = Binding<String?>(
            get: { selectedOption },
            set: { newValue in
                if let validValue = newValue {
                    selectedOption = validValue
                }
            }
        )
        
        Group {
            if sizeClass == .compact {
                // iPhone layout
                TabView(selection: $selectedOption) {
                    NavigationStack { DetailScreen(title: "Agenda", auth: auth) }
                        .tabItem { Label("Agenda", systemImage: "calendar") }
                        .tag("Agenda" as String?)
                    
                    NavigationStack { DetailScreen(title: "Chat", auth: auth) }
                        .tabItem { Label("Chat", systemImage: "message.fill") }
                        .tag("Chat" as String?)
                    
                    NavigationStack { DetailScreen(title: "Resources", auth: auth) }
                        .tabItem { Label("Resources", systemImage: "books.vertical.fill") }
                        .tag("Resources" as String?)
                    
                    NavigationStack { DetailScreen(title: "Profile", auth: auth) }
                        .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                        .tag("Profile" as String?)
                }
            } else {
                // iPad layout: Sidebar
                NavigationSplitView(columnVisibility: $columnVisibility) {
                    ZStack(alignment: .top) {
                        
                        // 1. SCROLLABLE LIST
                        List(selection: safeSelection.animation(.easeInOut(duration: 0.3))) {
                            Section {
                                NavigationLink(value: "Agenda") {
                                    Label("Agenda", systemImage: "calendar")
                                }
                                
                                DisclosureGroup(isExpanded: $isChatOpen) {
                                    NavigationLink(value: "Chat - Project A") { Label("Project A", systemImage: "message") }
                                    NavigationLink(value: "Chat - Team") { Label("Team", systemImage: "message") }
                                } label: {
                                    NavigationLink(value: "Chat") { Label("Chat", systemImage: "message.fill") }
                                }
                                
                                DisclosureGroup(isExpanded: $isFilesOpen) {
                                    NavigationLink(value: "Resources - Documents") { Label("Documents", systemImage: "doc") }
                                    NavigationLink(value: "Resources - Images") { Label("Images", systemImage: "photo") }
                                } label: {
                                    NavigationLink(value: "Resources") { Label("Resources", systemImage: "books.vertical.fill") }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .safeAreaInset(edge: .top) { Color.clear.frame(height: 135) }
                        .mask(
                            VStack(spacing: 0) {
                                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom).frame(height: 115)
                                Rectangle().fill(.black)
                                LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom).frame(height: 35)
                            }
                        )
                        
                        // 2. CUSTOM HEADER STACK SIDEBAR
                        VStack(spacing: 15) {
                            HStack(spacing: 12) {
                                Button {
                                    withAnimation { columnVisibility = .detailOnly }
                                } label: {
                                    Image(systemName: "rectangle").font(.title3).foregroundColor(.white)
                                }
                                Text("Get Done").font(.title2.bold()).foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            
                            // Dynamic Profile button
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { selectedOption = "Profile" }
                            } label: {
                                HStack(spacing: 15) {
                                    if auth.isLoggedIn, let photoUrl = URL(string: auth.userPicture), !auth.userPicture.isEmpty {
                                        AsyncImage(url: photoUrl) { phase in
                                            if let image = phase.image {
                                                image.resizable().aspectRatio(contentMode: .fill)
                                            } else {
                                                Image(systemName: "person.crop.circle.fill").resizable().foregroundColor(.white.opacity(0.9))
                                            }
                                        }
                                        .frame(width: 48, height: 48)
                                        .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 48, height: 48)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(auth.isLoggedIn ? (auth.userName.isEmpty ? "Google User" : auth.userName) : "Your Name")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(auth.isLoggedIn ? auth.userEmail : "Accounts, linked apps...")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal, 14)
                                .background {
                                    let isProfileActive = (selectedOption == "Profile")
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .fill(isProfileActive ? AnyShapeStyle(.regularMaterial) : AnyShapeStyle(Color.black))
                                        .environment(\.colorScheme, .dark)
                                        .overlay(
                                            Group {
                                                if isProfileActive {
                                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                                        .fill(LinearGradient(colors: [.white.opacity(0.15), .clear, .clear, .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                }
                                            }
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                                .stroke(LinearGradient(colors: isProfileActive ? [.white.opacity(0.6), .white.opacity(0.1), .clear, .white.opacity(0.2)] : [.white.opacity(0.2), .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.2)
                                        )
                                        .shadow(color: Color.black.opacity(0.5), radius: isProfileActive ? 15 : 5, x: 0, y: 8)
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 12)
                        }
                        .padding(.top, 10)
                    }
                    .ignoresSafeArea(edges: .top)
                    .toolbar(.hidden, for: .navigationBar)
                    
                } detail: {
                    NavigationStack {
                        Group {
                            if let selectie = selectedOption {
                                DetailScreen(title: selectie, auth: auth)
                                    .id(selectie)
                                    .transition(.opacity)
                            } else {
                                ZStack {
                                    Color.black.ignoresSafeArea()
                                    Text("Hey, let's get started!")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                }
                                .transition(.opacity)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if auth.isLoggedIn && auth.driveFiles.isEmpty && auth.classroomItems.isEmpty {
                auth.loadGoogleData()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}
