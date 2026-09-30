import SwiftUI

// MARK: - Slimme Popover Modifier (Dynamische Positie Logica)
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
        let screenHeight = UIScreen.main.bounds.height
        
        if frame.midY > (screenHeight * 0.55) {
            arrowEdge = .bottom
        } else {
            arrowEdge = .top
        }
    }
}

extension View {
    func slimmePopover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(AdaptivePopoverModifier(isPresented: isPresented, popoverContent: content))
    }
}

// MARK: - PROFIELLOGICA & HOOFDSCHERM

struct ProfielView: View {
    @ObservedObject var auth: WebGoogleAuthManager
    
    // MARK: - State voor Bevestigingspopup
    @State private var toonUitlogBevestiging: Bool = false
    
    // MARK: - Persistent Instellingen (Worden automatisch opgeslagen)
    @AppStorage("aiToon") private var aiToon: String = "Motiverend"
    @AppStorage("productiviteitsType") private var productiviteitsType: String = "Ochtendmens"
    @AppStorage("bufferTijdMinuten") private var bufferTijdMinuten: Int = 15
    @AppStorage("isMagisterLoggedIn") private var isMagisterLoggedIn: Bool = false
    @AppStorage("magister_voornaam") private var magisterVoornaam: String = ""
    @AppStorage("magister_achternaam") private var magisterAchternaam: String = ""
    
    private var magisterVolledigeNaam: String {
        let naam = "\(magisterVoornaam) \(magisterAchternaam)".trimmingCharacters(in: .whitespaces)
        return naam.isEmpty ? "Magister Gebruiker" : naam
    }
    
    // MARK: - Helper voor Schone & Veilige Foto URL
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
                    
                    // MARK: - Header (Profielfoto & Gebruikersinfo / Inloggen)
                    profielHeader
                    
