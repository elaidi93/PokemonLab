import Foundation

nonisolated enum Route: Hashable {
    case detail(pokemonID: Int, name: String)
}
