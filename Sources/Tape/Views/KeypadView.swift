import SwiftUI

private let keypadCornerRadius: CGFloat = 16
private let cursorScrubPadOutset: CGFloat = 4
private let keypadHorizontalPadding: CGFloat = 12

// MARK: - Keypad

struct KeypadView: View {
    let model: CalculatorModel

    @State private var isDragging = false
    @State private var enteringDragMode = false
    @State private var lastSteppedX: CGFloat = 0

    private let sensitivity: CGFloat = 10.0

    var body: some View {
        VStack(spacing: 10) {
            buttonGrid
                .disabled(isDragging)
                .opacity(isDragging ? 0.9 : 1.0)

            hintBar
        }
        .padding(.horizontal, keypadHorizontalPadding)
        .padding(.bottom, 12)
        .overlay {
            if isDragging {
                cursorScrubPad
                    .padding(.top, -cursorScrubPadOutset)
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isDragging)
        .contentShape(Rectangle())
        // Observe the hold without delaying normal button taps.
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.32, maximumDistance: 30)
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.16)) { isDragging = true }
                    enteringDragMode = true
                }
        )
        // Drag runs in parallel; the guard keeps it inert until isDragging
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    if enteringDragMode {
                        enteringDragMode = false
                        lastSteppedX = value.translation.width
                    }
                    guard isDragging else { return }
                    let delta = value.translation.width - lastSteppedX
                    let steps = Int(delta / sensitivity)
                    if steps != 0 {
                        model.moveCursorBy(steps)
                        lastSteppedX += CGFloat(steps) * sensitivity
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.16)) { isDragging = false }
                    enteringDragMode = false
                    lastSteppedX = 0
                }
        )
        .sensoryFeedback(.impact(weight: .medium), trigger: isDragging) { _, new in new }
        .sensoryFeedback(.selection, trigger: model.cursorIndex)
    }

    // MARK: - Button grid

    @ViewBuilder
    private var buttonGrid: some View {
        GlassEffectContainer(spacing: 8) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    CalcButton("C",  role: .function)  { model.clear() }
                    CalcButton("(",  role: .function)  { model.insert("(") }
                    CalcButton(")",  role: .function)  { model.insert(")") }
                    CalcButton("÷",  role: .operator)  { model.insert("/") }
                }
                .frame(maxHeight: .infinity)

                HStack(spacing: 8) {
                    CalcButton("7") { model.insert("7") }
                    CalcButton("8") { model.insert("8") }
                    CalcButton("9") { model.insert("9") }
                    CalcButton("×", role: .operator)   { model.insert("*") }
                }
                .frame(maxHeight: .infinity)

                HStack(spacing: 8) {
                    CalcButton("4") { model.insert("4") }
                    CalcButton("5") { model.insert("5") }
                    CalcButton("6") { model.insert("6") }
                    CalcButton("−", role: .operator)   { model.insert("-") }
                }
                .frame(maxHeight: .infinity)

                HStack(spacing: 8) {
                    CalcButton("1") { model.insert("1") }
                    CalcButton("2") { model.insert("2") }
                    CalcButton("3") { model.insert("3") }
                    CalcButton("+", role: .operator)   { model.insert("+") }
                }
                .frame(maxHeight: .infinity)

                HStack(spacing: 8) {
                    CalcButton(".")             { model.insert(".") }
                    CalcButton("0")             { model.insert("0") }
                    CalcButton("⌫", role: .function) { model.deleteBackward() }
                    CalcButton("=",  role: .equals)  { model.confirmResult() }
                        .sensoryFeedback(.success, trigger: model.history.count)
                }
                .frame(maxHeight: .infinity)
            }
        }
    }

    // MARK: - Drag mode overlay

    private var cursorScrubPad: some View {
        let cornerRadius = keypadCornerRadius + cursorScrubPadOutset
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: cornerRadius,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: cornerRadius,
            style: .continuous
        )

        return ZStack {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .glassEffect(.clear, in: shape)
                .overlay {
                    shape.strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.24),
                                    Color.white.opacity(0.04),
                                    Color.white.opacity(0.12),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.75
                        )
                }
                .shadow(color: Color.black.opacity(0.14), radius: 16, y: 8)

            HStack(spacing: 16) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                Text("drag to move cursor")
                    .font(.system(size: 16, weight: .medium))
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Hint

    private var hintBar: some View {
        HStack(spacing: 5) {
            Image(systemName: "hand.point.up.left.fill")
                .font(.caption2)
            Text("Hold keypad & drag to move cursor")
                .font(.caption2)
        }
        .foregroundStyle(.quaternary)
        .padding(.bottom, 4)
    }
}

// MARK: - Calculator button

enum CalcButtonRole { case digit, `operator`, function, equals }

struct CalcButton: View {
    let label: String
    let role: CalcButtonRole
    let action: () -> Void
    @Environment(\.theme) private var theme

    init(_ label: String, role: CalcButtonRole = .digit, action: @escaping () -> Void) {
        self.label = label
        self.role = role
        self.action = action
    }

    private var fgStyle: some ShapeStyle {
        switch role {
        case .operator: return AnyShapeStyle(theme.accent)
        case .equals:   return AnyShapeStyle(Color.white)
        default:        return AnyShapeStyle(Color.primary)
        }
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 26, weight: role == .equals ? .semibold : .regular))
                .foregroundStyle(fgStyle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(CalcButtonGlass(role: role, accent: theme.accent))
                .contentShape(.rect(cornerRadius: keypadCornerRadius, style: .continuous))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(.rect(cornerRadius: keypadCornerRadius, style: .continuous))
        .buttonStyle(CalcButtonStyle())
    }
}

private struct CalcButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                RoundedRectangle(cornerRadius: keypadCornerRadius, style: .continuous)
                    .fill(.white.opacity(configuration.isPressed ? 0.12 : 0))
                    .allowsHitTesting(false)
            }
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

private struct CalcButtonGlass: ViewModifier {
    let role: CalcButtonRole
    let accent: Color

    func body(content: Content) -> some View {
        switch role {
        case .digit:
            content.glassEffect(.regular, in: .rect(cornerRadius: keypadCornerRadius, style: .continuous))
        case .function:
            content.glassEffect(.regular, in: .rect(cornerRadius: keypadCornerRadius, style: .continuous))
        case .operator:
            content.glassEffect(
                .regular.tint(accent.opacity(0.18)),
                in: .rect(cornerRadius: keypadCornerRadius, style: .continuous)
            )
        case .equals:
            content.glassEffect(
                .regular.tint(accent),
                in: .rect(cornerRadius: keypadCornerRadius, style: .continuous)
            )
        }
    }
}
