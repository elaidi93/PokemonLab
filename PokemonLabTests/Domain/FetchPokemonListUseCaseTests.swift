import Foundation
import Testing
@testable import PokemonLab

@Suite("FetchPokemonListUseCase")
struct FetchPokemonListUseCaseTests {
    @Test("Returns repository results on success")
    func happyPath() async throws {
        let sample = [
            PokemonSummary(id: 1, name: "bulbasaur", spriteURL: try #require(URL(string: "https://x/1.png"))),
            PokemonSummary(id: 25, name: "pikachu", spriteURL: try #require(URL(string: "https://x/25.png"))),
        ]
        let repo = StubPokemonRepository()
        repo.listResult = .success(sample)
        let useCase = FetchPokemonListUseCase(repository: repo, defaultLimit: 151)

        let result = try await useCase()

        #expect(result == sample)
        #expect(repo.listCalls == 1)
    }

    @Test("Propagates repository error")
    func propagatesFailure() async {
        struct Boom: Error {}
        let repo = StubPokemonRepository()
        repo.listResult = .failure(Boom())
        let useCase = FetchPokemonListUseCase(repository: repo)

        await #expect(throws: Boom.self) {
            _ = try await useCase()
        }
    }
}
