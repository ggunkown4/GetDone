import SwiftUI
import Security

// MARK: - Secure Magister Storage
struct MagisterKeychainHelper {
    private static let service = "GetDone.Magister"
    
    static func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    @discardableResult
    static func save(_ value: String, key: String) -> Bool {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let attributes: [String: Any] = [kSecValueData as String: data]
        
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess { return true }
        
        var item = query
        item[kSecValueData as String] = data
        return SecItemAdd(item as CFDictionary, nil) == errSecSuccess
    }
    
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - AppStorage Helper
struct MagisterAppStorageHelper {
    static func read(key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    static func save(_ string: String, key: String) {
        UserDefaults.standard.set(string, forKey: key)
    }
    
    static func write(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func delete(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func saveDate(_ date: Date, key: String) {
        UserDefaults.standard.set(date, forKey: key)
    }
    
    static func readDate(key: String) -> Date? {
        return UserDefaults.standard.object(forKey: key) as? Date
    }
}

// MARK: - Resources & Filter Enums
enum SourceFilter: String, CaseIterable {
    case all = "All"
    case drive = "Google Drive"
    case classroom = "Google Classroom"
}

enum SortOption: String, CaseIterable {
    case name = "Name"
    case date = "Date"
}

enum SortDirection: String, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"
}

enum TimeFilter: String, CaseIterable {
    case all = "All"
    case lastWeek = "Last week"
    case lastMonth = "Last month"
    case lastYear = "Last year"
}

// MARK: - Magister Models
enum MagisterItemType: String {
    case homework = "Homework"
    case test = "Test"
    case information = "Information"
}

struct MagisterItem: Identifiable, Equatable {
    let id: UUID
    var magisterID: Int?
    var subjectName: String
    var title: String
    var description: String
    var date: Date
    var type: MagisterItemType
    var testType: String?
    var color: Color
    
    init(
        id: UUID = UUID(),
        magisterID: Int? = nil,
        subjectName: String,
        title: String,
        description: String,
        date: Date,
        type: MagisterItemType,
        testType: String? = nil,
        color: Color = .blue
    ) {
        self.id = id
        self.magisterID = magisterID
        self.subjectName = subjectName
        self.title = title
        self.description = description
        self.date = date
        self.type = type
        self.testType = testType
        self.color = color
    }
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Chat Component Models
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

// MARK: - Dynamic Planning Item Model
struct PlanningItem: Identifiable, Equatable {
    let id: UUID
    var magisterID: Int?
    var title: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var color: Color
    var isMagister: Bool
    
    init(
        id: UUID = UUID(),
        magisterID: Int? = nil,
        title: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        color: Color = .blue,
        isMagister: Bool = false
    ) {
        self.id = id
        self.magisterID = magisterID
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.color = color
        self.isMagister = isMagister || (magisterID != nil)
    }
    
    var timeFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var shortDay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).capitalized
    }
}

// MARK: - Magister User Model
struct MagisterUser {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var username: String = ""
    var password: String = ""
    var personId: Int? = nil
    var schoolDomain: String = ""
    
    var fullName: String {
        if firstName.isEmpty && lastName.isEmpty {
            return "Magister User"
        }
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    var formattedDomain: String {
        var d = schoolDomain.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if d.isEmpty { return "" }
        if !d.contains(".magister.net") {
            d += ".magister.net"
        }
        return d
    }
}

// MARK: - Schedule Lesson Model
struct Lesson: Identifiable {
    let id = UUID()
    let period: String
    let subject: String
    let room: String
    let time: String
}
