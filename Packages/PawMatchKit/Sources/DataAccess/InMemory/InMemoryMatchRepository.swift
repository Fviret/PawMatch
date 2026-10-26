import Foundation
import Domain

public actor InMemoryMatchRepository: MatchRepository {
    private var decisions: [Animal.ID: SwipeDecision] = [:]
    private var storedMatches: [Match] = []
    private let now: @Sendable () -> Date

    public init(now: @escaping @Sendable () -> Date = { .now }) {
        self.now = now
    }

    public func record(_ decision: SwipeDecision, for animal: Animal) async throws -> Match? {
        decisions[animal.id] = decision
        guard decision == .like else { return nil }

        let match = Match(id: Match.ID(UUID().uuidString), animal: animal, createdAt: now(), status: .pending)
        storedMatches.append(match)
        return match
    }

    public func matches() async throws -> [Match] {
        storedMatches
    }

    public func decidedAnimalIDs() async throws -> Set<Animal.ID> {
        Set(decisions.keys)
    }
}

public actor InMemoryAdopterProfileRepository: AdopterProfileRepository {
    private var profile: AdopterProfile

    public init(profile: AdopterProfile) {
        self.profile = profile
    }

    public func currentProfile() async throws -> AdopterProfile {
        profile
    }

    public func update(_ profile: AdopterProfile) {
        self.profile = profile
    }
}
