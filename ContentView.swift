import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var auth = WebGoogleAuthManager()
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var geselecteerdeOptie: String? = "Agenda"
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    @State private var isChatOpen: Bool = false
    @State private var isBestandenOpen: Bool = false
    
    var body: some View {
        let veiligeSelectie = Binding<String?>(
            get: { geselecteerdeOptie },
            set: { newValue in
                if let geldigeWaarde = newValue {
                    geselecteerdeOptie = geldigeWaarde
                }
            }
        )
        
        Group {
            if sizeClass == .compact {
                // iPhone layout
                TabView(selection: $geselecteerdeOptie) {
                    NavigationStack { DetailScherm(titel: "Agenda", auth: auth) }
                        .tabItem { Label("Agenda", systemImage: "calendar") }
                        .tag("Agenda" as String?)
                    
                    NavigationStack { DetailScherm(titel: "Chat", auth: auth) }
                        .tabItem { Label("Chat", systemImage: "message.fill") }
                        .tag("Chat" as String?)
                    
                    NavigationStack { DetailScherm(titel: "Bronnen", auth: auth) }
                        .tabItem { Label("Bronnen", systemImage: "books.vertical.fill") }
                        .tag("Bronnen" as String?)
                    
                    NavigationStack { DetailScherm(titel: "Profiel", auth: auth) }
                        .tabItem { Label("Profiel", systemImage: "person.crop.circle.fill") }
                        .tag("Profiel" as String?)
                }
            } else {
                // iPad layout: Zijbalk (Sidebar)
                NavigationSplitView(columnVisibility: $columnVisibility) {
                    ZStack(alignment: .top) {
                        
                        // 1. SCROLLBARE LIJST
                        List(selection: veiligeSelectie.animation(.easeInOut(duration: 0.3))) {
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
                                
                                DisclosureGroup(isExpanded: $isBestandenOpen) {
                                    NavigationLink(value: "Bronnen - Documenten") { Label("Documenten", systemImage: "doc") }
                                    NavigationLink(value: "Bronnen - Afbeeldingen") { Label("Afbeeldingen", systemImage: "photo") }
                                } label: {
                                    NavigationLink(value: "Bronnen") { Label("Bronnen", systemImage: "books.vertical.fill") }
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
                        
                        // 2. CUSTOM HEADER-STACK ZIJBALK
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
                            
                            // Dynamic Profielknop
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { geselecteerdeOptie = "Profiel" }
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
                                        Text(auth.isLoggedIn ? (auth.userName.isEmpty ? "Google Gebruiker" : auth.userName) : "Jouw Naam")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(auth.isLoggedIn ? auth.userEmail : "Accounts, gekoppelde apps...")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal, 14)
                                .background {
                                    let isProfielActief = (geselecteerdeOptie == "Profiel")
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .fill(isProfielActief ? AnyShapeStyle(.regularMaterial) : AnyShapeStyle(Color.black))
                                        .environment(\.colorScheme, .dark)
                                        .overlay(
                                            Group {
                                                if isProfielActief {
                                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                                        .fill(LinearGradient(colors: [.white.opacity(0.15), .clear, .clear, .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                }
                                            }
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                                .stroke(LinearGradient(colors: isProfielActief ? [.white.opacity(0.6), .white.opacity(0.1), .clear, .white.opacity(0.2)] : [.white.opacity(0.2), .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.2)
                                        )
                                        .shadow(color: Color.black.opacity(0.5), radius: isProfielActief ? 15 : 5, x: 0, y: 8)
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
                            if let selectie = geselecteerdeOptie {
                                DetailScherm(titel: selectie, auth: auth)
                                    .id(selectie)
                                    .transition(.opacity)
                            } else {
                                ZStack {
                                    Color.black.ignoresSafeArea()
                                    Text("Hé Gebruiker, laten we beginnen!")
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
                auth.laadGoogleData()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}
