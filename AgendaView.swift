import SwiftUI

// MARK: - Modal Sheet for Adding a Plan
struct AddPlanSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var plans: [PlanningItem]
    var selectedDate: Date
    
    @State private var planTitle: String = ""
    @State private var selectedPlanDate: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600)
    @State private var selectedColor: Color = .blue
    
    let availableColors: [Color] = [.blue, .purple, .orange, .green, .red, .pink, .yellow]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Plan Details") {
                    TextField("New plan", text: $planTitle)
                    DatePicker("Date", selection: $selectedPlanDate, displayedComponents: .date)
                    DatePicker("Start time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                Section("Color Category") {
                    HStack(spacing: 12) {
                        ForEach(availableColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let nieuwPlan = PlanningItem(
                            title: planTitle.isEmpty ? "New plan" : planTitle,
                            date: selectedPlanDate,
                            startTime: startTime,
                            endTime: endTime,
                            color: selectedColor,
                            isMagister: false
                        )
                        plans.append(nieuwPlan)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
        .onAppear {
            selectedPlanDate = selectedDate
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Week Selector Popover
struct WeekSelectorPopover: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    @State private var gekozenWeek: Int = 1
    @State private var typInvoer: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    adjustWeek(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
                
                Spacer()
                
                Text("Select Week")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    adjustWeek(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
            }
            
            HStack {
                Text("Enter week:")
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
                Text("Done")
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
            let week = cal.component(.weekOfYear, from: selectedDate)
            gekozenWeek = week
            typInvoer = "\(week)"
        }
    }
    
    private func adjustWeek(by offset: Int) {
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
        let jaar = calendar.component(.yearForWeekOfYear, from: selectedDate)
        
        var components = DateComponents()
        components.yearForWeekOfYear = jaar
        components.weekOfYear = week
        components.weekday = calendar.component(.weekday, from: selectedDate)
        
        if let newDate = calendar.date(from: components) {
            selectedDate = newDate
        }
    }
}

// MARK: - Agenda View Router
struct AgendaView: View {
    @Binding var selectedDate: Date
    @Binding var selectedView: Int
    @Binding var plans: [PlanningItem]
    var magisterPlans: [PlanningItem]
    @Binding var showNewPlanSheet: Bool
    
    @ObservedObject private var magisterManager = MagisterManager.shared
    
    var allePlanningen: [PlanningItem] {
        let gecombineerd = plans + magisterManager.magisterPlans + magisterPlans
        return ontdekEnOntdubbel(gecombineerd)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Status- & Laadbalk
            if magisterManager.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading schedule...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            } else if let error = magisterManager.errorMessage, !error.isEmpty {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.vertical, 4)
            }
            
            if selectedView == 0 {
                AgendaLijstView(
                    plans: $plans,
                    magisterPlans: magisterManager.magisterPlans.isEmpty ? magisterPlans : magisterManager.magisterPlans,
                    showNewPlanSheet: $showNewPlanSheet
                )
                .padding(.top, 10)
            } else if selectedView == 1 {
                AgendaDayView(
                    selectedDate: selectedDate,
                    plans: allePlanningen
                )
                .padding(.top, 10)
            } else {
                AgendaWeekView(
                    selectedDate: selectedDate,
                    plans: allePlanningen
                )
                .padding(.top, 10)
            }
            
            Spacer()
        }
        .onAppear {
            magisterManager.loadHomeworkAndSchedule(for: selectedDate)
        }
        .onChange(of: selectedDate) { _, newDate in
            magisterManager.loadHomeworkAndSchedule(for: newDate)
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
                let key = "\(item.title)_\(item.startTime.timeIntervalSince1970)"
                if !gezieneUniekeKeys.contains(key) {
                    gezieneUniekeKeys.insert(key)
                    uniekeItems.append(item)
                }
            }
        }
        return uniekeItems
    }
}

// MARK: - 1. List View
struct AgendaLijstView: View {
    @Binding var plans: [PlanningItem]
    var magisterPlans: [PlanningItem]
    @Binding var showNewPlanSheet: Bool
    
    var allSortedPlans: [PlanningItem] {
        let gecombineerd = plans + magisterPlans
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
        return uniekeItems.sorted { $0.startTime < $1.startTime }
    }
    
