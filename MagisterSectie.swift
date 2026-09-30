import SwiftUI
import WebKit
import UIKit
import Network

// MARK: - Netwerk / Wifi Monitor Helper
class MagisterNetworkMonitor {
    static let shared = MagisterNetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "MagisterNetworkMonitorQueue")
    
    private(set) var isConnected: Bool = true
    
    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = (path.status == .satisfied)
        }
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
            monitor.start(queue: queue)
        }
    }
}

// MARK: - Modellen
struct MagisterGebruikerModel {
    var voornaam: String = ""
    var achternaam: String = ""
    var email: String = ""
    var gebruikersnaam: String = ""
    var wachtwoord: String = ""
    var personId: Int? = nil
    var schoolDomein: String = "roercollege"
    
    var volledigeNaam: String {
        if voornaam.isEmpty && achternaam.isEmpty { return "Magister Gebruiker" }
        return "\(voornaam) \(achternaam)".trimmingCharacters(in: .whitespaces)
    }
    
    var geformatteerdDomein: String {
        var d = schoolDomein.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        d = d.replacingOccurrences(of: "https://", with: "")
        d = d.replacingOccurrences(of: "http://", with: "")
        d = d.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        if d.isEmpty { return "" }
        if !d.contains(".magister.net") { d += ".magister.net" }
        return d
    }
}

struct MagisterLes: Identifiable {
    let id = UUID()
    let uur: String
    let vak: String
    let lokaal: String
    let tijd: String
}

// MARK: - Hoofdscherm (MagisterSectie)
struct MagisterSectie: View {
    @AppStorage("isMagisterLoggedIn") private var isLoggedIn: Bool = false
    
    @State private var showLoginPopup: Bool = false
    @State private var logText: String = "Logboek gestart...\n"
    @State private var gebruiker = MagisterGebruikerModel()
    
    @State private var accessToken: String = ""
    @State private var mijnRooster: [MagisterLes] = []
    @State private var isLoadingRooster: Bool = false
    @State private var roosterFoutmelding: String? = nil
    @State private var startInlogFoutmelding: String? = nil
    @State private var cookieStatusMeldingText: String = ""
    @State private var laatstVerverstTekst: String = ""
    
    var magisterStartURL: URL {
        let domein = gebruiker.geformatteerdDomein.isEmpty ? "roercollege.magister.net" : gebruiker.geformatteerdDomein
        return URL(string: "https://\(domein)/") ?? URL(string: "https://roercollege.magister.net/")!
    }
    
    var body: some View {
        VStack {
            if isLoggedIn {
                dashboardView
            } else {
                startView
            }
        }
        .onAppear { herstelSessie() }
        .sheet(isPresented: $showLoginPopup) {
            MagisterLoginPopupView(
                isLoggedIn: $isLoggedIn,
                showLoginPopup: $showLoginPopup,
                logText: $logText,
                gebruiker: $gebruiker,
                accessToken: $accessToken,
                magisterURL: magisterStartURL,
                onLoginSuccess: { 
                    laadLiveRooster()
                    MagisterManager.shared.laadHuiswerkEnRooster()
                }
            )
        }
    }
    
    private func herstelSessie() {
        if let savedDomein = MagisterAppStorageHelper.read(key: "magister_domein"), !savedDomein.isEmpty { gebruiker.schoolDomein = savedDomein }
        if let savedUsername = leesGeheim(key: "magister_username") { gebruiker.gebruikersnaam = savedUsername }
        if let savedPassword = leesGeheim(key: "magister_password") { gebruiker.wachtwoord = savedPassword }
        if let savedVoornaam = MagisterAppStorageHelper.read(key: "magister_voornaam") { gebruiker.voornaam = savedVoornaam }
        if let savedAchternaam = MagisterAppStorageHelper.read(key: "magister_achternaam") { gebruiker.achternaam = savedAchternaam }
        
        if let savedToken = leesGeheim(key: "magister_access_token"), !savedToken.isEmpty {
            self.accessToken = savedToken
            self.isLoggedIn = true
            self.laadLiveRooster()
            MagisterManager.shared.laadHuiswerkEnRooster()
        } else {
            self.isLoggedIn = false
        }
    }
    
