import Testing
import Domain
import DataAccess
import Fixtures
@testable import FeatureDiscover

@MainActor
struct DiscoverViewModelTests {
    private func makeViewModel(
        animals: [Animal],
        matches: any MatchRepository = InMemoryMatchRepository()
    ) -> DiscoverViewModel {
        let animalRepository = InMemoryAnimalRepository(animals: animals)
        let profiles = InMemoryAdopterProfileRepository(profile: .fixture())
        return DiscoverViewModel(
            fetchFeed: FetchDiscoveryFeedUseCase(animals: animalRepository, matches: matches, profiles: profiles),
            recordSwipe: RecordSwipeUseCase(matches: matches),
            market: .france
        )
    }

    @Test func loadFillsTheDeck() async {
        let viewModel = makeViewModel(animals: [.fixture(id: "a"), .fixture(id: "b")])

        await viewModel.load()

        #expect(viewModel.state == .loaded)
        #expect(viewModel.deck.count == 2)
    }

    @Test func likeRemovesCardAndExposesMatch() async throws {
        let viewModel = makeViewModel(animals: [.fixture(id: "a"), .fixture(id: "b")])
        await viewModel.load()
        let top = try #require(viewModel.deck.first)

        await viewModel.decide(.like, on: top)

        #expect(!viewModel.deck.contains(top))
        #expect(viewModel.lastMatch?.animal.id == top.id)
    }

    @Test func passDoesNotCreateMatch() async throws {
        let viewModel = makeViewModel(animals: [.fixture(id: "a")])
        await viewModel.load()

        await viewModel.decide(.pass, on: try #require(viewModel.deck.first))

        #expect(viewModel.deck.isEmpty)
        #expect(viewModel.lastMatch == nil)
    }

    @Test func failedSaveRestoresTheCard() async throws {
        let viewModel = makeViewModel(animals: [.fixture(id: "a")], matches: FailingMatchRepository())
        await viewModel.load()
        let top = try #require(viewModel.deck.first)

        await viewModel.decide(.like, on: top)

        #expect(viewModel.deck == [top])
        #expect(viewModel.lastMatch == nil)
    }
}

private struct FailingMatchRepository: MatchRepository {
    struct SaveError: Error {}

    func record(_ decision: SwipeDecision, for animal: Animal) async throws -> Match? { throw SaveError() }
    func matches() async throws -> [Match] { [] }
    func decidedAnimalIDs() async throws -> Set<Animal.ID> { [] }
}
