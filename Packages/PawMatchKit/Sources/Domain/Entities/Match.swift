import Foundation

public enum SwipeDecision: String, Hashable, Sendable, Codable {
    case like, pass
}

/// A "like" turns into an adoption request that the shelter reviews.
/// Unlike a dating app, the match is not mutual at swipe time: the shelter decides.
public struct Match: Identifiable, Hashable, Sendable {
    public typealias ID = Identifier<Match>

    public let id: ID
    public let animal: Animal
    public let createdAt: Date
    public let status: MatchStatus

    public init(id: ID, animal: Animal, createdAt: Date, status: MatchStatus) {
        self.id = id
        self.animal = animal
        self.createdAt = createdAt
        self.status = status
    }
}

public enum MatchStatus: String, Hashable, Sendable, CaseIterable, Codable {
    case pending, accepted, declined, adopted
}
