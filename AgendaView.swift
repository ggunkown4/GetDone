import SwiftUI

// MARK: - Modal Sheet voor Plan Aanmaken
struct VoegPlanToeSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var planningen: [PlanningItem]
    var geselecteerdeDatum: Date
    
    @State private var titel: String = ""
    @State private var datum: Date = Date()
    @State private var beginTijd: Date = Date()
    @State private var eindTijd: Date = Date().addingTimeInterval(3600)
    @State private var gekozenKleur: Color = .blue
    
    let beschikbareKleuren: [Color] = [.blue, .purple, .orange, .green, .red, .pink, .yellow]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Plan Details") {
                    TextField("Nieuw plan", text: $titel)
                    DatePicker("Datum", selection: $datum, displayedComponents: .date)
                    DatePicker("Begintijd", selection: $beginTijd, displayedComponents: .hourAndMinute)
                    DatePicker("Eindtijd", selection: $eindTijd, displayedComponents: .hourAndMinute)
                }
                
                Section("Kleur Categorie") {
                    HStack(spacing: 12) {
                        ForEach(beschikbareKleuren, id: \.self) { kleur in
                            Circle()
                                .fill(kleur)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: gekozenKleur == kleur ? 3 : 0)
                                )
                                .onTapGesture {
                                    gekozenKleur = kleur
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Nieuw plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Opslaan") {
                        let nieuwPlan = PlanningItem(
                            titel: titel.isEmpty ? "Nieuw plan" : titel,
                            datum: datum,
                            beginTijd: beginTijd,
                            eindTijd: eindTijd,
                            kleur: gekozenKleur,
                            isMagister: false
                        )
                        planningen.append(nieuwPlan)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
        .onAppear {
            datum = geselecteerdeDatum
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Week Selector Popover
struct WeekSelectorPopover: View {
    @Binding var geselecteerdeDatum: Date
    @Environment(\.dismiss) var dismiss
    
    @State private var gekozenWeek: Int = 1
    @State private var typInvoer: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    pasWeekAan(met: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
                
                Spacer()
                
                Text("Selecteer Week")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
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
            
            HStack {
                Text("Typ week:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("1-53", text: $typInvoer)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .frame(width: 70)
                    .onSubmit {
                        if let getal = Int(typInvoer), (1...53).contains(getal) {
                            gekozenWeek = getal
                            veranderNaarWeek(getal)
                        }
                    }
            }
            
            Divider().background(Color.white.opacity(0.2))
            
            Picker("Week", selection: $gekozenWeek) {
                ForEach(1...53, id: \.self) { week in
                    Text("Week \(week)").tag(week)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .onChange(of: gekozenWeek) { _, newValue in
                typInvoer = "\(newValue)"
                veranderNaarWeek(newValue)
            }
            
            Button {
                dismiss()
            } label: {
                Text("Klaar")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.blue))
            }
        }
        .padding(16)
        .frame(width: 250)
        .background(Color.black)
        .preferredColorScheme(.dark)
        .onAppear {
            var cal = Calendar.current
            cal.firstWeekday = 2
            let week = cal.component(.weekOfYear, from: geselecteerdeDatum)
            gekozenWeek = week
            typInvoer = "\(week)"
        }
    }
    
    private func pasWeekAan(met offset: Int) {
        var nieuweWeek = gekozenWeek + offset
        if nieuweWeek < 1 { nieuweWeek = 53 }
        else if nieuweWeek > 53 { nieuweWeek = 1 }
        
        gekozenWeek = nieuweWeek
        typInvoer = "\(nieuweWeek)"
        veranderNaarWeek(nieuweWeek)
    }
    
    private func veranderNaarWeek(_ week: Int) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let jaar = calendar.component(.yearForWeekOfYear, from: geselecteerdeDatum)
        
        var components = DateComponents()
        components.yearForWeekOfYear = jaar
        components.weekOfYear = week
        components.weekday = calendar.component(.weekday, from: geselecteerdeDatum)
        
        if let nieuweDatum = calendar.date(from: components) {
            geselecteerdeDatum = nieuweDatum
        }
    }
}

// MARK: - Agenda Weergave Router
struct AgendaView: View {
    @Binding var geselecteerdeDatum: Date
    @Binding var geselecteerdeWeergave: Int
    @Binding var planningen: [PlanningItem]
    var magisterPlanningen: [PlanningItem]
    @Binding var toonNieuwPlanSheet: Bool
    
    @ObservedObject private var magisterManager = MagisterManager.shared
    
    var allePlanningen: [PlanningItem] {
        let gecombineerd = planningen + magisterManager.magisterPlanningen + magisterPlanningen
        return ontdekEnOntdubbel(gecombineerd)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Status- & Laadbalk
            if magisterManager.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Magister rooster laden...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            } else if let fout = magisterManager.foutmelding, !fout.isEmpty {
                Text(fout)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.vertical, 4)
            }
            
            if geselecteerdeWeergave == 0 {
                AgendaLijstView(
                    planningen: $planningen,
                    magisterPlanningen: magisterManager.magisterPlanningen.isEmpty ? magisterPlanningen : magisterManager.magisterPlanningen,
                    toonNieuwPlanSheet: $toonNieuwPlanSheet
                )
                .padding(.top, 10)
            } else if geselecteerdeWeergave == 1 {
                AgendaDagView(
                    geselecteerdeDatum: geselecteerdeDatum,
                    planningen: allePlanningen
                )
                .padding(.top, 10)
            } else {
                AgendaWeekView(
                    geselecteerdeDatum: geselecteerdeDatum,
                    planningen: allePlanningen
                )
                .padding(.top, 10)
            }
            
            Spacer()
        }
        .onAppear {
            magisterManager.laadHuiswerkEnRooster(voor: geselecteerdeDatum)
        }
        .onChange(of: geselecteerdeDatum) { _, nieuweDatum in
            magisterManager.laadHuiswerkEnRooster(voor: nieuweDatum)
        }
    }
    
    private func ontdekEnOntdubbel(_ items: [PlanningItem]) -> [PlanningItem] {
        var uniekeItems: [PlanningItem] = []
        var gezieneMagisterIDs = Set<Int>()
        var gezieneUniekeKeys = Set<String>()
        
        for item in items {
            if let mId = item.magisterID {
                if !gezieneMagisterIDs.contains(mId) {
                    gezieneMagisterIDs.insert(mId)
                    uniekeItems.append(item)
                }
            } else {
                let key = "\(item.titel)_\(item.beginTijd.timeIntervalSince1970)"
                if !gezieneUniekeKeys.contains(key) {
                    gezieneUniekeKeys.insert(key)
                    uniekeItems.append(item)
                }
            }
        }
        return uniekeItems
    }
}

