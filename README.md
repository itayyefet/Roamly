# Roamly 🧭

**Open. Choose. Explore.**

Roamly is an on-the-go city exploration app for iPhone. No planning required —
open the app, it detects your city, you pick the kind of experience you want and
how much time you have, and Roamly instantly builds a guided, step-by-step
walking route around you.

> This repository contains a complete, working **SwiftUI MVP**. Route generation
> runs locally against a curated sample catalog (Miami, Rome, New York, Paris,
> London) and is architected to swap in real APIs later with zero UI changes.

---

## ✨ Features

- **Instant routes** — choose an *intention* (History, Foodie, Hidden Gems, …)
  and a *time budget* (30 min → Weekend) and get three tailored routes.
- **Three route flavors** — *Best Overall*, *Local Favorite*, *Efficient Route*.
- **Smart route engine** — ranks places by relevance, ratings and iconic status;
  orders stops with nearest-neighbor pathing; respects opening hours; inserts
  coffee/meal/rest breaks on longer trips; scales stop count to your time.
- **Map-first navigation** — numbered pins, a drawn route path, a focused
  current-stop card with *Next Stop*, and one-tap hand-off to Apple Maps.
- **Rich place detail** — why it matters, insider tips, food picks, hours, map.
- **Saved trips** — bookmark and favorite routes; everything persists locally.
- **Graceful location handling** — permission explained up front; manual city
  picker and demo mode fallbacks when location is denied or unavailable.
- **Premium design system** — reusable color, typography, spacing, card, button
  and chip tokens. Full light & dark mode.

---

## 🚀 Getting started

### Requirements
- **Xcode 16** or newer (the project uses file-system-synchronized groups).
- **iOS 17.0+** deployment target.

### Run it
1. Open `Roamly.xcodeproj` in Xcode.
2. Select the **Roamly** scheme and an iPhone simulator (e.g. iPhone 15 Pro).
3. Press **⌘R**.

That's it — there are no third-party dependencies or package resolution steps.

### Trying it in the Simulator
The Simulator has no real GPS. Roamly handles this automatically by falling back
to a demo city, and you can also:
- Open **Settings → Location → Demo mode**, or pick a **Home city**, or
- Tap the city chip at the top of Home to choose any city manually, or
- Use Xcode's **Features → Location → Custom Location…** to simulate coordinates.

---

## 🗂 Project structure

```
Roamly/
├── App/              App entry, composition root, root navigation
├── DesignSystem/     Color/typography/spacing tokens + components
├── Models/           City, Place, Route, RouteStop, Intention, … 
├── Services/         Data, Location, RouteGeneration, Map, Persistence
├── Features/         One folder per screen (MVVM)
└── Resources/        Sample city catalog (Miami, Rome, NYC, Paris, London)
```

See **[ARCHITECTURE.md](ARCHITECTURE.md)** for a full breakdown.

---

## 🔌 Wiring real data later

Everything funnels through `PlacesDataProviding`. The MVP ships
`MockDataService`; to go live, implement a `RemotePlacesService` (Google Places,
Foursquare, Yelp, TripAdvisor, or a custom backend) behind the same protocol and
swap it in `AppEnvironment.makeDefault()`. No view or view-model code changes.

Integration points are marked with `// TODO:` comments throughout the codebase.

---

## 📚 More docs
- **[PRODUCT_SPEC.md](PRODUCT_SPEC.md)** — product decisions & rationale.
- **[ARCHITECTURE.md](ARCHITECTURE.md)** — how the app is built.
- **[FUTURE_ROADMAP.md](FUTURE_ROADMAP.md)** — premium features & monetization.

---

## 🏷 Branding notes
**Primary name:** Roamly · **Tagline:** Open. Choose. Explore.
**Alternatives considered:** LocalLoop · DriftGuide · CityPulse · Wayfindr · HereNow
**Palette:** deep blue (primary) · warm orange (accent) · soft neutral surfaces.
