import Testing
import Domain
import Fixtures

struct CompatibilityScorerTests {
    private let scorer = CompatibilityScorer()

    @Test func idealCandidateScoresHighWithHighlights() {
        let family = AdopterProfile.fixture(hasChildren: true, otherPets: [.cat], activityLevel: .moderate, isFirstPet: true)
        let animal = Animal.fixture(
            energyLevel: .moderate,
            compatibility: Compatibility(children: .yes, dogs: .unknown, cats: .yes)
        )

        let score = scorer.score(animal, for: family)

        #expect(score.value == 100)
        #expect(score.highlights == [.goodWithChildren, .getsAlongWithPets, .energyMatch, .suitedForFirstTimeOwner])
        #expect(score.warnings.isEmpty)
    }

    @Test func animalNotSuitedForChildrenIsPenalizedForFamilies() {
        let family = AdopterProfile.fixture(hasChildren: true)
        let friendly = Animal.fixture(compatibility: Compatibility(children: .yes, dogs: .unknown, cats: .unknown))
        let notForKids = Animal.fixture(compatibility: Compatibility(children: .no, dogs: .unknown, cats: .unknown))

        let notForKidsScore = scorer.score(notForKids, for: family)

        #expect(notForKidsScore.warnings.contains(.notRecommendedWithChildren))
        #expect(notForKidsScore.value < scorer.score(friendly, for: family).value)
    }

    @Test func childCompatibilityIsIgnoredWithoutChildren() {
        let single = AdopterProfile.fixture(hasChildren: false)
        let notForKids = Animal.fixture(compatibility: Compatibility(children: .no, dogs: .unknown, cats: .unknown))

        #expect(!scorer.score(notForKids, for: single).warnings.contains(.notRecommendedWithChildren))
    }

    @Test(arguments: [HousingType.apartment, .houseWithoutGarden])
    func gardenNeedIsAWarningWithoutGarden(housing: HousingType) {
        let animal = Animal.fixture(needs: Needs(garden: true, experiencedOwner: false))

        #expect(scorer.score(animal, for: .fixture(housing: housing)).warnings.contains(.needsGarden))
        #expect(!scorer.score(animal, for: .fixture(housing: .houseWithGarden)).warnings.contains(.needsGarden))
    }

    @Test func scoreIsClampedToZero() {
        let worstProfile = AdopterProfile.fixture(
            housing: .apartment, hasChildren: true, otherPets: [.dog], activityLevel: .low, isFirstPet: true
        )
        let worstAnimal = Animal.fixture(
            energyLevel: .high,
            compatibility: Compatibility(children: .no, dogs: .no, cats: .no),
            needs: Needs(garden: true, experiencedOwner: true)
        )

        #expect(scorer.score(worstAnimal, for: worstProfile).value == 0)
    }
}
