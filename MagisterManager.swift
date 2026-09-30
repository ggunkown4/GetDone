import Foundation
import SwiftUI

class MagisterManager: ObservableObject {
    static let shared = MagisterManager()
    
    @Published var magisterItems: [MagisterItem] = []
    @Published var magisterPlans: [PlanningItem] = []
    @Published var isLoading: Bool = false
    @Published var foutmelding: String? = nil
    
    // Alleen netwerkverzoeken uitschakelen tijdens SwiftUI Canvas static preview rendering
    private var isCanvasPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    func loadHomeworkAndSchedule(voor referentieDatum: Date = Date()) {
        if isCanvasPreview {
            return
        }
        
        let token = MagisterKeychainHelper.read(key: "magister_access_token") ?? ""
        
        if token.isEmpty {
            DispatchQueue.main.async {
                self.foutmelding = "Niet ingelogd bij Magister"
                self.isLoading = false
            }
            return
        }
        
        let domein = MagisterAppStorageHelper.read(key: "magister_domein") ?? "roercollege"
        let geformatteerdDomein = domein.contains(".magister.net") ? domein : "\(domein).magister.net"
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.foutmelding = nil
        }
        
        guard let accountURL = URL(string: "https://\(geformatteerdDomein)/api/account") else {
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
                    self.foutmelding = "Netwerkfout: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.foutmelding = "Could not validate account."
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
                    self.foutmelding = "Persoon ID niet gevonden."
                }
                return
            }
            
            self.haalAfsprakenEnRoosterOp(personId: pId, domein: geformatteerdDomein, token: token, referentieDatum: referentieDatum)
        }.resume()
    }
    
    private func haalAfsprakenEnRoosterOp(personId: Int, domein: String, token: String, referentieDatum: Date) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: referentieDatum)
        guard let startOfWeek = calendar.date(from: components),
              let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) else {
            DispatchQueue.main.async { self.isLoading = false }
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let vanStr = formatter.string(from: startOfWeek)
        let totStr = formatter.string(from: endOfWeek)
        
        guard let url = URL(string: "https://\(domein)/api/personen/\(personId)/afspraken?van=\(vanStr)&tot=\(totStr)") else {
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
                    self.foutmelding = error != nil ? "Fout bij ophalen rooster" : "None roosterdata ontvangen."
                }
                return
            }
            
            var geladenMagisterItems: [MagisterItem] = []
            var geladenPlanningen: [PlanningItem] = []
            
            for item in items {
                let magisterId = item["Id"] as? Int ?? item["id"] as? Int
                let omschrijving = item["Omschrijving"] as? String ?? "Les"
                let inhoudRaw = item["Inhoud"] as? String ?? item["Aantekening"] as? String ?? ""
                let schoonInhoud = inhoudRaw.strippingHTML
                let lokatie = item["Lokatie"] as? String ?? ""
                let status = item["Status"] as? Int ?? 1
                let isUitval = status == 4 || status == 5 || omschrijving.lowercased().contains("uitval")
                
                let beginStr = item["Begin"] as? String ?? ""
                let eindStr = item["Einde"] as? String ?? ""
                
                guard let beginDatum = self.parseDate(beginStr) else { continue }
                let eindDatum = self.parseDate(eindStr) ?? beginDatum.addingTimeInterval(2700)
                
                var vakNaam = "Algemeen"
                if let vakken = item["Vakken"] as? [[String: Any]], let eersteVak = vakken.first {
                    vakNaam = eersteVak["Naam"] as? String ?? eersteVak["Code"] as? String ?? "Vak"
                } else if !omschrijving.isEmpty {
                    vakNaam = omschrijving
                }
                
                let infoType = item["InfoType"] as? Int ?? 0
                let isHuiswerk = infoType == 1 || !schoonInhoud.isEmpty || omschrijving.lowercased().contains("huiswerk")
                let isToets = (infoType >= 2 && infoType <= 5) || schoonInhoud.lowercased().contains("toets") || omschrijving.lowercased().contains("toets") || schoonInhoud.lowercased().contains("proefwerk")
                
                var itemKleur: Color = .blue
                var titelPrefix = ""
                
                if isUitval {
                    itemKleur = .gray
                    titelPrefix = "[UITVAL] "
                } else if isToets {
                    itemKleur = .orange
                    titelPrefix = "📝 "
                } else if isHuiswerk {
                    itemKleur = .purple
                    titelPrefix = "📚 "
                } else {
                    itemKleur = .teal
                }
                
                let volledigeTitel = "\(titelPrefix)\(omschrijving)\(lokatie.isEmpty ? "" : " (\(lokatie))")"
                
                let planning = PlanningItem(
                    magisterID: magisterId,
                    titel: volledigeTitel,
                    datum: beginDatum,
                    beginTijd: beginDatum,
                    eindTijd: eindDatum,
                    kleur: itemKleur,
                    isMagister: true
                )
                
                if let mId = magisterId {
                    if !geladenPlanningen.contains(where: { $0.magisterID == mId }) {
                        geladenPlanningen.append(planning)
                    }
                } else {
                    geladenPlanningen.append(planning)
                }
                
                if isToets || isHuiswerk || !schoonInhoud.isEmpty {
                    var toetsSoort: String? = nil
                    if isToets {
                        switch infoType {
                        case 2: toetsSoort = "Proefwerk"
                        case 3: toetsSoort = "SO"
                        case 4: toetsSoort = "Mondeling"
                        case 5: toetsSoort = "Praktijk"
                        default: toetsSoort = "Toets"
                        }
                    }
                    
                    let mItem = MagisterItem(
                        magisterID: magisterId,
                        vakNaam: vakNaam.capitalized,
                        titel: volledigeTitel,
                        beschrijving: schoonInhoud.isEmpty ? omschrijving : schoonInhoud,
                        datum: beginDatum,
                        type: isToets ? .toets : .huiswerk,
                        toetsType: toetsSoort,
                        kleur: itemKleur
                    )
                    
                    if let mId = magisterId {
                        if !geladenMagisterItems.contains(where: { $0.magisterID == mId }) {
                            geladenMagisterItems.append(mItem)
                        }
                    } else {
                        geladenMagisterItems.append(mItem)
                    }
                }
            }
            
            DispatchQueue.main.async {
                let nieuweMagisterIDs = Set(geladenPlanningen.compactMap { $0.magisterID })
                
                self.magisterPlans.removeAll { existing in
                    if let id = existing.magisterID, nieuweMagisterIDs.contains(id) {
                        return true
                    }
                    return existing.datum >= startOfWeek && existing.datum < endOfWeek
                }
                
                self.magisterItems.removeAll { existing in
                    if let id = existing.magisterID, nieuweMagisterIDs.contains(id) {
                        return true
                    }
                    return existing.datum >= startOfWeek && existing.datum < endOfWeek
                }
                
                self.magisterPlans.append(contentsOf: geladenPlanningen)
                self.magisterItems.append(contentsOf: geladenMagisterItems)
                
                self.magisterPlans.sort(by: { $0.beginTijd < $1.beginTijd })
                self.magisterItems.sort(by: { $0.datum < $1.datum })
                self.foutmelding = nil
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
