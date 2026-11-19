//
//  DayStatusViewModel.swift
//  Untitled Project
//
//  Created by Lama Hamdan on 06/06/1448 AH.
//
import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {
    @Published var progress = GoalProgress()
    let period : Period
    
    init(period: Period) {
        self.period = period
    }
    
    var learnedCount: Int {progress.days.filter { $0.status == .learned }.count}
    var frozenCount: Int {progress.days.filter {$0.status == .frozen }.count}
    
    var freezeQuota: Int{
        switch period{
        case .week: return 2
        case .month: return 8
        case.year: return 32
        }
    }
    var remainingFreezes: Int {
        max(0, freezeQuota - progress.usedFreezeDays)
    }

    var hasFreezesLeft: Bool {
        remainingFreezes > 0
    }

    var todayStatus: DayStatus? {
            progress.days.first { Calendar.current.isDateInToday($0.date) }?.status
        }
    
    var canActToday: Bool {
            todayStatus == nil
    }
    func logToday() {
            guard canActToday else { return }
            progress.days.append(Day(date: Date(), status: .learned))
            progress.lastActivityDate = Date()
        }
    func freezeToday() {
            guard canActToday, hasFreezesLeft else { return }
            progress.days.append(Day(date: Date(), status: .frozen))
            progress.usedFreezeDays += 1
            progress.lastActivityDate = Date()
        }
    
}


