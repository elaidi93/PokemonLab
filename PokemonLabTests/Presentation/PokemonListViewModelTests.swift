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
        // Given
        let (sut, _, _) = makeSUT(list: .success(try samplePokemon()))

        // When
        await sut.load()

        // Then
        let loaded = try #require(sut.state.value)
        #expect(loaded.map(\.name) == ["bulbasaur", "charmander", "pikachu"])
    }

    @Test("load transitions to failed on error")
    func loadFailure() async {
        // Given
        struct Boom: Error {}
        let (sut, _, _) = makeSUT(list: .failure(Boom()))

        // When
        await sut.load()

        // Then
        if case .failed = sut.state {
            #expect(Bool(true))
        } else {
            Issue.record("Expected failed state, got \(sut.state)")
        }
    }

    @Test("loadIfNeeded is a no-op when already loaded")
    func loadIfNeededIdempotent() async throws {
        // Given
        let (sut, repo, _) = makeSUT(list: .success(try samplePokemon()))
        await sut.loadIfNeeded()

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(repo.listCallCount == 1)
    }

    @Test("loadIfNeeded retries after a previous failure")
    func loadIfNeededRetriesAfterFailure() async throws {
        // Given
        struct Boom: Error {}
        let (sut, repo, _) = makeSUT(list: .failure(Boom()))
        await sut.loadIfNeeded()
        repo.listResult = .success(try samplePokemon())

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(repo.listCallCount == 2)
        #expect(sut.state.value?.count == 3)
    }

    @Test("Search filters the loaded list case-insensitively")
    func searchFilters() async throws {
        // Given
        let (sut, _, _) = makeSUT(list: .success(try samplePokemon()))
        await sut.load()

        // When
        sut.searchQuery = "PiKa"

        // Then
        #expect(sut.visiblePokemon.map(\.name) == ["pikachu"])
    }

    @Test("Search with a whitespace-only query shows the full list")
    func searchWhitespaceOnly() async throws {
        // Given
        let (sut, _, _) = makeSUT(list: .success(try samplePokemon()))
        await sut.load()

        // When
        sut.searchQuery = "   "

        // Then
        #expect(sut.visiblePokemon.count == 3)
    }

    @Test("Search returns empty list when nothing matches")
    func searchNoMatch() async throws {
        // Given
        let (sut, _, _) = makeSUT(list: .success(try samplePokemon()))
        await sut.load()

        // When
        sut.searchQuery = "zzz"

        // Then
        #expect(sut.visiblePokemon.isEmpty)
    }

    @Test("didSelect pushes a detail route onto the coordinator")
    func didSelectNavigates() async throws {
        // Given
        let sample = try samplePokemon()
        let (sut, _, coordinator) = makeSUT(list: .success(sample))
        await sut.load()

        // When
        sut.didSelect(sample[2])

        // Then
        #expect(coordinator.path == [.detail(pokemonID: 25, name: "pikachu")])
    }
}
