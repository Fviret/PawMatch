import Foundation
import Domain

/// Typed access to `Resources/Localizable.xcstrings` (conventions: see DesignSystem/Strings.swift).
enum Strings {
    static var title: String { String(localized: "matches.title", bundle: .module) }
    static var emptyTitle: String { String(localized: "matches.empty.title", bundle: .module) }
    static var emptyMessage: String { String(localized: "matches.empty.message", bundle: .module) }
    static var errorTitle: String { String(localized: "matches.error.title", bundle: .module) }

    static func count(_ count: Int) -> String {
        String(localized: "matches.count \(count)", bundle: .module)
    }

    static func requestedOn(_ formattedDate: String) -> String {
        String(localized: "matches.requestedOn \(formattedDate)", bundle: .module)
    }

    static func status(_ status: MatchStatus) -> String {
        String(localized: String.LocalizationValue("matches.status.\(status.rawValue)"), bundle: .module)
    }
}
