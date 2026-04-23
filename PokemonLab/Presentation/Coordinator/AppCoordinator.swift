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

/// Root container: owns the NavigationStack and resolves Routes to views,
/// keeping navigation logic out of ViewModels and Views.
struct RootView: View {
    @Bindable var coordinator: AppCoordinator
    let dependencies: AppDependencies

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            PokemonListView(
                viewModel: PokemonListViewModel(
                    fetchList: dependencies.fetchPokemonList,
                    coordinator: coordinator
                )
            )
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
