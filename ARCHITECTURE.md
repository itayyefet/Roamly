# Roamly — Architecture

Roamly is a **SwiftUI + MVVM** app with a clean services layer and a single
composition root. It targets **iOS 17+** and has **no third-party dependencies**.

---

## High-level shape

```
        ┌─────────────────────────────────────────────┐
        │                  RoamlyApp                   │  @main
        │   creates AppEnvironment (composition root)  │
        └───────────────────────┬─────────────────────┘
                                 │ injects via @EnvironmentObject
                 ┌───────────────┴───────────────┐
                 │            RootView            │  Splash → Onboarding → Tabs
                 └───────────────┬───────────────┘
        ┌────────────────────────┼────────────────────────┐
     HomeView               SavedTripsView            SettingsView
        │  (NavigationStack + AppRoute destinations)
        ▼
  RouteOptions → RouteDetail → Itinerary → MapNavigation → PlaceDetail
```

### Layers

| Layer | Responsibility | Key types |
|-------|----------------|-----------|
| **App** | Composition root, lifecycle, top-level flow | `AppEnvironment`, `RootView` |
| **DesignSystem** | Tokens + reusable components | `RoamlyColor`, `RoamlyFont`, `RoamlySpacing`, `RoamlyButton`, `RoamlyChip`, `RoamlyCard` |
| **Models** | Pure value types | `City`, `Place`, `Route`, `RouteStop`, `Intention`, `TripDuration`, `UserPreference`, `LocationState`, `Coordinate` |
| **Services** | Side-effecting capabilities | `PlacesDataProviding`/`MockDataService`, `LocationService`, `RouteGenerationService`, `MapService`, `PersistenceProviding`, `SavedTripsStore` |
| **Features** | One folder per screen (View + ViewModel) | `HomeView`/`HomeViewModel`, `RouteOptionsView`, … |

---

## Composition root: `AppEnvironment`

`AppEnvironment` builds and owns the long-lived services and shared stores. It is
the **only** place that knows which concrete implementations are used, so the
entire app can be reconfigured (e.g. mock → live API) from one function:

```swift
static func makeDefault() -> AppEnvironment {
    let data = MockDataService()          // ← swap for RemotePlacesService later
    let persistence = UserDefaultsPersistenceService()
    let location = LocationService()
    let engine = RouteGenerationService(dataService: data)
    let map = MapService()
    return AppEnvironment(...)
}
```

It is provided to the view tree via `@EnvironmentObject`, along with
`LocationService` and `SavedTripsStore` for ergonomic access.

---

## Navigation

A single `AppRoute` enum models every push destination and is driven by a
`[AppRoute]` path on each tab's `NavigationStack`. `RouteDestinations.swift`
maps an `AppRoute` to its screen, so **Explore** and **Saved** reuse identical
routing.

```swift
enum AppRoute: Hashable {
    case routeOptions(RouteQuery)
    case routeDetail(Route)
    case itinerary(Route)
    case mapNavigation(Route)
    case placeDetail(Place)
}
```

`RouteQuery` is a small `Hashable` bundle (city + start + intention + duration +
pace) carried through navigation and turned into a `RouteRequest` for the engine.

---

## The route engine

`RouteGenerationService` is a deterministic, self-contained engine over local
data. Given a `RouteRequest` it returns three differentiated `Route`s:

1. **Candidate selection** — places matching the intention (a diverse mix for
   *Surprise Me*), filtered by opening hours when available (never to empty).
2. **Ranking** — three strategies:
   - *Best Overall*: iconic, then rating.
   - *Local Favorite*: boosts hidden gems / local classics, de-emphasizes
     obvious tourist magnets.
   - *Efficient*: closest-to-start first.
3. **Sequencing** — nearest-neighbor ordering from the start to avoid zig-zags.
4. **Assembly** — per-leg walking time from the user's pace, suggested dwell
   time per stop, inserted coffee/meal/rest breaks on longer trips, and totals.
5. **Time scaling** — `TripDuration.stopRange` controls how many stops fit; the
   weekend mode splits stops across days (`Route.dayBreaks`).

Because it consumes `PlacesDataProviding`, the same engine works unchanged
against a live backend.

---

## Location flow

`LocationService` wraps `CoreLocation`, publishing `authorizationStatus` and
`coordinate`. `HomeViewModel` resolves the active city with layered fallbacks:

```
manual home city  →  demo mode  →  GPS → nearest supported city
                                         └─ none nearby → demo city
permission denied / undecided  →  demo city (+ manual picker available)
```

This guarantees the app is always useful — even with no permission or in the
Simulator.

---

## Persistence

`PersistenceProviding` abstracts storage; `UserDefaultsPersistenceService`
implements it with JSON-encoded payloads for saved trips and preferences.
`SavedTripsStore` is the observable façade the UI binds to. The protocol is
intentionally tiny so it can be re-implemented with **SwiftData** or a synced
backend without touching features.

---

## Design system

All visual constants are tokens (`RoamlyColor`, `RoamlyFont`, `RoamlySpacing`,
`RoamlyRadius`, `RoamlyShadow`) and all repeated UI is a component
(`RoamlyCard`, `RoamlyButton`, `RoamlySelectableChip`, `RoamlyTagChip`,
`RoamlyMetric`, `FlowLayout`, `EmptyStateView`, `ErrorStateView`,
`LoadingStateView`). Colors are defined with explicit light/dark variants, so
the whole app supports both modes with no per-view work.

---

## Pluggable integrations (implemented seams)

The app ships offline-first but the live integrations are already wired behind
their protocols and toggled by `RoamlyConfig` (env-driven, no code changes):

| Capability | Default | Live option | Switch |
|-----------|---------|-------------|--------|
| Places | `MockDataService` | `RemotePlacesService` (Foursquare v3) | `ROAMLY_PLACES_PROVIDER=foursquare` + `FOURSQUARE_API_KEY` |
| Persistence | `UserDefaultsPersistenceService` | `SwiftDataPersistenceService` (`@Model`) | one line in `AppEnvironment.makeDefault()` |
| Narration | `MockRouteNarrator` | `AnthropicRouteNarrator` (Claude) | `ANTHROPIC_API_KEY` |

Each live path **fails soft** — a missing key or a network error transparently
falls back to offline behavior, so the app is never broken by configuration.
The route-detail screen shows an AI/local "Your guide" note sourced from
`RouteNarrating`. All three seams are unit-tested (DTO mapping, fallback
behavior, SwiftData round-trips).

## Testing & extension notes

- Services are protocol-backed (`PlacesDataProviding`, `PersistenceProviding`),
  so view models can be unit-tested with in-memory fakes.
- View models are `@MainActor ObservableObject`s with injected dependencies.
- Search the codebase for `// TODO:` to find every external-API seam.
