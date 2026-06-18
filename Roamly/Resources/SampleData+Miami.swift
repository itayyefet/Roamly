//
//  SampleData+Miami.swift
//  Roamly
//

import Foundation

extension SampleData {
    static let miami = City(
        id: "miami",
        name: "Miami",
        country: "USA",
        countryFlag: "🇺🇸",
        center: Coordinate(latitude: 25.7825, longitude: -80.1918),
        neighborhoods: [
            Neighborhood(name: "South Beach", center: Coordinate(latitude: 25.7825, longitude: -80.1340)),
            Neighborhood(name: "Wynwood", center: Coordinate(latitude: 25.8010, longitude: -80.1990)),
            Neighborhood(name: "Little Havana", center: Coordinate(latitude: 25.7657, longitude: -80.2197)),
            Neighborhood(name: "Downtown", center: Coordinate(latitude: 25.7743, longitude: -80.1937))
        ],
        places: [
            place(
                id: "mia-wynwood-walls",
                name: "Wynwood Walls",
                intentions: [.artCulture, .photography, .localClassics],
                lat: 25.8010, lon: -80.1995,
                category: "Outdoor Street-Art Museum",
                why: "An open-air gallery of world-class murals that defined Miami's art scene.",
                description: "Once a warehouse district, Wynwood is now a vivid canvas of large-scale murals by international street artists. The walls change regularly, so every visit feels new.",
                address: "2516 NW 2nd Ave, Miami, FL",
                rating: 4.7, symbol: "paintpalette.fill", minutes: 45, price: 1,
                hours: OpeningHours(opensAtHour: 10, closesAtHour: 23, closedWeekdays: []),
                tip: "Go an hour before sunset — the light makes the colors pop for photos.",
                food: "Coyo Taco around the corner for standout street tacos.",
                iconic: true
            ),
            place(
                id: "mia-ocean-drive",
                name: "Ocean Drive & Art Deco District",
                intentions: [.architecture, .photography, .localClassics, .nightlife],
                lat: 25.7805, lon: -80.1300,
                category: "Historic Architecture Strip",
                why: "The largest collection of Art Deco architecture in the world, right on the beach.",
                description: "Pastel facades, neon signs and 1930s glamour line this iconic beachfront stretch of South Beach. Stunning by day and electric at night.",
                address: "Ocean Dr, Miami Beach, FL",
                rating: 4.6, symbol: "building.2.fill", minutes: 40,
                tip: "The Art Deco Welcome Center offers a great self-guided walking map.",
                iconic: true
            ),
            place(
                id: "mia-vizcaya",
                name: "Vizcaya Museum & Gardens",
                intentions: [.history, .architecture, .artCulture, .photography],
                lat: 25.7444, lon: -80.2106,
                category: "Historic Estate & Gardens",
                why: "A 1916 Italian-Renaissance villa with breathtaking bayfront gardens.",
                description: "This opulent estate transports you to old-world Europe with ornate interiors, fountains and manicured gardens overlooking Biscayne Bay.",
                address: "3251 S Miami Ave, Miami, FL",
                rating: 4.7, symbol: "building.columns.fill", minutes: 75, price: 2,
                hours: OpeningHours(opensAtHour: 9, closesAtHour: 17, closedWeekdays: [4]),
                tip: "Weekday mornings are quietest for that postcard garden shot.",
                iconic: true
            ),
            place(
                id: "mia-calle-ocho",
                name: "Calle Ocho, Little Havana",
                intentions: [.foodie, .artCulture, .localClassics, .history],
                lat: 25.7657, lon: -80.2197,
                category: "Cuban Cultural District",
                why: "The beating heart of Miami's Cuban culture — music, cigars and cafecito.",
                description: "Stroll past domino players, salsa spilling from doorways, hand-rolled cigars and the aroma of Cuban coffee on every block.",
                address: "SW 8th St, Miami, FL",
                rating: 4.6, symbol: "music.note.house.fill", minutes: 50,
                tip: "Order a 'cortadito' at a walk-up window and people-watch at Domino Park.",
                food: "Versailles Restaurant for classic Cuban dishes and pastelitos."
            ),
            place(
                id: "mia-bayfront-park",
                name: "Bayfront Park",
                intentions: [.natureParks, .familyFriendly, .photography],
                lat: 25.7753, lon: -80.1860,
                category: "Waterfront Urban Park",
                why: "Green space and skyline-meets-bay views in the middle of downtown.",
                description: "A relaxing waterfront park with fountains, public art and sweeping views across Biscayne Bay — a calm break between sights.",
                address: "301 Biscayne Blvd, Miami, FL",
                rating: 4.4, symbol: "leaf.fill", minutes: 30,
                hours: OpeningHours.alwaysOpen
            ),
            place(
                id: "mia-perez-art",
                name: "Pérez Art Museum (PAMM)",
                intentions: [.artCulture, .architecture, .familyFriendly],
                lat: 25.7860, lon: -80.1862,
                category: "Contemporary Art Museum",
                why: "Modern art in a striking hanging-garden building on the bay.",
                description: "PAMM pairs ambitious contemporary exhibitions with a bold tropical-modern building, complete with hanging gardens and a waterfront terrace.",
                address: "1103 Biscayne Blvd, Miami, FL",
                rating: 4.5, symbol: "paintpalette.fill", minutes: 70, price: 2,
                hours: OpeningHours(opensAtHour: 11, closesAtHour: 18, closedWeekdays: [3, 4])
            ),
            place(
                id: "mia-marlins-park",
                name: "loanDepot Park",
                intentions: [.sports, .familyFriendly],
                lat: 25.7781, lon: -80.2197,
                category: "Baseball Stadium",
                why: "Home of the Miami Marlins and a retractable-roof landmark.",
                description: "A modern, climate-controlled ballpark in Little Havana — catch a Marlins game or tour the stadium's quirky art and design.",
                address: "501 Marlins Way, Miami, FL",
                rating: 4.3, symbol: "sportscourt.fill", minutes: 120, price: 2
            ),
            place(
                id: "mia-secret-garden",
                name: "The Kampong Garden",
                intentions: [.hiddenGems, .natureParks, .photography],
                lat: 25.7080, lon: -80.2510,
                category: "Hidden Botanical Garden",
                why: "A serene, little-known tropical garden once owned by a famed botanist.",
                description: "Tucked away in Coconut Grove, this lush botanical sanctuary of rare tropical fruit trees and palms feels like a secret kept from the city.",
                address: "4013 Douglas Rd, Miami, FL",
                rating: 4.8, symbol: "sparkles", minutes: 60, price: 1,
                hours: OpeningHours(opensAtHour: 9, closesAtHour: 16, closedWeekdays: [1, 7]),
                tip: "Reservations are encouraged — it's intentionally low-traffic and peaceful."
            )
        ]
    )
}
