import SwiftUI

struct ExpressionView: View {
    let model: CalculatorModel

    private var chars: [Character] { Array(model.expression) }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    CursorMarker(active: model.cursorIndex == 0)
                        .id(0)
                    ForEach(Array(chars.enumerated()), id: \.offset) { i, char in
                        CharView(
                            char: char,
                            isOperator: isOperator(char),
                            onBefore: { model.moveCursor(to: i) },
                            onAfter:  { model.moveCursor(to: i + 1) }
                        )
                        CursorMarker(active: model.cursorIndex == i + 1)
                            .id(i + 1)
                    }
                    if model.expression.isEmpty {
                        Color.clear
                            .frame(width: 40, height: 56)
                            .contentShape(Rectangle())
                            .onTapGesture { model.moveCursor(to: 0) }
                    }
                }
                .padding(.horizontal, 24)
                .overlayPreferenceValue(CursorAnchorKey.self) { anchor in
                    if let anchor {
                        GeometryReader { proxy in
                            BlinkingCursor()
                                .position(x: proxy[anchor].midX, y: proxy[anchor].midY)
                        }
                    }
                }
            }
            .onChange(of: model.cursorIndex) {
                proxy.scrollTo(model.cursorIndex, anchor: .trailing)
            }
        }
        .frame(height: 72)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.expression.isEmpty ? "Empty expression" : model.expression)
        .accessibilityValue("Cursor position \(model.cursorIndex + 1) of \(model.expression.count + 1)")
        .accessibilityIdentifier("expression")
        .accessibilityAdjustableAction { direction in
            model.moveCursorBy(direction == .increment ? 1 : -1)
        }
    }

    private func isOperator(_ c: Character) -> Bool {
        "+-*/×÷".contains(c)
    }
}

// MARK: - Cursor position marker

private struct CursorMarker: View {
    let active: Bool
    var body: some View {
        Color.clear
            .frame(width: 0, height: 50)
            .anchorPreference(key: CursorAnchorKey.self, value: .bounds) {
                active ? $0 : nil
            }
    }
}

private struct CursorAnchorKey: PreferenceKey {
    static let defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

// MARK: - Individual character

private struct CharView: View {
    let char: Character
    let isOperator: Bool
    let onBefore: () -> Void
    let onAfter: () -> Void
    @Environment(\.theme) private var theme

    var body: some View {
        Text(String(char))
            .font(.system(size: 46, weight: .light, design: .default))
            .foregroundStyle(isOperator ? theme.accent : Color.primary)
            .fixedSize()
            .overlay(
                HStack(spacing: 0) {
                    Color.clear.contentShape(Rectangle()).onTapGesture { onBefore() }
                    Color.clear.contentShape(Rectangle()).onTapGesture { onAfter() }
                }
            )
    }
}

// MARK: - Blinking cursor

struct BlinkingCursor: View {
    @State private var visible = true

    var body: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(Color.accentColor)
            .frame(width: 2, height: 50)
            .opacity(visible ? 1 : 0)
            .padding(.horizontal, 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.53).repeatForever(autoreverses: true)) {
                    visible.toggle()
                }
            }
    }
}
