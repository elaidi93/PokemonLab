import Foundation

struct PokemonSummary: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let spriteURL: URL
}
