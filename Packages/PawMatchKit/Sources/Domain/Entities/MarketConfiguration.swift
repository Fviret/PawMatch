/// Country-specific business and legal rules.
///
/// A *market* is where the adoption legally happens. It must never be derived
/// from the device language: a Spanish-speaking user living in France follows French law.
/// Today the definitions are static; the target is to serve them from the backend
/// (remote config) so opening a country doesn't require an App Store release.
public struct MarketConfiguration: Hashable, Sendable {
    /// ISO 3166-1 alpha-2.
    public let regionCode: String
    /// Mandatory minimum delay between the signed commitment and the adoption.
    public let coolingOffPeriodDays: Int
    /// Whether animals must be identified (microchip/tattoo) before leaving the shelter.
    public let requiresIdentification: Bool
    public let defaultSearchRadiusKilometers: Double

    public init(
        regionCode: String,
        coolingOffPeriodDays: Int,
        requiresIdentification: Bool,
        defaultSearchRadiusKilometers: Double
    ) {
        self.regionCode = regionCode
        self.coolingOffPeriodDays = coolingOffPeriodDays
        self.requiresIdentification = requiresIdentification
        self.defaultSearchRadiusKilometers = defaultSearchRadiusKilometers
    }
}

public extension MarketConfiguration {
    /// France: loi n° 2021-1539 du 30 novembre 2021 — "certificat d'engagement et de connaissance"
    /// signed at least 7 days before acquiring a dog or a cat. To be validated by a lawyer before launch.
    static let france = MarketConfiguration(
        regionCode: "FR",
        coolingOffPeriodDays: 7,
        requiresIdentification: true,
        defaultSearchRadiusKilometers: 50
    )

    /// Used for markets without a specific configuration yet: no legal assumption.
    static let generic = MarketConfiguration(
        regionCode: "ZZ",
        coolingOffPeriodDays: 0,
        requiresIdentification: false,
        defaultSearchRadiusKilometers: 50
    )

    static let all: [MarketConfiguration] = [.france]

    static func resolve(regionCode: String?) -> MarketConfiguration {
        guard let regionCode else { return .generic }
        return all.first { $0.regionCode.caseInsensitiveCompare(regionCode) == .orderedSame } ?? .generic
    }
}
