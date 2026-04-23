import Foundation
import Testing
@testable import PokemonLab

@MainActor
@Suite("PokemonDetailViewModel")
struct PokemonDetailViewModelTests {
    private let pikachu = PokemonDetail(
        id: 25,
        name: "pikachu",
        heightDecimetres: 4,
        weightHectograms: 60,
        types: ["electric"],
        stats: [.init(name: "hp", baseValue: 35)],
        spriteURL: nil
    )

    @Test("Navigation title falls back to the passed name until detail loads")
    func navigationTitleFallback() {
        // Given
        let repo = StubPokemonRepository()
        let vm = PokemonDetailViewModel(
            pokemonID: 25,
            fallbackName: "pikachu",
            fetchDetail: FetchPokemonDetailUseCase(repository: repo)
        )

        // When / Then
        #expect(vm.navigationTitle == "Pikachu")
    }

    @Test("load transitions to loaded and navigation title uses the loaded name")
    func loadSuccess() async throws {
        // Given
        let repo = StubPokemonRepository()
        repo.detailResult = .success(pikachu)
        let vm = PokemonDetailViewModel(
            pokemonID: 25,
            fallbackName: "???",
            fetchDetail: FetchPokemonDetailUseCase(repository: repo)
        )

        // When
        await vm.load()

        // Then
        let loaded = try #require(vm.state.value)
        #expect(loaded == pikachu)
        #expect(vm.navigationTitle == "Pikachu")
    }

    @Test("load transitions to failed on error")
    func loadFailure() async {
        // Given
        struct Boom: Error {}
        let repo = StubPokemonRepository()
        repo.detailResult = .failure(Boom())
        let vm = PokemonDetailViewModel(
            pokemonID: 25,
            fallbackName: "pikachu",
            fetchDetail: FetchPokemonDetailUseCase(repository: repo)
        )

        // When
        await vm.load()

        // Then
        if case .failed = vm.state {
            #expect(Bool(true))
        } else {
            Issue.record("Expected failed state, got \(vm.state)")
        }
    }

    @Test("loadIfNeeded is a no-op when already loaded")
    func loadIfNeededIdempotent() async throws {
        // Given
        let repo = StubPokemonRepository()
        repo.detailResult = .success(pikachu)
        let vm = PokemonDetailViewModel(
            pokemonID: 25,
            fallbackName: "pikachu",
            fetchDetail: FetchPokemonDetailUseCase(repository: repo)
        )
        await vm.loadIfNeeded()

        // When
        await vm.loadIfNeeded()

        // Then
        #expect(repo.detailCalls == [25])
    }

    @Test("loadIfNeeded retries after a previous failure")
    func loadIfNeededRetriesAfterFailure() async throws {
        // Given
        struct Boom: Error {}
        let repo = StubPokemonRepository()
        repo.detailResult = .failure(Boom())
        let vm = PokemonDetailViewModel(
            pokemonID: 25,
            fallbackName: "pikachu",
            fetchDetail: FetchPokemonDetailUseCase(repository: repo)
        )
        await vm.loadIfNeeded()
        repo.detailResult = .success(pikachu)

        // When
        await vm.loadIfNeeded()

        // Then
        #expect(repo.detailCalls == [25, 25])
        #expect(vm.state.value == pikachu)
    }
}
