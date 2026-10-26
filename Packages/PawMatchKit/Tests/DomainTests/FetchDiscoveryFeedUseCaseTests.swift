import Testing
import Domain
import Fixtures

struct FetchDiscoveryFeedUseCaseTests {
    @Test func excludesDecidedAnimalsAndSortsByCompatibility() async throws {
        let profile = AdopterProfile.fixture(hasChildren: true)
        let great = Animal.fixture(id: "great", compatibility: Compatibility(children: .yes, dogs: .unknown, cats: .unknown))
        let poor = Animal.fixture(id: "poor", compatibility: Compatibility(children: .no, dogs: .unknown, cats: .unknown))
        let alreadySeen = Animal.fixture(id: "seen")

        let useCase = FetchDiscoveryFeedUseCase(
            animals: StubAnimalRepository(animals: [poor, alreadySeen, great]),
            matches: StubMatchRepository(decided: [alreadySeen.id]),
            profiles: StubProfileRepository(profile: profile)
        )

        let feed = try await useCase()

        #expect(feed.map(\.id) == [great.id, poor.id])
    }

    @Test func computesDistanceFromAdopterLocation() async throws {
        let animal = Animal.fixture(shelter: .fixture(coordinate: .lyon))
        let useCase = FetchDiscoveryFeedUseCase(
            animals: StubAnimalRepository(animals: [animal]),
            matches: StubMatchRepository(decided: []),
            profiles: StubProfileRepository(profile: .fixture(location: .paris))
        )

        let distance = try #require(try await useCase().first?.distanceMeters)

        #expect(abs(distance - 392_000) < 5_000)
    }
}

struct MarketConfigurationTests {
    @Test func resolvesFranceCaseInsensitively() {
        #expect(MarketConfiguration.resolve(regionCode: "fr") == .france)
        #expect(MarketConfiguration.france.coolingOffPeriodDays == 7)
    }

    @Test(arguments: [nil, "US", "JP"])
    func unknownMarketsFallBackToGeneric(regionCode: String?) {
        #expect(MarketConfiguration.resolve(regionCode: regionCode) == .generic)
    }
}

// MARK: - Stubs

private struct StubAnimalRepository: AnimalRepository {
    let animals: [Animal]

    func discoveryFeed(for profile: AdopterProfile) async throws -> [Animal] { animals }
    func animal(withID id: Animal.ID) async throws -> Animal { animals.first { $0.id == id }! }
}

private struct StubMatchRepository: MatchRepository {
    let decided: Set<Animal.ID>

    func record(_ decision: SwipeDecision, for animal: Animal) async throws -> Match? { nil }
    func matches() async throws -> [Match] { [] }
    func decidedAnimalIDs() async throws -> Set<Animal.ID> { decided }
}

private struct StubProfileRepository: AdopterProfileRepository {
    let profile: AdopterProfile

    func currentProfile() async throws -> AdopterProfile { profile }
}
