import Foundation
@testable import PokemonLab

final class MockAPIClient: APIClient, @unchecked Sendable {
    enum Behavior {
        case data(Data)
        case error(Error)
    }

    private let lock = NSLock()
    private var _responses: [String: Behavior] = [:]
    private(set) var requestedURLs: [URL] = []

    func stub(_ url: URL, with behavior: Behavior) {
        lock.lock(); defer { lock.unlock() }
        _responses[url.absoluteString] = behavior
    }

    func stub(prefix: String, with behavior: Behavior) {
        lock.lock(); defer { lock.unlock() }
        _responses[prefix] = behavior
    }

    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T {
        lock.lock()
        requestedURLs.append(url)
        let behavior = _responses.first { url.absoluteString.hasPrefix($0.key) }?.value
            ?? _responses[url.absoluteString]
        lock.unlock()

        guard let behavior else {
            throw APIError.invalidResponse(statusCode: 404)
        }
        switch behavior {
        case .data(let data):
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding
            }
        case .error(let error):
            throw error
        }
    }
}
