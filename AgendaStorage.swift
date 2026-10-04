import Foundation
import SwiftUI
import UIKit

private struct StoredPlanningItem: Codable {
    var id: UUID
    var magisterID: Int?
    var title: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    var isMagister: Bool

    init(_ item: PlanningItem) {
        id = item.id
        magisterID = item.magisterID
        title = item.title
        date = item.date
        startTime = item.startTime
        endTime = item.endTime
        isMagister = item.isMagister

        var colorRed: CGFloat = 0
        var colorGreen: CGFloat = 0
        var colorBlue: CGFloat = 0
        var colorOpacity: CGFloat = 1
        UIColor(item.color).getRed(&colorRed, green: &colorGreen, blue: &colorBlue, alpha: &colorOpacity)
        red = Double(colorRed)
        green = Double(colorGreen)
        blue = Double(colorBlue)
        opacity = Double(colorOpacity)
    }

    var planningItem: PlanningItem {
        PlanningItem(
            id: id,
            magisterID: magisterID,
            title: title,
            date: date,
            startTime: startTime,
            endTime: endTime,
            color: Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity),
            isMagister: isMagister
        )
    }
}

enum AgendaStorage {
    static func loadCustomPlans() -> [PlanningItem] {
        loadPlans(from: "custom_plans.json")
    }

    static func saveCustomPlans(_ plans: [PlanningItem]) {
        savePlans(plans, to: "custom_plans.json")
    }

    static func loadMagisterPlans(for domain: String) -> [PlanningItem] {
        loadPlans(from: magisterFileName(for: domain))
    }

    static func saveMagisterPlans(_ plans: [PlanningItem], for domain: String) {
        savePlans(plans, to: magisterFileName(for: domain))
    }

    private static func magisterFileName(for domain: String) -> String {
        let safeDomain = domain.lowercased().filter { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "." || $0 == "-") }
        return "magister_schedule_\(safeDomain).json"
    }

    private static func loadPlans(from fileName: String) -> [PlanningItem] {
        guard let url = documentURL(for: fileName),
              let data = try? Data(contentsOf: url),
              let storedItems = try? JSONDecoder().decode([StoredPlanningItem].self, from: data) else {
            return []
        }
        return storedItems.map(\.planningItem)
    }

    private static func savePlans(_ plans: [PlanningItem], to fileName: String) {
        guard let url = documentURL(for: fileName),
              let data = try? JSONEncoder().encode(plans.map(StoredPlanningItem.init)) else {
            return
        }
        try? data.write(to: url, options: .atomic)
    }

    private static func documentURL(for fileName: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName)
    }
}

@MainActor
final class AgendaViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var selectedView = 0
    @Published var customPlans: [PlanningItem] = AgendaStorage.loadCustomPlans() {
        didSet { AgendaStorage.saveCustomPlans(customPlans) }
    }

    func addPlan(_ plan: PlanningItem) {
        customPlans.append(plan)
    }

    func updatePlan(_ plan: PlanningItem) {
        guard let index = customPlans.firstIndex(where: { $0.id == plan.id }) else { return }
        customPlans[index] = plan
    }

    func deletePlan(_ plan: PlanningItem) {
        customPlans.removeAll { $0.id == plan.id }
    }
}