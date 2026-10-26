import Foundation

/// Typed access to `Resources/Localizable.xcstrings` (conventions: see DesignSystem/Strings.swift).
enum Strings {
    static var sectionCompatibility: String { String(localized: "detail.section.compatibility", bundle: .module) }
    static var sectionAbout: String { String(localized: "detail.section.about", bundle: .module) }
    static var sectionHealth: String { String(localized: "detail.section.health", bundle: .module) }
    static var sectionShelter: String { String(localized: "detail.section.shelter", bundle: .module) }
    static var healthNeutered: String { String(localized: "detail.health.neutered", bundle: .module) }
    static var healthVaccinated: String { String(localized: "detail.health.vaccinated", bundle: .module) }
    static var healthIdentified: String { String(localized: "detail.health.identified", bundle: .module) }
    static var yes: String { String(localized: "detail.answer.yes", bundle: .module) }
    static var no: String { String(localized: "detail.answer.no", bundle: .module) }
    static var mixedBreed: String { String(localized: "detail.breed.mixed", bundle: .module) }

    static func shelterLocation(city: String, country: String) -> String {
        String(localized: "detail.shelter.location \(city) \(country)", bundle: .module)
    }
}
