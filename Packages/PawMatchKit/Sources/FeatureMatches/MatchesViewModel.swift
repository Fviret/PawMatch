import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class MatchesViewModel {
    public enum State: Equatable {
        case idle, loading, loaded, failed
    }

    public private(set) var state: State = .idle
    public private(set) var matches: [Match] = []

    private let fetchMatches: FetchMatchesUseCase

    public init(fetchMatches: FetchMatchesUseCase) {
        self.fetchMatches = fetchMatches
    }

    public func load() async {
        if matches.isEmpty { state = .loading }
        do {
            matches = try await fetchMatches()
            state = .loaded
        } catch {
            state = .failed
        }
    }
}
