import Foundation

struct PokemonListDTO: Decodable, Sendable {
    let results: [Entry]

    struct Entry: Decodable, Sendable {
        let name: String
        let url: String
    }
}
