import Foundation

nonisolated struct PokemonDetailDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [TypeSlot]
    let stats: [StatSlot]
    let sprites: Sprites

    nonisolated struct TypeSlot: Decodable, Sendable {
        let type: Named
    }

    nonisolated struct StatSlot: Decodable, Sendable {
        let baseStat: Int
        let stat: Named
    }

    nonisolated struct Named: Decodable, Sendable {
        let name: String
    }

    nonisolated struct Sprites: Decodable, Sendable {
        let frontDefault: String?
    }
}
