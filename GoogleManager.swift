import SwiftUI
import AuthenticationServices
import CryptoKit

// MARK: - API Modellen
struct DriveFile: Codable, Identifiable {
    let id: String
    let name: String
    let mimeType: String?
    let webViewLink: String?
    let modifiedTime: String?
    
    var datum: Date {
        guard let timeStr = modifiedTime else { return Date.distantPast }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timeStr) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: timeStr) ?? Date.distantPast
    }
    
    var datumFormatted: String {
        guard modifiedTime != nil else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: datum, relativeTo: Date())
    }
}

struct DriveListResponse: Codable {
    let files: [DriveFile]?
    let nextPageToken: String?
}

struct ClassroomCourse: Codable, Identifiable {
    let id: String
    let name: String
}

enum ClassroomItemType: String { 
    case opdracht = "Opdracht"
    case aankondiging = "Aankondiging"
    case materiaal = "Materiaal" 
}

struct ClassroomItem: Identifiable {
    let id: String
    let titel: String
    let vakNaam: String
    let type: ClassroomItemType
    let url: String
    let datum: Date
    let kleur: Color
    let tekst: String?
    
    var datumFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: datum, relativeTo: Date())
    }
}

// MARK: - PKCE Hulpfuncties
func generateCodeVerifier() -> String {
    var buffer = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
    return Data(buffer).base64URLEncoded()
}

func generateCodeChallenge(from verifier: String) -> String {
    guard let data = verifier.data(using: .utf8) else { return "" }
    let hash = SHA256.hash(data: data)
    return Data(hash).base64URLEncoded()
}

extension Data {
    func base64URLEncoded() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// MARK: - Web Google Auth Manager
class WebGoogleAuthManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @AppStorage("google_access_token") var accessToken: String = ""
    @AppStorage("google_refresh_token") var refreshToken: String = ""
    @AppStorage("google_user_email") var userEmail: String = ""
    @AppStorage("google_user_name") var userName: String = ""
    @AppStorage("google_user_picture") var userPicture: String = ""
    
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String? = nil
    
    // Drive variabelen
    @Published var driveFiles: [DriveFile] = []
    @Published var driveNextPageToken: String? = nil
    @Published var isLoadingMoreFiles: Bool = false
    
    // Classroom variabelen
    @Published var classroomCourses: [ClassroomCourse] = []
    @Published var classroomItems: [ClassroomItem] = []
    @Published var isLoadingData: Bool = false
    @Published var isLoadingMoreClassroomItems: Bool = false
    @Published var classroomHasMoreItems: Bool = false
    
    // Classroom paginatie tokens per vak
    private var courseWorkTokens: [String: String] = [:]
    private var materialsTokens: [String: String] = [:]
    private var announcementsTokens: [String: String] = [:]
    
    let clientId = "957241245759-auud3t9qndam5rhclbufckgt8fidsten.apps.googleusercontent.com"
    let redirectScheme = "com.googleusercontent.apps.957241245759-auud3t9qndam5rhclbufckgt8fidsten"
    
