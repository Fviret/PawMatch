/// Ports implemented by the DataAccess module (in-memory, REST, cache…).
/// Features depend on these protocols only, which keeps them testable with fakes.

public protocol AnimalRepository: Sendable {
    /// Candidates matching the profile's species and search radius.
    func discoveryFeed(for profile: AdopterProfile) async throws -> [Animal]
    func animal(withID id: Animal.ID) async throws -> Animal
}

public protocol MatchRepository: Sendable {
    /// Stores the decision; returns the created match when the decision is a like.
    func record(_ decision: SwipeDecision, for animal: Animal) async throws -> Match?
    func matches() async throws -> [Match]
    /// Animals already liked or passed, to avoid showing them twice.
    func decidedAnimalIDs() async throws -> Set<Animal.ID>
}

public protocol AdopterProfileRepository: Sendable {
    func currentProfile() async throws -> AdopterProfile
}
