import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class DiscoverViewModel {
    public enum State: Equatable {
        case idle, loading, loaded, failed
    }

    public private(set) var state: State = .idle
    public private(set) var deck: [ScoredAnimal] = []
    /// Set after a like; drives the confirmation sheet.
    public var lastMatch: Match?
    public let market: MarketConfiguration

    private let fetchFeed: FetchDiscoveryFeedUseCase
    private let recordSwipe: RecordSwipeUseCase

    public init(fetchFeed: FetchDiscoveryFeedUseCase, recordSwipe: RecordSwipeUseCase, market: MarketConfiguration) {
        self.fetchFeed = fetchFeed
        self.recordSwipe = recordSwipe
        self.market = market
    }

    public func load() async {
        state = .loading
        do {
            deck = try await fetchFeed()
            state = .loaded
        } catch {
            state = .failed
        }
    }

    /// Optimistic: the card leaves immediately and comes back if saving fails.
    public func decide(_ decision: SwipeDecision, on candidate: ScoredAnimal) async {
        guard let index = deck.firstIndex(where: { $0.id == candidate.id }) else { return }
        deck.remove(at: index)
        do {
            if let match = try await recordSwipe(decision, on: candidate.animal) {
                lastMatch = match
            }
        } catch {
            deck.insert(candidate, at: min(index, deck.count))
        }
    }
}
