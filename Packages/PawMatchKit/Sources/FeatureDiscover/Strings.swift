import Foundation

/// Typed access to `Resources/Localizable.xcstrings` (conventions: see DesignSystem/Strings.swift).
enum Strings {
    static var title: String { String(localized: "discover.title", bundle: .module) }
    static var loading: String { String(localized: "discover.loading", bundle: .module) }
    static var emptyTitle: String { String(localized: "discover.empty.title", bundle: .module) }
    static var emptyMessage: String { String(localized: "discover.empty.message", bundle: .module) }
    static var errorTitle: String { String(localized: "discover.error.title", bundle: .module) }
    static var retry: String { String(localized: "discover.error.retry", bundle: .module) }
    static var like: String { String(localized: "discover.action.like", bundle: .module) }
    static var pass: String { String(localized: "discover.action.pass", bundle: .module) }
    static var details: String { String(localized: "discover.action.details", bundle: .module) }
    static var close: String { String(localized: "discover.action.close", bundle: .module) }
    static var matchTitle: String { String(localized: "discover.match.title", bundle: .module) }
    static var matchContinue: String { String(localized: "discover.match.continue", bundle: .module) }

    static func matchMessage(shelter: String, animal: String) -> String {
        String(localized: "discover.match.message \(shelter) \(animal)", bundle: .module)
    }

    static func coolingOff(days: Int) -> String {
        String(localized: "discover.match.coolingOff \(days)", bundle: .module)
    }

    static func distance(_ formattedDistance: String) -> String {
        String(localized: "discover.distance \(formattedDistance)", bundle: .module)
    }
}