    private func leesGeheim(key: String) -> String? {
        if let value = MagisterKeychainHelper.read(key: key) {
            return value
        }
        
        guard let legacyValue = MagisterAppStorageHelper.read(key: key), !legacyValue.isEmpty else {
            return nil
        }
        
        MagisterKeychainHelper.save(legacyValue, key: key)
        MagisterAppStorageHelper.delete(key: key)
        return legacyValue
    }
    
    var startView: some View {
        VStack(spacing: 20) {
            Image(systemName: "graduationcap.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
                .padding(.top, 10)
            
            Text("Magister Koppelen")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Schooldomein:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("bijv. roercollege", text: $gebruiker.schoolDomein)
                        .padding(12)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gebruikersnaam / Leerlingnummer:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("bijv. 123456", text: $gebruiker.gebruikersnaam)
                        .padding(12)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wachtwoord:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    SecureField("Wachtwoord", text: $gebruiker.wachtwoord)
                        .padding(12)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                
                if let fout = startInlogFoutmelding {
                    Text(fout).font(.caption).foregroundColor(.red)
                }
            }
            
            Button(action: {
                if !MagisterNetworkMonitor.shared.isConnected {
                    startInlogFoutmelding = "Geen wifi of internetverbinding beschikbaar."
                    return
                }
                if gebruiker.geformatteerdDomein.isEmpty {
                    startInlogFoutmelding = "Vul a.u.b. een schoolnaam in."
                    return
                }
                
                gebruiker.personId = nil
                gebruiker.voornaam = ""
                gebruiker.achternaam = ""
                gebruiker.email = ""
                accessToken = ""
                laatstVerverstTekst = ""
                
                MagisterKeychainHelper.delete(key: "magister_access_token")
                MagisterAppStorageHelper.save(gebruiker.schoolDomein, key: "magister_domein")
                MagisterKeychainHelper.save(gebruiker.gebruikersnaam, key: "magister_username")
                MagisterKeychainHelper.save(gebruiker.wachtwoord, key: "magister_password")
                MagisterAppStorageHelper.delete(key: "magister_username")
                MagisterAppStorageHelper.delete(key: "magister_password")
                
                URLCache.shared.removeAllCachedResponses()
                startInlogFoutmelding = nil
                logText = "Logboek gestart...\nDoel URL: https://\(gebruiker.geformatteerdDomein)/\n"
                
                WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0)) {
                    DispatchQueue.main.async { showLoginPopup = true }
                }
            }) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                    Text("Inloggen met Magister")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    var dashboardView: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                ZStack {
                    Circle().fill(Color.orange).frame(width: 70, height: 70)
                    Text(gebruikerInitialen).font(.title.bold()).foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(gebruiker.volledigeNaam).font(.title2).bold().foregroundColor(.white)
                    
                    if !gebruiker.email.isEmpty {
                        Text(gebruiker.email).font(.subheadline).foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: accessToken.isEmpty ? "xmark.circle.fill" : "checkmark.circle.fill").font(.caption2)
                        Text(accessToken.isEmpty ? "Sessie status: Inactief" : "Sessie status: Actief").font(.caption2)
                    }
                    .foregroundColor(accessToken.isEmpty ? Color.red : Color.green)
                }
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
            
            VStack(spacing: 6) {
                Button(action: {
                    self.accessToken = ""
                    self.gebruiker.personId = nil
                    MagisterKeychainHelper.delete(key: "magister_access_token")
                    URLCache.shared.removeAllCachedResponses()
                    WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0)) {
                        DispatchQueue.main.async {
                            self.cookieStatusMeldingText = "Sessie & cookies gewist! Rooster blijft zichtbaar."
                            Task { try? await Task.sleep(nanoseconds: 3_000_000_000); self.cookieStatusMeldingText = "" }
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Sessie & Cookies Wissen")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.red)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(10)
                }
                
                if !cookieStatusMeldingText.isEmpty {
                    Text(cookieStatusMeldingText).font(.caption.bold()).foregroundColor(.orange)
                }
            }
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mijn Live Rooster (Vandaag)").font(.headline).foregroundColor(.white)
                        if !laatstVerverstTekst.isEmpty {
                            Text(laatstVerverstTekst).font(.caption).foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Button(action: { 
                        laadLiveRooster()
                        MagisterManager.shared.laadHuiswerkEnRooster()
                    }) {
                        Image(systemName: "arrow.clockwise").font(.subheadline).foregroundColor(.orange)
                    }
                }
                .padding(.bottom, 5)
                
                if isLoadingRooster {
                    HStack {
                        Spacer()
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .orange)).padding()
                        Spacer()
                    }
                }
                
                if let error = roosterFoutmelding {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                            Text("Foutmelding / Status").font(.caption.bold()).foregroundColor(.red)
                            Spacer()
                        }
                        ScrollView {
                            Text(error).font(.footnote).foregroundColor(.red).frame(maxWidth: .infinity, alignment: .leading)
                        }.frame(maxHeight: 80)
                        Button("Sessie Vernieuwen via Cookie") {
                            showLoginPopup = true
                        }
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.bottom, 8)
                }
                
                if mijnRooster.isEmpty && !isLoadingRooster {
                    Text("Geen lessen meer ingepland voor vandaag!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                } else {
                    ForEach(mijnRooster) { les in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(les.uur).bold().foregroundColor(.white)
                                Text(les.tijd).font(.caption2).foregroundColor(.gray)
                            }
                            .frame(width: 50, alignment: .leading)
                            
                            Text(les.vak).font(.body.weight(.medium)).foregroundColor(.white)
                            Spacer()
                            Text(les.lokaal).font(.subheadline).foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                        .padding(.bottom, 2)
                    }
                }
            }
            
            VStack(spacing: 12) {
                Button("Uitloggen (Naar Startscherm)") {
                    isLoggedIn = false
                    accessToken = ""
                    MagisterKeychainHelper.delete(key: "magister_access_token")
                }
                .font(.subheadline)
                .foregroundColor(.orange)
                
                Button("Volledig Uitloggen & Alles Wissen") {
                    isLoggedIn = false
                    accessToken = ""
                    gebruiker = MagisterGebruikerModel()
                    mijnRooster = []
                    MagisterKeychainHelper.delete(key: "magister_access_token")
                    MagisterKeychainHelper.delete(key: "magister_username")
                    MagisterKeychainHelper.delete(key: "magister_password")
                    if let bundleID = Bundle.main.bundleIdentifier { UserDefaults.standard.removePersistentDomain(forName: bundleID) }
                    WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0)) {}
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    var gebruikerInitialen: String {
        let v = gebruiker.voornaam.prefix(1)
        let a = gebruiker.achternaam.prefix(1)
        return "\(v)\(a)".uppercased()
    }
    
    func laadLiveRooster() {
        if !MagisterNetworkMonitor.shared.isConnected {
            roosterFoutmelding = "Geen internetverbinding."
            isLoadingRooster = false; return
        }
        guard !accessToken.isEmpty else {
            roosterFoutmelding = "Access Token ontbreekt."
            showLoginPopup = true; return
        }
        let domein = gebruiker.geformatteerdDomein
        isLoadingRooster = true
        roosterFoutmelding = nil
        
        guard let accountURL = URL(string: "https://\(domein)/api/account") else { return }
        var request = URLRequest(url: accountURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                DispatchQueue.main.async { self.isLoadingRooster = false; self.roosterFoutmelding = "Sessie-token verlopen (401)."; self.showLoginPopup = true }
                return
            }
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async { self.roosterFoutmelding = "Fout bij ophalen account data."; self.isLoadingRooster = false }
                return
            }
            
            var pId: Int? = nil
            let subDictKeys = ["Persoon", "persoon", "Person", "person", "User", "user", "Account", "account"]
            for subKey in subDictKeys {
                if let subDict = json[subKey] as? [String: Any], let foundId = subDict["Id"] as? Int ?? subDict["id"] as? Int {
                    pId = foundId
                    DispatchQueue.main.async {
                        self.gebruiker.voornaam = subDict["Roepnaam"] as? String ?? ""
                        self.gebruiker.achternaam = subDict["Achternaam"] as? String ?? ""
                    }
                    break
                }
            }
            
            if let personId = pId ?? json["Id"] as? Int ?? json["id"] as? Int {
                DispatchQueue.main.async { self.gebruiker.personId = personId }
                self.haalAfsprakenOp(personId: personId, domein: domein)
            } else {
                DispatchQueue.main.async { self.roosterFoutmelding = "Persoon ID niet gevonden."; self.isLoadingRooster = false }
            }
        }.resume()
    }
    
    private func haalAfsprakenOp(personId: Int, domein: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let vandaagStr = formatter.string(from: Date())
        
        guard let afsprakenURL = URL(string: "https://\(domein)/api/personen/\(personId)/afspraken?van=\(vandaagStr)&tot=\(vandaagStr)") else { return }
        var request = URLRequest(url: afsprakenURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.isLoadingRooster = false }
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let items = json["Items"] as? [[String: Any]] else {
                DispatchQueue.main.async { self.roosterFoutmelding = "Geen afspraken ontvangen." }
                return
            }
            
            var nieuweLessen: [MagisterLes] = []
            for item in items {
                let omschrijving = item["Omschrijving"] as? String ?? item["Inhoud"] as? String ?? "Les"
                let lokaal = item["Lokatie"] as? String ?? "Onbekend"
                let lesuur = item["LesuurVan"] as? Int
                let uurStr = lesuur != nil ? "\(lesuur!)e" : "-"
                var tijdStr = ""
                if let begin = item["Begin"] as? String { tijdStr = String(begin.prefix(16).suffix(5)) }
                nieuweLessen.append(MagisterLes(uur: uurStr, vak: omschrijving, lokaal: lokaal, tijd: tijdStr))
            }
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            
            DispatchQueue.main.async {
                self.mijnRooster = nieuweLessen
                self.laatstVerverstTekst = "Laatst vernieuwd om \(timeFormatter.string(from: Date()))"
            }
        }.resume()
    }
}

