import SwiftUI
import WebKit
import UIKit
import Network

// MARK: - Network / WiFi Monitor Helper
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

// MARK: - Models
struct MagisterUserModel {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var username: String = ""
    var password: String = ""
    var personId: Int? = nil
    var schoolDomain: String = "roercollege"
    
    var fullName: String {
        if firstName.isEmpty && lastName.isEmpty { return "Magister User" }
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    var formattedDomain: String {
        var d = schoolDomain.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        d = d.replacingOccurrences(of: "https://", with: "")
        d = d.replacingOccurrences(of: "http://", with: "")
        d = d.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        if d.isEmpty { return "" }
        if !d.contains(".magister.net") { d += ".magister.net" }
        return d
    }
}

struct MagisterLesson: Identifiable {
    let id = UUID()
    let period: String
    let subject: String
    let room: String
    let timeStr: String
}

// MARK: - Main View (MagisterSection)
struct MagisterSection: View {
    @AppStorage("isMagisterLoggedIn") private var isLoggedIn: Bool = false
    
    @State private var showLoginPopup: Bool = false
    @State private var logText: String = "Log started...\n"
    @State private var user = MagisterUserModel()
    
    @State private var accessToken: String = ""
    @State private var mySchedule: [MagisterLesson] = []
    @State private var isLoadingSchedule: Bool = false
    @State private var scheduleError: String? = nil
    @State private var startLoginError: String? = nil
    @State private var cookieStatusMessageText: String = ""
    @State private var lastRefreshedText: String = ""
    
    var magisterStartURL: URL {
        let domain = user.formattedDomain.isEmpty ? "roercollege.magister.net" : user.formattedDomain
        return URL(string: "https://\(domain)/") ?? URL(string: "https://roercollege.magister.net/")!
    }
    
    var body: some View {
        VStack {
            if isLoggedIn {
                dashboardView
            } else {
                startView
            }
        }
        .onAppear { restoreSession() }
        .sheet(isPresented: $showLoginPopup) {
            MagisterLoginPopupView(
                isLoggedIn: $isLoggedIn,
                showLoginPopup: $showLoginPopup,
                logText: $logText,
                user: $user,
                accessToken: $accessToken,
                magisterURL: magisterStartURL,
                onLoginSuccess: { 
                    loadLiveSchedule()
                    MagisterManager.shared.loadHomeworkAndSchedule()
                }
            )
        }
    }
    
    private func restoreSession() {
        if let savedDomein = MagisterAppStorageHelper.read(key: "magister_domein"), !savedDomein.isEmpty { user.schoolDomain = savedDomein }
        if let savedUsername = readSecret(key: "magister_username") { user.username = savedUsername }
        if let savedPassword = readSecret(key: "magister_password") { user.password = savedPassword }
        if let savedFirstName = MagisterAppStorageHelper.read(key: "magister_voornaam") { user.firstName = savedFirstName }
        if let savedLastName = MagisterAppStorageHelper.read(key: "magister_achternaam") { user.lastName = savedLastName }
        
        if let savedToken = leesGeheim(key: "magister_access_token"), !savedToken.isEmpty {
            self.accessToken = savedToken
            self.isLoggedIn = true
            self.loadLiveSchedule()
            MagisterManager.shared.loadHomeworkAndSchedule()
        } else {
            self.isLoggedIn = false
        }
    }
    
