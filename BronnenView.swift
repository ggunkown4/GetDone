import SwiftUI

// MARK: - Bronnen Weergave
struct BronnenView: View {
    @ObservedObject var auth: WebGoogleAuthManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var geselecteerdFilter: BronFilter
    
    // Volgorde opgeslagen via AppStorage
    @AppStorage("bronnenVolgorde") private var bronnenVolgordeRaw: String = "drive,classroom"
    
    // Weergave Opties
    @State private var sorteerOptie: SorteerOptie = .datum
    @State private var sorteerRichting: SorteerRichting = .aflopend
    @State private var tijdFilter: TijdFilter = .alles
    
    // Map Navigatie Status
    @State private var mapGeschiedenis: [DriveFile] = []
    @State private var huidigeMap: DriveFile? = nil
    
    // LOKALE CACHE: Slaat bestanden op per mapId ("root" voor de hoofdmap)
    @State private var mappenCache: [String: [DriveFile]] = [:]
    
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 20)
    ]
    
    private var huidigeMapKey: String {
        huidigeMap?.id ?? "root"
    }
    
    private var actueleBestanden: [DriveFile] {
        if let cached = mappenCache[huidigeMapKey], !cached.isEmpty {
            return cached
        }
        return auth.driveFiles
    }
    
    private var bronnenVolgorde: [String] {
        let items = bronnenVolgordeRaw.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let geldigeItems = items.filter { $0 == "drive" || $0 == "classroom" }
        return geldigeItems.isEmpty ? ["drive", "classroom"] : geldigeItems
    }
    
    private var filterDatumGrens: Date? {
        let kalender = Calendar.current
        switch tijdFilter {
        case .alles: return nil
        case .laatsteWeek: return kalender.date(byAdding: .day, value: -7, to: Date())
        case .laatsteMaand: return kalender.date(byAdding: .month, value: -1, to: Date())
        case .laatsteJaar: return kalender.date(byAdding: .year, value: -1, to: Date())
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 30) {
                        ForEach(bronnenVolgorde, id: \.self) { bronKey in
                            if bronKey == "drive" && (geselecteerdFilter == .alles || geselecteerdFilter == .drive) {
                                weergaveBestandenSectie
                            }
                            
                            if bronKey == "classroom" && (geselecteerdFilter == .alles || geselecteerdFilter == .classroom) {
                                weergaveClassroomSectie
                            }
                        }
                        
                        if geselecteerdFilter == .alles && actueleBestanden.isEmpty && auth.classroomItems.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "tray")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Je hebt nog geen bronnen.")
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 40)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .onChange(of: auth.driveFiles.map(\.id)) { _ in
            if !auth.driveFiles.isEmpty {
                mappenCache[huidigeMapKey] = auth.driveFiles
            }
        }
        .onChange(of: geselecteerdFilter) { newValue in
            if newValue == .alles {
                resetMapNavigatie()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if geselecteerdFilter != .alles {
                    Button {
                        withAnimation {
                            geselecteerdFilter = .alles
                            resetMapNavigatie()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.subheadline.bold())
                            if horizontalSizeClass == .regular {
                                Text("Alles")
                                    .font(.subheadline.bold())
                            }
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Section(header: Text("Sorteren op")) {
                        Picker("Sorteer optie", selection: $sorteerOptie) {
                            ForEach(SorteerOptie.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                    }
                    Section(header: Text("Volgorde")) {
                        Picker("Richting", selection: $sorteerRichting) {
                            ForEach(SorteerRichting.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                    }
                    Section(header: Text("Tijdfilter")) {
                        Picker("Filter", selection: $tijdFilter) {
                            ForEach(TijdFilter.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.subheadline.bold())
                        if horizontalSizeClass == .regular {
                            Text("Weergave")
                                .font(.subheadline.bold())
                        }
                    }
                    .foregroundColor(.white)
                }
                
                Menu {
                    Picker("Bron", selection: $geselecteerdFilter) {
                        ForEach(BronFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.closed.fill")
                            .font(.subheadline.bold())
                        if horizontalSizeClass == .regular {
                            Text("Bron")
                                .font(.subheadline.bold())
                        }
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Map Navigatie Functies
    private func navigeerNaarMap(_ map: DriveFile) {
        withAnimation(.easeInOut(duration: 0.2)) {
            geselecteerdFilter = .drive 
            if let huidige = huidigeMap {
                mapGeschiedenis.append(huidige)
            }
            huidigeMap = map
        }
        
        if mappenCache[map.id] == nil {
            auth.laadBestandenVoorMap(mapId: map.id)
        }
    }
    
    private func gaTerugInMappen() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if !mapGeschiedenis.isEmpty {
                huidigeMap = mapGeschiedenis.removeLast()
            } else {
                huidigeMap = nil
            }
        }
        
        if mappenCache[huidigeMapKey] == nil {
            auth.laadBestandenVoorMap(mapId: huidigeMap?.id)
        }
    }
    
    private func resetMapNavigatie() {
        withAnimation(.easeInOut(duration: 0.2)) {
            huidigeMap = nil
            mapGeschiedenis.removeAll()
        }
        if mappenCache["root"] == nil {
            auth.laadBestandenVoorMap(mapId: nil)
        }
    }
    
    // MARK: - Subweergave: Drive Bestanden
    @ViewBuilder
    private var weergaveBestandenSectie: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                if let map = huidigeMap {
                    Button(action: gaTerugInMappen) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                            Text(mapGeschiedenis.isEmpty ? "Google Drive" : (mapGeschiedenis.last?.name ?? "Vorige"))
                                .font(.title3.bold())
                        }
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    Text("›").font(.title3.bold()).foregroundColor(.gray)
                    Text(map.name).font(.title3.bold()).foregroundColor(.white).lineLimit(1)
                    Spacer()
                } else {
                    if geselecteerdFilter == .alles {
                        Button {
                            withAnimation { geselecteerdFilter = .drive }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Google Drive").font(.title2.bold()).foregroundColor(.white)
                                Image(systemName: "chevron.right").font(.title3.bold()).foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("Google Drive").font(.title2.bold()).foregroundColor(.white)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            
            let bestandenTerTonen = actueleBestanden
            
            if bestandenTerTonen.isEmpty && !auth.isLoadingData {
                VStack(spacing: 16) {
                    Image(systemName: "folder").font(.system(size: 50)).foregroundColor(.gray)
                    Text(huidigeMap != nil ? "Deze map is leeg" : "Je Drive is leeg").foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                let basisBestanden = bestandenTerTonen.filter { file in
                    guard let grens = filterDatumGrens else { return true }
                    return file.datum >= grens 
                }
                
                let gesorteerdeBestanden = basisBestanden.sorted { (file1, file2) -> Bool in
                    let isFolder1 = file1.mimeType == "application/vnd.google-apps.folder"
                    let isFolder2 = file2.mimeType == "application/vnd.google-apps.folder"
                    
                    if isFolder1 != isFolder2 { return isFolder1 }
                    
                    if sorteerOptie == .naam {
                        return sorteerRichting == .oplopend ? file1.name < file2.name : file1.name > file2.name
                    } else {
                        return sorteerRichting == .oplopend ? file1.datum < file2.datum : file1.datum > file2.datum
                    }
                }
                
                let tonenBestanden = (geselecteerdFilter == .alles && huidigeMap == nil)
                ? Array(gesorteerdeBestanden.prefix(6))
                : gesorteerdeBestanden
                
                if tonenBestanden.isEmpty {
                    Text("Geen bestanden gevonden met deze filters.")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                } else {
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(tonenBestanden) { file in
                            BronIcoonWeergave(file: file) { geselecteerdeMap in
                                navigeerNaarMap(geselecteerdeMap)
                            }
                            .onAppear {
                                if geselecteerdFilter == .drive, file.id == tonenBestanden.last?.id {
                                    auth.laadMeerBestandenVoorMap(mapId: huidigeMap?.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    if auth.isLadenMeerBestanden {
                        ProgressView("Meer laden...")
                            .tint(.white)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    }
                }
            }
        }
    }
    
    // MARK: - Subweergave: Classroom Items
    @ViewBuilder
    private var weergaveClassroomSectie: some View {
        if auth.classroomItems.isEmpty {
            if geselecteerdFilter == .classroom {
                VStack(spacing: 16) {
                    Image(systemName: "graduationcap").font(.system(size: 50)).foregroundColor(.gray)
                    Text("Geen materiaal of opdrachten gevonden").foregroundColor(.gray)
                }
                .padding(.top, 40)
            }
        } else {
            VStack(alignment: .leading, spacing: 16) {
                if geselecteerdFilter == .alles {
                    Button {
                        withAnimation { geselecteerdFilter = .classroom }
                    } label: {
                        HStack(spacing: 8) {
                            Text("Google Classroom").font(.title2.bold()).foregroundColor(.white)
                            Image(systemName: "chevron.right").font(.title3.bold()).foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Google Classroom").font(.title2.bold()).foregroundColor(.white).padding(.horizontal, 20)
                }
                
                let basisItems = auth.classroomItems.filter { item in
                    guard let grens = filterDatumGrens else { return true }
                    return item.datum >= grens
                }
                
                let gesorteerdeItems = basisItems.sorted { item1, item2 in
                    if sorteerOptie == .naam {
                        return sorteerRichting == .oplopend ? item1.titel < item2.titel : item1.titel > item2.titel
                    } else {
                        return sorteerRichting == .oplopend ? item1.datum < item2.datum : item1.datum > item2.datum
                    }
                }
                
                let tonenItems = geselecteerdFilter == .alles 
                ? Array(gesorteerdeItems.prefix(4)) 
                : gesorteerdeItems
                
                if tonenItems.isEmpty {
                    Text("Geen items gevonden met deze filters.").foregroundColor(.gray).padding(.horizontal, 20)
                } else {
                    LazyVStack(spacing: 14) {
                        ForEach(tonenItems) { item in
                            if item.type == .aankondiging {
                                AankondigingBalkWeergave(item: item)
                                    .onAppear {
                                        if geselecteerdFilter == .classroom, item.id == tonenItems.last?.id {
                                            auth.laadMeerClassroomItems()
                                        }
                                    }
                            } else {
                                ClassroomItemKaartWeergave(item: item)
                                    .onAppear {
                                        if geselecteerdFilter == .classroom, item.id == tonenItems.last?.id {
                                            auth.laadMeerClassroomItems()
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    if auth.isLadenMeerClassroomItems {
                        ProgressView("Meer Classroom items laden...")
                            .tint(.white)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 16)
                    }
                }
            }
        }
    }
}

// MARK: - Drive & Classroom Hulpweergaven
struct BronIcoonWeergave: View {
    let file: DriveFile
    var actieBijMap: ((DriveFile) -> Void)? = nil
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button {
            let isMap = file.mimeType == "application/vnd.google-apps.folder"
            if isMap {
                actieBijMap?(file)
            } else if let linkString = file.webViewLink, let url = URL(string: linkString) {
                openURL(url)
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(achtergrondKleurVoorType(file.mimeType))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icoonVoorType(file.mimeType))
                        .font(.system(size: 36))
                        .foregroundColor(icoonKleurVoorType(file.mimeType))
                }
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                let isMap = file.mimeType == "application/vnd.google-apps.folder"
                
                VStack(spacing: 2) {
                    Text(file.name)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if !isMap {
                        Text(file.datumFormatted)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .frame(height: 32, alignment: .top)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func icoonVoorType(_ type: String?) -> String {
        guard let type = type else { return "doc.fill" }
        if type.contains("folder") { return "folder.fill" }
        if type.contains("document") || type.contains("pdf") { return "doc.text.fill" }
        if type.contains("spreadsheet") { return "tablecells.fill" }
        if type.contains("presentation") { return "play.rectangle.fill" }
        if type.contains("image") { return "photo.fill" }
        if type.contains("video") { return "video.fill" }
        if type.contains("audio") { return "waveform" }
        if type.contains("zip") || type.contains("rar") { return "doc.zipper" }
        return "doc.fill"
    }
    
    private func achtergrondKleurVoorType(_ type: String?) -> Color {
        guard let type = type else { return Color.white.opacity(0.1) }
        if type.contains("folder") { return Color.blue.opacity(0.2) }
        return Color.white.opacity(0.1)
    }
    
    private func icoonKleurVoorType(_ type: String?) -> Color {
        guard let type = type else { return .gray }
        if type.contains("folder") { return .blue }
        if type.contains("document") { return .blue }
        if type.contains("pdf") { return .red }
        if type.contains("spreadsheet") { return .green }
        if type.contains("presentation") { return .orange }
        if type.contains("image") || type.contains("video") { return .purple }
        return .white
    }
}

struct AankondigingBalkWeergave: View {
    let item: ClassroomItem
    @Environment(\.openURL) var openURL
    var body: some View {
        Button { if let url = URL(string: item.url) { openURL(url) } } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(item.vakNaam).font(.caption.bold()).foregroundColor(.white).padding(.horizontal, 10).padding(.vertical, 4).background(item.kleur).clipShape(Capsule())
                    Text("Aankondiging").font(.caption2.bold()).foregroundColor(item.kleur)
                    Spacer()
                    Text(item.datumFormatted).font(.caption2).foregroundColor(.gray)
                }
                if let tekst = item.tekst, !tekst.isEmpty {
                    Text(tekst).font(.subheadline).foregroundColor(.white).multilineTextAlignment(.leading).lineLimit(4)
                }
            }
            .padding(14).background(item.kleur.opacity(0.12)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(item.kleur.opacity(0.35), lineWidth: 1))
        }.buttonStyle(.plain)
    }
}

struct ClassroomItemKaartWeergave: View {
    let item: ClassroomItem
    @Environment(\.openURL) var openURL
    var body: some View {
        Button { if let url = URL(string: item.url) { openURL(url) } } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(item.kleur.opacity(0.2)).frame(width: 46, height: 46)
                    Image(systemName: item.type == .opdracht ? "doc.text.fill" : "book.fill").font(.title3).foregroundColor(item.kleur)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.vakNaam).font(.system(size: 10, weight: .bold)).foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 3).background(item.kleur).clipShape(Capsule())
                        Spacer()
                        Text(item.datumFormatted).font(.caption2).foregroundColor(.gray)
                    }
                    Text(item.titel).font(.subheadline.bold()).foregroundColor(.white).lineLimit(2)
                }
            }
            .padding(12).background(Color.white.opacity(0.06)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(item.kleur.opacity(0.25), lineWidth: 1))
        }.buttonStyle(.plain)
    }
}

