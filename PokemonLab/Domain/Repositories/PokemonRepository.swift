import Foundation

nonisolated protocol PokemonRepository: Sendable {
    func fetchList(limit: Int) async throws -> [PokemonSummary]
    func fetchDetail(id: Int) async throws -> PokemonDetail
}