    override init() {
        super.init()
        if !accessToken.isEmpty {
            self.isLoggedIn = true
            DispatchQueue.main.async {
                self.laadGoogleData()
            }
        }
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return window
            }
            return UIWindow(windowScene: windowScene)
        }
        return UIWindow(frame: UIScreen.main.bounds)
    }
    
    func startGoogleLogin() {
        errorMessage = nil
        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)
        let redirectUri = "\(redirectScheme):/oauth2redirect"
        
        let scopes = [
            "email",
            "profile",
            "https://www.googleapis.com/auth/drive.readonly",
            "https://www.googleapis.com/auth/classroom.courses.readonly",
            "https://www.googleapis.com/auth/classroom.coursework.me.readonly",
            "https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly",
            "https://www.googleapis.com/auth/classroom.announcements.readonly"
        ].joined(separator: " ")
        
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent")
        ]
        
        guard let authURL = components.url else { return }
        
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: redirectScheme) { callbackURL, error in
            if error != nil {
                DispatchQueue.main.async { self.errorMessage = "Login cancelled or failed." }
                return
            }
            guard let callbackURL = callbackURL,
                  let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems,
                  let code = queryItems.first(where: { $0.name == "code" })?.value else {
                DispatchQueue.main.async { self.errorMessage = "None geldige respons ontvangen." }
                return
            }
            
            self.exchangeCodeForToken(code: code, codeVerifier: codeVerifier, redirectUri: redirectUri)
        }
        
        session.presentationContextProvider = self
        session.start()
    }
    
    private func exchangeCodeForToken(code: String, codeVerifier: String, redirectUri: String) {
        guard let url = URL(string: "https://oauth2.googleapis.com/token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyComponents = [
            "client_id=\(clientId)",
            "code=\(code)",
            "code_verifier=\(codeVerifier)",
            "grant_type=authorization_code",
            "redirect_uri=\(redirectUri)"
        ]
        request.httpBody = bodyComponents.joined(separator: "&").data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["access_token"] as? String {
                DispatchQueue.main.async {
                    self.accessToken = token
                    if let refresh = json["refresh_token"] as? String {
                        self.refreshToken = refresh
                    }
                    self.isLoggedIn = true
                    self.fetchUserProfile(token: token)
                    self.laadGoogleData()
                }
            } else {
                DispatchQueue.main.async { self.errorMessage = "Error fetching tokens." }
            }
        }.resume()
    }
    
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard !refreshToken.isEmpty, let url = URL(string: "https://oauth2.googleapis.com/token") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyComponents = [
            "client_id=\(clientId)",
            "refresh_token=\(refreshToken)",
            "grant_type=refresh_token"
        ]
        request.httpBody = bodyComponents.joined(separator: "&").data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let newToken = json["access_token"] as? String else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            DispatchQueue.main.async {
                self.accessToken = newToken
                completion(true)
            }
        }.resume()
    }
    
    // Generieke netwerkfunctie met automatische token refresh
    private func fetchAuthenticatedData(url: URL, isRetry: Bool = false, completion: @escaping (Data?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401, !isRetry {
                self.refreshAccessToken { success in
                    if success {
                        self.fetchAuthenticatedData(url: url, isRetry: true, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Sessie verlopen. Log opnieuw in."
                            self.logout()
                        }
                        completion(nil, error)
                    }
                }
                return
            }
            completion(data, error)
        }.resume()
    }
    
    private func fetchUserProfile(token: String) {
        guard let url = URL(string: "https://www.googleapis.com/oauth2/v2/userinfo") else { return }
        fetchAuthenticatedData(url: url) { data, _ in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    self.userEmail = json["email"] as? String ?? ""
                    self.userName = json["name"] as? String ?? ""
                    self.userPicture = json["picture"] as? String ?? ""
                }
            }
        }
    }
    
    func laadGoogleData() {
        guard !accessToken.isEmpty else { return }
        DispatchQueue.main.async { 
            self.isLoadingData = true 
            self.classroomItems.removeAll()
            self.driveFiles.removeAll()
            self.driveNextPageToken = nil
            self.isLoadingMoreFiles = false
            self.courseWorkTokens.removeAll()
            self.materialsTokens.removeAll()
            self.announcementsTokens.removeAll()
        }
        
        fetchDriveFiles(mapId: nil, loadMore: false)
        fetchClassroomCourses()
    }
    
    // MARK: - Drive Ophalen
    func loadFilesForFolder(mapId: String?) {
        driveNextPageToken = nil
        isLoadingMoreFiles = false
        fetchDriveFiles(mapId: mapId, loadMore: false)
    }
    
    func loadMoreBestandenVoorMap(mapId: String?) {
        guard driveNextPageToken != nil, !isLoadingMoreFiles else { return }
        isLoadingMoreFiles = true
        fetchDriveFiles(mapId: mapId, loadMore: true)
    }
    
    private func fetchDriveFiles(mapId: String? = nil, loadMore: Bool = false) {
        let query: String
        if let parentId = mapId {
            query = "'\(parentId)' in parents and trashed = false"
        } else {
            query = "(mimeType != 'application/vnd.google-apps.folder' or 'root' in parents) and trashed = false"
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var urlString = "https://www.googleapis.com/drive/v3/files?q=\(encodedQuery)&pageSize=40&fields=nextPageToken,files(id,name,mimeType,webViewLink,modifiedTime)&orderBy=folder,name"
        
        if loadMore, let token = driveNextPageToken {
            urlString += "&pageToken=\(token)"
        }
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { self.isLoadingMoreFiles = false }
            return
        }
        
        fetchAuthenticatedData(url: url) { data, _ in
            if let data = data,
               let response = try? JSONDecoder().decode(DriveListResponse.self, from: data) {
                DispatchQueue.main.async {
                    let newFiles = response.files ?? []
                    
                    if loadMore {
                        var bestaande = self.driveFiles
                        for file in newFiles {
                            if !bestaande.contains(where: { $0.id == file.id }) {
                                bestaande.append(file)
                            }
                        }
                        self.driveFiles = bestaande
                    } else {
                        self.driveFiles = newFiles
                    }
                    
                    self.driveNextPageToken = response.nextPageToken
                    self.isLoadingMoreFiles = false
                }
            } else {
                DispatchQueue.main.async { self.isLoadingMoreFiles = false }
            }
        }
    }
    
    // MARK: - Classroom Ophalen
    private func fetchClassroomCourses() {
        guard let url = URL(string: "https://classroom.googleapis.com/v1/courses?courseStates=ACTIVE") else { return }
        
        fetchAuthenticatedData(url: url) { data, _ in
            if let data = data,
               let response = try? JSONDecoder().decode([String: [ClassroomCourse]].self, from: data),
               let courses = response["courses"] {
                DispatchQueue.main.async {
                    self.classroomCourses = courses
                    self.fetchClassroomItems(for: courses, loadMore: false)
                }
            } else {
                DispatchQueue.main.async { self.isLoadingData = false }
            }
        }
    }
    
    func loadMoreClassroomItems() {
        guard classroomHasMoreItems, !isLoadingMoreClassroomItems else { return }
        isLoadingMoreClassroomItems = true
        fetchClassroomItems(for: classroomCourses, loadMore: true)
    }
    
    private func fetchClassroomItems(for courses: [ClassroomCourse], loadMore: Bool = false) {
        if !loadMore {
            courseWorkTokens.removeAll()
            materialsTokens.removeAll()
            announcementsTokens.removeAll()
        }
        
        let dispatchGroup = DispatchGroup()
        var opgehaaldeItems: [ClassroomItem] = []
        let arrayQueue = DispatchQueue(label: "com.classroom.items.queue")
        let tokenQueue = DispatchQueue(label: "com.classroom.tokens.queue")
        
        let pageSize = 10
        
        for course in courses {
            let courseId = course.id
            let courseName = course.name
            let courseColor = self.kleurVoorVak(id: courseId)
            
            // 1. Opdrachten
            let cwToken = courseWorkTokens[courseId]
            if !loadMore || cwToken != nil {
                dispatchGroup.enter()
                var cwUrlString = "https://classroom.googleapis.com/v1/courses/\(courseId)/courseWork?pageSize=\(pageSize)"
                if loadMore, let token = cwToken { cwUrlString += "&pageToken=\(token)" }
                
                fetchEndpoint(cwUrlString) { json in
                    if let json = json {
                        let newToken = json["nextPageToken"] as? String
                        tokenQueue.sync {
                            if let token = newToken { self.courseWorkTokens[courseId] = token }
                            else { self.courseWorkTokens.removeValue(forKey: courseId) }
                        }
                        
                        if let works = json["courseWork"] as? [[String: Any]] {
                            for work in works {
                                if let id = work["id"] as? String,
                                   let title = work["title"] as? String,
                                   let url = work["alternateLink"] as? String {
                                    let timeStr = work["creationTime"] as? String
                                    let item = ClassroomItem(
                                        id: id, titel: title, vakNaam: courseName,
                                        type: .opdracht, url: url, datum: self.parseISO8601Date(timeStr),
                                        kleur: courseColor, tekst: work["description"] as? String
                                    )
                                    arrayQueue.sync { opgehaaldeItems.append(item) }
                                }
                            }
                        }
                    }
                    dispatchGroup.leave()
                }
            }
            
            // 2. Materialen
            let matToken = materialsTokens[courseId]
            if !loadMore || matToken != nil {
                dispatchGroup.enter()
                var matUrlString = "https://classroom.googleapis.com/v1/courses/\(courseId)/courseWorkMaterials?pageSize=\(pageSize)"
                if loadMore, let token = matToken { matUrlString += "&pageToken=\(token)" }
                
                fetchEndpoint(matUrlString) { json in
                    if let json = json {
                        let newToken = json["nextPageToken"] as? String
                        tokenQueue.sync {
                            if let token = newToken { self.materialsTokens[courseId] = token }
                            else { self.materialsTokens.removeValue(forKey: courseId) }
                        }
                        
                        if let materials = json["courseWorkMaterial"] as? [[String: Any]] {
                            for mat in materials {
                                if let id = mat["id"] as? String,
                                   let title = mat["title"] as? String,
                                   let url = mat["alternateLink"] as? String {
                                    let timeStr = mat["creationTime"] as? String
                                    let item = ClassroomItem(
                                        id: id, titel: title, vakNaam: courseName,
                                        type: .materiaal, url: url, datum: self.parseISO8601Date(timeStr),
                                        kleur: courseColor, tekst: mat["description"] as? String
                                    )
                                    arrayQueue.sync { opgehaaldeItems.append(item) }
                                }
                            }
                        }
                    }
                    dispatchGroup.leave()
                }
            }
            
            // 3. Aankondigingen
            let annToken = announcementsTokens[courseId]
            if !loadMore || annToken != nil {
                dispatchGroup.enter()
                var annUrlString = "https://classroom.googleapis.com/v1/courses/\(courseId)/announcements?pageSize=\(pageSize)"
                if loadMore, let token = annToken { annUrlString += "&pageToken=\(token)" }
                
                fetchEndpoint(annUrlString) { json in
                    if let json = json {
                        let newToken = json["nextPageToken"] as? String
                        tokenQueue.sync {
                            if let token = newToken { self.announcementsTokens[courseId] = token }
                            else { self.announcementsTokens.removeValue(forKey: courseId) }
                        }
                        
                        if let announcements = json["announcements"] as? [[String: Any]] {
                            for ann in announcements {
                                if let id = ann["id"] as? String,
                                   let text = ann["text"] as? String,
                                   let url = ann["alternateLink"] as? String {
                                    let timeStr = ann["creationTime"] as? String
                                    let item = ClassroomItem(
                                        id: id, titel: "Aankondiging", vakNaam: courseName,
                                        type: .aankondiging, url: url, datum: self.parseISO8601Date(timeStr),
                                        kleur: courseColor, tekst: text
                                    )
                                    arrayQueue.sync { opgehaaldeItems.append(item) }
                                }
                            }
                        }
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if loadMore {
                var bestaande = self.classroomItems
                for item in opgehaaldeItems {
                    if !bestaande.contains(where: { $0.id == item.id }) {
                        bestaande.append(item)
                    }
                }
                self.classroomItems = bestaande
                self.isLoadingMoreClassroomItems = false
            } else {
                self.classroomItems = opgehaaldeItems
                self.isLoadingData = false
            }
            
            self.classroomHasMoreItems = !self.courseWorkTokens.isEmpty || !self.materialsTokens.isEmpty || !self.announcementsTokens.isEmpty
        }
    }
    
    private func fetchEndpoint(_ urlString: String, completion: @escaping ([String: Any]?) -> Void) {
        guard let url = URL(string: urlString) else { completion(nil); return }
        fetchAuthenticatedData(url: url) { data, _ in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                completion(json)
            } else {
                completion(nil)
            }
        }
    }
    
    func parseISO8601Date(_ dateString: String?) -> Date {
        guard let dateString = dateString else { return Date.distantPast }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateString) ?? Date.distantPast
    }
    
    private func kleurVoorVak(id: String) -> Color {
        let kleurenpalet: [Color] = [.blue, .green, .orange, .purple, .red, .teal, .pink]
        return kleurenpalet[abs(id.hashValue) % kleurenpalet.count]
    }
    
    func logout() {
        accessToken = ""
        refreshToken = ""
        userEmail = ""
        userName = ""
        userPicture = ""
        driveFiles.removeAll()
        classroomCourses.removeAll()
        classroomItems.removeAll()
        isLoggedIn = false
    }
}
