import Foundation
@testable import PokemonLab

final class StubPokemonRepository: PokemonRepository, @unchecked Sendable {
    var listResult: Result<[PokemonSummary], Error> = .success([])
    var detailResult: Result<PokemonDetail, Error> = .failure(APIError.invalidResponse(statusCode: 404))
    private(set) var listCalls = 0
    private(set) var detailCalls: [Int] = []

    func fetchList(limit: Int) async throws -> [PokemonSummary] {
        listCalls += 1
        return try listResult.get()
    }

    func fetchDetail(id: Int) async throws -> PokemonDetail {
        detailCalls.append(id)
        return try detailResult.get()
    }
}
