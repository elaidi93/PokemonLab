import SwiftUI

@Observable
final class AppCoordinator {
    var path: [Route] = []

    func show(_ route: Route) {
        path.append(route)
    }

    func popToRoot() {
        path.removeAll()
    }
}

struct RootView: View {
    @Bindable var coordinator: AppCoordinator
    let dependencies: AppDependencies

    @State private var listViewModel: PokemonListViewModel

    init(coordinator: AppCoordinator, dependencies: AppDependencies) {
        self.coordinator = coordinator
        self.dependencies = dependencies
        self._listViewModel = State(
            wrappedValue: PokemonListViewModel(
                fetchList: dependencies.fetchPokemonList,
                coordinator: coordinator
            )
        )
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            PokemonListView(viewModel: listViewModel)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .detail(let id, let name):
                        PokemonDetailView(
                            viewModel: PokemonDetailViewModel(
                                pokemonID: id,
                                fallbackName: name,
                                fetchDetail: dependencies.fetchPokemonDetail
                            )
                        )
                    }
                }
        }
    }
}
