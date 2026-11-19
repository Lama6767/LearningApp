//
//  EditGoalView.swift
//  Untitled Project
//
//  Created by Lama Hamdan on 09/06/1448 AH.
//
import SwiftUI

struct EditGoalView: View {
    @ObservedObject var viewModel: ActivityViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newTopic: String = ""
    @State private var selectedPeriod: Period = .week
    @State private var showConfirmation = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 28) {
                // حقل تعديل الموضوع
                VStack(alignment: .leading, spacing: 10) {
                    Text("I want to learn")
                        .font(.headline)
                    
                    TextField("Enter topic", text: $newTopic)
                        .padding(.vertical, 10)
                    
                    Divider()
                }
                
                // اختيار المدة الزمنية
                VStack(alignment: .leading, spacing: 14) {
                    Text("I want to learn it in a")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach([Period.week, .month, .year], id: \.self) { item in
                            Button {
                                selectedPeriod = item
                            } label: {
                                Text(periodTitle(for: item))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 12)
                                    .background(selectedPeriod == item ? Color.orange : Color.gray.opacity(0.2))
                                    .foregroundStyle(selectedPeriod == item ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Spacer()
                
                // زر الحفظ
                Button {
                    showConfirmation = true
                } label: {
                    Text("Update Goal")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isInputValid ? Color.orange : Color.gray.opacity(0.4))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!isInputValid)
            }
            .padding(24)
            .navigationTitle("Learning Goal")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                newTopic = viewModel.topic
                selectedPeriod = viewModel.period
            }
            
            // تنبيه التأكيد
            if showConfirmation {
                confirmationOverlay
            }
        }
    }
    
    private var isInputValid: Bool {
        !newTopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func periodTitle(for period: Period) -> String {
        switch period {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }
    
    // رسالة تنبيه ذكية توضح هل سيتصفر التقدم أم سيتم التمديد
    private var willResetProgress: Bool {
        let isSameTopic = newTopic.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == viewModel.topic.lowercased()
        return !(isSameTopic && selectedPeriod.daysCount >= viewModel.period.daysCount)
    }
    
    private var confirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Update Learning Goal?")
                    .font(.headline)
                
                Text(willResetProgress
                     ? "Changing your topic or shortening the period will reset your current streak and progress."
                     : "Extending your period for the same topic will keep your current progress!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        showConfirmation = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(Capsule().stroke(Color.primary.opacity(0.3), lineWidth: 1))
                    
                    Button("Update") {
                        viewModel.updateGoal(newTopic: newTopic, newPeriod: selectedPeriod)
                        showConfirmation = false
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
            .padding(.horizontal, 32)
        }
    }
}

