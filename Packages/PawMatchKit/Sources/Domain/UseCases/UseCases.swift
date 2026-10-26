import Foundation

/// A candidate enriched with everything the discovery screen needs.
public struct ScoredAnimal: Identifiable, Hashable, Sendable {
    public let animal: Animal
    public let score: CompatibilityScore
    /// `nil` when the adopter's location is unknown.
    public let distanceMeters: Double?

    public var id: Animal.ID { animal.id }

    public init(animal: Animal, score: CompatibilityScore, distanceMeters: Double?) {
        self.animal = animal
        self.score = score
        self.distanceMeters = distanceMeters
    }
}

public struct FetchDiscoveryFeedUseCase: Sendable {
    private let animals: any AnimalRepository
    private let matches: any MatchRepository
    private let profiles: any AdopterProfileRepository
    private let scorer: CompatibilityScorer

    public init(
        animals: any AnimalRepository,
        matches: any MatchRepository,
        profiles: any AdopterProfileRepository,
        scorer: CompatibilityScorer = CompatibilityScorer()
    ) {
        self.animals = animals
        self.matches = matches
        self.profiles = profiles
        self.scorer = scorer
    }

    /// Unseen candidates, best compatibility first (newest first on ties).
    public func callAsFunction() async throws -> [ScoredAnimal] {
        let profile = try await profiles.currentProfile()
        async let candidates = animals.discoveryFeed(for: profile)
        async let alreadyDecided = matches.decidedAnimalIDs()
        let excluded = try await alreadyDecided

        return try await candidates
            .filter { !excluded.contains($0.id) }
            .map { animal in
                ScoredAnimal(
                    animal: animal,
                    score: scorer.score(animal, for: profile),
                    distanceMeters: profile.location.map { $0.distance(to: animal.shelter.coordinate) }
                )
            }
            .sorted {
                if $0.score.value != $1.score.value { return $0.score.value > $1.score.value }
                return $0.animal.publishedAt > $1.animal.publishedAt
            }
    }
}

public struct RecordSwipeUseCase: Sendable {
    private let matches: any MatchRepository

    public init(matches: any MatchRepository) {
        self.matches = matches
    }

    public func callAsFunction(_ decision: SwipeDecision, on animal: Animal) async throws -> Match? {
        try await matches.record(decision, for: animal)
    }
}

public struct FetchMatchesUseCase: Sendable {
    private let matches: any MatchRepository

    public init(matches: any MatchRepository) {
        self.matches = matches
    }

    /// Most recent first.
    public func callAsFunction() async throws -> [Match] {
        try await matches.matches().sorted { $0.createdAt > $1.createdAt }
    }
}
