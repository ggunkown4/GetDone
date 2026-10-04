import SwiftUI

// MARK: - DetailScreen with Floating '+' Button Bottom Right
struct DetailScreen: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    var title: String
    @ObservedObject var auth: WebGoogleAuthManager
    @ObservedObject var magisterManager = MagisterManager.shared

    @StateObject private var agendaModel = AgendaViewModel()
    @State private var showDatePicker: Bool = false
    @State private var showWeekPicker: Bool = false

    // Status for source filter
    @State private var sourceFilter: SourceFilter = .all
    @State private var isPlanEditorPresented: Bool = false
    @State private var selectedPlanForEditing: PlanningItem?
    @State private var planEditorStartTime: Date?

    private var selectedDate: Date { agendaModel.selectedDate }
    private var selectedView: Int { agendaModel.selectedView }
    
    private var currentWeekNumber: Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar.component(.weekOfYear, from: selectedDate)
    }
    
    private var viewTitle: String {
        switch selectedView {
        case 0: return "List"
        case 1: return "Day"
        case 2: return "Week"
        default: return "View"
        }
    }
    
    private func adjustWeek(by offset: Int) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        if let newDate = calendar.date(byAdding: .weekOfYear, value: offset, to: selectedDate) {
            withAnimation {
                agendaModel.selectedDate = newDate
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.ignoresSafeArea()
            
            // ROUTING BASED ON TITLE
            if title == "Agenda" {
                AgendaView(
                    selectedDate: $agendaModel.selectedDate,
                    selectedView: $agendaModel.selectedView,
                    plans: $agendaModel.customPlans,
                    magisterPlans: magisterManager.magisterPlans,
                    onSelectPlan: { plan in
                        guard !plan.isMagister else { return }
                        selectedPlanForEditing = plan
                        planEditorStartTime = nil
                        isPlanEditorPresented = true
                    },
                    onAddPlan: {
                        selectedPlanForEditing = nil
                        planEditorStartTime = nil
                        isPlanEditorPresented = true
                    },
                    onAddAtTime: { date in
                        selectedPlanForEditing = nil
                        planEditorStartTime = date
                        isPlanEditorPresented = true
                    },
                    onRefresh: { magisterManager.loadHomeworkAndSchedule(for: selectedDate) }
                )
            } else if title.hasPrefix("Chat") { 
                ChatView(title: title)
            } else if title == "Resources" || title.hasPrefix("Source") {
                ResourcesView(auth: auth, selectedFilter: $sourceFilter)
            } else if title == "Profile" {
                ProfileView(auth: auth)
            } else {
                Text("Currently viewing: \(title)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // floating '+' button BOTTOM RIGHT (Agenda only)
            if title == "Agenda" {
                Button {
                    selectedPlanForEditing = nil
                    planEditorStartTime = nil
                    isPlanEditorPresented = true
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
        .sheet(isPresented: $isPlanEditorPresented) {
            PlanEditorSheet(
                plan: selectedPlanForEditing,
                selectedDate: selectedDate,
                onSave: { plan in
                    if selectedPlanForEditing == nil {
                        agendaModel.addPlan(plan)
                    } else {
                        agendaModel.updatePlan(plan)
                    }
                },
                onDelete: selectedPlanForEditing.map { planToDelete in
                    { agendaModel.deletePlan(planToDelete) }
                },
                initialStartTime: planEditorStartTime
            )
        }
        .toolbar {
            // LEFT: Title & Date Picker
            ToolbarItem(placement: .topBarLeading) {
                if title == "Agenda" {
                    Button {
                        showDatePicker.toggle()
                    } label: {
                        HStack(spacing: 0) {
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
                        }
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showDatePicker) {
                        DatePicker("", selection: $agendaModel.selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .padding()
                            .frame(width: 330, height: 350)
                            .presentationCompactAdaptation(.popover)
                    }
                }
            }
            
            // CENTER: Week button + Arrows (iPad) - Agenda only
            if title == "Agenda" {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        if sizeClass == .regular {
                            HStack(spacing: 4) {
                                Button {
                                    adjustWeek(by: -1)
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Circle().fill(Color.white.opacity(0.12)))
                                }
                                
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
                        }
                        
                        Button {
                            showWeekPicker.toggle()
                        } label: {
                            Text(sizeClass == .regular ? "Week \(currentWeekNumber)" : "W \(currentWeekNumber)")
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
                        .popover(isPresented: $showWeekPicker) {
                            WeekSelectorPopover(selectedDate: $agendaModel.selectedDate)
                                .presentationCompactAdaptation(.popover)
                        }
                    }
                }
            }
            
            // RIGHT: Today button, Magister Status & View Options - Agenda only
            if title == "Agenda" {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        if magisterManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        } else {
                            Button {
                                magisterManager.loadHomeworkAndSchedule(for: selectedDate)
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Today button
                        Button {
                            withAnimation {
                                agendaModel.selectedDate = Date()
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
                        
                        // View menu button
                        Menu {
                            Picker("View", selection: $agendaModel.selectedView) {
                                Label("List", systemImage: "list.bullet").tag(0)
                                Label("Day", systemImage: "calendar.day.timeline.left").tag(1)
                                Label("Week", systemImage: "calendar").tag(2)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: selectedView == 0 ? "list.bullet" : (selectedView == 1 ? "calendar.day.timeline.left" : "calendar"))
                                    .font(.subheadline)
                                
                                if sizeClass == .regular {
                                    Text(viewTitle)
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