                    // MARK: - Sectie 1: Instellingen & Voorkeuren per Tabblad
                    InstellingenKaart(titel: "INSTELLINGEN & VOORKEUREN") {
                        VStack(spacing: 0) {
                            
                            NavigationLink(destination: AgendaInstellingenView()) {
                                MenuRijView(
                                    icoon: "calendar.badge.clock",
                                    kleur: .blue,
                                    titel: "Agenda",
                                    subtekst: "\(bufferTijdMinuten) min buffer • \(productiviteitsType)"
                                )
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                            
                            NavigationLink(destination: ChatInstellingenView()) {
                                MenuRijView(
                                    icoon: "bubble.left.and.bubble.right.fill",
                                    kleur: .purple,
                                    titel: "Chat",
                                    subtekst: "AI Toon: \(aiToon)"
                                )
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                            
                            NavigationLink(destination: BronnenInstellingenView()) {
                                MenuRijView(
                                    icoon: "folder.fill",
                                    kleur: .orange,
                                    titel: "Bronnen",
                                    subtekst: "Drive & Magister sync"
                                )
                            }
                        }
                    }
                    
                    // MARK: - Sectie 2: Gekoppelde Accounts
                    InstellingenKaart(titel: "GEKOPPELDE ACCOUNTS") {
                        VStack(spacing: 0) {
                            
                            // Google Submenu Knop
                            NavigationLink(destination: GoogleAccountDetailView(auth: auth)) {
                                MenuRijView(
                                    icoon: "g.circle.fill",
                                    kleur: .red,
                                    titel: "Google"
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
                                MenuRijView(
                                    icoon: "graduationcap.fill",
                                    kleur: .orange,
                                    titel: "Magister"
                                ) {
                                    if isMagisterLoggedIn {
                                        Text(magisterVolledigeNaam)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    // MARK: - Sectie 3: Bronnen
                    InstellingenKaart(titel: "BRONNEN") {
                        VStack(spacing: 0) {
                            NavigationLink(destination: BronnenView(auth: auth, geselecteerdFilter: .constant(.drive))) {
                                MenuRijView(
                                    icoon: "folder.fill",
                                    kleur: .blue,
                                    titel: "Google Drive",
                                    subtekst: "Bestanden & Mappen"
                                )
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                            
                            NavigationLink(destination: BronnenView(auth: auth, geselecteerdFilter: .constant(.classroom))) {
                                MenuRijView(
                                    icoon: "book.fill",
                                    kleur: .green,
                                    titel: "Google Classroom",
                                    subtekst: "Opdrachten & Cursussen"
                                )
                            }
                        }
                    }

                    // MARK: - Sectie 4: Diagnostiek
                    InstellingenKaart(titel: "DIAGNOSTIEK") {
                        VStack(spacing: 0) {
                            NavigationLink(destination: DiagnostiekStatusView(auth: auth)) {
                                MenuRijView(
                                    icoon: "waveform.path.ecg",
                                    kleur: .green,
                                    titel: "Status",
                                    subtekst: "Systeem & Verbindingen"
                                )
                            }
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                            
                            NavigationLink(destination: DiagnostiekLogboekView()) {
                                MenuRijView(
                                    icoon: "doc.text.fill",
                                    kleur: .gray,
                                    titel: "Logboek",
                                    subtekst: "Console & Gebeurtenissen"
                                )
                            }
                        }
                    }
                    
                    // MARK: - Sectie 5: Uitloggen Knop met Slimme Popover
                    if auth.isLoggedIn {
                        Button(role: .destructive, action: {
                            toonUitlogBevestiging = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Uitloggen")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                        }
                        .padding(.top, 8)
                        .slimmePopover(isPresented: $toonUitlogBevestiging) {
                            VStack(spacing: 16) {
                                VStack(spacing: 6) {
                                    Text("Weet je het zeker?")
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Je moet opnieuw inloggen om toegang te krijgen tot je accounts en gegevens.")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                VStack(spacing: 8) {
                                    Button(role: .destructive) {
                                        toonUitlogBevestiging = false
                                        auth.logout()
                                    } label: {
                                        Text("Uitloggen")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(Color.red.opacity(0.15))
                                            .foregroundColor(.red)
                                            .cornerRadius(8)
                                    }
                                    
                                    Button(role: .cancel) {
                                        toonUitlogBevestiging = false
                                    } label: {
                                        Text("Annuleer")
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
    private var profielHeader: some View {
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
                        Text("Koppel je accounts om aan de slag te gaan")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button(action: { auth.startGoogleLogin() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "g.circle.fill")
                                Text("Inloggen met Google")
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

// MARK: - SUBMENU'S PER TABBLAD

struct AgendaInstellingenView: View {
    @AppStorage("productiviteitsType") private var productiviteitsType: String = "Ochtendmens"
    @AppStorage("dynamischHerplannen") private var dynamischHerplannen: Bool = true
    @AppStorage("maxStudieUur") private var maxStudieUur: Double = 4.0
    @AppStorage("bufferTijdMinuten") private var bufferTijdMinuten: Int = 15
    @AppStorage("inclusiefWeekend") private var inclusiefWeekend: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Slim Inplannen").foregroundColor(.orange)) {
                Picker("Productiviteitsritme", selection: $productiviteitsType) {
                    Text("Ochtendmens").tag("Ochtendmens")
                    Text("Middagmens").tag("Middagmens")
                    Text("Avondmens").tag("Avondmens")
                }
                
                Toggle("Dynamisch Herplannen", isOn: $dynamischHerplannen)
                Toggle("Weekend gebruiken voor studie", isOn: $inclusiefWeekend)
            }
            
            Section(header: Text("Tijden & Limieten").foregroundColor(.orange)) {
                Stepper("Buffer tussen afspraken: \(bufferTijdMinuten) min", value: $bufferTijdMinuten, in: 0...60, step: 5)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Max. studietijd per dag")
                        Spacer()
                        Text("\(Int(maxStudieUur)) uur").bold().foregroundColor(.orange)
                    }
                    Slider(value: $maxStudieUur, in: 1...8, step: 0.5)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Agenda Instellingen")
    }
}

struct ChatInstellingenView: View {
    @AppStorage("aiToon") private var aiToon: String = "Motiverend"
    @AppStorage("ochtendBriefing") private var ochtendBriefing: Bool = true
    @AppStorage("avondEvaluatie") private var avondEvaluatie: Bool = true
    @AppStorage("aiServerURL") private var aiServerURL: String = ""
    @AppStorage("aiServerToken") private var aiServerToken: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("AI Persona").foregroundColor(.orange)) {
                Picker("AI Toon & Stijl", selection: $aiToon) {
                    Text("Motiverend").tag("Motiverend")
                    Text("Direct & Zakelijk").tag("Direct & Zakelijk")
                    Text("Relaxed").tag("Relaxed")
                }
            }
            
            Section(header: Text("Lokale AI-server").foregroundColor(.orange)) {
                TextField("https://jouw-server.nl", text: $aiServerURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                
                SecureField("API-token", text: $aiServerToken)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            
            Section(header: Text("Automatische Berichten").foregroundColor(.orange)) {
                Toggle("Ochtend Briefing Ontvangen", isOn: $ochtendBriefing)
                Toggle("Avond Evaluatie Ontvangen", isOn: $avondEvaluatie)
            }
            
            Section(header: Text("Geheugen").foregroundColor(.orange)) {
                Button("Wis AI-Chatgeschiedenis", role: .destructive) {
                }
            }
        }
        .navigationTitle("Chat Instellingen")
    }
}

struct BronnenInstellingenView: View {
    @AppStorage("syncDrive") private var syncDrive: Bool = true
    @AppStorage("syncClassroom") private var syncClassroom: Bool = true
    @AppStorage("compacteBronweergave") private var compacteBronweergave: Bool = false
    @AppStorage("bronnenVolgorde") private var bronnenVolgordeRaw: String = "drive,classroom"
    
    @State private var bronnenVolgorde: [String] = ["drive", "classroom"]
    
    var body: some View {
        Form {
            Section(header: Text("Volgorde op Hoofdscherm").foregroundColor(.orange)) {
                ForEach(Array(bronnenVolgorde.enumerated()), id: \.element) { index, bronKey in
                    HStack(spacing: 12) {
                        Image(systemName: bronKey == "drive" ? "folder.fill" : "graduationcap.fill")
                            .foregroundColor(bronKey == "drive" ? .blue : .orange)
                        
                        Text(bronKey == "drive" ? "Google Drive" : "Google Classroom")
                        
                        Spacer()
                        
                        // Pijltje Omhoog
                        Button(action: { verplaatsOmhoog(index: index) }) {
                            Image(systemName: "arrow.up")
                                .foregroundColor(index == 0 ? .gray.opacity(0.3) : .orange)
                        }
                        .buttonStyle(.borderless)
                        .disabled(index == 0)
                        
                        // Pijltje Omlaag
                        Button(action: { verplaatsOmlaag(index: index) }) {
                            Image(systemName: "arrow.down")
                                .foregroundColor(index == bronnenVolgorde.count - 1 ? .gray.opacity(0.3) : .orange)
                        }
                        .buttonStyle(.borderless)
                        .disabled(index == bronnenVolgorde.count - 1)
                    }
                }
                .onMove(perform: verplaatsMetDrag)
            }
            
            Section(header: Text("Weergave & Sortering").foregroundColor(.orange)) {
                Toggle("Compacte weergave", isOn: $compacteBronweergave)
            }
            
            Section(header: Text("Automatische Synchronisatie").foregroundColor(.orange)) {
                Toggle("Google Drive Mappen Sync", isOn: $syncDrive)
                Toggle("Google Classroom Opdrachten Sync", isOn: $syncClassroom)
            }
            
            Section(header: Text("Onderhoud").foregroundColor(.orange)) {
                Button("Ververs Alle Bronnen Cache", role: .destructive) {
                    // Cache opschonen logica
                }
            }
        }
        .navigationTitle("Bronnen Instellingen")
        .toolbar {
            EditButton()
        }
        .onAppear {
            laadVolgorde()
        }
    }
    
    private func laadVolgorde() {
        let geladen = bronnenVolgordeRaw.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if !geladen.isEmpty && geladen.contains("drive") && geladen.contains("classroom") {
            bronnenVolgorde = geladen
        } else {
            bronnenVolgorde = ["drive", "classroom"]
        }
    }
    
    private func opslaan() {
        bronnenVolgordeRaw = bronnenVolgorde.joined(separator: ",")
    }
    
    private func verplaatsOmhoog(index: Int) {
        guard index > 0 else { return }
        withAnimation {
            bronnenVolgorde.swapAt(index, index - 1)
            opslaan()
        }
    }
    
    private func verplaatsOmlaag(index: Int) {
        guard index < bronnenVolgorde.count - 1 else { return }
        withAnimation {
            bronnenVolgorde.swapAt(index, index + 1)
            opslaan()
        }
    }
    
    private func verplaatsMetDrag(from source: IndexSet, to destination: Int) {
        bronnenVolgorde.move(fromOffsets: source, toOffset: destination)
        opslaan()
    }
}


// MARK: - ACCOUNTS SUBMENU SCHERMEN

struct GoogleAccountDetailView: View {
    @ObservedObject var auth: WebGoogleAuthManager
    
    @State private var toonUitlogBevestiging: Bool = false
    
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
                            Text(auth.userName.isEmpty ? "Google Gebruiker" : auth.userName)
                                .font(.headline)
                            Text(auth.userEmail)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(role: .destructive, action: {
                        toonUitlogBevestiging = true
                    }) {
                        Text("Uitloggen bij Google")
                    }
                    .slimmePopover(isPresented: $toonUitlogBevestiging) {
                        VStack(spacing: 16) {
                            VStack(spacing: 6) {
                                Text("Weet je het zeker?")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                
                                Text("Je moet opnieuw inloggen om toegang te krijgen tot je Google-bestanden en -gegevens.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            VStack(spacing: 8) {
                                Button(role: .destructive) {
                                    toonUitlogBevestiging = false
                                    auth.logout()
                                } label: {
                                    Text("Uitloggen bij Google")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color.red.opacity(0.15))
                                        .foregroundColor(.red)
                                        .cornerRadius(8)
                                }
                                
                                Button(role: .cancel) {
                                    toonUitlogBevestiging = false
                                } label: {
                                    Text("Annuleer")
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
                    Text("Log in om Drive-bestanden en Classroom-opdrachten op te halen.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: { auth.startGoogleLogin() }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Inloggen met Google")
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
                MagisterSectie()
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Magister")
    }
}

// MARK: - DIAGNOSTIEK SUBMENU SCHERMEN

struct DiagnostiekStatusView: View {
    @ObservedObject var auth: WebGoogleAuthManager
    @AppStorage("isMagisterLoggedIn") private var isMagisterLoggedIn: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("AI Assistent").foregroundColor(.orange)) {
                HStack(spacing: 8) {
                    Circle().fill(Color.green).frame(width: 10, height: 10)
                    Text("AI Assistent Actief")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            
            Section(header: Text("Systeem Status").foregroundColor(.orange)) {
                HStack {
                    Text("App Versie")
                    Spacer()
                    Text("1.0.0").foregroundColor(.gray)
                }
                HStack {
                    Text("AI Engine")
                    Spacer()
                    Text("Actief").foregroundColor(.green).bold()
                }
            }
            
            Section(header: Text("Koppelingen").foregroundColor(.orange)) {
                HStack {
                    Text("Google API")
                    Spacer()
                    Text(auth.isLoggedIn ? "Verbonden" : "Niet verbonden")
                        .foregroundColor(auth.isLoggedIn ? .green : .red)
                }
                HStack {
                    Text("Magister API")
                    Spacer()
                    Text(isMagisterLoggedIn ? "Verbonden" : "Niet verbonden")
                        .foregroundColor(isMagisterLoggedIn ? .green : .red)
                }
            }
        }
        .navigationTitle("Status")
    }
}

struct LogGebeurtenis: Identifiable {
    let id = UUID()
    let titel: String
    let beschrijving: String
}

struct DiagnostiekLogboekView: View {
    @State private var consoleLogs: [String] = [
        "[SYSTEM] App gestart v1.0.0",
        "[AUTH] WebGoogleAuthManager geïnitialiseerd",
        "[NETWORK] Verbinding gecontroleerd -> OK",
        "[AI Engine] Assistent status: Actief",
        "[CACHE] Gegevenscache geladen"
    ]
    
    @State private var recenteGebeurtenissen: [LogGebeurtenis] = [
        LogGebeurtenis(titel: "App gestart", beschrijving: "Systeem succesvol geïnitialiseerd."),
        LogGebeurtenis(titel: "Google Auth Check", beschrijving: "Sessie gecontroleerd.")
    ]
    
    private var logboekExporteerTekst: String {
        let logs = consoleLogs.isEmpty ? "Geen console logs." : consoleLogs.joined(separator: "\n")
        let gebeurtenissen = recenteGebeurtenissen.isEmpty ? "Geen recente gebeurtenissen." : recenteGebeurtenissen.map { "\($0.titel): \($0.beschrijving)" }.joined(separator: "\n")
        return "=== CONSOLE LOGS ===\n\(logs)\n\n=== RECENTE GEBEURTENISSEN ===\n\(gebeurtenissen)"
    }
    
    var body: some View {
        Form {
            Section(header: Text("Console Log").foregroundColor(.orange)) {
                ScrollView(.horizontal, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 4) {
                        if consoleLogs.isEmpty {
                            Text("Console log is leeg.")
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
                if !consoleLogs.isEmpty || !recenteGebeurtenissen.isEmpty {
                    ShareLink(item: logboekExporteerTekst) {
                        Label("Exporteer Logboek", systemImage: "square.and.arrow.up")
                            .foregroundColor(.orange)
                    }
                } else {
                    Text("Geen logboek beschikbaar om te exporteren")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Button(role: .destructive, action: wisLogboek) {
                    Label("Wis Logboek", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .disabled(consoleLogs.isEmpty && recenteGebeurtenissen.isEmpty)
            }
            
            Section(header: Text("Recente Gebeurtenissen").foregroundColor(.orange)) {
                if recenteGebeurtenissen.isEmpty {
                    Text("Geen recente gebeurtenissen.")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    ForEach(recenteGebeurtenissen) { gebeurtenis in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(gebeurtenis.titel)
                                .font(.subheadline.bold())
                            Text(gebeurtenis.beschrijving)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("Logboek")
    }
    
    private func wisLogboek() {
        consoleLogs.removeAll()
        recenteGebeurtenissen.removeAll()
    }
}

// MARK: - HELPER VIEWS
struct InstellingenKaart<Content: View>: View {
    let titel: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titel)
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

// Generieke MenuRijView met ondersteuning voor op maat gemaakte content aan de rechterkant
struct MenuRijView<TrailingContent: View>: View {
    let icoon: String
    let kleur: Color
    let titel: String
    let trailingContent: TrailingContent
    
    init(icoon: String, kleur: Color, titel: String, @ViewBuilder trailingContent: () -> TrailingContent) {
        self.icoon = icoon
        self.kleur = kleur
        self.titel = titel
        self.trailingContent = trailingContent()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icoon)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(kleur)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(titel)
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

// Extensie voor gemakkelijke weergave met alleen een subtekst
extension MenuRijView where TrailingContent == Text {
    init(icoon: String, kleur: Color, titel: String, subtekst: String) {
        self.icoon = icoon
        self.kleur = kleur
        self.titel = titel
        self.trailingContent = Text(subtekst)
            .font(.caption)
            .foregroundColor(.gray)
    }
}

#Preview {
    let mockGoogleAuth = WebGoogleAuthManager()
    return ProfielView(auth: mockGoogleAuth)
}
