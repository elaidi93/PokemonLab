import Foundation

struct PokemonRepositoryImpl: PokemonRepository {
    private let apiClient: any APIClient
    private let baseURL: URL

    init(
        apiClient: any APIClient,
        baseURL: URL = URL(string: "https://pokeapi.co/api/v2")!
    ) {
        self.apiClient = apiClient
        self.baseURL = baseURL
    }

    func fetchList(limit: Int) async throws -> [PokemonSummary] {
        let url = baseURL
            .appending(path: "pokemon")
            .appending(queryItems: [URLQueryItem(name: "limit", value: String(limit))])
        let dto = try await apiClient.get(url, as: PokemonListDTO.self)
        return dto.results.compactMap { $0.toDomain() }
    }

    func fetchDetail(id: Int) async throws -> PokemonDetail {
        let url = baseURL.appending(path: "pokemon/\(id)")
        let dto = try await apiClient.get(url, as: PokemonDetailDTO.self)
        return dto.toDomain()
    }
}
