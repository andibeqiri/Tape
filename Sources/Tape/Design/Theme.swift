import SwiftUI

struct Theme {
    var accent: Color

    static let `default` = Theme(accent: .orange)
}

extension EnvironmentValues {
    @Entry var theme: Theme = .default
}
