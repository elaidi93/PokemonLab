import Foundation
import Testing
@testable import PokemonLab

@Suite("PokemonRepositoryImpl")
struct PokemonRepositoryImplTests {
    let baseURL = URL(string: "https://test.local/api")!

    @Test("fetchList hits /pokemon with limit and maps DTOs")
    func fetchListSuccess() async throws {
        let client = MockAPIClient()
        client.stub(prefix: "https://test.local/api/pokemon", with: .data(try FixtureLoader.data("pokemon_list")))
        let repo = PokemonRepositoryImpl(apiClient: client, baseURL: baseURL)

        let result = try await repo.fetchList(limit: 3)

        #expect(result.count == 3)
        #expect(result.map(\.name) == ["bulbasaur", "ivysaur", "venusaur"])
        #expect(result.map(\.id) == [1, 2, 3])
        let requested = try #require(client.requestedURLs.first)
        #expect(requested.absoluteString.contains("limit=3"))
    }

    @Test("fetchDetail hits /pokemon/{id} and maps DTO")
    func fetchDetailSuccess() async throws {
        let client = MockAPIClient()
        client.stub(prefix: "https://test.local/api/pokemon/25", with: .data(try FixtureLoader.data("pokemon_25")))
        let repo = PokemonRepositoryImpl(apiClient: client, baseURL: baseURL)

        let detail = try await repo.fetchDetail(id: 25)

        #expect(detail.id == 25)
        #expect(detail.name == "pikachu")
        #expect(detail.types == ["electric"])
    }

    @Test("Repository surfaces transport errors from the client")
    func fetchListPropagatesError() async {
        let client = MockAPIClient()
        client.stub(prefix: "https://test.local/api/pokemon", with: .error(APIError.transport))
        let repo = PokemonRepositoryImpl(apiClient: client, baseURL: baseURL)

        await #expect(throws: APIError.transport) {
            _ = try await repo.fetchList(limit: 10)
        }
    }
}