// MARK: - Login Popup Met Log-Terminal
struct MagisterLoginPopupView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showLoginPopup: Bool
    @Binding var logText: String
    @Binding var gebruiker: MagisterGebruikerModel
    @Binding var accessToken: String
    let magisterURL: URL
    var onLoginSuccess: () -> Void
    
    @State private var kopieerMelding: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                MagisterWKWebView(
                    url: magisterURL,
                    logText: $logText,
                    isLoggedIn: $isLoggedIn,
                    showLoginPopup: $showLoginPopup,
                    gebruiker: $gebruiker,
                    accessToken: $accessToken,
                    onLoginSuccess: onLoginSuccess
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Logboek")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            UIPasteboard.general.string = logText
                            kopieerMelding = "Gekopieerd!"
                            Task {
                                try? await Task.sleep(nanoseconds: 2_000_000_000)
                                kopieerMelding = ""
                            }
                        }) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text(kopieerMelding.isEmpty ? "Kopieer logboek" : kopieerMelding)
                            }
                            .font(.caption)
                            .padding(6)
                            .background(Color.blue.opacity(0.15))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    TextEditor(text: $logText)
                        .font(.system(.footnote, design: .monospaced))
                        .frame(height: 110)
                        .padding(4)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(6)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
                .background(Color.white.opacity(0.05))
            }
            .navigationTitle("Magister Inloggen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sluiten") { showLoginPopup = false }
                }
            }
        }
    }
}

