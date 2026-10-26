import Foundation
import Domain

// Display names for Domain enums. Domain stays UI-free; this is the only place
// that turns semantic values into text.

public extension Species {
    var localizedName: String { Strings.lookup("species.\(rawValue)") }

    var symbolName: String {
        switch self {
        case .dog: "dog.fill"
        case .cat: "cat.fill"
        case .rabbit: "hare.fill"
        case .other: "pawprint.fill"
        }
    }
}

public extension Sex {
    var localizedName: String { Strings.lookup("sex.\(rawValue)") }
}

public extension Size {
    var localizedName: String { Strings.lookup("size.\(rawValue)") }
}

public extension EnergyLevel {
    var localizedName: String {
        switch self {
        case .low: Strings.lookup("energy.low")
        case .moderate: Strings.lookup("energy.moderate")
        case .high: Strings.lookup("energy.high")
        }
    }
}

public extension CompatibilityReason {
    var localizedTitle: String { Strings.lookup("compatibility.\(rawValue)") }
}

public enum AnimalFormatter {
    /// "6 mois" / "3 ans" / "1 year", with plural rules handled by the String Catalog.
    public static func age(of animal: Animal, at date: Date = .now) -> String {
        let months = animal.ageInMonths(at: date)
        return months < 12 ? Strings.ageMonths(months) : Strings.ageYears(months / 12)
    }

    /// kg or lb depending on the user's region settings.
    public static func weight(kilograms: Double, locale: Locale = .current) -> String {
        Measurement(value: kilograms, unit: UnitMass.kilograms)
            .formatted(.measurement(width: .abbreviated, usage: .personWeight, numberFormatStyle: .number.precision(.fractionLength(0...1))).locale(locale))
    }

    /// km or mi depending on the user's region settings.
    public static func distance(meters: Double, locale: Locale = .current) -> String {
        Measurement(value: meters, unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road).locale(locale))
    }

    public static func compatibilityScore(_ score: CompatibilityScore) -> String {
        Strings.compatibilityScore(score.value)
    }

    /// Country name in the user's language, e.g. "BE" → "Belgique" / "Belgium".
    public static func countryName(regionCode: String, locale: Locale = .current) -> String {
        locale.localizedString(forRegionCode: regionCode) ?? regionCode
    }
}
