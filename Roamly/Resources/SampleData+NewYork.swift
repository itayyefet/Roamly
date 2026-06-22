//
//  SampleData+NewYork.swift
//  Roamly
//

import Foundation

extension SampleData {
    static let newYork = City(
        id: "newyork",
        name: "Manhattan",
        country: "New York",
        countryFlag: "🇺🇸",
        center: Coordinate(latitude: 40.7549, longitude: -73.9840),
        neighborhoods: [
            Neighborhood(name: "Midtown", center: Coordinate(latitude: 40.7549, longitude: -73.9840)),
            Neighborhood(name: "Greenwich Village", center: Coordinate(latitude: 40.7336, longitude: -74.0027)),
            Neighborhood(name: "Lower Manhattan", center: Coordinate(latitude: 40.7075, longitude: -74.0113)),
            Neighborhood(name: "Upper West Side", center: Coordinate(latitude: 40.7870, longitude: -73.9754))
        ],
        places: [
            place(
                id: "nyc-central-park",
                name: "Central Park",
                intentions: [.natureParks, .familyFriendly, .photography, .localClassics],
                lat: 40.7812, lon: -73.9665,
                category: "Iconic Urban Park",
                why: "843 acres of green at the heart of Manhattan — the city's backyard.",
                description: "From the Bethesda Fountain to the Bow Bridge and Strawberry Fields, Central Park offers endless walks, skyline views and a calm escape from the grid.",
                address: "Central Park, Manhattan, NY",
                rating: 4.8, symbol: "leaf.fill", minutes: 75,
                hours: OpeningHours(opensAtHour: 6, closesAtHour: 24, closedWeekdays: []),
                tip: "Enter at 72nd St for the prettiest loop: Bethesda Terrace to the Bow Bridge.",
                iconic: true
            ),
            place(
                id: "nyc-met",
                name: "The Met",
                intentions: [.artCulture, .history, .architecture, .familyFriendly],
                lat: 40.7794, lon: -73.9632,
                category: "Encyclopedic Art Museum",
                why: "One of the world's greatest museums — 5,000 years of art under one roof.",
                description: "The Metropolitan Museum of Art spans Egyptian temples, European masters and a rooftop garden with skyline views. You could spend days and not see it all.",
                address: "1000 5th Ave, New York, NY",
                rating: 4.8, symbol: "paintpalette.fill", minutes: 120, price: 2,
                hours: OpeningHours(opensAtHour: 10, closesAtHour: 17, closedWeekdays: [4]),
                tip: "The rooftop bar (seasonal) has one of the best sunset views in the city.",
                iconic: true
            ),
            place(
                id: "nyc-highline",
                name: "The High Line",
                intentions: [.architecture, .natureParks, .photography, .localClassics],
                lat: 40.7480, lon: -74.0048,
                category: "Elevated Park",
                why: "A railway turned linear park, floating above the West Side.",
                description: "This ingenious elevated greenway weaves through Chelsea with gardens, art installations and unexpected views of the Hudson and the streets below.",
                address: "Gansevoort St to 34th St, NY",
                rating: 4.7, symbol: "building.2.fill", minutes: 50,
                hours: OpeningHours(opensAtHour: 7, closesAtHour: 22, closedWeekdays: []),
                tip: "Start at the Whitney end and walk north toward Hudson Yards.",
                iconic: true
            ),
            place(
                id: "nyc-brooklyn-bridge",
                name: "Brooklyn Bridge",
                intentions: [.architecture, .photography, .history, .localClassics],
                lat: 40.7061, lon: -73.9969,
                category: "Historic Suspension Bridge",
                why: "A 19th-century engineering marvel with unbeatable skyline views.",
                description: "Walk the wooden promenade above the East River for sweeping views of Lower Manhattan and the Statue of Liberty in the distance.",
                address: "Brooklyn Bridge, New York, NY",
                rating: 4.8, symbol: "building.2.fill", minutes: 40,
                hours: OpeningHours.alwaysOpen,
                tip: "Walk Brooklyn-to-Manhattan at golden hour for the skyline lit up ahead of you."
            ),
            place(
                id: "nyc-chelsea-market",
                name: "Chelsea Market",
                intentions: [.foodie, .shopping, .familyFriendly, .localClassics],
                lat: 40.7424, lon: -74.0061,
                category: "Indoor Food Hall",
                why: "A former Nabisco factory packed with the city's best bites under one roof.",
                description: "Lobster rolls, tacos, artisan bakeries and global street food fill this bustling brick-walled market — perfect for grazing your way through lunch.",
                address: "75 9th Ave, New York, NY",
                rating: 4.6, symbol: "fork.knife", minutes: 45, price: 2,
                hours: OpeningHours(opensAtHour: 7, closesAtHour: 21, closedWeekdays: []),
                food: "Los Tacos No.1 and a brownie from Fat Witch — the local one-two punch."
            ),
            place(
                id: "nyc-times-square",
                name: "Times Square",
                intentions: [.nightlife, .photography, .localClassics, .shopping],
                lat: 40.7580, lon: -73.9855,
                category: "Iconic Entertainment Plaza",
                why: "The dazzling, neon-soaked crossroads of the world.",
                description: "Love it or love-to-hate it, the wall-to-wall lights of Times Square are pure NYC spectacle — especially electric after dark.",
                address: "Manhattan, NY 10036",
                rating: 4.4, symbol: "moon.stars.fill", minutes: 30,
                hours: OpeningHours.alwaysOpen
            ),
            place(
                id: "nyc-yankee",
                name: "Yankee Stadium",
                intentions: [.sports, .familyFriendly],
                lat: 40.8296, lon: -73.9262,
                category: "Baseball Stadium",
                why: "The cathedral of baseball and home of the 27-time champion Yankees.",
                description: "Catch a game in the Bronx for hot dogs, history and the roar of one of sport's most storied franchises.",
                address: "1 E 161 St, Bronx, NY",
                rating: 4.7, symbol: "sportscourt.fill", minutes: 150, price: 2
            ),
            place(
                id: "nyc-whisper-gallery",
                name: "Grand Central Whispering Gallery",
                intentions: [.hiddenGems, .architecture, .history],
                lat: 40.7527, lon: -73.9772,
                category: "Architectural Curiosity",
                why: "A hidden acoustic trick beneath the Beaux-Arts ceiling of Grand Central.",
                description: "Stand at opposite corners of the tiled archway outside the Oyster Bar and whisper — your voice carries perfectly across the vault to a friend.",
                address: "Grand Central Terminal, NY",
                rating: 4.6, symbol: "sparkles", minutes: 20,
                hours: OpeningHours(opensAtHour: 7, closesAtHour: 21, closedWeekdays: []),
                tip: "It's just outside the Oyster Bar on the lower level — easy to miss."
            )
        ]
    )
}