// MARK: - 1. Lijst Weergave
struct AgendaLijstView: View {
    @Binding var planningen: [PlanningItem]
    var magisterPlanningen: [PlanningItem]
    @Binding var toonNieuwPlanSheet: Bool
    
    var alleGesorteerdePlanningen: [PlanningItem] {
        let gecombineerd = planningen + magisterPlanningen
        var uniekeItems: [PlanningItem] = []
        var gezieneMagisterIDs = Set<Int>()
        
        for item in gecombineerd {
            if let mId = item.magisterID {
                if !gezieneMagisterIDs.contains(mId) {
                    gezieneMagisterIDs.insert(mId)
                    uniekeItems.append(item)
                }
            } else {
                uniekeItems.append(item)
            }
        }
        return uniekeItems.sorted { $0.beginTijd < $1.beginTijd }
    }
    
    var body: some View {
        if alleGesorteerdePlanningen.isEmpty {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.6))
                Text("Nog geen plannen aanwezig")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("Tik op '+' om een nieuw plan toe te voegen.")
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.8))
                
                Button {
                    toonNieuwPlanSheet = true
                } label: {
                    Text("Plan toevoegen")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.blue))
                }
                .padding(.top, 10)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(alleGesorteerdePlanningen) { item in
                        let isMagisterItem = item.isMagister || item.magisterID != nil
                        
                        HStack(spacing: 15) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(item.kleur)
                                .frame(width: 5)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(item.titel)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    if isMagisterItem {
                                        Image(systemName: "graduationcap.fill")
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                    }
                                }
                                
                                Text("\(item.dagKort) \(item.datum.formatted(.dateTime.day().month())) • \(item.tijdFormat)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            if !isMagisterItem {
                                Button {
                                    if let index = planningen.firstIndex(where: { $0.id == item.id }) {
                                        planningen.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.gray.opacity(0.6))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - 2. Dagrooster Weergave
struct AgendaDagView: View {
    var geselecteerdeDatum: Date
    var planningen: [PlanningItem]
    
    let uurHoogte: CGFloat = 60
    let startUur = 0
    let eindUur = 23
    
    private var dagPlanningen: [PlanningItem] {
        planningen.filter { Calendar.current.isDate($0.datum, inSameDayAs: geselecteerdeDatum) }
    }
    
    private var totaleHoogte: CGFloat {
        CGFloat(eindUur - startUur + 1) * uurHoogte
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(startUur...eindUur, id: \.self) { uur in
                        HStack(alignment: .top) {
                            Text(String(format: "%02d:00", uur))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(width: 45, alignment: .leading)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                        .frame(height: uurHoogte, alignment: .top)
                    }
                }
                
                GeometryReader { geo in
                    ForEach(dagPlanningen) { item in
                        let yPositie = berekenYPositie(voor: item.beginTijd)
                        let blokHoogte = berekenHoogte(begin: item.beginTijd, eind: item.eindTijd)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.titel)
                                .font(.caption.bold())
                                .lineLimit(1)
                            
                            Text(item.tijdFormat)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .padding(6)
                        .frame(width: max(0, geo.size.width - 60), height: blokHoogte, alignment: .topLeading)
                        .background(item.kleur.opacity(0.25))
                        .foregroundColor(item.kleur)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(item.kleur, lineWidth: 1)
                        )
                        .offset(x: 50, y: yPositie)
                    }
                }
            }
            .frame(height: totaleHoogte)
            .padding(.horizontal, 10)
            .padding(.bottom, 30)
        }
    }
    
    private func berekenYPositie(voor tijd: Date) -> CGFloat {
        let kalender = Calendar.current
        let uur = kalender.component(.hour, from: tijd)
        let minuut = kalender.component(.minute, from: tijd)
        
        let urenVanafStart = CGFloat(uur - startUur)
        let minutenFractie = CGFloat(minuut) / 60.0
        
        return (urenVanafStart + minutenFractie) * uurHoogte
    }
    
    private func berekenHoogte(begin: Date, eind: Date) -> CGFloat {
        let duurInSeconden = eind.timeIntervalSince(begin)
        let duurInUren = CGFloat(duurInSeconden) / 3600.0
        
        return max(duurInUren * uurHoogte, 30)
    }
}

