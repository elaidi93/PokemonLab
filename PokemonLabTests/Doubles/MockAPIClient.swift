import Foundation
@testable import PokemonLab

nonisolated final class MockAPIClient: APIClient, @unchecked Sendable {
    enum Behavior {
        case data(Data)
        case error(Error)
    }

    private let queue = DispatchQueue(label: "MockAPIClient.state")
    private var _responses: [String: Behavior] = [:]
    private var _requestedURLs: [URL] = []

    var requestedURLs: [URL] {
        queue.sync { _requestedURLs }
    }

    func stub(_ url: URL, with behavior: Behavior) {
        queue.sync { _responses[url.absoluteString] = behavior }
    }

    func stub(prefix: String, with behavior: Behavior) {
        queue.sync { _responses[prefix] = behavior }
    }

    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T {
        let behavior: Behavior? = queue.sync {
            _requestedURLs.append(url)
            return _responses.first { url.absoluteString.hasPrefix($0.key) }?.value
                ?? _responses[url.absoluteString]
        }

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
