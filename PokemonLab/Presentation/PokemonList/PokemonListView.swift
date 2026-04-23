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
            .refreshable { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Chargement…")
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("list.loading")

        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
            .accessibilityIdentifier("list.error")

        case .loaded:
            listContent
        }
    }

    private var listContent: some View {
        List {
            ForEach(viewModel.visiblePokemon) { pokemon in
                PokemonRow(pokemon: pokemon)
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.didSelect(pokemon) }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Text("Image de \(pokemon.name.capitalized), numéro \(pokemon.id)"))
                    .accessibilityHint(Text("Ouvre la fiche détaillée"))
                    .accessibilityAddTraits(.isButton)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.visiblePokemon.isEmpty && !viewModel.searchQuery.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchQuery)
            }
        }
    }
}

private struct PokemonRow: View {
    let pokemon: PokemonSummary
    @ScaledMetric private var spriteSize: CGFloat = 56

    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(
                url: pokemon.spriteURL,
                accessibilityDescription: String(localized: "Image de \(pokemon.name.capitalized)")
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
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 4)
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