    var body: some View {
        if allSortedPlans.isEmpty {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.6))
                Text("No plans yet")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("Tap + to add a new plan.")
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.8))
                
                Button {
                    showNewPlanSheet = true
                } label: {
                    Text("Add Plan")
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
                    ForEach(allSortedPlans) { item in
                        let isMagisterItem = item.isMagister || item.magisterID != nil
                        
                        HStack(spacing: 15) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(item.color)
                                .frame(width: 5)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(item.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    if isMagisterItem {
                                        Image(systemName: "graduationcap.fill")
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                    }
                                }
                                
                                Text("\(item.shortDay) \(item.date.formatted(.dateTime.day().month())) • \(item.timeFormat)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            if !isMagisterItem {
                                Button {
                                    if let index = plans.firstIndex(where: { $0.id == item.id }) {
                                        plans.remove(at: index)
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

// MARK: - 2. Day View
struct AgendaDayView: View {
    var selectedDate: Date
    var plans: [PlanningItem]
    
    let hourHeight: CGFloat = 60
    let startHour = 0
    let endHour = 23
    
    private var dayPlans: [PlanningItem] {
        plans.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    private var totalHeight: CGFloat {
        CGFloat(endHour - startHour + 1) * hourHeight
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(startHour...endHour, id: \.self) { hour in
                        HStack(alignment: .top) {
                            Text(String(format: "%02d:00", hour))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(width: 45, alignment: .leading)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                        .frame(height: hourHeight, alignment: .top)
                    }
                }
                
                GeometryReader { geo in
                    ForEach(dayPlans) { item in
                        let yPosition = calculateYPosition(for: item.startTime)
                        let blockHeight = calculateHeight(start: item.startTime, end: item.endTime)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.caption.bold())
                                .lineLimit(1)
                            
                            Text(item.timeFormat)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .padding(6)
                        .frame(width: max(0, geo.size.width - 60), height: blockHeight, alignment: .topLeading)
                        .background(item.color.opacity(0.25))
                        .foregroundColor(item.color)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(item.color, lineWidth: 1)
                        )
                        .offset(x: 50, y: yPosition)
                    }
                }
            }
            .frame(height: totalHeight)
            .padding(.horizontal, 10)
            .padding(.bottom, 30)
        }
    }
    
    private func calculateYPosition(for time: Date) -> CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        let hoursFromStart = CGFloat(hour - startHour)
        let minutesFraction = CGFloat(minute) / 60.0
        
        return (hoursFromStart + minutesFraction) * hourHeight
    }
    
    private func calculateHeight(start: Date, end: Date) -> CGFloat {
        let durationInSeconds = end.timeIntervalSince(start)
        let durationInHours = CGFloat(durationInSeconds) / 3600.0
        
        return max(durationInHours * hourHeight, 30)
    }
}

// MARK: - 3. Week View
struct AgendaWeekView: View {
    var selectedDate: Date
    var plans: [PlanningItem]
    
    private var weekDayen: [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 15) {
                ForEach(weekDayen, id: \.self) { dayDate in
                    let dayPlans = plans
                        .filter { Calendar.current.isDate($0.date, inSameDayAs: dayDate) }
                        .sorted(by: { $0.startTime < $1.startTime })
                    
                    VStack {
                        VStack(spacing: 2) {
                            Text(dayDate.formatted(.dateTime.weekday(.abbreviated)))
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(dayDate.formatted(.dateTime.day()))
                                .font(.caption.bold())
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 10)
                        
                        if dayPlans.isEmpty {
                            Text("No plans")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.6))
                                .frame(height: 100)
                        } else {
                            ForEach(dayPlans) { item in
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                    Text(item.timeFormat)
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(8)
                                .frame(width: 110, alignment: .leading)
                                .background(item.color.opacity(0.5))
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
        selectedDate: .constant(Date()),
        selectedView: .constant(0),
        plans: .constant([
            PlanningItem(
                title: "Math Homework",
                date: Date(),
                startTime: Date(),
                endTime: Date().addingTimeInterval(3600),
                color: .blue
            )
        ]),
        magisterPlans: [],
        showNewPlanSheet: .constant(false)
    )
}
