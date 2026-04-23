import Foundation
import Testing
@testable import PokemonLab

@MainActor
@Suite("AppCoordinator")
struct AppCoordinatorTests {
    @Test("show appends a route to the path")
    func showAppendsRoute() {
        // Given
        let coordinator = AppCoordinator()

        // When
        coordinator.show(.detail(pokemonID: 25, name: "pikachu"))

        // Then
        #expect(coordinator.path == [.detail(pokemonID: 25, name: "pikachu")])
    }

    @Test("show preserves previously pushed routes")
    func showStacksRoutes() {
        // Given
        let coordinator = AppCoordinator()
        coordinator.show(.detail(pokemonID: 1, name: "bulbasaur"))

        // When
        coordinator.show(.detail(pokemonID: 25, name: "pikachu"))

        // Then
        #expect(coordinator.path == [
            .detail(pokemonID: 1, name: "bulbasaur"),
            .detail(pokemonID: 25, name: "pikachu"),
        ])
    }

    @Test("popToRoot clears the entire navigation stack")
    func popToRootClearsPath() {
        // Given
        let coordinator = AppCoordinator()
        coordinator.show(.detail(pokemonID: 1, name: "bulbasaur"))
        coordinator.show(.detail(pokemonID: 25, name: "pikachu"))

        // When
        coordinator.popToRoot()

        // Then
        #expect(coordinator.path.isEmpty)
    }
}
