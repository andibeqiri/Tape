import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    let model: CalculatorModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .trailing, spacing: 0) {
                ForEach(model.history.reversed()) { entry in
                    Button {
                        model.loadFromHistory(entry)
                        dismiss()
                    } label: {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(entry.expression)
                                .font(.system(size: 18, weight: .light))
                                .foregroundStyle(.secondary)
                            Text("= \(entry.resultString)")
                                .font(.system(size: 13))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Divider().padding(.horizontal, 24)
                }
            }
        }
        .defaultScrollAnchor(.bottom)
        .accessibilityIdentifier("historyList")
    }
}
