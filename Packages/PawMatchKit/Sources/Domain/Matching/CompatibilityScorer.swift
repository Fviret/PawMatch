/// Semantic reasons explaining a score. The UI maps them to localized text,
/// so the algorithm never produces display strings.
public enum CompatibilityReason: String, Hashable, Sendable, CaseIterable {
    case goodWithChildren
    case notRecommendedWithChildren
    case getsAlongWithPets
    case notRecommendedWithPets
    case energyMatch
    case energyMismatch
    case needsGarden
    case suitedForFirstTimeOwner
    case needsExperiencedOwner
}

public struct CompatibilityScore: Hashable, Sendable {
    /// 0...100
    public let value: Int
    public let highlights: [CompatibilityReason]
    public let warnings: [CompatibilityReason]

    public init(value: Int, highlights: [CompatibilityReason], warnings: [CompatibilityReason]) {
        self.value = value
        self.highlights = highlights
        self.warnings = warnings
    }
}

/// Rule-based, explainable scoring. Kept pure and deterministic so it can be unit-tested
/// and later moved server-side (or replaced) without touching the UI.
public struct CompatibilityScorer: Sendable {
    private static let baseline = 60

    public init() {}

    public func score(_ animal: Animal, for profile: AdopterProfile) -> CompatibilityScore {
        var points = Self.baseline
        var highlights: [CompatibilityReason] = []
        var warnings: [CompatibilityReason] = []

        if profile.hasChildren {
            switch animal.compatibility.children {
            case .yes:
                points += 15
                highlights.append(.goodWithChildren)
            case .no:
                points -= 40
                warnings.append(.notRecommendedWithChildren)
            case .unknown:
                break
            }
        }

        let petAnswers = profile.otherPets.map { animal.compatibility.answer(with: $0) }
        if petAnswers.contains(.no) {
            points -= 30
            warnings.append(.notRecommendedWithPets)
        } else if !petAnswers.isEmpty, petAnswers.allSatisfy({ $0 == .yes }) {
            points += 10
            highlights.append(.getsAlongWithPets)
        }

        switch abs(animal.energyLevel.rawValue - profile.activityLevel.rawValue) {
        case 0:
            points += 15
            highlights.append(.energyMatch)
        case 1:
            break
        default:
            points -= 15
            warnings.append(.energyMismatch)
        }

        if animal.needs.garden, profile.housing != .houseWithGarden {
            points -= 20
            warnings.append(.needsGarden)
        }

        if profile.isFirstPet {
            if animal.needs.experiencedOwner {
                points -= 15
                warnings.append(.needsExperiencedOwner)
            } else {
                points += 5
                highlights.append(.suitedForFirstTimeOwner)
            }
        }

        return CompatibilityScore(value: min(max(points, 0), 100), highlights: highlights, warnings: warnings)
    }
}
