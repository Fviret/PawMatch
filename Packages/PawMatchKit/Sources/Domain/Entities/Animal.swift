import Foundation

/// An animal available for adoption.
///
/// Internationalisation rules applied here:
/// - quantities are stored in SI units (`weightKilograms`); conversion to lb is a presentation concern;
/// - enums carry *semantic* values only, never display text;
/// - free text (`breedName`, `story`) comes already localized from the backend,
///   because it is shelter content, not app UI.
public struct Animal: Identifiable, Hashable, Sendable {
    public typealias ID = Identifier<Animal>

    public let id: ID
    public let name: String
    public let species: Species
    /// Breed label localized by the backend (breed registries differ per country). `nil` for mixed breeds.
    public let breedName: String?
    public let sex: Sex
    public let birthDate: Date
    public let size: Size
    public let weightKilograms: Double?
    public let energyLevel: EnergyLevel
    public let compatibility: Compatibility
    public let needs: Needs
    public let health: Health
    /// Written by the shelter; localized by the backend when a translation exists.
    public let story: String
    public let photoURLs: [URL]
    public let shelter: Shelter
    public let publishedAt: Date

    public init(
        id: ID,
        name: String,
        species: Species,
        breedName: String?,
        sex: Sex,
        birthDate: Date,
        size: Size,
        weightKilograms: Double?,
        energyLevel: EnergyLevel,
        compatibility: Compatibility,
        needs: Needs,
        health: Health,
        story: String,
        photoURLs: [URL],
        shelter: Shelter,
        publishedAt: Date
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.breedName = breedName
        self.sex = sex
        self.birthDate = birthDate
        self.size = size
        self.weightKilograms = weightKilograms
        self.energyLevel = energyLevel
        self.compatibility = compatibility
        self.needs = needs
        self.health = health
        self.story = story
        self.photoURLs = photoURLs
        self.shelter = shelter
        self.publishedAt = publishedAt
    }

    /// Age in whole months; the UI decides whether to display months or years.
    public func ageInMonths(at date: Date = .now, calendar: Calendar = .current) -> Int {
        max(calendar.dateComponents([.month], from: birthDate, to: date).month ?? 0, 0)
    }
}

/// Unknown values sent by a newer backend decode to `.other` instead of failing (see DataAccess).
public enum Species: String, Hashable, Sendable, CaseIterable, Codable {
    case dog, cat, rabbit, other
}

public enum Sex: String, Hashable, Sendable, CaseIterable, Codable {
    case female, male, unknown
}

public enum Size: String, Hashable, Sendable, CaseIterable, Codable {
    case small, medium, large, extraLarge
}

public enum EnergyLevel: Int, Hashable, Sendable, CaseIterable, Codable, Comparable {
    case low = 1, moderate, high

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

/// Shelters often don't know: "unknown" must stay distinct from "no".
public enum CompatibilityAnswer: String, Hashable, Sendable, Codable {
    case yes, no, unknown
}

public struct Compatibility: Hashable, Sendable {
    public let children: CompatibilityAnswer
    public let dogs: CompatibilityAnswer
    public let cats: CompatibilityAnswer

    public init(children: CompatibilityAnswer, dogs: CompatibilityAnswer, cats: CompatibilityAnswer) {
        self.children = children
        self.dogs = dogs
        self.cats = cats
    }

    public func answer(with species: Species) -> CompatibilityAnswer {
        switch species {
        case .dog: dogs
        case .cat: cats
        case .rabbit, .other: .unknown
        }
    }
}

public struct Needs: Hashable, Sendable {
    public let garden: Bool
    public let experiencedOwner: Bool

    public init(garden: Bool, experiencedOwner: Bool) {
        self.garden = garden
        self.experiencedOwner = experiencedOwner
    }
}

public struct Health: Hashable, Sendable {
    public let isNeutered: Bool
    public let isVaccinated: Bool
    /// Microchip or tattoo; mandatory for dogs and cats in France.
    public let isIdentified: Bool

    public init(isNeutered: Bool, isVaccinated: Bool, isIdentified: Bool) {
        self.isNeutered = isNeutered
        self.isVaccinated = isVaccinated
        self.isIdentified = isIdentified
    }
}