    private func readSecret(key: String) -> String? {
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
            
            Text("Connect Magister")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("School domain:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("e.g. roercollege", text: $user.schoolDomain)
                        .padding(12)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Username / Student number:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("e.g. 123456", text: $user.username)
                        .padding(12)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Password:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    SecureField("Password", text: $user.password)
                        .padding(12)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                
                if let errorMsg = startLoginError {
                    Text(errorMsg).font(.caption).foregroundColor(.red)
                }
            }
            
            Button(action: {
                if !MagisterNetworkMonitor.shared.isConnected {
                    startLoginError = "No wifi or internet connection available."
                    return
                }
                if user.formattedDomain.isEmpty {
                    startLoginError = "Please enter a school name."
                    return
                }
                
                user.personId = nil
                user.firstName = ""
                user.lastName = ""
                user.email = ""
                accessToken = ""
                laatstVerverstTekst = ""
                
                MagisterKeychainHelper.delete(key: "magister_access_token")
                MagisterAppStorageHelper.save(user.schoolDomain, key: "magister_domein")
                MagisterKeychainHelper.save(user.username, key: "magister_username")
                MagisterKeychainHelper.save(user.password, key: "magister_password")
                MagisterAppStorageHelper.delete(key: "magister_username")
                MagisterAppStorageHelper.delete(key: "magister_password")
                
                URLCache.shared.removeAllCachedResponses()
                startLoginError = nil
                logText = "Log started...\nTarget URL: https://\(user.formattedDomain)/\n"
                
                WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0)) {
                    DispatchQueue.main.async { showLoginPopup = true }
                }
            }) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                    Text("Log in with Magister")
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
                    Text(userInitials).font(.title.bold()).foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullName).font(.title2).bold().foregroundColor(.white)
                    
                    if !user.email.isEmpty {
                        Text(user.email).font(.subheadline).foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: accessToken.isEmpty ? "xmark.circle.fill" : "checkmark.circle.fill").font(.caption2)
                        Text(accessToken.isEmpty ? "Session status: Inactive" : "Session status: Active").font(.caption2)
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
                    self.user.personId = nil
                    MagisterKeychainHelper.delete(key: "magister_access_token")
                    URLCache.shared.removeAllCachedResponses()
                    WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0)) {
                        DispatchQueue.main.async {
                            self.cookieStatusMessageText = "Session & cookies cleared! Schedule remains visible."
                            Task { try? await Task.sleep(nanoseconds: 3_000_000_000); self.cookieStatusMessageText = "" }
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Clear Session & Cookies")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.red)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(10)
                }
                
                if !cookieStatusMessageText.isEmpty {
                    Text(cookieStatusMessageText).font(.caption.bold()).foregroundColor(.orange)
                }
            }
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("My Live Schedule (Today)").font(.headline).foregroundColor(.white)
                        if !lastRefreshedText.isEmpty {
                            Text(lastRefreshedText).font(.caption).foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Button(action: { 
                        loadLiveSchedule()
                        MagisterManager.shared.loadHomeworkAndSchedule()
                    }) {
                        Image(systemName: "arrow.clockwise").font(.subheadline).foregroundColor(.orange)
                    }
                }
                .padding(.bottom, 5)
                
                if isLoadingSchedule {
                    HStack {
                        Spacer()
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .orange)).padding()
                        Spacer()
                    }
                }
                
                if let error = scheduleError {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                            Text("Error / Status").font(.caption.bold()).foregroundColor(.red)
                            Spacer()
                        }
                        ScrollView {
                            Text(error).font(.footnote).foregroundColor(.red).frame(maxWidth: .infinity, alignment: .leading)
                        }.frame(maxHeight: 80)
                        Button("Refresh Session via Cookie") {
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
                
                if mySchedule.isEmpty && !isLoadingSchedule {
                    Text("No more lessons scheduled for today!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                } else {
                    ForEach(mySchedule) { lesson in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(lesson.period).bold().foregroundColor(.white)
                                Text(lesson.timeStr).font(.caption2).foregroundColor(.gray)
                            }
                            .frame(width: 50, alignment: .leading)
                            
                            Text(lesson.subject).font(.body.weight(.medium)).foregroundColor(.white)
                            Spacer()
                            Text(lesson.room).font(.subheadline).foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                        .padding(.bottom, 2)
                    }
                }
            }
            
            VStack(spacing: 12) {
                Button("Log Out (To Start Screen)") {
                    isLoggedIn = false
                    accessToken = ""
                    MagisterKeychainHelper.delete(key: "magister_access_token")
                }
                .font(.subheadline)
                .foregroundColor(.orange)
                
                Button("Full Log Out & Clear All") {
                    isLoggedIn = false
                    accessToken = ""
                    user = MagisterUserModel()
                    mySchedule = []
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
    
    var userInitials: String {
        let v = user.firstName.prefix(1)
        let a = user.lastName.prefix(1)
        return "\(v)\(a)".uppercased()
    }
    
    func loadLiveSchedule() {
        if !MagisterNetworkMonitor.shared.isConnected {
            scheduleError = "No internet connection."
            isLoadingSchedule = false; return
        }
        guard !accessToken.isEmpty else {
            scheduleError = "Access Token missing."
            showLoginPopup = true; return
        }
        let domein = user.formattedDomain
        isLoadingSchedule = true
        scheduleError = nil
        
        guard let accountURL = URL(string: "https://\(domein)/api/account") else { return }
        var request = URLRequest(url: accountURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                DispatchQueue.main.async { self.isLoadingSchedule = false; self.scheduleError = "Session token expired (401)."; self.showLoginPopup = true }
                return
            }
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async { self.scheduleError = "Error fetching account data."; self.isLoadingSchedule = false }
                return
            }
            
            var pId: Int? = nil
            let subDictKeys = ["Persoon", "persoon", "Person", "person", "User", "user", "Account", "account"]
            for subKey in subDictKeys {
                if let subDict = json[subKey] as? [String: Any], let foundId = subDict["Id"] as? Int ?? subDict["id"] as? Int {
                    pId = foundId
                    DispatchQueue.main.async {
                        self.user.firstName = subDict["Roepnaam"] as? String ?? ""
                        self.user.lastName = subDict["Achternaam"] as? String ?? ""
                    }
                    break
                }
            }
            
            if let personId = pId ?? json["Id"] as? Int ?? json["id"] as? Int {
                DispatchQueue.main.async { self.user.personId = personId }
                self.fetchAppointments(personId: personId, domein: domein)
            } else {
                DispatchQueue.main.async { self.scheduleError = "Person ID not found."; self.isLoadingSchedule = false }
            }
        }.resume()
    }
    
    private func fetchAppointments(personId: Int, domein: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        
        guard let appointmentsURL = URL(string: "https://\(domein)/api/personen/\(personId)/afspraken?van=\(todayStr)&tot=\(todayStr)") else { return }
        var request = URLRequest(url: appointmentsURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.isLoadingSchedule = false }
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let items = json["Items"] as? [[String: Any]] else {
                DispatchQueue.main.async { self.scheduleError = "No appointments received." }
                return
            }
            
            var newLessons: [MagisterLesson] = []
            for item in items {
                let lessonDesc = item["Omschrijving"] as? String ?? item["Inhoud"] as? String ?? "Lesson"
                let room = item["Lokatie"] as? String ?? "Unknown"
                let lessonHour = item["LesuurVan"] as? Int
                let hourStr = lesuur != nil ? "\(lesuur!)e" : "-"
                var tijdStr = ""
                if let begin = item["Begin"] as? String { tijdStr = String(begin.prefix(16).suffix(5)) }
                newLessons.append(MagisterLesson(period: uurStr, subject: lessonDesc, room: room, timeStr: tijdStr))
            }
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            
            DispatchQueue.main.async {
                self.mySchedule = newLessons
                self.lastRefreshedText = "Last updated at \(timeFormatter.string(from: Date()))"
            }
        }.resume()
    }
}

