/// What the future owner told us about their life; input of the matching algorithm.
public struct AdopterProfile: Hashable, Sendable {
    public var housing: HousingType
    public var hasChildren: Bool
    public var otherPets: Set<Species>
    public var activityLevel: EnergyLevel
    public var isFirstPet: Bool
    /// Empty means "any species".
    public var preferredSpecies: Set<Species>
    public var location: GeoCoordinate?
    public var searchRadiusKilometers: Double

    public init(
        housing: HousingType,
        hasChildren: Bool,
        otherPets: Set<Species>,
        activityLevel: EnergyLevel,
        isFirstPet: Bool,
        preferredSpecies: Set<Species>,
        location: GeoCoordinate?,
        searchRadiusKilometers: Double
    ) {
        self.housing = housing
        self.hasChildren = hasChildren
        self.otherPets = otherPets
        self.activityLevel = activityLevel
        self.isFirstPet = isFirstPet
        self.preferredSpecies = preferredSpecies
        self.location = location
        self.searchRadiusKilometers = searchRadiusKilometers
    }
}

public enum HousingType: String, Hashable, Sendable, CaseIterable, Codable {
    case apartment, houseWithGarden, houseWithoutGarden
}
