//
//  DayStatus.swift
//  Untitled Project
//
//  Created by Lama Hamdan on 06/06/1448 AH.
//
import Foundation

enum DayStatus{
    case learned
    case frozen
    case missed
    case pending
    case future
}

enum GoalState{
    case active
    case completed
    case failed
}


struct Day {
    
    var date: Date
    var status: DayStatus
    
}


struct GoalProgress {
    var startdate: Date = Date()
    var days: [Day] = []
    var lastActivityDate: Date? = nil
    var usedFreezeDays: Int = 0
}
