import Foundation

enum FixtureLoader {
    private final class BundleAnchor {}

    static func data(_ name: String, `extension`: String = "json") throws -> Data {
        let bundle = Bundle(for: BundleAnchor.self)
        guard let url = bundle.url(forResource: name, withExtension: `extension`) else {
            throw FixtureError.notFound("\(name).\(`extension`)")
        }
        return try Data(contentsOf: url)
    }

    enum FixtureError: Error, CustomStringConvertible {
        case notFound(String)
        var description: String {
            switch self {
            case .notFound(let name): "Fixture not found: \(name)"
            }
        }
    }
}
