import Foundation
import Testing
import Domain
import Fixtures
@testable import DataAccess

struct AnimalDTOTests {
    private let json = """
    {
      "id": "a1", "name": "Kiwi", "species": "ferret", "breed_name": null, "sex": "female",
      "birth_date": "2023-04-01T00:00:00Z", "size": "small", "weight_kg": 1.2, "energy_level": 3,
      "good_with_children": "yes", "good_with_dogs": null, "good_with_cats": "maybe",
      "needs_garden": false, "requires_experienced_owner": true,
      "is_neutered": true, "is_vaccinated": true, "is_identified": false,
      "story": "Kiwi adore explorer.", "photo_urls": ["https://example.com/kiwi.jpg"],
      "shelter": { "id": "s1", "name": "Refuge", "city": "Lyon", "region_code": "FR", "latitude": 45.76, "longitude": 4.83 },
      "published_at": "2026-10-01T08:00:00Z"
    }
    """

    @Test func unknownValuesDegradeGracefully() throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let animal = try decoder.decode(AnimalDTO.self, from: Data(json.utf8)).toDomain()

        #expect(animal.species == .other)
        #expect(animal.compatibility.cats == .unknown)
        #expect(animal.compatibility.dogs == .unknown)
        #expect(animal.compatibility.children == .yes)
        #expect(animal.energyLevel == .high)
        #expect(animal.shelter.regionCode == "FR")
    }
}

struct APIClientTests {
    @Test func acceptLanguageHeaderListsPreferencesWithDecreasingQuality() {
        #expect(APIClient.acceptLanguageHeader(for: ["fr-FR", "en-US", "es"]) == "fr-FR, en-US;q=0.9, es;q=0.8")
    }
}

struct InMemoryRepositoryTests {
    @Test func likeCreatesPendingMatchAndPassDoesNot() async throws {
        let repository = InMemoryMatchRepository()
        let liked = Animal.fixture(id: "liked")
        let passed = Animal.fixture(id: "passed")

        let match = try await repository.record(.like, for: liked)
        let noMatch = try await repository.record(.pass, for: passed)

        #expect(match?.status == .pending)
        #expect(noMatch == nil)
        #expect(try await repository.matches().map(\.animal.id) == [liked.id])
        #expect(try await repository.decidedAnimalIDs() == [liked.id, passed.id])
    }

    @Test func feedFiltersBySpeciesAndRadius() async throws {
        let nearbyDog = Animal.fixture(id: "dog", species: .dog, shelter: .fixture(coordinate: .paris))
        let nearbyCat = Animal.fixture(id: "cat", species: .cat, shelter: .fixture(coordinate: .paris))
        let farDog = Animal.fixture(id: "far", species: .dog, shelter: .fixture(coordinate: .marseille))
        let repository = InMemoryAnimalRepository(animals: [nearbyDog, nearbyCat, farDog])

        let feed = try await repository.discoveryFeed(
            for: .fixture(preferredSpecies: [.dog], location: .paris, searchRadiusKilometers: 100)
        )

        #expect(feed.map(\.id) == [nearbyDog.id])
    }
}
