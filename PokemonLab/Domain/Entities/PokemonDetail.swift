import Foundation

nonisolated struct PokemonDetail: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let heightDecimetres: Int
    let weightHectograms: Int
    let types: [String]
    let stats: [Stat]
    let spriteURL: URL?

    nonisolated struct Stat: Hashable, Sendable, Identifiable {
        let name: String
        let baseValue: Int
        var id: String { name }
    }

    var heightMeters: Measurement<UnitLength> {
        Measurement(value: Double(heightDecimetres) / 10, unit: .meters)
    }

    var weightKilograms: Measurement<UnitMass> {
        Measurement(value: Double(weightHectograms) / 10, unit: .kilograms)
    }
}
