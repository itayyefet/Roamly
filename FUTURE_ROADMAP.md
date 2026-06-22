# Roamly — Future Roadmap

The MVP proves the core loop (*Detect → Choose → Explore*) against local data.
This document captures the premium feature roadmap and monetization strategy.

---

## 🧠 Intelligence & data

- **AI-generated personalized city routes** — an LLM composes and narrates routes
  from your taste profile, pace and past trips.
  *Seam:* `RouteGenerationService` / `PlacesDataProviding`.
- **Real-time events** — concerts, markets, festivals folded into routes by time.
- **Weather-aware routing** — favor indoor stops when it rains; sunset timing for
  photography routes.
- **Live data providers** — Google Places, Foursquare, Yelp, TripAdvisor for
  photos, hours, ratings and reviews. *Seam:* `RemotePlacesService`.

## 🗺 Navigation & access

- **Offline maps** — downloadable city packs (tiles + catalog) for travelers
  without data.
- **Accessibility-aware routing** — step-free paths, rest density, surface types.
- **Voice-guided tours** — hands-free audio narration between and at stops.
- **AR city overlay** — point your camera to see what you're looking at and
  directional cues.
- **Hotel pickup route start** — begin and loop back to your accommodation.

## 🎟 Transactions

- **Restaurant reservations** — book the food picks inside the itinerary.
- **Ticket booking** — skip-the-line entry for museums and landmarks.

## 👨‍👩‍👧 Audiences & modes

- **Family mode** — kid-friendly pacing, stroller routes, playground breaks.
- **Budget filters** — free-only or price-tier caps.
- **Conference/business traveler mode** — short, near-venue routes between
  sessions; calendar-aware.

## 🔗 Integrations

- **Calendar & flights** — auto-suggest a route in a layover or a free evening.
- **Social sharing** — share a route as a beautiful card or live link.
- **Group trip planning** — co-build and vote on a shared itinerary.

---

## 💰 Monetization

| Model | Description |
|-------|-------------|
| **Freemium** | Core routing free; premium unlocks AI routes, offline, advanced filters. |
| **Premium city packs** | One-time purchase for deeply curated/expert city guides. |
| **AI concierge subscription** | Recurring plan for personalized, narrated, weather/event-aware routes. |
| **Affiliate revenue** | Commission on reservations, tickets and tours booked in-app. |
| **Business traveler plan** | Team/expense-friendly subscription with calendar & venue features. |
| **White-label** | Licensed version for city tourism boards & hotels, themed to their brand. |

### Suggested phasing
1. **Phase 1** — Live data + photos; launch *Premium city packs*.
2. **Phase 2** — AI personalized routes + narration; launch the *AI concierge* subscription.
3. **Phase 3** — Reservations/tickets (affiliate); offline packs.
4. **Phase 4** — Business mode, white-label, group planning.

---

## 🧩 Why these are cheap to add

The MVP was built around replaceable seams:

- `PlacesDataProviding` → live providers / AI ranking.
- `PersistenceProviding` → SwiftData / synced backend / accounts.
- `MapService` → richer navigation, offline tiles.
- `AppEnvironment.makeDefault()` → single switch-over point.

Every integration point is marked with `// TODO:` in the source.
