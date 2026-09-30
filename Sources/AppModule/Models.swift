import SwiftUI
import Security

// MARK: - Beveiligde Magister Opslag
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

// MARK: - Bronnen & Filter Enums
enum BronFilter: String, CaseIterable {
    case alles = "Alles"
    case drive = "Google Drive"
    case classroom = "Google Classroom"
}

enum SorteerOptie: String, CaseIterable {
    case naam = "Naam"
    case datum = "Datum"
}

enum SorteerRichting: String, CaseIterable {
    case oplopend = "Oplopend"
    case aflopend = "Aflopend"
}

enum TijdFilter: String, CaseIterable {
    case alles = "Alles"
    case laatsteWeek = "Afgelopen week"
    case laatsteMaand = "Afgelopen maand"
    case laatsteJaar = "Afgelopen jaar"
}

// MARK: - Magister Modellen
enum MagisterItemType: String {
    case huiswerk = "Huiswerk"
    case toets = "Toets"
    case informatie = "Informatie"
}

struct MagisterItem: Identifiable, Equatable {
    let id: UUID
    var magisterID: Int?
    var vakNaam: String
    var titel: String
    var beschrijving: String
    var datum: Date
    var type: MagisterItemType
    var toetsType: String?
    var kleur: Color
    
    init(
        id: UUID = UUID(),
        magisterID: Int? = nil,
        vakNaam: String,
        titel: String,
        beschrijving: String,
        datum: Date,
        type: MagisterItemType,
        toetsType: String? = nil,
        kleur: Color = .blue
    ) {
        self.id = id
        self.magisterID = magisterID
        self.vakNaam = vakNaam
        self.titel = titel
        self.beschrijving = beschrijving
        self.datum = datum
        self.type = type
        self.toetsType = toetsType
        self.kleur = kleur
    }
    
    var datumFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: datum)
    }
}

// MARK: - Chat Component Modellen
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

// MARK: - Dynamic Planning Item Model
struct PlanningItem: Identifiable, Equatable {
    let id: UUID
    var magisterID: Int?
    var titel: String
    var datum: Date
    var beginTijd: Date
    var eindTijd: Date
    var kleur: Color
    var isMagister: Bool
    
    init(
        id: UUID = UUID(),
        magisterID: Int? = nil,
        titel: String,
        datum: Date,
        beginTijd: Date,
        eindTijd: Date,
        kleur: Color = .blue,
        isMagister: Bool = false
    ) {
        self.id = id
        self.magisterID = magisterID
        self.titel = titel
        self.datum = datum
        self.beginTijd = beginTijd
        self.eindTijd = eindTijd
        self.kleur = kleur
        self.isMagister = isMagister || (magisterID != nil)
    }
    
    var tijdFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: beginTijd)) - \(formatter.string(from: eindTijd))"
    }
    
    var dagKort: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateFormat = "EEE"
        return formatter.string(from: datum).capitalized
    }
}

// MARK: - Magister Gebruikersmodel
struct MagisterGebruiker {
    var voornaam: String = ""
    var achternaam: String = ""
    var email: String = ""
    var gebruikersnaam: String = ""
    var wachtwoord: String = ""
    var personId: Int? = nil
    var schoolDomein: String = ""
    
    var volledigeNaam: String {
        if voornaam.isEmpty && achternaam.isEmpty {
            return "Magister Gebruiker"
        }
        return "\(voornaam) \(achternaam)".trimmingCharacters(in: .whitespaces)
    }
    
    var geformatteerdDomein: String {
        var d = schoolDomein.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if d.isEmpty { return "" }
        if !d.contains(".magister.net") {
            d += ".magister.net"
        }
        return d
    }
}

// MARK: - Rooster Lesmodel
struct Les: Identifiable {
    let id = UUID()
    let uur: String
    let vak: String
    let lokaal: String
    let tijd: String
}
