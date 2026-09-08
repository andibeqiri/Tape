import SwiftUI

extension View {
    func inputGlass(cornerRadius: CGFloat = 24) -> some View {
        self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius, style: .continuous))
    }

    func pillGlass(isActive: Bool = false) -> some View {
        modifier(PillGlassModifier(isActive: isActive))
    }
}

private struct PillGlassModifier: ViewModifier {
    let isActive: Bool
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        if isActive {
            content.glassEffect(.regular.tint(theme.accent.opacity(0.25)).interactive(), in: .capsule)
        } else {
            content.glassEffect(.regular.interactive(), in: .capsule)
        }
    }
}
