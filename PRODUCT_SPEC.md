# Roamly — Product Spec

**Roamly** — *Open. Choose. Explore.*
A smart local guide in your pocket. It removes planning friction and creates
immediate, location-aware sightseeing experiences with step-by-step navigation.

---

## 1. Problem & promise

Travelers (and curious locals) waste time researching what to see and how to
string it together. Roamly's promise: **open the app and start walking in under
30 seconds**, with a route tailored to your mood and the time you actually have.

Core loop: **Detect → Choose intention → Choose time → Get 3 routes → Walk.**

---

## 2. Target users

- **Time-boxed travelers** — a few free hours between meetings or before a flight.
- **Spontaneous explorers** — no itinerary, want something good *now*.
- **Locals & staycationers** — rediscovering their own city by theme.

---

## 3. Intentions (the "vibe")

History · Art & Culture · Sports · Foodie · Architecture · Family Friendly ·
Nature & Parks · Hidden Gems · Shopping · Nightlife · Photography ·
Religious / Heritage · Local Classics · **Surprise Me**

*Surprise Me* generates a curated, deliberately diverse mix across categories.

## 4. Time modes → stop counts

| Mode | Budget | Stops | Meal break |
|------|--------|-------|-----------|
| Quick Walk | 30 min | 1–2 | — |
| Express | 1 hr | 2–3 | — |
| Mini Tour | 2 hrs | 3–4 | — |
| Half Day | 4 hrs | 4–6 | ✓ |
| Full Day | 8 hrs | 6–9 | ✓ |
| Weekend | 2 days | 8–14 | ✓ (multi-day) |

---

## 5. Route options

Every generation returns **three** cards so the user chooses a *style*, not a
spreadsheet:

- **Best Overall** — iconic highlights, balanced for the time available.
- **Local Favorite** — where locals go; favors hidden gems, softens tourist magnets.
- **Efficient Route** — maximum to see, minimum walking; tightly sequenced.

Each card shows title, description, estimated time, walking distance, stop count,
tags, and a **Start** button.

---

## 6. Step-by-step itinerary

Per stop: number, name, category, *why it matters*, suggested dwell time,
walking time/distance to next, address, optional insider tip, optional nearby
food pick. Longer routes auto-insert coffee/meal/rest breaks. Weekend trips are
grouped by **Day**.

---

## 7. Map behavior

User location, numbered route pins (by stop order), a drawn route path
(real walking polyline via MapKit Directions, straight-line fallback when
offline), a focused current-stop card with **Next Stop**, and one-tap
hand-off to **Apple Maps** for turn-by-turn.

---

## 8. Key product decisions & assumptions

1. **Local mock engine for the MVP.** Ships realistic, hand-authored data for 5
   cities so the experience is complete and demoable offline — while the
   `PlacesDataProviding` seam keeps a real API one file away.
2. **Three routes, not one.** Choosing a *style* feels smart and low-effort; a
   single answer feels arbitrary.
3. **Always-useful fallbacks.** No GPS, denied permission or an unsupported
   city never dead-ends the user — we fall back to a demo/manual city.
4. **Walking-first, gentle pacing.** Nearest-neighbor sequencing plus a
   user-selectable pace avoid "aggressive" routes; breaks appear on long trips.
5. **Opinionated, premium design.** Tokenized design system, large cards,
   minimal text, strong hierarchy, full light/dark — never prototype-looking.
6. **Privacy-respecting.** Location is used only in-session to build routes;
   nothing is sold or shared. Everything persists on-device.
7. **No blank screens.** Every list/flow has empty, error and loading states.

---

## 9. Success metrics (post-MVP)

- Time-to-first-route (target < 30s from cold open).
- Route start rate (started / generated).
- Stops completed per started route.
- Save & repeat-open rates.

---

## 10. Out of scope for the MVP

Live data/APIs, accounts, payments/subscriptions, offline map tiles, AR, social
sharing, and reservations — all captured in **FUTURE_ROADMAP.md**.

---

## 11. Branding

- **Name:** Roamly · **Tagline:** Open. Choose. Explore.
- **Alternatives:** LocalLoop · DriftGuide · CityPulse · Wayfindr · HereNow
- **Colors:** deep blue (primary), warm orange (accent), soft neutral surfaces.
- **Voice:** friendly but professional — a knowledgeable local, not a brochure.
