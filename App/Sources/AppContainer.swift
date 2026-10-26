import Foundation
import Domain
import DataAccess
import Fixtures
import FeatureDiscover
import FeatureMatches

/// Which backend the app talks to. Selected per build configuration / scheme.
enum AppEnvironment {
    /// Offline, in-memory data: demos, UI work, App Store screenshots.
    case demo
    case remote(baseURL: URL)

    static var current: AppEnvironment {
        // Switch to `.remote` once the API exists, ideally reading the URL from an .xcconfig
        // (one per environment: dev / staging / prod) exposed through Info.plist.
        .demo
    }
}

/// Composition root: the only place that knows concrete implementations.
/// Features receive use cases built on Domain protocols, never DataAccess types.
@MainActor
final class AppContainer {
    let market: MarketConfiguration

    private let animalRepository: any AnimalRepository
    private let matchRepository: any MatchRepository
    private let profileRepository: any AdopterProfileRepository

    init(environment: AppEnvironment) {
        // Temporary: the market should come from the adopter's address once accounts exist,
        // not from device settings (language ≠ country of residence).
        market = MarketConfiguration.resolve(regionCode: Locale.current.region?.identifier)

        switch environment {
        case .demo:
            animalRepository = InMemoryAnimalRepository(animals: SampleData.animals)
        case let .remote(baseURL):
            animalRepository = RemoteAnimalRepository(client: APIClient(baseURL: baseURL))
        }
        // No backend yet for these two: in-memory in every environment for now.
        matchRepository = InMemoryMatchRepository()
        profileRepository = InMemoryAdopterProfileRepository(profile: SampleData.profile)
    }

    func makeDiscoverViewModel() -> DiscoverViewModel {
        DiscoverViewModel(
            fetchFeed: FetchDiscoveryFeedUseCase(
                animals: animalRepository,
                matches: matchRepository,
                profiles: profileRepository
            ),
            recordSwipe: RecordSwipeUseCase(matches: matchRepository),
            market: market
        )
    }

    func makeMatchesViewModel() -> MatchesViewModel {
        MatchesViewModel(fetchMatches: FetchMatchesUseCase(matches: matchRepository))
    }
}
