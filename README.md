# PokemonLab

A small iOS application built as a technical test for **GMF Assurance**.

Two screens backed by [PokeAPI](https://pokeapi.co):

- **List** — the first 151 Pokémon with local search and pull-to-refresh.
- **Detail** — types, measurements (height, weight) and base stats.

French-only UI (the brief is written in French).

---

## Tech stack

- **Xcode 26.4**, iOS 26.4, Swift 5
- **SwiftUI** with `@Observable` view models and `@Bindable` views
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — Domain / Data / DTO layers are marked `nonisolated`
- **Swift Testing** (not XCTest) for unit tests
- **String Catalog** (`Localizable.xcstrings`) with `fr` as source language

No third-party dependencies.

---

## Architecture

Clean Architecture in three layers with a strict dependency direction:

```
Presentation  →  Domain  ←  Data
```

```
PokemonLab/
├── App/
│   ├── PokemonLabApp.swift       @main — owns AppDependencies + AppCoordinator
│   └── AppDependencies.swift     Composition root (wires APIClient → Repository → UseCases)
├── Domain/
│   ├── Entities/                 PokemonSummary, PokemonDetail
│   ├── Repositories/             PokemonRepository protocol
│   └── UseCases/                 FetchPokemonList, FetchPokemonDetail
├── Data/
│   ├── Network/                  APIClient, URLSessionAPIClient, APIError
│   ├── DTO/                      Raw PokeAPI DTOs + DTO → Domain mapping
│   └── Repository/               PokemonRepositoryImpl
└── Presentation/
    ├── Coordinator/              AppCoordinator (@Observable, owns path), Route
    ├── PokemonList/              ViewModel + View
    ├── PokemonDetail/            ViewModel + View
    └── Shared/                   LoadableState, AsyncImageView, PreviewFactory (#if DEBUG)
```

### Why MVVM-C in SwiftUI

`AppCoordinator` owns `[Route]` as the `NavigationStack` path. The root view uses
`NavigationStack(path: $coordinator.path)` with `.navigationDestination(for: Route.self)`,
and view models call `coordinator.show(.detail(...))` — they never construct views.
Navigation logic lives in exactly one place.

### Why `@Observable` over `ObservableObject`

Targets iOS 17+, removes `@Published` boilerplate, plays cleanly with the project-wide
`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` setting.

### Why `nonisolated` is sprinkled around Domain / Data

Because the project is MainActor-by-default, types declared without an explicit
annotation inherit main-actor isolation — including their `Decodable` / `Equatable`
conformances. That breaks the `T: Decodable & Sendable` generic bound on
`APIClient.get`. Marking Domain, Data, DTOs, and shared presentation value types
`nonisolated` keeps them cross-actor-safe. View models and views stay on `MainActor`.

---

## Accessibility

- **VoiceOver** — every list row is a single spoken element:
  *"Image de Pikachu, numéro 25. Button. Opens the detail page."*
  On the detail screen the sprite is its own focusable element:
  *"Image de Pikachu, image."* Section headers carry `.isHeader`, stat bars
  expose a numeric `accessibilityValue`, and the chevron is hidden from VoiceOver.
- **Dynamic Type** — only semantic fonts (`.headline`, `.body`, `.caption`);
  sprite sizes use `@ScaledMetric`; layout reflows at AX sizes.
- **Contrast and color-independence** — no color-only information (type names
  are spelled out, stat bars also show numeric values). No custom hex values
  in Swift: all colors come from the asset catalog with explicit light / dark
  variants, so everything adapts automatically.

---

## Dark mode

All colors live in the asset catalog with **Any Appearance + Dark** variants:

- `AccentColor` — Pokéball red, softened for dark mode
- `BrandSurface` — card background
- `TypeChipFill` / `TypeChipBorder` — type pill styling

Generated Swift symbols (`Color.brandSurface`, `Color.typeChipFill`, …) are
enabled via `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES`,
so there is zero hex-in-code.

SwiftUI previews render each screen in both `.light` and `.dark` color schemes.

---

## Build & tests

Open `PokemonLab.xcodeproj` in Xcode 26 and run on an iPhone 17 simulator.

From the command line:

```bash
# Build
xcodebuild -project PokemonLab.xcodeproj -scheme PokemonLab \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# Unit tests
xcodebuild -project PokemonLab.xcodeproj -scheme PokemonLab \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:PokemonLabTests test
```

### Test coverage

20 unit tests across 6 Swift Testing suites:

| Suite | Covers |
| --- | --- |
| `DTOMappingTests` | DTO → Domain mapping, URL-id parsing (parametrised), malformed input, missing sprite |
| `PokemonRepositoryImplTests` | URL construction with limit, detail endpoint, error propagation |
| `FetchPokemonListUseCaseTests` | Happy path + error propagation |
| `FetchPokemonDetailUseCaseTests` | Forwards id, returns detail |
| `PokemonListViewModelTests` | State transitions, `loadIfNeeded` idempotency, search filter, navigation |
| `PokemonDetailViewModelTests` | Fallback navigation title, load success / failure |

Test doubles (`MockAPIClient`, `StubPokemonRepository`) and JSON fixtures live in
the test target only — no `#if DEBUG` hacks in the app target.

---

## Manual review checklist

1. List loads 151 Pokémon with sprites; each row shows name and number.
2. Pull down → list refreshes.
3. Type *"pika"* in the search bar → list filters to Pikachu.
4. Tap a row → detail screen shows types, height, weight, and stats.
5. Go back → list is instantly visible (no re-spinner).
6. ⇧⌘A in the simulator toggles dark mode — verify both screens.
7. Accessibility Inspector → enable VoiceOver and swipe through the list and
   detail screens; labels read naturally in French.
8. Settings → Accessibility → Larger Text → max size → layout reflows without
   clipping.

---

## Known trade-offs (deliberately left out)

- **No pagination** — 151 is a clean gen-1 cap; infinite scroll would be
  scope-creep for the brief.
- **No image caching beyond `URLCache`** — fine for 151 sprites.
- **No offline detection** — errors are shown with a retry button.
- **No snapshot tests** — unit tests cover logic; snapshot coverage would be
  the natural next step.
- **Use cases are thin pass-throughs** — kept to demonstrate the layering; in
  production they'd pick up caching, combining repositories, etc.

---

## Project structure notes

- The Xcode project uses `PBXFileSystemSynchronizedRootGroup`, so any file
  added under `PokemonLab/`, `PokemonLabTests/`, or `PokemonLabUITests/`
  is auto-synced into the target — no `project.pbxproj` edits needed.
- `LOCALIZATION_PREFERS_STRING_CATALOGS = YES` — the catalog is the single
  source of truth for translations.
- `SWIFT_APPROACHABLE_CONCURRENCY = YES` — opts in to Swift 6-style actor
  checks so the isolation story is explicit, not implicit.
