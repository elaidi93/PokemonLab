import Foundation

/// Composition root — wires concrete Data-layer types into the Domain protocols
/// that Presentation consumes. One instance lives for the app's lifetime.
struct AppDependencies {
    let fetchPokemonList: FetchPokemonListUseCase
    let fetchPokemonDetail: FetchPokemonDetailUseCase

    static func live() -> AppDependencies {
        let apiClient = URLSessionAPIClient()
        let repository = PokemonRepositoryImpl(apiClient: apiClient)
        return AppDependencies(
            fetchPokemonList: FetchPokemonListUseCase(repository: repository),
            fetchPokemonDetail: FetchPokemonDetailUseCase(repository: repository)
        )
    }
}
