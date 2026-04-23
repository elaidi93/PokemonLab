import SwiftUI

@main
struct PokemonLabApp: App {
    @State private var dependencies = AppDependencies.live()
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            RootView(coordinator: coordinator, dependencies: dependencies)
        }
    }
}
