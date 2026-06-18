//
//  SampleData+Rome.swift
//  Roamly
//

import Foundation

extension SampleData {
    static let rome = City(
        id: "rome",
        name: "Rome",
        country: "Italy",
        countryFlag: "🇮🇹",
        center: Coordinate(latitude: 41.9009, longitude: 12.4833),
        neighborhoods: [
            Neighborhood(name: "Centro Storico", center: Coordinate(latitude: 41.8989, longitude: 12.4769)),
            Neighborhood(name: "Trastevere", center: Coordinate(latitude: 41.8896, longitude: 12.4695)),
            Neighborhood(name: "Monti", center: Coordinate(latitude: 41.8950, longitude: 12.4925))
        ],
        places: [
            place(
                id: "rom-colosseum",
                name: "The Colosseum",
                intentions: [.history, .architecture, .photography, .localClassics],
                lat: 41.8902, lon: 12.4922,
                category: "Ancient Roman Amphitheatre",
                why: "The greatest surviving monument of ancient Rome — 2,000 years of history.",
                description: "Once host to gladiatorial combat before 50,000 spectators, the Colosseum remains an awe-inspiring feat of Roman engineering and the symbol of the Eternal City.",
                address: "Piazza del Colosseo, Rome",
                rating: 4.8, symbol: "building.columns.fill", minutes: 90, price: 2,
                hours: OpeningHours(opensAtHour: 9, closesAtHour: 19, closedWeekdays: []),
                tip: "Book a timed ticket online to skip the long entrance queue.",
                iconic: true
            ),
            place(
                id: "rom-pantheon",
                name: "The Pantheon",
                intentions: [.history, .architecture, .religiousHeritage, .photography],
                lat: 41.8986, lon: 12.4769,
                category: "Ancient Temple",
                why: "A perfectly preserved Roman temple with the world's largest unreinforced concrete dome.",
                description: "Nearly two millennia old, the Pantheon's coffered dome and central oculus still astonish architects today. Free to enter and endlessly photogenic.",
                address: "Piazza della Rotonda, Rome",
                rating: 4.8, symbol: "building.columns.fill", minutes: 35,
                tip: "Stand directly under the oculus when it rains — the water drains through hidden floor holes.",
                iconic: true
            ),
            place(
                id: "rom-trevi",
                name: "Trevi Fountain",
                intentions: [.architecture, .photography, .localClassics],
                lat: 41.9009, lon: 12.4833,
                category: "Baroque Fountain",
                why: "Rome's most theatrical fountain — toss a coin to ensure your return.",
                description: "A cascade of Baroque sculpture and turquoise water tucked into a small piazza. Tradition says a coin tossed over your shoulder guarantees a return to Rome.",
                address: "Piazza di Trevi, Rome",
                rating: 4.7, symbol: "drop.fill", minutes: 25,
                hours: OpeningHours.alwaysOpen,
                tip: "Come at 7am for the fountain almost to yourself.",
                iconic: true
            ),
            place(
                id: "rom-vatican",
                name: "St. Peter's Basilica",
                intentions: [.religiousHeritage, .architecture, .history, .artCulture],
                lat: 41.9022, lon: 12.4539,
                category: "Renaissance Basilica",
                why: "The spiritual center of Catholicism and a Renaissance masterpiece.",
                description: "Home to Michelangelo's Pietà and a dome you can climb for the best view in Rome, St. Peter's is overwhelming in scale and artistry.",
                address: "Vatican City",
                rating: 4.9, symbol: "books.vertical.fill", minutes: 90,
                hours: OpeningHours(opensAtHour: 7, closesAtHour: 19, closedWeekdays: []),
                tip: "Dress code is enforced — shoulders and knees covered.",
                iconic: true
            ),
            place(
                id: "rom-trastevere",
                name: "Trastevere Lanes",
                intentions: [.foodie, .hiddenGems, .nightlife, .localClassics],
                lat: 41.8896, lon: 12.4695,
                category: "Historic Food & Nightlife Quarter",
                why: "Cobblestone lanes, trattorias and Rome's most charming evening buzz.",
                description: "Across the Tiber, Trastevere's ivy-draped alleys hide some of the city's best home-style Roman cooking and a lively after-dark wine scene.",
                address: "Trastevere, Rome",
                rating: 4.7, symbol: "fork.knife", minutes: 60,
                tip: "Wander away from the main square to find the family-run spots locals love.",
                food: "Order cacio e pepe and supplì — Roman comfort food at its best."
            ),
            place(
                id: "rom-borghese",
                name: "Villa Borghese Gardens",
                intentions: [.natureParks, .familyFriendly, .artCulture],
                lat: 41.9145, lon: 12.4923,
                category: "Landscaped City Park",
                why: "Rome's green lung — gardens, a lake and a world-class art gallery.",
                description: "Rent a rowboat, stroll shaded paths, or visit the Galleria Borghese's Bernini sculptures in this vast, elegant park above the city.",
                address: "Piazzale Napoleone I, Rome",
                rating: 4.6, symbol: "leaf.fill", minutes: 60,
                hours: OpeningHours(opensAtHour: 7, closesAtHour: 20, closedWeekdays: [])
            ),
            place(
                id: "rom-testaccio-market",
                name: "Testaccio Market",
                intentions: [.foodie, .hiddenGems, .localClassics],
                lat: 41.8765, lon: 12.4757,
                category: "Local Food Market",
                why: "Where Romans actually shop and eat — far from the tourist crowds.",
                description: "A modern covered market in a working-class neighborhood, packed with produce stalls and legendary panini counters serving Roman classics.",
                address: "Via Beniamino Franklin, Rome",
                rating: 4.6, symbol: "basket.fill", minutes: 45, price: 1,
                hours: OpeningHours(opensAtHour: 8, closesAtHour: 15, closedWeekdays: [1]),
                food: "Mordi e Vai's stewed-beef panino is the stuff of legend."
            ),
            place(
                id: "rom-stadio-olimpico",
                name: "Stadio Olimpico",
                intentions: [.sports],
                lat: 41.9339, lon: 12.4547,
                category: "Football Stadium",
                why: "Home to AS Roma and Lazio — the cauldron of Roman football.",
                description: "Catch a Serie A match for an unforgettable atmosphere of flares, chants and fierce local passion in this historic 70,000-seat arena.",
                address: "Viale dei Gladiatori, Rome",
                rating: 4.5, symbol: "sportscourt.fill", minutes: 120, price: 2
            ),
            place(
                id: "rom-aventine-keyhole",
                name: "The Aventine Keyhole",
                intentions: [.hiddenGems, .photography, .religiousHeritage],
                lat: 41.8838, lon: 12.4786,
                category: "Hidden Viewpoint",
                why: "A secret keyhole that perfectly frames St. Peter's dome.",
                description: "Peer through an unassuming green door on the Aventine Hill and a hedge-lined path magically frames the distant dome of St. Peter's. A quiet, magical surprise.",
                address: "Piazza dei Cavalieri di Malta, Rome",
                rating: 4.7, symbol: "sparkles", minutes: 20,
                hours: OpeningHours.alwaysOpen,
                tip: "There's often a short line — it's worth the two-minute wait."
            )
        ]
    )
}
