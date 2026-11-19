//
//  ActivitiesCalendarView.swift
//  Untitled Project
//
//  Created by Lama Hamdan on 09/06/1448 AH.
//

import SwiftUI

struct ActivitiesCalendarView: View {
    @ObservedObject var viewModel: ActivityViewModel
    private let calendar = Calendar.current
    private let weekDays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    // يعرض 6 أشهر (الشهر الحالي + 5 أشهر قادمة أو سابقة حسب رغبتك)
    private var months: [Date] {
        (-1...4).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: Date())
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
                ForEach(months, id: \.self) { monthDate in
                    monthSection(for: monthDate)
                }
            }
            .padding()
        }
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func monthSection(for monthDate: Date) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // اسم الشهر والسنة (مثال: January 2026)
            Text(monthDate.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
                .fontWeight(.bold)
            
            // صف أسماء الأيام
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // شبكة أيام الشهر
            let days = generateDaysInMonth(for: monthDate)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(0..<days.count, id: \.self) { index in
                    if let date = days[index] {
                        calendarDayCell(for: date)
                    } else {
                        Text("")
                            .frame(height: 36)
                    }
                }
            }
            
            Divider()
                .padding(.top, 8)
        }
    }
    
    private func calendarDayCell(for date: Date) -> some View {
        let status = viewModel.progress.days
            .first { calendar.isDate($0.date, inSameDayAs: date) }?.status
        
        let bgColor: Color = {
            switch status {
            case .learned: return Color.orange.opacity(0.3)
            case .frozen: return Color.cyan.opacity(0.3)
            default: return Color.clear
            }
        }()
        
        let textColor: Color = {
            switch status {
            case .learned: return .orange
            case .frozen: return .cyan
            case .missed: return .red
            default: return .primary
            }
        }()
        
        return Text("\(calendar.component(.day, from: date))")
            .font(.subheadline)
            .fontWeight(status != nil ? .bold : .regular)
            .foregroundStyle(textColor)
            .frame(width: 36, height: 36)
            .background(bgColor, in: Circle())
    }
    
    // دالة توليد أيام الشهر مع الفراغات في البداية لمطابقة أيام الأسبوع
    private func generateDaysInMonth(for date: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        
        let daysCount = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysCount {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(dayDate)
            }
        }
        return days
    }
}
