import Foundation

nonisolated enum APIError: Error, Equatable {
    case invalidRequest
    case invalidResponse(statusCode: Int)
    case decoding
    case transport

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case let (.invalidResponse(l), .invalidResponse(r)): l == r
        case (.invalidRequest, .invalidRequest),
             (.decoding, .decoding),
             (.transport, .transport): true
        default: false
        }
    }
}
