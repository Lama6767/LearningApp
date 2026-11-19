import SwiftUI

enum ActiveAlert {
    case confirmLearn
    case rescueFreeze
    case streakLost
}

struct ActivityView: View {
    @StateObject private var viewModel: ActivityViewModel
    @State private var activeAlert: ActiveAlert? = nil
    @Environment(\.colorScheme) private var colorScheme
    
    init(topic: String = "Swift", period: Period) {
        _viewModel = StateObject(wrappedValue: ActivityViewModel(topic: topic, period: period))
    }
    
    var body: some View {
        ZStack {
            mainContent
            
            if let alertType = activeAlert {
                customAlertView(for: alertType)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.checkStreakStatus()
            if viewModel.showStreakLostAlert {
                activeAlert = .streakLost
            }
        }
        .onChange(of: viewModel.showStreakLostAlert) { _, isLost in
            if isLost {
                activeAlert = .streakLost
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 24) {
            header
            weekStrip
            statCards
            
            if viewModel.goalState == .active {
                Spacer()
                logButton
                Spacer()
                freezeSection
            } else {
                Spacer()
                goalResultSection(isSuccess: viewModel.goalState == .completed)
                Spacer()
            }
        }
        .padding()
    }
    
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activity")
                    .font(.largeTitle).bold()
                Text(viewModel.selectedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                NavigationLink {
                    ActivitiesCalendarView(viewModel: viewModel)
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .glassEffect(.regular.interactive(), in: .circle)
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    EditGoalView(viewModel: viewModel)
                } label: {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .glassEffect(.regular.interactive(), in: .circle)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var weekStrip: some View {
        HStack(spacing: 8) {
            ForEach(weekDates, id: \.self) { date in
                dayCircle(for: date)
            }
        }
    }
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        guard let start = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }
    
    private func dayCircle(for date: Date) -> some View {
        let isToday = Calendar.current.isDateInToday(date)
        let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
        
        return VStack(spacing: 6) {
            Text(date.formatted(.dateTime.weekday(.narrow)))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            
            Text(date.formatted(.dateTime.day()))
                .font(.headline)
                .foregroundStyle(textColor(for: date))
                .frame(width: 40, height: 40)
                .background(fillColor(for: date), in: Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected && !isToday ? Color.primary.opacity(0.4) : Color.clear, lineWidth: 1.5)
                )
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedDate = date
            }
        }
    }
    
    private func fillColor(for date: Date) -> Color {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let isInDanger = viewModel.isDateInDangerZone(date)
        let status = viewModel.progress.days
            .first { calendar.isDate($0.date, inSameDayAs: date) }?.status
        
        switch status {
        case .learned:
            return Color.orange.opacity(0.35)
        case .frozen:
            return Color.cyan.opacity(0.35)
        case .missed:
            return Color.clear
        default:
            if isToday { return Color.orange }
            if isInDanger { return Color.red.opacity(0.25) }
            return Color.clear
        }
    }
    
    private func textColor(for date: Date) -> Color {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let isInDanger = viewModel.isDateInDangerZone(date)
        let status = viewModel.progress.days
            .first { calendar.isDate($0.date, inSameDayAs: date) }?.status
        
        switch status {
        case .learned:
            return .orange
        case .frozen:
            return .cyan
        case .missed:
            return .red
        default:
            if isToday { return .white }
            if isInDanger { return .red }
            return .primary
        }
    }
    
    private var statCards: some View {
        HStack(spacing: 12) {
            statCard(icon: "flame.fill", color: .orange,
                     value: viewModel.currentStreak, label: "Learned")
            statCard(icon: "snowflake", color: .cyan,
                     value: viewModel.frozenCount, label: "Freezed")
        }
    }
    
    private var logButton: some View {
        Button {
            if viewModel.canRescueSelectedFreeze {
                activeAlert = .rescueFreeze
            } else if viewModel.canLogSelectedDate {
                activeAlert = .confirmLearn
            }
        } label: {
            VStack(spacing: 8) {
                Text(mainButtonTitle)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                if viewModel.canRescueSelectedFreeze {
                    Text("Tap to learn & restore your freeze")
                        .font(.caption)
                        .opacity(0.9)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)
            .foregroundStyle(viewModel.isMainButtonActive ? Color.white : Color.gray)
            .frame(width: 240, height: 240)
        }
        .buttonStyle(.plain)
        .glassEffect(
            viewModel.canRescueSelectedFreeze ? .regular.tint(.cyan).interactive() :
                (viewModel.canLogSelectedDate ? .regular.tint(.orange).interactive() : .regular),
            in: .circle
        )
        .disabled(!viewModel.isMainButtonActive)
    }
    
    private var mainButtonTitle: String {
        if viewModel.selectedDateStatus == .learned {
            return "Learned!"
        } else if viewModel.canRescueSelectedFreeze {
            return "Day Freezed"
        } else if viewModel.selectedDateStatus == .frozen {
            return "Freeze Locked"
        } else if viewModel.selectedDateStatus == .missed {
            return "Day Missed"
        } else if !viewModel.canLogSelectedDate {
            return "Unavailable"
        } else {
            return "Log as Learned"
        }
    }
    
    private var freezeSection: some View {
        VStack(spacing: 8) {
            Button {
                viewModel.freezeSelectedDate()
            } label: {
                Text("Freeze for a day")
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .foregroundStyle(viewModel.canFreezeSelectedDate ? Color.white : Color.gray)
            }
            .buttonStyle(.plain)
            .glassEffect(viewModel.canFreezeSelectedDate ? .regular.tint(.cyan).interactive() : .regular, in: .capsule)
            .disabled(!viewModel.canFreezeSelectedDate)
            
            Text("\(viewModel.progress.usedFreezeDays) out of \(viewModel.freezeQuota) Freezes used")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private func goalResultSection(isSuccess: Bool) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: isSuccess ? "hands.clap.fill" : "xmark.seal")
                    .font(.system(size: 44))
                    .foregroundStyle(.orange)
                
                Text(isSuccess ? "Well done!" : "You didn't reach your goal this time.")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(isSuccess ? "Ready for your next goal?" : "Want to set another goal?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            NavigationLink {
                EditGoalView(viewModel: viewModel)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "target")
                    Text("Set a goal")
                        .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color.orange, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        }
                        private func customAlertView(for type: ActiveAlert) -> some View {
                        ZStack {
                        Color.black
                        .opacity(colorScheme == .dark ? 0.5 : 0.2)
                        .ignoresSafeArea()
                        VStack(spacing: 20) {
                        VStack(spacing: 8) {
                        Text(alertTitle(for: type))
                        .font(.headline)
                        Text(alertMessage(for: type))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        }
                        HStack(spacing: 12) {
                        Button {
                        if type == .streakLost {
                        viewModel.showStreakLostAlert = false
                        }
                        activeAlert = nil
                        } label: {
                        Text(type == .streakLost ? "Continue" : "Cancel")
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(
                        Capsule().stroke(Color.primary.opacity(0.3), lineWidth: 1)
                        )
                        }
                        .buttonStyle(.plain)
                        Button {
                        switch type {
                        case .confirmLearn:
                        viewModel.logSelectedDate()
                        case .rescueFreeze:
                        viewModel.rescueFreezeAndLearn()
                        case .streakLost:
                        viewModel.resetGoal()
                        }
                        activeAlert = nil
                        } label: {
                        Text(alertConfirmButtonTitle(for: type))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.orange, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        }
                        }
                        .padding(24)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
                        .padding(.horizontal, 32)
                        }
                        }
                        private func alertTitle(for type: ActiveAlert) -> String {
                        switch type {
                        case .confirmLearn: return "Log as Learned?"
                        case .rescueFreeze: return "Rescue Your Freeze?"
                        case .streakLost: return "Streak Lost!"
                        }
                        }
                        private func alertMessage(for type: ActiveAlert) -> String {
                        switch type {
                        case .confirmLearn:
                        return "Are you sure you want to log this day as learned? Once confirmed, this action cannot be undone."
                        case .rescueFreeze:
                        return "If you learn within the 32-hour window, your freeze will be restored to your balance and this day will be logged as learned."
                        case .streakLost:
                        return "More than 32 hours have passed and your streak was reset. Would you like to continue your current journey or start a new goal?"
                        }
                        }
                        private func alertConfirmButtonTitle(for type: ActiveAlert) -> String {
                        switch type {
                        case .confirmLearn: return "Confirm"
                        case .rescueFreeze: return "Learn & Restore"
                        case .streakLost: return "Start New"
                        }
                        }
                        private func statCard(icon: String, color: Color, value: Int, label: String) -> some View {
                        VStack(spacing: 6) {
                        Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundStyle(color)
                        Text(value == 1 ? "1 day" : "\(value) days")
                        .font(.headline)
                        Text(label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))
                        }
                        }
                        #Preview("Light Mode") {
                        NavigationStack {
                        ActivityView(period: .week)
                        }
                        .preferredColorScheme(.light)
                        }
                        #Preview("Dark Mode") {
                        NavigationStack {
                        ActivityView(period: .week)
                        }
                        .preferredColorScheme(.dark)
                        }

