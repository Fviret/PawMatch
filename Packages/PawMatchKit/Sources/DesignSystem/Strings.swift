import Foundation

/// Typed access to `Resources/Localizable.xcstrings` of this module.
///
/// Conventions (same in every module):
/// - semantic keys `area.element[.variant]`: the English text can change without breaking translations;
/// - interpolations stay inside the localized string (`"%lld years"`) so translators control word order
///   and plural forms — never concatenate translated fragments;
/// - computed properties: the lookup always uses the current app language.
enum Strings {
    static func ageMonths(_ months: Int) -> String {
        String(localized: "animal.age.months \(months)", bundle: .module)
    }

    static func ageYears(_ years: Int) -> String {
        String(localized: "animal.age.years \(years)", bundle: .module)
    }

    static func compatibilityScore(_ value: Int) -> String {
        String(localized: "compatibility.score \(value)", bundle: .module)
    }

    static func photoAccessibilityLabel(_ name: String) -> String {
        String(localized: "accessibility.photo \(name)", bundle: .module)
    }

    /// Dynamic key built from a semantic enum raw value. Every case must exist in the catalog
    /// (checked by `scripts/check_localizations.py`).
    static func lookup(_ key: String) -> String {
        String(localized: String.LocalizationValue(key), bundle: .module)
    }
}
