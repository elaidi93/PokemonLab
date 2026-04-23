import Foundation

nonisolated struct PokemonRepositoryImpl: PokemonRepository {
    private let apiClient: any APIClient
    private let baseURL: String

    init(
        apiClient: any APIClient,
        baseURL: String = "https://pokeapi.co/api/v2"
    ) {
        self.apiClient = apiClient
        self.baseURL = baseURL
    }

    func fetchList(limit: Int) async throws -> [PokemonSummary] {
        let url = try makeURL(
            path: "pokemon",
            queryItems: [URLQueryItem(name: "limit", value: String(limit))]
        )
        let dto = try await apiClient.get(url, as: PokemonListDTO.self)
        return dto.results.compactMap { $0.toDomain() }
    }

    func fetchDetail(id: Int) async throws -> PokemonDetail {
        let url = try makeURL(path: "pokemon/\(id)")
        let dto = try await apiClient.get(url, as: PokemonDetailDTO.self)
        return dto.toDomain()
    }

    private func makeURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(string: baseURL) else {
            throw APIError.invalidRequest
        }
        components.path += "/\(path)"
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidRequest
        }
        return url
    }
}
