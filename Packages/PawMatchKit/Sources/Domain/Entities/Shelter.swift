import Foundation

/// An animal shelter. Deliberately generic (not "SPA"): the same model covers
/// any association in any country.
public struct Shelter: Identifiable, Hashable, Sendable {
    public typealias ID = Identifier<Shelter>

    public let id: ID
    public let name: String
    public let city: String
    /// ISO 3166-1 alpha-2 code ("FR", "BE"…). Display names come from `Locale`, never hard-coded.
    public let regionCode: String
    public let coordinate: GeoCoordinate

    public init(id: ID, name: String, city: String, regionCode: String, coordinate: GeoCoordinate) {
        self.id = id
        self.name = name
        self.city = city
        self.regionCode = regionCode
        self.coordinate = coordinate
    }
}

public struct GeoCoordinate: Hashable, Sendable, Codable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /// Great-circle distance in meters (haversine). Kept here so Domain doesn't depend on CoreLocation.
    public func distance(to other: GeoCoordinate) -> Double {
        let earthRadius = 6_371_000.0
        let lat1 = latitude * .pi / 180
        let lat2 = other.latitude * .pi / 180
        let deltaLat = (other.latitude - latitude) * .pi / 180
        let deltaLon = (other.longitude - longitude) * .pi / 180
        let a = sin(deltaLat / 2) * sin(deltaLat / 2)
            + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2)
        return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a))
    }
}