// MARK: - WKWebView Met Uitgebreide Logging Handlers
struct MagisterWKWebView: UIViewRepresentable {
    let url: URL
    @Binding var logText: String
    @Binding var isLoggedIn: Bool
    @Binding var showLoginPopup: Bool
    @Binding var gebruiker: MagisterGebruikerModel
    @Binding var accessToken: String
    var onLoginSuccess: () -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let webpagePreferences = WKWebpagePreferences()
        webpagePreferences.allowsContentJavaScript = true
        
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "logHandler")
        
        let config = WKWebViewConfiguration()
        config.preferences = preferences
        config.defaultWebpagePreferences = webpagePreferences
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
        
        webView.navigationDelegate = context.coordinator
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: MagisterWKWebView
        private var loginCompletionHandled = false
        
        init(_ parent: MagisterWKWebView) { self.parent = parent }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "logHandler", let body = message.body as? String {
                DispatchQueue.main.async { self.parent.logText += "\n" + body }
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                checkHost(url)
                DispatchQueue.main.async {
                    self.parent.logText += "\n🔄 Navigatie: \(self.veiligeURLBeschrijving(url))"
                    self.verwerkURL(url)
                }
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if let url = webView.url {
                checkHost(url)
                DispatchQueue.main.async {
                    self.parent.logText += "\n⏳ Laden: \(self.veiligeURLBeschrijving(url))"
                    self.verwerkURL(url)
                }
            }
        }
        
        private func checkHost(_ url: URL) {
            if let host = url.host, host.hasSuffix(".magister.net"), host != "accounts.magister.net" {
                DispatchQueue.main.async {
                    let schoolNaam = host.replacingOccurrences(of: ".magister.net", with: "")
                    self.parent.gebruiker.schoolDomein = schoolNaam
                    MagisterAppStorageHelper.save(schoolNaam, key: "magister_domein")
                }
            }
        }
        
        private func verwerkURL(_ url: URL) {
            let parameters = callbackParameters(from: url)
            var extractedToken: String? = nil
            
            if let token = parameters["access_token"], !token.isEmpty {
                extractedToken = token
                DispatchQueue.main.async {
                    self.parent.accessToken = token
                    MagisterKeychainHelper.save(token, key: "magister_access_token")
                    MagisterAppStorageHelper.saveDate(Date(), key: "magister_last_login_date")
                }
            }
            
            if let idToken = parameters["id_token"],
               let payload = parseJWTPayload(idToken) {
                DispatchQueue.main.async {
                    if let voornaam = payload["given_name"] as? String {
                        self.parent.gebruiker.voornaam = voornaam
                        MagisterAppStorageHelper.save(voornaam, key: "magister_voornaam")
                    }
                    if let achternaam = payload["family_name"] as? String {
                        self.parent.gebruiker.achternaam = achternaam
                        MagisterAppStorageHelper.save(achternaam, key: "magister_achternaam")
                    }
                    if let email = payload["email"] as? String {
                        self.parent.gebruiker.email = email
                    }
                    if let username = payload["preferred_username"] as? String {
                        self.parent.gebruiker.gebruikersnaam = username
                        MagisterKeychainHelper.save(username, key: "magister_username")
                        MagisterAppStorageHelper.delete(key: "magister_username")
                    }
                }
            }
            
            guard let validToken = extractedToken,
                  !validToken.isEmpty,
                  !loginCompletionHandled else { return }
            
            loginCompletionHandled = true
            DispatchQueue.main.async {
                self.parent.accessToken = validToken
                MagisterKeychainHelper.save(validToken, key: "magister_access_token")
                MagisterAppStorageHelper.save(self.parent.gebruiker.schoolDomein, key: "magister_domein")
                MagisterKeychainHelper.save(self.parent.gebruiker.gebruikersnaam, key: "magister_username")
                MagisterKeychainHelper.save(self.parent.gebruiker.wachtwoord, key: "magister_password")
                MagisterAppStorageHelper.delete(key: "magister_username")
                MagisterAppStorageHelper.delete(key: "magister_password")
                
                self.parent.isLoggedIn = true
                self.parent.showLoginPopup = false
                self.parent.onLoginSuccess()
            }
        }
        
        private func callbackParameters(from url: URL) -> [String: String] {
            let queryParameters: [(String, String)] = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.compactMap { item in
                guard let value = item.value else { return nil }
                return (item.name, value)
            } ?? []
            var parameters: [String: String] = Dictionary(uniqueKeysWithValues: queryParameters)
            
            if let fragment = url.fragment,
               let fragmentComponents = URLComponents(string: "https://callback.invalid/?\(fragment)") {
                for item in fragmentComponents.queryItems ?? [] {
                    if let value = item.value {
                        parameters[item.name] = value
                    }
                }
            }
            return parameters
        }
        
        private func veiligeURLBeschrijving(_ url: URL) -> String {
            let host = url.host ?? "onbekende host"
            let path = url.path.isEmpty ? "/" : url.path
            return "https://\(host)\(path)"
        }
        
        private func javaScriptString(_ value: String) -> String {
            guard let data = try? JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed]),
                  let encodedValue = String(data: data, encoding: .utf8) else {
                return "\"\""
            }
            return encodedValue
        }
        
        private func parseJWTPayload(_ jwtToken: String) -> [String: Any]? {
            let segments = jwtToken.components(separatedBy: ".")
            guard segments.count > 1 else { return nil }
            
            var base64String = segments[1]
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            
            let length = Double(base64String.lengthOfBytes(using: .utf8))
            let requiredLength = 4 * ceil(length / 4.0)
            let paddingLength = Int(requiredLength - length)
            if paddingLength > 0 {
                let padding = String(repeating: "=", count: paddingLength)
                base64String += padding
            }
            
            guard let data = Data(base64Encoded: base64String) else { return nil }
            return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let url = webView.url {
                DispatchQueue.main.async { self.parent.logText += "\n✅ Pagina Geladen: \(self.veiligeURLBeschrijving(url))" }
                
                let savedUsername = MagisterKeychainHelper.read(key: "magister_username") ?? self.parent.gebruiker.gebruikersnaam
                let savedPassword = MagisterKeychainHelper.read(key: "magister_password") ?? self.parent.gebruiker.wachtwoord
                
                if url.host == "accounts.magister.net" {
                    let usernameJSON = javaScriptString(savedUsername)
                    let passwordJSON = javaScriptString(savedPassword)
                    let autoLoginJS = """
                    (function() {
                        if (window.magisterAutoRunner) return;
                        window.magisterAutoRunner = true;
                    
                        var username = \(usernameJSON);
                        var password = \(passwordJSON);
                    
                        function setNativeValue(element, value) {
                            var valueSetter = Object.getOwnPropertyDescriptor(element, 'value') || 
                                              Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value');
                            if (valueSetter && valueSetter.set) {
                                valueSetter.set.call(element, value);
                            } else {
                                element.value = value;
                            }
                            element.dispatchEvent(new Event('input', { bubbles: true }));
                            element.dispatchEvent(new Event('change', { bubbles: true }));
                            element.dispatchEvent(new Event('blur', { bubbles: true }));
                        }
                    
                        var isBusy = false;
                        var interval = setInterval(function() {
                            if (isBusy) return;
                    
                            var usernameInput = document.querySelector('input#username') || document.querySelector('input[type="text"]');
                            var usernameBtn = document.querySelector('sl-button#username_submit') || document.querySelector('#username_submit');
                            var usePasswordBtn = document.querySelector('sl-button#use_password_button') || document.querySelector('#use_password_button');
                            var passwordInput = document.querySelector('input#password') || document.querySelector('input[type="password"]');
                            var passwordBtn = document.querySelector('sl-button#password_submit') || document.querySelector('#password_submit');
                    
                            if (usernameInput && usernameInput.offsetParent !== null && !passwordInput && usernameInput.value !== username) {
                                isBusy = true;
                                setNativeValue(usernameInput, username);
                                setTimeout(function() {
                                    if (usernameBtn) usernameBtn.click();
                                    isBusy = false;
                                }, 600);
                                return;
                            }
                    
                            if (usePasswordBtn && usePasswordBtn.offsetParent !== null && !passwordInput) {
                                isBusy = true;
                                setTimeout(function() {
                                    usePasswordBtn.click();
                                    isBusy = false;
                                }, 400);
                                return;
                            }
                    
                            if (passwordInput && passwordInput.offsetParent !== null && passwordInput.value !== password) {
                                isBusy = true;
                                setNativeValue(passwordInput, password);
                                setTimeout(function() {
                                    if (passwordBtn) passwordBtn.click();
                                    clearInterval(interval);
                                    isBusy = false;
                                }, 600);
                                return;
                            }
                        }, 300);
                    })();
                    """
                    webView.evaluateJavaScript(autoLoginJS, completionHandler: nil)
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.parent.logText += "\n❌ Fout: \(error.localizedDescription)" }
        }
    }
}
