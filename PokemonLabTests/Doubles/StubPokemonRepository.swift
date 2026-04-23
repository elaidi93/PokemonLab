import Foundation
@testable import PokemonLab

nonisolated final class StubPokemonRepository: PokemonRepository, @unchecked Sendable {
    var listResult: Result<[PokemonSummary], Error> = .success([])
    var detailResult: Result<PokemonDetail, Error> = .failure(APIError.invalidResponse(statusCode: 404))
    private(set) var listCalls: [Int] = []
    private(set) var detailCalls: [Int] = []

    var listCallCount: Int { listCalls.count }

    func fetchList(limit: Int) async throws -> [PokemonSummary] {
        listCalls.append(limit)
        return try listResult.get()
    }

    func fetchDetail(id: Int) async throws -> PokemonDetail {
        detailCalls.append(id)
        return try detailResult.get()
    }
}
