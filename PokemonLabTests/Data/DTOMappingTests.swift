import Foundation
import Testing
@testable import PokemonLab

@Suite("DTO mapping")
struct DTOMappingTests {
    @Test("List entry extracts the numeric id from the PokeAPI URL")
    func parsesIDFromEntryURL() throws {
        let entry = PokemonListDTO.Entry(
            name: "pikachu",
            url: "https://pokeapi.co/api/v2/pokemon/25/"
        )
        let domain = try #require(entry.toDomain())
        #expect(domain.id == 25)
        #expect(domain.name == "pikachu")
        #expect(domain.spriteURL.absoluteString.hasSuffix("/25.png"))
    }

    @Test(
        "parseID handles trailing slash and no slash",
        arguments: [
            ("https://pokeapi.co/api/v2/pokemon/1/", 1),
            ("https://pokeapi.co/api/v2/pokemon/151", 151),
            ("https://pokeapi.co/api/v2/pokemon/99/", 99),
        ]
    )
    func parsesIDFromVariousURLShapes(urlString: String, expected: Int) {
        #expect(PokemonListDTO.Entry.parseID(from: urlString) == expected)
    }

    @Test("List entry with a non-numeric URL segment is dropped")
    func rejectsMalformedURL() {
        let entry = PokemonListDTO.Entry(name: "???", url: "not-a-url")
        #expect(entry.toDomain() == nil)
    }

    @Test("Detail DTO maps to domain entity with all fields")
    func detailMaps() throws {
        let data = try FixtureLoader.data("pokemon_25")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(PokemonDetailDTO.self, from: data)
        let domain = dto.toDomain()

        #expect(domain.id == 25)
        #expect(domain.name == "pikachu")
        #expect(domain.heightDecimetres == 4)
        #expect(domain.weightHectograms == 60)
        #expect(domain.types == ["electric"])
        #expect(domain.stats.count == 6)
        let hp = try #require(domain.stats.first { $0.name == "hp" })
        #expect(hp.baseValue == 35)
        #expect(domain.spriteURL?.absoluteString.hasSuffix("/25.png") == true)
    }

    @Test("Detail DTO with missing sprite produces nil spriteURL")
    func detailWithoutSprite() {
        let dto = PokemonDetailDTO(
            id: 1,
            name: "bulbasaur",
            height: 7,
            weight: 69,
            types: [],
            stats: [],
            sprites: .init(frontDefault: nil)
        )
        #expect(dto.toDomain().spriteURL == nil)
    }
}