// MARK: - Login Popup With Log Terminal
struct MagisterLoginPopupView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showLoginPopup: Bool
    @Binding var logText: String
    @Binding var user: MagisterUserModel
    @Binding var accessToken: String
    let magisterURL: URL
    var onLoginSuccess: () -> Void
    
    @State private var copyMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                MagisterWKWebView(
                    url: magisterURL,
                    logText: $logText,
                    isLoggedIn: $isLoggedIn,
                    showLoginPopup: $showLoginPopup,
                    user: $user,
                    accessToken: $accessToken,
                    onLoginSuccess: onLoginSuccess
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Log")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            UIPasteboard.general.string = logText
                            copyMessage = "Copied!"
                            Task {
                                try? await Task.sleep(nanoseconds: 2_000_000_000)
                                copyMessage = ""
                            }
                        }) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text(copyMessage.isEmpty ? "Copy log" : copyMessage)
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
            .navigationTitle("Magister Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { showLoginPopup = false }
                }
            }
        }
    }
}

// MARK: - WKWebView With Extended Logging Handlers
struct MagisterWKWebView: UIViewRepresentable {
    let url: URL
    @Binding var logText: String
    @Binding var isLoggedIn: Bool
    @Binding var showLoginPopup: Bool
    @Binding var user: MagisterUserModel
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
                    self.parent.logText += "\n🔄 Navigation: \(self.safeURLDescription(url))"
                    self.processURL(url)
                }
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if let url = webView.url {
                checkHost(url)
                DispatchQueue.main.async {
                    self.parent.logText += "\n⏳ Loading: \(self.safeURLDescription(url))"
                    self.processURL(url)
                }
            }
        }
        
        private func checkHost(_ url: URL) {
            if let host = url.host, host.hasSuffix(".magister.net"), host != "accounts.magister.net" {
                DispatchQueue.main.async {
                    let schoolName = host.replacingOccurrences(of: ".magister.net", with: "")
                    self.parent.user.schoolDomain = schoolName
                    MagisterAppStorageHelper.save(schoolName, key: "magister_domein")
                }
            }
        }
        
        private func processURL(_ url: URL) {
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
                    if let firstName = payload["given_name"] as? String {
                        self.parent.user.firstName = firstName
                        MagisterAppStorageHelper.save(firstName, key: "magister_voornaam")
                    }
                    if let lastName = payload["family_name"] as? String {
                        self.parent.user.lastName = lastName
                        MagisterAppStorageHelper.save(lastName, key: "magister_achternaam")
                    }
                    if let email = payload["email"] as? String {
                        self.parent.user.email = email
                    }
                    if let username = payload["preferred_username"] as? String {
                        self.parent.user.username = username
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
                MagisterAppStorageHelper.save(self.parent.user.schoolDomain, key: "magister_domein")
                MagisterKeychainHelper.save(self.parent.user.username, key: "magister_username")
                MagisterKeychainHelper.save(self.parent.user.password, key: "magister_password")
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
        
        private func safeURLDescription(_ url: URL) -> String {
            let host = url.host ?? "unknown host"
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
                DispatchQueue.main.async { self.parent.logText += "\n✅ Page Loaded: \(self.safeURLDescription(url))" }
                
                let savedUsername = MagisterKeychainHelper.read(key: "magister_username") ?? self.parent.user.username
                let savedPassword = MagisterKeychainHelper.read(key: "magister_password") ?? self.parent.user.password
                
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
            DispatchQueue.main.async { self.parent.logText += "\n❌ Error: \(error.localizedDescription)" }
        }
    }
}
