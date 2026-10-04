import Foundation
import SwiftUI

class MagisterManager: ObservableObject {
    static let shared = MagisterManager()
    
    @Published var magisterItems: [MagisterItem] = []
    @Published var magisterPlans: [PlanningItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Disable network requests during SwiftUI Canvas static preview rendering
    private var isCanvasPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    func loadHomeworkAndSchedule(for referenceDate: Date = Date()) {
        if isCanvasPreview {
            return
        }
        
        let token = MagisterKeychainHelper.read(key: "magister_access_token") ?? ""
        
        if token.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Not logged in to Magister"
                self.isLoading = false
            }
            return
        }
        
        let domain = MagisterAppStorageHelper.read(key: "magister_domain") ?? "roercollege"
        let formattedDomain = domain.contains(".magister.net") ? domain : "\(domain).magister.net"
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        guard let accountURL = URL(string: "https://\(formattedDomain)/api/account") else {
            DispatchQueue.main.async { self.isLoading = false }
            return
        }
        
        var request = URLRequest(url: accountURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Could not validate account."
                }
                return
            }
            
            var personId: Int? = nil
            let subDictKeys = ["Persoon", "persoon", "Person", "person", "User", "user", "Account", "account"]
            for subKey in subDictKeys {
                if let subDict = json[subKey] as? [String: Any], let foundId = subDict["Id"] as? Int ?? subDict["id"] as? Int {
                    personId = foundId
                    break
                }
            }
            if personId == nil {
                personId = json["Id"] as? Int ?? json["id"] as? Int
            }
            
            guard let pId = personId else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Person ID not found."
                }
                return
            }
            
            self.fetchAppointmentsAndSchedule(personId: pId, domain: formattedDomain, token: token, referenceDate: referenceDate)
        }.resume()
    }
    
    private func fetchAppointmentsAndSchedule(personId: Int, domain: String, token: String, referenceDate: Date) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: referenceDate)
        guard let startOfWeek = calendar.date(from: components),
              let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) else {
            DispatchQueue.main.async { self.isLoading = false }
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let fromStr = formatter.string(from: startOfWeek)
        let toStr = formatter.string(from: endOfWeek)
        
        guard let url = URL(string: "https://\(domain)/api/personen/\(personId)/afspraken?van=\(fromStr)&tot=\(toStr)") else {
            DispatchQueue.main.async { self.isLoading = false }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.isLoading = false }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let items = json["Items"] as? [[String: Any]] else {
                DispatchQueue.main.async {
                    self.errorMessage = error != nil ? "Error fetching schedule" : "No schedule data received."
                }
                return
            }
            
            var loadedMagisterItems: [MagisterItem] = []
            var loadedPlans: [PlanningItem] = []
            
            for item in items {
                let magisterId = item["Id"] as? Int ?? item["id"] as? Int
                let description = item["Omschrijving"] as? String ?? "Lesson"
                let contentRaw = item["Inhoud"] as? String ?? item["Aantekening"] as? String ?? ""
                let cleanContent = contentRaw.strippingHTML
                let location = item["Lokatie"] as? String ?? ""
                let status = item["Status"] as? Int ?? 1
                let isCancelled = status == 4 || status == 5 || description.lowercased().contains("uitval")
                
                let beginStr = item["Begin"] as? String ?? ""
                let eindStr = item["Einde"] as? String ?? ""
                
                guard let startDate = self.parseDate(beginStr) else { continue }
                let endDate = self.parseDate(eindStr) ?? startDate.addingTimeInterval(2700)
                
                var subjectName = "General"
                if let subjects = item["Vakken"] as? [[String: Any]], let firstSubject = subjects.first {
                    subjectName = firstSubject["Naam"] as? String ?? firstSubject["Code"] as? String ?? "Subject"
                } else if !description.isEmpty {
                    subjectName = description
                }
                
                let infoType = item["InfoType"] as? Int ?? 0
                let isHomework = infoType == 1 || !cleanContent.isEmpty || description.lowercased().contains("homework")
                let isTest = (infoType >= 2 && infoType <= 5) || cleanContent.lowercased().contains("toets") || description.lowercased().contains("toets") || cleanContent.lowercased().contains("proefwerk")
                
                var itemColor: Color = .blue
                var titlePrefix = ""
                
                if isCancelled {
                    itemColor = .gray
                    titlePrefix = "[CANCELLED] "
                } else if isTest {
                    itemColor = .orange
                    titlePrefix = "📝 "
                } else if isHomework {
                    itemColor = .purple
                    titlePrefix = "📚 "
                } else {
                    itemColor = .teal
                }
                
                let fullTitle = "\(titlePrefix)\(description)\(location.isEmpty ? "" : " (\(location))")"
                
                let planning = PlanningItem(
                    magisterID: magisterId,
                    title: fullTitle,
                    date: startDate,
                    startTime: startDate,
                    endTime: endDate,
                    color: itemColor,
                    isMagister: true
                )
                
                if let mId = magisterId {
                    if !loadedPlans.contains(where: { $0.magisterID == mId }) {
                        loadedPlans.append(planning)
                    }
                } else {
                    loadedPlans.append(planning)
                }
                
                if isTest || isHomework || !cleanContent.isEmpty {
                    var testSort: String? = nil
                    if isTest {
                        switch infoType {
                        case 2: testSort = "Written Exam"
                        case 3: testSort = "Quiz"
                        case 4: testSort = "Oral Exam"
                        case 5: testSort = "Practical"
                        default: testSort = "Test"
                        }
                    }
                    
                    let mItem = MagisterItem(
                        magisterID: magisterId,
                        subjectName: subjectName.capitalized,
                        title: fullTitle,
                        description: cleanContent.isEmpty ? description : cleanContent,
                        date: startDate,
                        type: isTest ? .test : .homework,
                        testType: testSort,
                        color: itemColor
                    )
                    
                    if let mId = magisterId {
                        if !loadedMagisterItems.contains(where: { $0.magisterID == mId }) {
                            loadedMagisterItems.append(mItem)
                        }
                    } else {
                        loadedMagisterItems.append(mItem)
                    }
                }
            }
            
            DispatchQueue.main.async {
                let newMagisterIDs = Set(loadedPlans.compactMap { $0.magisterID })
                
                self.magisterPlans.removeAll { existing in
                    if let id = existing.magisterID, newMagisterIDs.contains(id) {
                        return true
                    }
                    return existing.date >= startOfWeek && existing.date < endOfWeek
                }
                
                self.magisterItems.removeAll { existing in
                    if let id = existing.magisterID, newMagisterIDs.contains(id) {
                        return true
                    }
                    return existing.date >= startOfWeek && existing.date < endOfWeek
                }
                
                self.magisterPlans.append(contentsOf: loadedPlans)
                self.magisterItems.append(contentsOf: loadedMagisterItems)
                
                self.magisterPlans.sort(by: { $0.startTime < $1.startTime })
                self.magisterItems.sort(by: { $0.date < $1.date })
                self.errorMessage = nil
            }
        }.resume()
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        if dateString.isEmpty { return nil }
        
        let isoFractional = ISO8601DateFormatter()
        isoFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFractional.date(from: dateString) { return date }
        
        let isoStandard = ISO8601DateFormatter()
        isoStandard.formatOptions = [.withInternetDateTime]
        if let date = isoStandard.date(from: dateString) { return date }
        
        let customFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]
        
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for format in customFormats {
            df.dateFormat = format
            if let date = df.date(from: dateString) {
                return date
            }
        }
        return nil
    }
}

extension String {
    var strippingHTML: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
