import Foundation

struct PokemonDetailDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [TypeSlot]
    let stats: [StatSlot]
    let sprites: Sprites

    struct TypeSlot: Decodable, Sendable {
        let type: Named
    }

    struct StatSlot: Decodable, Sendable {
        let baseStat: Int
        let stat: Named
    }

    struct Named: Decodable, Sendable {
        let name: String
    }

    struct Sprites: Decodable, Sendable {
        let frontDefault: String?
    }
}
