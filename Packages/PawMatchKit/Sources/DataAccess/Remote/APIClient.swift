import Foundation

public enum APIError: Error, Equatable {
    case invalidURL
    case unexpectedStatus(Int)
}

/// Minimal JSON client. Sends the user's languages so the backend can return
/// shelter content (stories, breed names) in the right language.
public struct APIClient: Sendable {
    public let baseURL: URL
    private let session: URLSession
    private let preferredLanguages: @Sendable () -> [String]

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        preferredLanguages: @escaping @Sendable () -> [String] = { Locale.preferredLanguages }
    ) {
        self.baseURL = baseURL
        self.session = session
        self.preferredLanguages = preferredLanguages
    }

    func get<Response: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> Response {
        guard var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !query.isEmpty {
            components.queryItems = query
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(Self.acceptLanguageHeader(for: preferredLanguages()), forHTTPHeaderField: "Accept-Language")

        let (body, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.unexpectedStatus(-1) }
        guard (200..<300).contains(http.statusCode) else { throw APIError.unexpectedStatus(http.statusCode) }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Response.self, from: body)
    }

    /// `["fr-FR", "en-US"]` → `"fr-FR, en-US;q=0.9"` (RFC 9110 quality values).
    static func acceptLanguageHeader(for languages: [String]) -> String {
        languages.prefix(5).enumerated().map { index, language in
            index == 0 ? language : "\(language);q=\(String(format: "%.1f", 1.0 - Double(index) * 0.1))"
        }
        .joined(separator: ", ")
    }
}
