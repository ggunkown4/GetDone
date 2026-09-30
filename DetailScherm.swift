import SwiftUI

// MARK: - DetailScherm met Floating '+' Knop Rechts Onderin
struct DetailScherm: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    var titel: String
    @ObservedObject var auth: WebGoogleAuthManager
    @ObservedObject var magisterManager = MagisterManager.shared
    
    @State private var geselecteerdeDatum: Date = Date()
    @State private var toonDatePicker: Bool = false
    @State private var toonWeekPicker: Bool = false
    @State private var geselecteerdeWeergave: Int = 0 // 0 = Lijst, 1 = Dag, 2 = Week
    
    // Status voor bronnenfilter
    @State private var bronFilter: BronFilter = .alles
    
    // Eigen plannen opslaan
    @State private var planningen: [PlanningItem] = []
    @State private var toonNieuwPlanSheet: Bool = false
    
    private var huidigWeekNummer: Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar.component(.weekOfYear, from: geselecteerdeDatum)
    }
    
    private var weergaveTitel: String {
        switch geselecteerdeWeergave {
        case 0: return "Lijst"
        case 1: return "Dag"
        case 2: return "Week"
        default: return "Weergave"
        }
    }
    
    private func pasWeekAan(met offset: Int) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        if let nieuweDatum = calendar.date(byAdding: .weekOfYear, value: offset, to: geselecteerdeDatum) {
            withAnimation {
                geselecteerdeDatum = nieuweDatum
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.ignoresSafeArea()
            
            // ROUTING OP BASIS VAN TITEL
            if titel == "Agenda" {
                AgendaView(
                    geselecteerdeDatum: $geselecteerdeDatum,
                    geselecteerdeWeergave: $geselecteerdeWeergave,
                    planningen: $planningen,
                    magisterPlanningen: magisterManager.magisterPlanningen,
                    toonNieuwPlanSheet: $toonNieuwPlanSheet
                )
            } else if titel.hasPrefix("Chat") { 
                ChatView(titel: titel)
            } else if titel == "Bronnen" || titel.hasPrefix("Bron") {
                BronnenView(auth: auth, geselecteerdFilter: $bronFilter)
            } else if titel == "Profiel" {
                ProfielView(auth: auth)
            } else {
                Text("Je kijkt nu naar: \(titel)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // zwevende '+' knop RECHTS ONDERAAN (Alleen in Agenda)
            if titel == "Agenda" {
                Button {
                    toonNieuwPlanSheet = true
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
        .sheet(isPresented: $toonNieuwPlanSheet) {
            VoegPlanToeSheet(planningen: $planningen, geselecteerdeDatum: geselecteerdeDatum)
        }
        .onAppear {
            if titel == "Agenda" {
                magisterManager.laadHuiswerkEnRooster(voor: geselecteerdeDatum)
            }
        }
        .onChange(of: geselecteerdeDatum) { _, nieuweDatum in
            if titel == "Agenda" {
                magisterManager.laadHuiswerkEnRooster(voor: nieuweDatum)
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
                                    Text(geselecteerdeDatum.formatted(.dateTime.weekday(.wide)))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.white)
                                        .fixedSize()
                                        .layoutPriority(1)
                                    Text(geselecteerdeDatum.formatted(.dateTime.day().month(.wide)))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.white)
                                        .fixedSize()
                                        .layoutPriority(1)
                                } else {
                                    Text(geselecteerdeDatum.formatted(.dateTime.weekday()))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.white)
                                    Text(geselecteerdeDatum.formatted(.dateTime.day().month(.abbreviated)))
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
                        DatePicker("", selection: $geselecteerdeDatum, displayedComponents: .date)
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
                        .padding(.trailing, (titel == "Bronnen" && bronFilter != .alles) ? 0 : 12)
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
                            WeekSelectorPopover(geselecteerdeDatum: $geselecteerdeDatum)
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
                                magisterManager.laadHuiswerkEnRooster(voor: geselecteerdeDatum)
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Vandaag knop
                        Button {
                            withAnimation {
                                geselecteerdeDatum = Date()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar.badge")
                                    .font(.subheadline.bold())
                                
                                if sizeClass == .regular {
                                    Text("Vandaag")
                                        .font(.subheadline.bold())
                                }
                            }
                            .foregroundColor(.white)
                        }
                        
                        // Weergave menu knop
                        Menu {
                            Picker("Weergave", selection: $geselecteerdeWeergave) {
                                Label("Lijst", systemImage: "list.bullet").tag(0)
                                Label("Dag", systemImage: "calendar.day.timeline.left").tag(1)
                                Label("Week", systemImage: "calendar").tag(2)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: geselecteerdeWeergave == 0 ? "list.bullet" : (geselecteerdeWeergave == 1 ? "calendar.day.timeline.left" : "calendar"))
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
