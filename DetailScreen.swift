import SwiftUI

// MARK: - DetailScreen met Floating '+' Knop Rechts Onderin
struct DetailScreen: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    var titel: String
    @ObservedObject var auth: WebGoogleAuthManager
    @ObservedObject var magisterManager = MagisterManager.shared
    
    @State private var selectedDate: Date = Date()
    @State private var toonDatePicker: Bool = false
    @State private var toonWeekPicker: Bool = false
    @State private var selectedView: Int = 0 // 0 = Lijst, 1 = Day, 2 = Week
    
    // Status voor bronnenfilter
    @State private var bronFilter: BronFilter = .alles
    
    // Eigen plannen opslaan
    @State private var plans: [PlanningItem] = []
    @State private var showNewPlanSheet: Bool = false
    
    private var huidigWeekNummer: Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar.component(.weekOfYear, from: selectedDate)
    }
    
    private var weergaveTitel: String {
        switch selectedView {
        case 0: return "List"
        case 1: return "Day"
        case 2: return "Week"
        default: return "Weergave"
        }
    }
    
    private func pasWeekAan(met offset: Int) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        if let nieuweDatum = calendar.date(byAdding: .weekOfYear, value: offset, to: selectedDate) {
            withAnimation {
                selectedDate = nieuweDatum
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.ignoresSafeArea()
            
            // ROUTING OP BASIS VAN TITEL
            if titel == "Agenda" {
                AgendaView(
                    selectedDate: $selectedDate,
                    selectedView: $selectedView,
                    plans: $plans,
                    magisterPlans: magisterManager.magisterPlans,
                    showNewPlanSheet: $showNewPlanSheet
                )
            } else if titel.hasPrefix("Chat") { 
                ChatView(titel: titel)
            } else if titel == "Resources" || titel.hasPrefix("Bron") {
                ResourcesView(auth: auth, selectedFilter: $bronFilter)
            } else if titel == "Profiel" {
                ProfileView(auth: auth)
            } else {
                Text("Je kijkt nu naar: \(titel)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // zwevende '+' knop RECHTS ONDERAAN (Alleen in Agenda)
            if titel == "Agenda" {
                Button {
                    showNewPlanSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(Color.blue))
                        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $showNewPlanSheet) {
            AddPlanSheet(plans: $plans, selectedDate: selectedDate)
        }
        .onAppear {
            if titel == "Agenda" {
                magisterManager.loadHomeworkAndSchedule(voor: selectedDate)
            }
        }
        .onChange(of: selectedDate) { _, nieuweDatum in
            if titel == "Agenda" {
                magisterManager.loadHomeworkAndSchedule(voor: nieuweDatum)
            }
        }
        .toolbar {
            // LINKS: Titel & Datum Picker
            ToolbarItem(placement: .topBarLeading) {
                if titel == "Agenda" {
                    Button {
                        toonDatePicker.toggle()
                    } label: {
                        HStack(spacing: 0) {
                            Text(titel)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .fixedSize()
                                .padding(.leading, 10)
                                .padding(.trailing, 12)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                if sizeClass == .regular {
                                    Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.white)
                                        .fixedSize()
                                        .layoutPriority(1)
                                    Text(selectedDate.formatted(.dateTime.day().month(.wide)))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.white)
                                        .fixedSize()
                                        .layoutPriority(1)
                                } else {
                                    Text(selectedDate.formatted(.dateTime.weekday()))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.white)
                                    Text(selectedDate.formatted(.dateTime.day().month(.abbreviated)))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.white)
                                        .fixedSize()
                                        .layoutPriority(1)
                                }
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal, 10)
                            .background {
                                Capsule()
                                    .fill(Color.white.opacity(0.12))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $toonDatePicker) {
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .padding()
                            .frame(width: 330, height: 350)
                            .presentationCompactAdaptation(.popover)
                    }
                } else {
                    Text(titel)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .fixedSize()
                        .layoutPriority(1)
                        .padding(.leading, 10)
                        .padding(.trailing, (titel == "Resources" && bronFilter != .alles) ? 0 : 12)
                }
            }
            
            // MIDDEN: Week knop + Pijltjes (op iPad) - Alleen Agenda
            if titel == "Agenda" {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        if sizeClass == .regular {
                            HStack(spacing: 4) {
                                Button {
                                    pasWeekAan(met: -1)
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Circle().fill(Color.white.opacity(0.12)))
                                }
                                
                                Button {
                                    pasWeekAan(met: 1)
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Circle().fill(Color.white.opacity(0.12)))
                                }
                            }
                        }
                        
                        Button {
                            toonWeekPicker.toggle()
                        } label: {
                            Text(sizeClass == .regular ? "Week \(huidigWeekNummer)" : "W \(huidigWeekNummer)")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.12))
                                        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                )
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $toonWeekPicker) {
                            WeekSelectorPopover(selectedDate: $selectedDate)
                                .presentationCompactAdaptation(.popover)
                        }
                    }
                }
            }
            
            // RECHTS: Vandaag-knop, Magister Status & Weergave Opties - Alleen Agenda
            if titel == "Agenda" {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        if magisterManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        } else {
                            Button {
                                magisterManager.loadHomeworkAndSchedule(voor: selectedDate)
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Vandaag knop
                        Button {
                            withAnimation {
                                selectedDate = Date()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar.badge")
                                    .font(.subheadline.bold())
                                
                                if sizeClass == .regular {
                                    Text("Today")
                                        .font(.subheadline.bold())
                                }
                            }
                            .foregroundColor(.white)
                        }
                        
                        // Weergave menu knop
                        Menu {
                            Picker("Weergave", selection: $selectedView) {
                                Label("List", systemImage: "list.bullet").tag(0)
                                Label("Day", systemImage: "calendar.day.timeline.left").tag(1)
                                Label("Week", systemImage: "calendar").tag(2)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: selectedView == 0 ? "list.bullet" : (selectedView == 1 ? "calendar.day.timeline.left" : "calendar"))
                                    .font(.subheadline)
                                
                                if sizeClass == .regular {
                                    Text(weergaveTitel)
                                        .font(.subheadline.bold())
                                }
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
    }
}
