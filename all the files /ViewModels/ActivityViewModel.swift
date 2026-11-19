import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {
    @Published var progress = GoalProgress()
    @Published var selectedDate: Date = Date() // اليوم المحدد حالياً (الافتراضي: اليوم)
    @Published var showStreakLostAlert: Bool = false // يتحكم في ظهور تنبيه خسارة الستريك
    @Published var topic: String
    @Published var period: Period
    
    init(topic: String = "Swift", period: Period) {
        self.topic = topic
        self.period = period
        checkStreakStatus()
    }
    
    // MARK: - منطق الهدف العام (اكتمال أو تعثر)
    var targetDaysCount: Int {
        switch period {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
    
    var completedDaysCount: Int {
        progress.days.filter { $0.status == .learned || $0.status == .frozen }.count
    }
    
    var goalState: GoalState {
        if completedDaysCount >= targetDaysCount {
            return .completed
        }
        
        let calendar = Calendar.current
        let startOfGoal = calendar.startOfDay(for: progress.startdate)
        if let endDate = calendar.date(byAdding: .day, value: targetDaysCount, to: startOfGoal),
           Date() >= endDate {
            return .failed
        }
        
        return .active
    }
    
    func resetGoal() {
        progress = GoalProgress(startdate: Date())
        selectedDate = Date()
        showStreakLostAlert = false
    }
    
    func updateGoal(newTopic: String, newPeriod: Period) {
        let cleanedNewTopic = newTopic.trimmingCharacters(in: .whitespacesAndNewlines)
        let isSameTopic = cleanedNewTopic.lowercased() == topic.lowercased()
        
        // إذا كان نفس الموضوع والمدة الجديدة أطول أو مساوية: نمدد بدون تصفير التقدم
        if isSameTopic && newPeriod.daysCount >= period.daysCount {
            self.topic = cleanedNewTopic
            self.period = newPeriod
        } else {
            // إذا غيّر الموضوع أو قلّل المدة: نصفر التقدم ونبدأ من جديد
            self.topic = cleanedNewTopic
            self.period = newPeriod
            resetGoal()
        }
    }
    
    // MARK: - الإحصائيات والستريك
    var currentStreak: Int {
        let sortedDays = progress.days.sorted { $0.date > $1.date }
        var streak = 0
        for day in sortedDays {
            if day.status == .learned {
                streak += 1
            } else if day.status == .frozen {
                continue
            } else if day.status == .missed {
                break
            }
        }
        return streak
    }
    
    var frozenCount: Int { progress.days.filter { $0.status == .frozen }.count }
    
    var freezeQuota: Int {
        switch period {
        case .week: return 2
        case .month: return 8
        case .year: return 32
        }
    }
    
    var remainingFreezes: Int { max(0, freezeQuota - progress.usedFreezeDays) }
    var hasFreezesLeft: Bool { remainingFreezes > 0 }
    
    // MARK: - منطق اليوم المحدد (selectedDate)
    private var selectedDayIndex: Int? {
        progress.days.firstIndex { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    var selectedDateStatus: DayStatus? {
        guard let index = selectedDayIndex else { return nil }
        return progress.days[index].status
    }
    
    var isSelectedDateToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    func isDateInDangerZone(_ date: Date) -> Bool {
        let calendar = Calendar.current
        guard calendar.isDateInYesterday(date) else { return false }
        
        // التأكد أن التاريخ يقع ضمن فترة الهدف وليس قبل بدايته
        let startOfGoal = calendar.startOfDay(for: progress.startdate)
        guard calendar.startOfDay(for: date) >= startOfGoal else { return false }
        
        let hasRecord = progress.days.contains { calendar.isDate($0.date, inSameDayAs: date) }
        guard !hasRecord else { return false }
        guard progress.lastActivityDate != nil else { return false }
        
        let startOfYesterday = calendar.startOfDay(for: date)
        guard let deadline = calendar.date(byAdding: .hour, value: 32, to: startOfYesterday) else { return false }
        
        return Date() < deadline
    }
    
    var canLogSelectedDate: Bool {
        guard selectedDateStatus == nil else { return false }
        return isSelectedDateToday || isDateInDangerZone(selectedDate)
    }
    
    var canRescueSelectedFreeze: Bool {
        guard selectedDateStatus == .frozen else { return false }
        let calendar = Calendar.current
        let startOfSelectedDay = calendar.startOfDay(for: selectedDate)
        guard let deadline = calendar.date(byAdding: .hour, value: 32, to: startOfSelectedDay) else { return false }
        return Date() < deadline
    }
    
    var isMainButtonActive: Bool {
        canLogSelectedDate || canRescueSelectedFreeze
    }
    
    var canFreezeSelectedDate: Bool {
        canLogSelectedDate && hasFreezesLeft
    }
    
    // فحص مرور 32 ساعة وتصفير الستريك وتفعيل التنبيه بشكل منطقي
    func checkStreakStatus() {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfGoal = calendar.startOfDay(for: progress.startdate)
        
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday) else { return }
        
        // 1. إذا كان يوم أمس يسبق بداية الهدف أصلاً -> نتوقف ولا نحسب شيئاً
        guard yesterday >= startOfGoal else { return }
        
        // 2. يجب أن يكون هناك نشاط مسجل قبل بداية اليوم الحالي
        guard let lastActivity = progress.lastActivityDate, lastActivity < startOfToday else { return }
        
        // 3. التحقق من عدم وجود سجل ليوم أمس مسبقاً
        let hasYesterdayRecord = progress.days.contains { calendar.isDate($0.date, inSameDayAs: yesterday) }
        
        if !hasYesterdayRecord {
            if let deadline = calendar.date(byAdding: .hour, value: 32, to: yesterday), Date() >= deadline {
                progress.days.append(Day(date: yesterday, status: .missed))
                showStreakLostAlert = true
            }
        }
    }
    
    // MARK: - الأوامر (Actions) لليوم المحدد
    func logSelectedDate() {
        guard canLogSelectedDate else { return }
        progress.days.append(Day(date: selectedDate, status: .learned))
        if isSelectedDateToday || progress.lastActivityDate == nil {
            progress.lastActivityDate = Date()
        }
    }
    
    func freezeSelectedDate() {
        guard canFreezeSelectedDate else { return }
        progress.days.append(Day(date: selectedDate, status: .frozen))
        progress.usedFreezeDays += 1
        if isSelectedDateToday || progress.lastActivityDate == nil {
            progress.lastActivityDate = Date()
        }
    }
    
    func rescueFreezeAndLearn() {
        guard canRescueSelectedFreeze, let index = selectedDayIndex else { return }
        progress.days[index].status = .learned
        progress.usedFreezeDays = max(0, progress.usedFreezeDays - 1)
    }
}
