#if DEBUG
import Foundation

/// Stubbed dependencies used only by SwiftUI previews. Kept behind `#if DEBUG`
/// so no preview-only code ships in Release builds.
enum PreviewFactory {
    nonisolated static let samplePokemon: [PokemonSummary] = [
        PokemonSummary(id: 1, name: "bulbasaur", spriteURL: spriteURL(1)),
        PokemonSummary(id: 4, name: "charmander", spriteURL: spriteURL(4)),
        PokemonSummary(id: 7, name: "squirtle", spriteURL: spriteURL(7)),
        PokemonSummary(id: 25, name: "pikachu", spriteURL: spriteURL(25)),
        PokemonSummary(id: 150, name: "mewtwo", spriteURL: spriteURL(150)),
    ]

    nonisolated static let pikachuDetail = PokemonDetail(
        id: 25,
        name: "pikachu",
        heightDecimetres: 4,
        weightHectograms: 60,
        types: ["electric"],
        stats: [
            .init(name: "hp", baseValue: 35),
            .init(name: "attack", baseValue: 55),
            .init(name: "defense", baseValue: 40),
            .init(name: "speed", baseValue: 90),
        ],
        spriteURL: spriteURL(25)
    )

    static func listViewModel(state: LoadableState<[PokemonSummary]>) -> PokemonListViewModel {
        PokemonListViewModel(
            initialState: state,
            fetchList: FetchPokemonListUseCase(repository: PreviewRepository()),
            coordinator: AppCoordinator()
        )
    }

    static func detailViewModel(state: LoadableState<PokemonDetail>) -> PokemonDetailViewModel {
        PokemonDetailViewModel(
            initialState: state,
            pokemonID: 25,
            fallbackName: "pikachu",
            fetchDetail: FetchPokemonDetailUseCase(repository: PreviewRepository())
        )
    }

    /// Compile-time-known URL. A failure here is a developer error caught during preview,
    /// never a runtime concern — hence the trap with a descriptive message rather than
    /// a force-unwrap or a swallowed optional.
    nonisolated private static func spriteURL(_ id: Int) -> URL {
        let raw = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
        guard let url = URL(string: raw) else {
            preconditionFailure("Invalid static sprite URL: \(raw)")
        }
        return url
    }

    private struct PreviewRepository: PokemonRepository {
        func fetchList(limit: Int) async throws -> [PokemonSummary] { samplePokemon }
        func fetchDetail(id: Int) async throws -> PokemonDetail { pikachuDetail }
    }
}
#endif
