import Domain

/// Demo/offline implementation. Mirrors the filtering the real backend is expected to do.
public actor InMemoryAnimalRepository: AnimalRepository {
    private let animals: [Animal]

    public init(animals: [Animal]) {
        self.animals = animals
    }

    public func discoveryFeed(for profile: AdopterProfile) async throws -> [Animal] {
        animals.filter { animal in
            let speciesMatches = profile.preferredSpecies.isEmpty || profile.preferredSpecies.contains(animal.species)
            let isInRange = profile.location.map {
                $0.distance(to: animal.shelter.coordinate) <= profile.searchRadiusKilometers * 1_000
            } ?? true
            return speciesMatches && isInRange
        }
    }

    public func animal(withID id: Animal.ID) async throws -> Animal {
        guard let animal = animals.first(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        return animal
    }
}

public enum RepositoryError: Error, Equatable {
    case notFound
}
