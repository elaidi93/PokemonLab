import Foundation
import Testing
@testable import PokemonLab

@Suite("FetchPokemonDetailUseCase")
struct FetchPokemonDetailUseCaseTests {
    @Test("Forwards id to repository and returns detail")
    func happyPath() async throws {
        // Given
        let detail = PokemonDetail(
            id: 25,
            name: "pikachu",
            heightDecimetres: 4,
            weightHectograms: 60,
            types: ["electric"],
            stats: [.init(name: "hp", baseValue: 35)],
            spriteURL: nil
        )
        let repo = StubPokemonRepository()
        repo.detailResult = .success(detail)
        let useCase = FetchPokemonDetailUseCase(repository: repo)

        // When
        let result = try await useCase(id: 25)

        // Then
        #expect(result == detail)
        #expect(repo.detailCalls == [25])
    }

    @Test("Propagates repository error")
    func propagatesFailure() async {
        // Given
        struct Boom: Error {}
        let repo = StubPokemonRepository()
        repo.detailResult = .failure(Boom())
        let useCase = FetchPokemonDetailUseCase(repository: repo)

        // When / Then
        await #expect(throws: Boom.self) {
            _ = try await useCase(id: 1)
        }
    }
}
