//
//  ModelGoalSetupScreen.swift
//  Untitled Project
//
//  Created by Lama Hamdan on 01/06/1448 AH.
//

import Foundation

enum Period : CaseIterable{
    case week
    case month
    case year
    var title: String{
        switch self{
        case.week: return "week"
        case.month: return "month"
        case.year:return"year"
        }
    }
    var daysCount: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}

struct LearningGoal : Hashable{
    
    var subject: String
    var period: Period
    
}


