import SwiftUI

@main
struct TapeApp: App {
    private let theme = Theme.default

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.theme, theme)
                .tint(theme.accent)
                .preferredColorScheme(.dark)
        }
    }
}
