import Foundation
import Testing
@testable import PokemonLab

@MainActor
@Suite("PokemonListViewModel")
struct PokemonListViewModelTests {
    private func makeSUT(
        list: Result<[PokemonSummary], Error> = .success([])
    ) -> (PokemonListViewModel, StubPokemonRepository, AppCoordinator) {
        let repo = StubPokemonRepository()
        repo.listResult = list
        let coordinator = AppCoordinator()
        let vm = PokemonListViewModel(
            fetchList: FetchPokemonListUseCase(repository: repo),
            coordinator: coordinator
        )
        return (vm, repo, coordinator)
    }

    private func samplePokemon() throws -> [PokemonSummary] {
        [
            PokemonSummary(id: 1, name: "bulbasaur", spriteURL: try #require(URL(string: "https://x/1.png"))),
            PokemonSummary(id: 4, name: "charmander", spriteURL: try #require(URL(string: "https://x/4.png"))),
            PokemonSummary(id: 25, name: "pikachu", spriteURL: try #require(URL(string: "https://x/25.png"))),
        ]
    }

    @Test("load transitions idle → loaded on success")
    func loadSuccess() async throws {
        let (sut, _, _) = makeSUT(list: .success(try samplePokemon()))

        await sut.load()

        let loaded = try #require(sut.state.value)
        #expect(loaded.map(\.name) == ["bulbasaur", "charmander", "pikachu"])
    }

    @Test("load transitions to failed on error")
    func loadFailure() async {
        struct Boom: Error {}
        let (sut, _, _) = makeSUT(list: .failure(Boom()))

        await sut.load()

        if case .failed = sut.state {
            #expect(Bool(true))
        } else {
            Issue.record("Expected failed state, got \(sut.state)")
        }
    }

    @Test("loadIfNeeded is a no-op when already loaded")
    func loadIfNeededIdempotent() async throws {
        let (sut, repo, _) = makeSUT(list: .success(try samplePokemon()))
        await sut.loadIfNeeded()
        #expect(repo.listCalls == 1)

        await sut.loadIfNeeded()
        #expect(repo.listCalls == 1, "Second call should not refetch")
    }

    @Test("Search filters the loaded list case-insensitively")
    func searchFilters() async throws {
        let (sut, _, _) = makeSUT(list: .success(try samplePokemon()))
        await sut.load()

        sut.searchQuery = "PiKa"
        #expect(sut.visiblePokemon.map(\.name) == ["pikachu"])

        sut.searchQuery = ""
        #expect(sut.visiblePokemon.count == 3)
    }

    @Test("Search returns empty list when nothing matches")
    func searchNoMatch() async throws {
        let (sut, _, _) = makeSUT(list: .success(try samplePokemon()))
        await sut.load()

        sut.searchQuery = "zzz"
        #expect(sut.visiblePokemon.isEmpty)
    }

    @Test("didSelect pushes a detail route onto the coordinator")
    func didSelectNavigates() async throws {
        let sample = try samplePokemon()
        let (sut, _, coordinator) = makeSUT(list: .success(sample))
        await sut.load()

        sut.didSelect(sample[2])

        #expect(coordinator.path == [.detail(pokemonID: 25, name: "pikachu")])
    }
}
