import Foundation

nonisolated protocol APIClient: Sendable {
    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T
}
