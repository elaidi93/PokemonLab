import SwiftUI

struct PokemonDetailView: View {
    @Bindable var viewModel: PokemonDetailViewModel

    var body: some View {
        content
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .task { await viewModel.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView(Text("common.loading"))
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            ContentUnavailableView {
                Label(String(localized: "detail.error.title"), systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button(action: { Task { await viewModel.load() } }) {
                    Text("list.error.retry")
                }
                .buttonStyle(.borderedProminent)
            }

        case .loaded(let detail):
            DetailContent(detail: detail)
        }
    }
}

private struct DetailContent: View {
    let detail: PokemonDetail
    @ScaledMetric private var spriteSize: CGFloat = 180

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                typesSection
                measurementsSection
                statsSection
            }
            .padding()
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            AsyncImageView(
                url: detail.spriteURL,
                accessibilityDescription: String(
                    localized: "common.sprite.alt.\(detail.name)"
                )
            )
            .frame(width: spriteSize, height: spriteSize)

            Text(String(format: "N°%03d", detail.id))
                .font(.title3.monospacedDigit())
                .foregroundStyle(.secondary)
                .accessibilityLabel(Text("detail.number.accessibility.\(detail.id)"))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var typesSection: some View {
        Section {
            let label = detail.types.map(\.capitalized).joined(separator: ", ")
            HStack {
                ForEach(detail.types, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.callout.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(Color.accentColor.opacity(0.18))
                        )
                        .overlay(
                            Capsule().stroke(Color.accentColor.opacity(0.35), lineWidth: 1)
                        )
                        .foregroundStyle(.primary)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("detail.types.accessibility.\(label)"))
        } header: {
            sectionHeader(Text("detail.types"))
        }
    }

    private var measurementsSection: some View {
        Section {
            let fmt = Measurement<UnitLength>.FormatStyle.measurement(
                width: .abbreviated,
                usage: .asProvided
            )
            let wfmt = Measurement<UnitMass>.FormatStyle.measurement(
                width: .abbreviated,
                usage: .asProvided
            )

            VStack(spacing: 8) {
                labeledRow(
                    key: "detail.height",
                    value: detail.heightMeters.formatted(fmt)
                )
                labeledRow(
                    key: "detail.weight",
                    value: detail.weightKilograms.formatted(wfmt)
                )
            }
        } header: {
            sectionHeader(Text("detail.measurements"))
        }
    }

    private var statsSection: some View {
        Section {
            VStack(spacing: 12) {
                ForEach(detail.stats) { stat in
                    StatBar(stat: stat)
                }
            }
        } header: {
            sectionHeader(Text("detail.stats"))
        }
    }

    private func sectionHeader(_ title: Text) -> some View {
        title
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }

    private func labeledRow(key: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(key)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}

private struct StatBar: View {
    let stat: PokemonDetail.Stat
    private let maxValue = 255.0  // PokeAPI per-stat theoretical cap

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(localizedStatName)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(String(stat.baseValue))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.2))
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .frame(height: 8)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(localizedStatName))
        .accessibilityValue(Text(verbatim: String(stat.baseValue)))
    }

    private var fraction: CGFloat {
        CGFloat(min(Double(stat.baseValue) / maxValue, 1.0))
    }

    /// Maps PokeAPI stat names to localized keys. Falls back to the raw name
    /// when we haven't provided a translation.
    private var localizedStatName: String {
        let key = "detail.stat.\(stat.name)"
        let localized = String(localized: String.LocalizationValue(key))
        return localized == key ? stat.name.capitalized : localized
    }
}

#Preview("Loaded — light") {
    NavigationStack {
        PokemonDetailView(
            viewModel: PreviewFactory.detailViewModel(state: .loaded(PreviewFactory.pikachuDetail))
        )
    }
}

#Preview("Loaded — dark") {
    NavigationStack {
        PokemonDetailView(
            viewModel: PreviewFactory.detailViewModel(state: .loaded(PreviewFactory.pikachuDetail))
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Error") {
    NavigationStack {
        PokemonDetailView(
            viewModel: PreviewFactory.detailViewModel(state: .failed("Impossible de charger les informations."))
        )
    }
}
