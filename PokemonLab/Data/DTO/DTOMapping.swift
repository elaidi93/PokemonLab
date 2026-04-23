import Foundation

nonisolated extension PokemonListDTO.Entry {
    /// PokeAPI list URLs look like `https://pokeapi.co/api/v2/pokemon/25/`.
    /// The id is the last non-empty path component.
    func toDomain() -> PokemonSummary? {
        guard
            let id = Self.parseID(from: url),
            let spriteURL = Self.spriteURL(for: id)
        else { return nil }
        return PokemonSummary(id: id, name: name, spriteURL: spriteURL)
    }

    static func parseID(from urlString: String) -> Int? {
        URL(string: urlString)?
            .pathComponents
            .reversed()
            .first { !$0.isEmpty && $0 != "/" }
            .flatMap(Int.init)
    }

    static func spriteURL(for id: Int) -> URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }
}

nonisolated extension PokemonDetailDTO {
    func toDomain() -> PokemonDetail {
        PokemonDetail(
            id: id,
            name: name,
            heightDecimetres: height,
            weightHectograms: weight,
            types: types.map(\.type.name),
            stats: stats.map { PokemonDetail.Stat(name: $0.stat.name, baseValue: $0.baseStat) },
            spriteURL: sprites.frontDefault.flatMap(URL.init(string:))
        )
    }
}
