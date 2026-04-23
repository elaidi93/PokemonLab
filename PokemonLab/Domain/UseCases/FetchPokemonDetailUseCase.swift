import Foundation

struct FetchPokemonDetailUseCase: Sendable {
    private let repository: any PokemonRepository

    init(repository: any PokemonRepository) {
        self.repository = repository
    }

    func callAsFunction(id: Int) async throws -> PokemonDetail {
        try await repository.fetchDetail(id: id)
    }
}
