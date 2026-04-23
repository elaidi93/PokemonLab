import Foundation

nonisolated struct FetchPokemonListUseCase: Sendable {
    private let repository: any PokemonRepository
    private let defaultLimit: Int

    init(repository: any PokemonRepository, defaultLimit: Int = 151) {
        self.repository = repository
        self.defaultLimit = defaultLimit
    }

    func callAsFunction() async throws -> [PokemonSummary] {
        try await repository.fetchList(limit: defaultLimit)
    }
}
