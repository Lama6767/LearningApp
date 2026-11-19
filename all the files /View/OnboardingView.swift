import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var createdGoal: LearningGoal? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {

                // الأيقونة
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)

                Spacer()

                // الترحيب
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 6) {
                        Text("Hello").fontWeight(.light)
                        Text("Learner").fontWeight(.bold)
                    }
                    .font(.largeTitle)
                    Text("This app will help you learn everyday!")
                        .foregroundStyle(.secondary)
                }

                // الحقل
                VStack(alignment: .leading, spacing: 8) {
                    Text("I want to learn")
                    TextField("Swift", text: $viewModel.subject)
                        .foregroundStyle(.primary)
                    Divider()
                }

                // المدة
                VStack(alignment: .leading, spacing: 12) {
                    Text("I want to learn it in a")
                    GlassEffectContainer(spacing: 12) {
                        HStack(spacing: 12) {
                            ForEach(Period.allCases, id: \.self) { period in
                                let isSelected = viewModel.selectedPeriod == period
                                Button {
                                    viewModel.selectedPeriod = period
                                } label: {
                                    Text(period.title)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .foregroundStyle(isSelected ? Color.white : Color.gray)
                                }
                                .buttonStyle(.plain)
                                .glassEffect(isSelected ? .regular.tint(.orange).interactive() : .regular.interactive())
                            }
                        }
                    }
                }

                Spacer()

                // الزر + النص
                VStack(spacing: 8) {
                    Button {
                        if let goal = viewModel.makeGoal() {
                            createdGoal = goal
                        }
                    } label: {
                        Text("Start Learning")
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .foregroundStyle(viewModel.isFormValid ? Color.white : Color.gray)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(viewModel.isFormValid ? .regular.tint(.orange).interactive() : .regular)
                    .disabled(!viewModel.isFormValid)

                    Text("You can edit your desire later")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .navigationDestination(item: $createdGoal) { goal in
                ActivityView(topic: goal.subject, period: goal.period)
            }
        }
    }
}

#Preview("Light") {
    OnboardingView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    OnboardingView()
        .preferredColorScheme(.dark)
}
