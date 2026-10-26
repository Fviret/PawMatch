import Foundation
import Domain

// Builders with sensible defaults: tests and previews only state what matters to them.

public extension Shelter {
    static func fixture(
        id: String = "shelter-test",
        name: String = "Refuge de test",
        city: String = "Paris",
        regionCode: String = "FR",
        coordinate: GeoCoordinate = .paris
    ) -> Shelter {
        Shelter(id: Shelter.ID(id), name: name, city: city, regionCode: regionCode, coordinate: coordinate)
    }
}

public extension Animal {
    static func fixture(
        id: String = UUID().uuidString,
        name: String = "Rex",
        species: Species = .dog,
        breedName: String? = nil,
        sex: Sex = .male,
        ageInMonths: Int = 24,
        size: Size = .medium,
        weightKilograms: Double? = 12,
        energyLevel: EnergyLevel = .moderate,
        compatibility: Compatibility = Compatibility(children: .unknown, dogs: .unknown, cats: .unknown),
        needs: Needs = Needs(garden: false, experiencedOwner: false),
        health: Health = Health(isNeutered: true, isVaccinated: true, isIdentified: true),
        story: String = "",
        photoURLs: [URL] = [],
        shelter: Shelter = .fixture(),
        publishedAt: Date = Date(timeIntervalSince1970: 1_760_000_000)
    ) -> Animal {
        Animal(
            id: Animal.ID(id),
            name: name,
            species: species,
            breedName: breedName,
            sex: sex,
            birthDate: Calendar.current.date(byAdding: .month, value: -ageInMonths, to: .now) ?? .now,
            size: size,
            weightKilograms: weightKilograms,
            energyLevel: energyLevel,
            compatibility: compatibility,
            needs: needs,
            health: health,
            story: story,
            photoURLs: photoURLs,
            shelter: shelter,
            publishedAt: publishedAt
        )
    }
}

public extension AdopterProfile {
    static func fixture(
        housing: HousingType = .apartment,
        hasChildren: Bool = false,
        otherPets: Set<Species> = [],
        activityLevel: EnergyLevel = .moderate,
        isFirstPet: Bool = false,
        preferredSpecies: Set<Species> = [],
        location: GeoCoordinate? = .paris,
        searchRadiusKilometers: Double = 1_000
    ) -> AdopterProfile {
        AdopterProfile(
            housing: housing,
            hasChildren: hasChildren,
            otherPets: otherPets,
            activityLevel: activityLevel,
            isFirstPet: isFirstPet,
            preferredSpecies: preferredSpecies,
            location: location,
            searchRadiusKilometers: searchRadiusKilometers
        )
    }
}

public extension GeoCoordinate {
    static let paris = GeoCoordinate(latitude: 48.8566, longitude: 2.3522)
    static let lyon = GeoCoordinate(latitude: 45.7640, longitude: 4.8357)
    static let marseille = GeoCoordinate(latitude: 43.2965, longitude: 5.3698)
    static let annecy = GeoCoordinate(latitude: 45.8992, longitude: 6.1294)
    static let liege = GeoCoordinate(latitude: 50.6326, longitude: 5.5797)
}
