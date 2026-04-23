import Foundation

enum APIError: Error, Equatable {
    case invalidResponse(statusCode: Int)
    case decoding
    case transport

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case let (.invalidResponse(l), .invalidResponse(r)): l == r
        case (.decoding, .decoding), (.transport, .transport): true
        default: false
        }
    }
}
