import Foundation
import Testing
@testable import PokemonLab

@Suite("FetchPokemonListUseCase")
struct FetchPokemonListUseCaseTests {
    @Test("Returns repository results on success")
    func happyPath() async throws {
        // Given
        let sample = [
            PokemonSummary(id: 1, name: "bulbasaur", spriteURL: try #require(URL(string: "https://x/1.png"))),
            PokemonSummary(id: 25, name: "pikachu", spriteURL: try #require(URL(string: "https://x/25.png"))),
        ]
        let repo = StubPokemonRepository()
        repo.listResult = .success(sample)
        let useCase = FetchPokemonListUseCase(repository: repo, defaultLimit: 151)

        // When
        let result = try await useCase()

        // Then
        #expect(result == sample)
        #expect(repo.listCallCount == 1)
    }

    @Test("Forwards the default limit to the repository")
    func forwardsDefaultLimit() async throws {
        // Given
        let repo = StubPokemonRepository()
        repo.listResult = .success([])
        let useCase = FetchPokemonListUseCase(repository: repo, defaultLimit: 151)

        // When
        _ = try await useCase()

        // Then
        #expect(repo.listCalls == [151])
    }

    @Test("Propagates repository error")
    func propagatesFailure() async {
        // Given
        struct Boom: Error {}
        let repo = StubPokemonRepository()
        repo.listResult = .failure(Boom())
        let useCase = FetchPokemonListUseCase(repository: repo)

        // When / Then
        await #expect(throws: Boom.self) {
            _ = try await useCase()
        }
    }
}
