import Foundation

nonisolated struct PokemonListDTO: Decodable, Sendable {
    let results: [Entry]

    nonisolated struct Entry: Decodable, Sendable {
        let name: String
        let url: String
    }
}
