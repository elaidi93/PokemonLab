import SwiftUI

struct PokemonListView: View {
    @Bindable var viewModel: PokemonListViewModel

    var body: some View {
        content
            .navigationTitle(Text("Pokédex"))
            .searchable(
                text: $viewModel.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("Rechercher un Pokémon")
            )
            .task { await viewModel.loadIfNeeded() }
            .refreshable { await viewModel.refresh() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            placeholderList
                .accessibilityIdentifier("list.loading")
                .accessibilityLabel(Text("Chargement du Pokédex"))

        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
            .accessibilityIdentifier("list.error")

        case .loaded:
            listContent
        }
    }

    private var placeholderList: some View {
        List(0..<8, id: \.self) { _ in
            PokemonRowPlaceholder()
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.brandSurface)
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .accessibilityHidden(true)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemBackground))
        .allowsHitTesting(false)
    }

    private var listContent: some View {
        List {
            ForEach(viewModel.visiblePokemon) { pokemon in
                PokemonRow(pokemon: pokemon, reloadToken: viewModel.reloadToken)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.brandSurface)
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .onTapGesture { viewModel.didSelect(pokemon) }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Text("Image de \(pokemon.name.capitalized), numéro \(pokemon.id)"))
                    .accessibilityHint(Text("Ouvre la fiche détaillée"))
                    .accessibilityAddTraits(.isButton)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemBackground))
        .overlay {
            if viewModel.visiblePokemon.isEmpty && !viewModel.searchQuery.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchQuery)
            }
        }
    }
}

private struct PokemonRow: View {
    let pokemon: PokemonSummary
    let reloadToken: UUID
    @ScaledMetric private var spriteSize: CGFloat = 56

    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(
                url: pokemon.spriteURL,
                accessibilityDescription: String(localized: "Image de \(pokemon.name.capitalized)"),
                reloadToken: reloadToken
            )
            .frame(width: spriteSize, height: spriteSize)

            VStack(alignment: .leading, spacing: 2) {
                Text(pokemon.name.capitalized)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(String(format: "N°%03d", pokemon.id))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
        }
    }
}

private struct PokemonRowPlaceholder: View {
    @ScaledMetric private var spriteSize: CGFloat = 56

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: spriteSize, height: spriteSize)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: 140, height: 14)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: 60, height: 12)
            }

            Spacer(minLength: 0)
        }
        .shimmering()
    }
}

private struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(String(localized: "Oups"), systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button(action: retry) {
                Text("Réessayer")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint(Text("Recharge la liste des Pokémon"))
        }
    }
}

#Preview("Loaded — light") {
    NavigationStack {
        PokemonListView(
            viewModel: PreviewFactory.listViewModel(state: .loaded(PreviewFactory.samplePokemon))
        )
    }
}

#Preview("Loaded — dark") {
    NavigationStack {
        PokemonListView(
            viewModel: PreviewFactory.listViewModel(state: .loaded(PreviewFactory.samplePokemon))
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Error") {
    NavigationStack {
        PokemonListView(
            viewModel: PreviewFactory.listViewModel(state: .failed("Impossible de charger le Pokédex."))
        )
    }
}

#Preview("Loading — shimmer") {
    NavigationStack {
        PokemonListView(
            viewModel: PreviewFactory.listViewModel(state: .loading)
        )
    }
}
