import Domain

/// Fictional demo data used by the "demo" environment and SwiftUI previews.
/// Stories are in French on purpose: they are shelter content, which the backend
/// localizes — not app UI, which lives in the String Catalogs.
public enum SampleData {
    public static let shelters: [Shelter] = [
        .fixture(id: "shelter-paris", name: "Refuge des Quatre Pattes", city: "Paris", coordinate: .paris),
        .fixture(id: "shelter-annecy", name: "Refuge du Lac", city: "Annecy", coordinate: .annecy),
        .fixture(id: "shelter-marseille", name: "Refuge de la Côte", city: "Marseille", coordinate: .marseille),
        .fixture(id: "shelter-liege", name: "Refuge des Ardennes", city: "Liège", regionCode: "BE", coordinate: .liege),
    ]

    public static let profile = AdopterProfile.fixture(
        housing: .apartment,
        hasChildren: true,
        otherPets: [.cat],
        activityLevel: .moderate,
        isFirstPet: true,
        location: .paris,
        searchRadiusKilometers: 800
    )

    public static let animals: [Animal] = [
        .fixture(
            id: "rocky", name: "Rocky", species: .dog, breedName: "Berger australien", sex: .male,
            ageInMonths: 36, size: .large, weightKilograms: 28, energyLevel: .high,
            compatibility: Compatibility(children: .yes, dogs: .yes, cats: .no),
            needs: Needs(garden: true, experiencedOwner: true),
            story: "Rocky déborde d'énergie et adore les longues balades. Il cherche une famille sportive avec un jardin.",
            shelter: shelters[0]
        ),
        .fixture(
            id: "mia", name: "Mia", species: .cat, breedName: "Européen", sex: .female,
            ageInMonths: 24, size: .small, weightKilograms: 4, energyLevel: .low,
            compatibility: Compatibility(children: .yes, dogs: .unknown, cats: .yes),
            story: "Mia est une chatte douce et câline qui aime les siestes au soleil.",
            shelter: shelters[0]
        ),
        .fixture(
            id: "biscotte", name: "Biscotte", species: .rabbit, sex: .female,
            ageInMonths: 12, size: .small, weightKilograms: 2, energyLevel: .moderate,
            compatibility: Compatibility(children: .yes, dogs: .unknown, cats: .unknown),
            story: "Biscotte est curieuse et sociable. Elle a besoin d'espace pour gambader chaque jour.",
            shelter: shelters[1]
        ),
        .fixture(
            id: "oscar", name: "Oscar", species: .dog, sex: .male,
            ageInMonths: 96, size: .medium, weightKilograms: 14, energyLevel: .low,
            compatibility: Compatibility(children: .yes, dogs: .yes, cats: .yes),
            story: "Oscar est un senior paisible qui s'entend avec tout le monde. Parfait pour une vie en appartement.",
            shelter: shelters[2]
        ),
        .fixture(
            id: "nala", name: "Nala", species: .dog, breedName: "Labrador", sex: .female,
            ageInMonths: 6, size: .medium, weightKilograms: 9, energyLevel: .high,
            compatibility: Compatibility(children: .yes, dogs: .yes, cats: .unknown),
            story: "Nala est une jeune chienne pleine de vie, à éduquer avec patience et bienveillance.",
            shelter: shelters[1]
        ),
        .fixture(
            id: "pistache", name: "Pistache", species: .cat, sex: .male,
            ageInMonths: 132, size: .medium, weightKilograms: 5.5, energyLevel: .low,
            compatibility: Compatibility(children: .no, dogs: .no, cats: .no),
            story: "Pistache est un papy chat qui aspire au calme. Il sera heureux comme animal unique.",
            shelter: shelters[2]
        ),
        .fixture(
            id: "luna", name: "Luna", species: .dog, breedName: "Malinois", sex: .female,
            ageInMonths: 48, size: .large, weightKilograms: 27, energyLevel: .moderate,
            compatibility: Compatibility(children: .yes, dogs: .yes, cats: .yes),
            story: "Luna est équilibrée et très attachée à l'humain. Elle connaît les ordres de base.",
            shelter: shelters[3]
        ),
        .fixture(
            id: "filou", name: "Filou", species: .cat, sex: .male,
            ageInMonths: 36, size: .medium, weightKilograms: 4.8, energyLevel: .moderate,
            compatibility: Compatibility(children: .yes, dogs: .yes, cats: .yes),
            story: "Filou est joueur et sociable, il s'adapte à toutes les familles.",
            shelter: shelters[0]
        ),
    ]
}
