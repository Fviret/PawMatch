import Foundation
import Domain

/// REST implementation, ready for when the backend exists. Endpoints are a proposal.
public struct RemoteAnimalRepository: AnimalRepository {
    private let client: APIClient

    public init(client: APIClient) {
        self.client = client
    }

    public func discoveryFeed(for profile: AdopterProfile) async throws -> [Animal] {
        var query = [URLQueryItem(name: "radius_km", value: String(Int(profile.searchRadiusKilometers)))]
        if let location = profile.location {
            query.append(URLQueryItem(name: "lat", value: String(location.latitude)))
            query.append(URLQueryItem(name: "lon", value: String(location.longitude)))
        }
        if !profile.preferredSpecies.isEmpty {
            let species = profile.preferredSpecies.map(\.rawValue).sorted().joined(separator: ",")
            query.append(URLQueryItem(name: "species", value: species))
        }
        let dtos: [AnimalDTO] = try await client.get("v1/animals/feed", query: query)
        return dtos.map { $0.toDomain() }
    }

    public func animal(withID id: Animal.ID) async throws -> Animal {
        let dto: AnimalDTO = try await client.get("v1/animals/\(id.rawValue)")
        return dto.toDomain()
    }
}
