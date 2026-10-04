import SwiftUI

// MARK: - Plan Creation and Editing
struct PlanEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let plan: PlanningItem?
    let onSave: (PlanningItem) -> Void
    let onDelete: (() -> Void)?
    let initialStartTime: Date?

    @State private var planTitle: String
    @State private var planDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedColor: Color

    private let availableColors: [Color] = [.blue, .purple, .orange, .green, .red, .pink, .yellow]

    init(
        plan: PlanningItem?,
        selectedDate: Date,
        onSave: @escaping (PlanningItem) -> Void,
        onDelete: (() -> Void)? = nil,
        initialStartTime: Date? = nil
    ) {
        self.plan = plan
        self.onSave = onSave
        self.onDelete = onDelete
        self.initialStartTime = initialStartTime
        _planTitle = State(initialValue: plan?.title ?? "")
        _planDate = State(initialValue: plan?.date ?? selectedDate)
        let startTime = plan?.startTime ?? initialStartTime ?? selectedDate
        _startTime = State(initialValue: startTime)
        _endTime = State(initialValue: plan?.endTime ?? startTime.addingTimeInterval(3600))
        _selectedColor = State(initialValue: plan?.color ?? .blue)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Plan Details") {
                    TextField("Plan title", text: $planTitle)
                    DatePicker("Date", selection: $planDate, displayedComponents: .date)
                    DatePicker("Start time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End time", selection: $endTime, displayedComponents: .hourAndMinute)
                }

                Section("Color Category") {
                    HStack(spacing: 12) {
                        ForEach(availableColors, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(Circle().stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Plan color")
                            .accessibilityAddTraits(selectedColor == color ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 4)
                }

                if onDelete != nil {
                    Section {
                        Button("Delete Plan", role: .destructive) {
                            onDelete?()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(plan == nil ? "New plan" : "Edit plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(PlanningItem(
                            id: plan?.id ?? UUID(),
                            title: planTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "New plan" : planTitle,
                            date: planDate,
                            startTime: startTime,
                            endTime: endTime,
                            color: selectedColor
                        ))
                        dismiss()
                    }
                    .bold()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Week Selector Popover
struct WeekSelectorPopover: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedWeek: Int = 1
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
                        if let number = Int(typInvoer), (1...53).contains(number) {
                            selectedWeek = number
                            changeToWeek(number)
                        }
                    }
            }
            
            Divider().background(Color.white.opacity(0.2))
            
            Picker("Week", selection: $selectedWeek) {
                ForEach(1...53, id: \.self) { week in
                    Text("Week \(week)").tag(week)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .onChange(of: selectedWeek) { _, newValue in
                typInvoer = "\(newValue)"
                changeToWeek(newValue)
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
            selectedWeek = week
            typInvoer = "\(week)"
        }
    }
    
    private func adjustWeek(by offset: Int) {
        var newWeek = selectedWeek + offset
        if newWeek < 1 { newWeek = 53 }
        else if newWeek > 53 { newWeek = 1 }
        
        selectedWeek = newWeek
        typInvoer = "\(newWeek)"
        changeToWeek(newWeek)
    }
    
    private func changeToWeek(_ week: Int) {
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
    var onSelectPlan: (PlanningItem) -> Void = { _ in }
    var onAddPlan: () -> Void = {}
    var onAddAtTime: (Date) -> Void = { _ in }
    var onRefresh: () -> Void = {}

    @ObservedObject private var magisterManager = MagisterManager.shared
    @State private var visibleErrorMessage: String?
    
    var allePlanningen: [PlanningItem] {
        let combined = plans + magisterManager.magisterPlans + magisterPlans
        return discoverAndDeduplicate(combined)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Status & Loading Bar
            if magisterManager.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading schedule...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            
            if selectedView == 0 {
                AgendaListView(
                    plans: $plans,
                    magisterPlans: magisterManager.magisterPlans.isEmpty ? magisterPlans : magisterManager.magisterPlans,
                    selectedDate: selectedDate,
                    onSelectPlan: onSelectPlan,
                    onAddPlan: onAddPlan,
                    onRefresh: onRefresh
                )
                .padding(.top, 10)
            } else if selectedView == 1 {
                AgendaDayView(
                    selectedDate: selectedDate,
                    plans: allePlanningen,
                    onSelectPlan: onSelectPlan,
                    onAddAtTime: onAddAtTime,
                    onRefresh: onRefresh
                )
                .padding(.top, 10)
            } else {
                AgendaWeekView(
                    selectedDate: selectedDate,
                    plans: allePlanningen,
                    onSelectPlan: onSelectPlan,
                    onRefresh: onRefresh
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
        .task(id: magisterManager.errorMessage) {
            guard let message = magisterManager.errorMessage, !message.isEmpty else { return }
            visibleErrorMessage = message
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            if !Task.isCancelled && visibleErrorMessage == message {
                visibleErrorMessage = nil
            }
        }
        .overlay(alignment: .top) {
            if let visibleErrorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(visibleErrorMessage)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.3), in: Capsule())
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: visibleErrorMessage)
    }
    
    private func discoverAndDeduplicate(_ items: [PlanningItem]) -> [PlanningItem] {
        var uniqueItems: [PlanningItem] = []
        var seenMagisterIDs = Set<Int>()
        var seenUniqueKeys = Set<String>()
        
        for item in items {
            if let mId = item.magisterID {
                if !seenMagisterIDs.contains(mId) {
                    seenMagisterIDs.insert(mId)
                    uniqueItems.append(item)
                }
            } else {
                let key = "\(item.title)_\(item.startTime.timeIntervalSince1970)"
                if !seenUniqueKeys.contains(key) {
                    seenUniqueKeys.insert(key)
                    uniqueItems.append(item)
                }
            }
        }
        return uniqueItems
    }
}

// MARK: - 1. List View
struct AgendaListView: View {
    @Binding var plans: [PlanningItem]
    var magisterPlans: [PlanningItem]
    var selectedDate: Date
    var onSelectPlan: (PlanningItem) -> Void
    var onAddPlan: () -> Void
    var onRefresh: () -> Void

    @State private var scope: AgendaListScope = .selectedDay

    private var visiblePlans: [PlanningItem] {
        let combined = plans + magisterPlans
        var uniqueItems: [PlanningItem] = []
        var seenMagisterIDs = Set<Int>()
        
        for item in combined {
            if let mId = item.magisterID {
                if !seenMagisterIDs.contains(mId) {
                    seenMagisterIDs.insert(mId)
                    uniqueItems.append(item)
                }
            } else {
                uniqueItems.append(item)
            }
        }
        let filteredItems = uniqueItems.filter { item in
            switch scope {
            case .selectedDay:
                return Calendar.current.isDate(item.date, inSameDayAs: selectedDate)
            case .allUpcoming:
                return item.date >= Calendar.current.startOfDay(for: selectedDate)
            }
        }
        return filteredItems.sorted { $0.startTime < $1.startTime }
    }

    private var groupedPlans: [PlanDaySection] {
        Dictionary(grouping: visiblePlans) { Calendar.current.startOfDay(for: $0.date) }
            .map { PlanDaySection(date: $0.key, plans: $0.value) }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Picker("Plan range", selection: $scope) {
                    Text("Selected Day").tag(AgendaListScope.selectedDay)
                    Text("All Upcoming").tag(AgendaListScope.allUpcoming)
                }
                .pickerStyle(.segmented)

                if groupedPlans.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No plans for this range")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Button {
                            onAddPlan()
                        } label: {
                            Label("Add Plan", systemImage: "plus")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color.blue))
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 260)
                } else {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(groupedPlans) { section in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(section.date.formatted(date: .complete, time: .omitted))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.gray)

                                ForEach(section.plans) { item in
                                    planRow(item)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .refreshable { onRefresh() }
    }

    @ViewBuilder
    private func planRow(_ item: PlanningItem) -> some View {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture { onSelectPlan(item) }

            if !isMagisterItem {
                Button {
                    if let index = plans.firstIndex(where: { $0.id == item.id }) {
                        plans.remove(at: index)
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.gray.opacity(0.7))
                }
                .accessibilityLabel("Delete \(item.title)")
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

private enum AgendaListScope: String, Hashable {
    case selectedDay
    case allUpcoming
}

private struct PlanDaySection: Identifiable {
    let date: Date
    let plans: [PlanningItem]
    var id: Date { date }
}

// MARK: - 2. Day View
struct AgendaDayView: View {
    var selectedDate: Date
    var plans: [PlanningItem]
    var onSelectPlan: (PlanningItem) -> Void = { _ in }
    var onAddAtTime: (Date) -> Void = { _ in }
    var onRefresh: () -> Void = {}
    
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
        ScrollViewReader { proxy in
            ScrollView {
                ZStack(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(startHour...endHour, id: \.self) { hour in
                            HStack(alignment: .top) {
                                Text(String(format: "%02d:00", hour))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(width: 45, alignment: .leading)

                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                    .padding(.top, 1)
                            }
                            .frame(height: hourHeight, alignment: .top)
                            .contentShape(Rectangle())
                            .onTapGesture(coordinateSpace: .local) { location in
                                let minute = min(59, max(0, Int(location.y / hourHeight * 60)))
                                if let tappedDate = Calendar.current.date(
                                    bySettingHour: hour,
                                    minute: minute,
                                    second: 0,
                                    of: selectedDate
                                ) {
                                    onAddAtTime(tappedDate)
                                }
                            }
                            .id(hour)
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
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(item.color, lineWidth: 1))
                            .offset(x: 50, y: yPosition)
                            .contentShape(Rectangle())
                            .onTapGesture { onSelectPlan(item) }
                        }
                    }

                    TimelineView(.periodic(from: .now, by: 60)) { context in
                        if Calendar.current.isDate(context.date, inSameDayAs: selectedDate) {
                            let yPosition = calculateYPosition(for: context.date)
                            HStack(spacing: 0) {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 8, height: 8)
                                Rectangle()
                                    .fill(.red)
                                    .frame(height: 2)
                            }
                            .offset(x: 46, y: yPosition)
                        }
                    }
                    .allowsHitTesting(false)
                }
                .frame(height: totalHeight)
                .padding(.horizontal, 10)
                .padding(.bottom, 30)
            }
            .refreshable { onRefresh() }
            .onAppear { scrollToCurrentHour(using: proxy) }
            .onChange(of: selectedDate) { oldDate, newDate in
                if !Calendar.current.isDate(oldDate, inSameDayAs: newDate) {
                    scrollToCurrentHour(using: proxy)
                }
            }
        }
    }

    private func scrollToCurrentHour(using proxy: ScrollViewProxy) {
        guard Calendar.current.isDateInToday(selectedDate) else { return }
        let currentHour = Calendar.current.component(.hour, from: Date())
        withAnimation {
            proxy.scrollTo(max(startHour, currentHour - 1), anchor: .top)
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
    @Environment(\.horizontalSizeClass) private var sizeClass
    var selectedDate: Date
    var plans: [PlanningItem]
    var onSelectPlan: (PlanningItem) -> Void = { _ in }
    var onRefresh: () -> Void = {}

    private var weekDays: [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
    }
    
    var body: some View {
        ScrollView {
            if sizeClass == .regular {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                    ForEach(weekDays, id: \.self) { dayDate in
                        dayColumn(dayDate)
                    }
                }
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(weekDays, id: \.self) { dayDate in
                            dayColumn(dayDate)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .refreshable { onRefresh() }
    }

    private func dayColumn(_ dayDate: Date) -> some View {
        let dayPlans = plans
            .filter { Calendar.current.isDate($0.date, inSameDayAs: dayDate) }
            .sorted { $0.startTime < $1.startTime }

        return VStack {
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(item.color.opacity(0.5))
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                    .onTapGesture { onSelectPlan(item) }
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: sizeClass == .regular ? .infinity : nil)
        .frame(width: sizeClass == .regular ? nil : 115)
        .padding(.vertical)
        .padding(.horizontal, 4)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
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
        magisterPlans: []
    )
}
