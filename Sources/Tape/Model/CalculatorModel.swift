import Foundation

struct HistoryEntry: Identifiable {
    let id = UUID()
    let expression: String
    let result: Double

    var resultString: String { formatNumber(result) }
}

@Observable
@MainActor
final class CalculatorModel {
    var expression: String = ""
    var cursorIndex: Int = 0
    var history: [HistoryEntry] = []

    var result: Double? { ExpressionEvaluator.evaluate(expression) }

    var resultText: String {
        guard let r = result else { return "" }
        return formatNumber(r)
    }

    func insert(_ text: String) {
        let idx = expression.index(expression.startIndex, offsetBy: cursorIndex)
        expression.insert(contentsOf: text, at: idx)
        cursorIndex += text.count
    }

    func deleteBackward() {
        guard cursorIndex > 0 else { return }
        let end = expression.index(expression.startIndex, offsetBy: cursorIndex)
        let start = expression.index(before: end)
        expression.removeSubrange(start..<end)
        cursorIndex -= 1
    }

    func moveCursor(to index: Int) {
        cursorIndex = max(0, min(index, expression.count))
    }

    func moveCursorBy(_ delta: Int) {
        moveCursor(to: cursorIndex + delta)
    }

    func confirmResult() {
        guard let r = result else { return }
        history.insert(HistoryEntry(expression: expression, result: r), at: 0)
        let text = formatNumber(r)
        expression = text
        cursorIndex = text.count
    }

    func clear() {
        expression = ""
        cursorIndex = 0
    }

    func loadFromHistory(_ entry: HistoryEntry) {
        expression = entry.expression
        cursorIndex = entry.expression.count
    }
}

private func formatNumber(_ value: Double) -> String {
    if value.isNaN || value.isInfinite { return "" }
    if value == 0 { return "0" }
    if value.truncatingRemainder(dividingBy: 1) == 0 && abs(value) < 1e15 {
        return String(format: "%.0f", value)
    }
    return String(format: "%.10g", value)
}
