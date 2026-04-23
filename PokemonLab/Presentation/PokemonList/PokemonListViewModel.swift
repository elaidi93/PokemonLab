import Foundation

@Observable
final class PokemonListViewModel {
    private(set) var state: LoadableState<[PokemonSummary]> = .idle
    private(set) var reloadToken = UUID()
    var searchQuery: String = ""

    private let fetchList: FetchPokemonListUseCase
    private let coordinator: AppCoordinator

    init(fetchList: FetchPokemonListUseCase, coordinator: AppCoordinator) {
        self.fetchList = fetchList
        self.coordinator = coordinator
    }

    convenience init(
        initialState: LoadableState<[PokemonSummary]>,
        fetchList: FetchPokemonListUseCase,
        coordinator: AppCoordinator
    ) {
        self.init(fetchList: fetchList, coordinator: coordinator)
        self.state = initialState
    }

    var visiblePokemon: [PokemonSummary] {
        guard let all = state.value else { return [] }
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return all }
        let needle = trimmed.localizedLowercase
        return all.filter { $0.name.localizedLowercase.contains(needle) }
    }

    func loadIfNeeded() async {
        if case .loaded = state { return }
        await load()
    }

    func load() async {
        state = .loading
        await performFetch()
    }

    /// Pull-to-refresh entry point. Keeps the currently loaded list on screen
    /// while the request is in flight, and only switches away on failure.
    func refresh() async {
        await performFetch()
    }

    private func performFetch() async {
        do {
            let list = try await fetchList()
            state = .loaded(list)
            reloadToken = UUID()
        } catch {
            state = .failed(String(localized: "Impossible de charger le Pokédex. Vérifie ta connexion et réessaie."))
        }
    }

    func didSelect(_ pokemon: PokemonSummary) {
        coordinator.show(.detail(pokemonID: pokemon.id, name: pokemon.name))
    }
}
