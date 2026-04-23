import Foundation

@Observable
final class PokemonDetailViewModel {
    let pokemonID: Int
    let fallbackName: String
    private(set) var state: LoadableState<PokemonDetail> = .idle

    private let fetchDetail: FetchPokemonDetailUseCase

    init(
        pokemonID: Int,
        fallbackName: String,
        fetchDetail: FetchPokemonDetailUseCase
    ) {
        self.pokemonID = pokemonID
        self.fallbackName = fallbackName
        self.fetchDetail = fetchDetail
    }

    convenience init(
        initialState: LoadableState<PokemonDetail>,
        pokemonID: Int,
        fallbackName: String,
        fetchDetail: FetchPokemonDetailUseCase
    ) {
        self.init(pokemonID: pokemonID, fallbackName: fallbackName, fetchDetail: fetchDetail)
        self.state = initialState
    }

    var navigationTitle: String {
        state.value?.name.capitalized ?? fallbackName.capitalized
    }

    func loadIfNeeded() async {
        if case .loaded = state { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            let detail = try await fetchDetail(id: pokemonID)
            state = .loaded(detail)
        } catch {
            state = .failed(String(localized: "Impossible de charger les informations de ce Pokémon."))
        }
    }
}
