//
//  ViewModelGoalSetupScreen.swift
//  Untitled Project
//
//  Created by Lama Hamdan on 01/06/1448 AH.
//
import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {

    // 1) حالات نخزنها (المستخدم يغيّرها)
    @Published var subject: String = ""
    @Published var selectedPeriod: Period? = nil

    // 2) قيمة محسوبة (نحسبها من اللي فوق)
    var isFormValid: Bool {
        let trimmed = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && selectedPeriod != nil
    }

    // 3) إنشاء الهدف عند الضغط على الزر
    func makeGoal() -> LearningGoal? {
        guard isFormValid, let period = selectedPeriod else { return nil }
        let trimmed = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        return LearningGoal(subject: trimmed, period: period)
    }
}