// MARK: - 3. Weekrooster Weergave
struct AgendaWeekView: View {
    var geselecteerdeDatum: Date
    var planningen: [PlanningItem]
    
    private var weekDagen: [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: geselecteerdeDatum) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 15) {
                ForEach(weekDagen, id: \.self) { dagDatum in
                    let dagPlanningen = planningen
                        .filter { Calendar.current.isDate($0.datum, inSameDayAs: dagDatum) }
                        .sorted(by: { $0.beginTijd < $1.beginTijd })
                    
                    VStack {
                        VStack(spacing: 2) {
                            Text(dagDatum.formatted(.dateTime.weekday(.abbreviated)))
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(dagDatum.formatted(.dateTime.day()))
                                .font(.caption.bold())
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 10)
                        
                        if dagPlanningen.isEmpty {
                            Text("Geen plannen")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.6))
                                .frame(height: 100)
                        } else {
                            ForEach(dagPlanningen) { item in
                                VStack(alignment: .leading) {
                                    Text(item.titel)
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                    Text(item.tijdFormat)
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(8)
                                .frame(width: 110, alignment: .leading)
                                .background(item.kleur.opacity(0.5))
                                .cornerRadius(8)
                            }
                        }
                        Spacer()
                    }
                    .frame(width: 115)
                    .padding(.vertical)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Swift Playgrounds Canvas Preview Provider
#Preview {
    AgendaView(
        geselecteerdeDatum: .constant(Date()),
        geselecteerdeWeergave: .constant(0),
        planningen: .constant([
            PlanningItem(
                titel: "Wiskunde Huiswerk",
                datum: Date(),
                beginTijd: Date(),
                eindTijd: Date().addingTimeInterval(3600),
                kleur: .blue
            )
        ]),
        magisterPlanningen: [],
        toonNieuwPlanSheet: .constant(false)
    )
}
