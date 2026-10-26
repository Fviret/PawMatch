import Foundation
import Domain

/// Wire format. Kept separate from `Animal` so API changes stay contained in this module.
/// Unknown enum values degrade gracefully instead of failing the whole feed.
struct AnimalDTO: Decodable {
    struct ShelterDTO: Decodable {
        let id: String
        let name: String
        let city: String
        let regionCode: String
        let latitude: Double
        let longitude: Double
    }

    let id: String
    let name: String
    let species: String
    let breedName: String?
    let sex: String
    let birthDate: Date
    let size: String
    let weightKg: Double?
    let energyLevel: Int
    let goodWithChildren: String?
    let goodWithDogs: String?
    let goodWithCats: String?
    let needsGarden: Bool
    let requiresExperiencedOwner: Bool
    let isNeutered: Bool
    let isVaccinated: Bool
    let isIdentified: Bool
    let story: String
    let photoUrls: [URL]
    let shelter: ShelterDTO
    let publishedAt: Date

    func toDomain() -> Animal {
        Animal(
            id: Animal.ID(id),
            name: name,
            species: Species(rawValue: species) ?? .other,
            breedName: breedName,
            sex: Sex(rawValue: sex) ?? .unknown,
            birthDate: birthDate,
            size: Size(rawValue: size) ?? .medium,
            weightKilograms: weightKg,
            energyLevel: EnergyLevel(rawValue: energyLevel) ?? .moderate,
            compatibility: Compatibility(
                children: goodWithChildren.flatMap(CompatibilityAnswer.init(rawValue:)) ?? .unknown,
                dogs: goodWithDogs.flatMap(CompatibilityAnswer.init(rawValue:)) ?? .unknown,
                cats: goodWithCats.flatMap(CompatibilityAnswer.init(rawValue:)) ?? .unknown
            ),
            needs: Needs(garden: needsGarden, experiencedOwner: requiresExperiencedOwner),
            health: Health(isNeutered: isNeutered, isVaccinated: isVaccinated, isIdentified: isIdentified),
            story: story,
            photoURLs: photoUrls,
            shelter: Shelter(
                id: Shelter.ID(shelter.id),
                name: shelter.name,
                city: shelter.city,
                regionCode: shelter.regionCode,
                coordinate: GeoCoordinate(latitude: shelter.latitude, longitude: shelter.longitude)
            ),
            publishedAt: publishedAt
        )
    }
}
