import SwiftUI

struct ContentView: View {
    @State private var model = CalculatorModel()
    @State private var expressionAppeared = false
    @State private var isHistoryPresented = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("History", systemImage: "clock.arrow.circlepath") {
                    isHistoryPresented = true
                }
                .labelStyle(.iconOnly)
                .frame(width: 44, height: 44)
                .pillGlass()
                .disabled(model.history.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            expressionCard
                .padding(.vertical, 8)
                .offset(y: expressionAppeared ? 0 : -400)
                .onAppear {
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                        expressionAppeared = true
                    }
                }

            Divider()

            KeypadView(model: model)
                .frame(maxHeight: .infinity)
        }
        .background(
            LinearGradient(
                colors: [Color(white: 0.10), Color(white: 0.03)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $isHistoryPresented) {
            NavigationStack {
                HistoryView(model: model)
                    .navigationTitle("History")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("History", systemImage: "clock.arrow.circlepath") {
                                isHistoryPresented = false
                            }
                            .labelStyle(.iconOnly)
                        }
                    }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var expressionCard: some View {
        VStack(alignment: .trailing, spacing: 4) {
            ExpressionView(model: model)
            resultLine
                .frame(height: 30)
        }
        .padding(.top, 8)
        .padding(.bottom, 10)
        .inputGlass()
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var resultLine: some View {
        let text = model.resultText
        if !text.isEmpty && model.expression != text {
            Text("= \(text)")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(.secondary)
                .padding(.trailing, 24)
                .contentTransition(.numericText())
                .animation(.default, value: text)
        } else {
            Color.clear
        }
    }
}
