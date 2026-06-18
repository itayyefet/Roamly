//
//  SampleData+Copenhagen.swift
//  Roamly
//

import Foundation

extension SampleData {
    static let copenhagen = City(
        id: "copenhagen",
        name: "Copenhagen",
        country: "Denmark",
        countryFlag: "🇩🇰",
        center: Coordinate(latitude: 55.6761, longitude: 12.5683),
        neighborhoods: [
            Neighborhood(name: "Indre By", center: Coordinate(latitude: 55.6800, longitude: 12.5790)),
            Neighborhood(name: "Nyhavn", center: Coordinate(latitude: 55.6797, longitude: 12.5913)),
            Neighborhood(name: "Vesterbro", center: Coordinate(latitude: 55.6680, longitude: 12.5520)),
            Neighborhood(name: "Christianshavn", center: Coordinate(latitude: 55.6736, longitude: 12.5960))
        ],
        places: [
            place(
                id: "cph-nyhavn",
                name: "Nyhavn",
                intentions: [.architecture, .photography, .foodie, .localClassics],
                lat: 55.6797, lon: 12.5913,
                category: "Historic Waterfront",
                why: "The candy-colored canal houses that are the postcard of Copenhagen.",
                description: "Once a rowdy sailors' harbor, Nyhavn's 17th-century townhouses, wooden ships and canal-side cafés are now the city's most photographed and convivial spot.",
                address: "Nyhavn, 1051 Copenhagen",
                rating: 4.7, symbol: "building.2.fill", minutes: 40,
                tip: "Grab a canal-boat tour from here — it's the prettiest way to see the city.",
                food: "Pick up smørrebrød (open-faced sandwiches) from a quayside spot.",
                iconic: true
            ),
            place(
                id: "cph-tivoli",
                name: "Tivoli Gardens",
                intentions: [.familyFriendly, .localClassics, .photography, .natureParks],
                lat: 55.6736, lon: 12.5681,
                category: "Historic Amusement Garden",
                why: "One of the world's oldest amusement parks — and an inspiration for Disneyland.",
                description: "Opened in 1843, Tivoli blends vintage rides, lush gardens, illuminations and concerts into pure fairy-tale charm in the heart of the city.",
                address: "Vesterbrogade 3, Copenhagen",
                rating: 4.7, symbol: "sparkles", minutes: 120, price: 2,
                hours: OpeningHours(opensAtHour: 11, closesAtHour: 23, closedWeekdays: []),
                tip: "It's magical after dark when thousands of lights switch on.",
                iconic: true
            ),
            place(
                id: "cph-little-mermaid",
                name: "The Little Mermaid",
                intentions: [.localClassics, .photography, .history],
                lat: 55.6929, lon: 12.5993,
                category: "Iconic Statue",
                why: "Copenhagen's beloved bronze tribute to Hans Christian Andersen's tale.",
                description: "Perched on a rock at the Langelinie promenade since 1913, this small but world-famous statue is a must-tick on any first visit.",
                address: "Langelinie, Copenhagen",
                rating: 4.2, symbol: "figure.wave", minutes: 20,
                hours: OpeningHours.alwaysOpen,
                tip: "Pair it with a stroll through the nearby Kastellet star fortress.",
                iconic: true
            ),
            place(
                id: "cph-rosenborg",
                name: "Rosenborg Castle",
                intentions: [.history, .architecture, .artCulture],
                lat: 55.6857, lon: 12.5775,
                category: "Renaissance Castle",
                why: "A fairy-tale royal castle housing the Danish Crown Jewels.",
                description: "Built by Christian IV in the 1600s, Rosenborg's turrets, royal interiors and treasury of crown regalia sit within the leafy King's Garden.",
                address: "Øster Voldgade 4A, Copenhagen",
                rating: 4.7, symbol: "building.columns.fill", minutes: 75, price: 2,
                hours: OpeningHours(opensAtHour: 10, closesAtHour: 16, closedWeekdays: [2])
            ),
            place(
                id: "cph-smk",
                name: "SMK – National Gallery of Denmark",
                intentions: [.artCulture, .familyFriendly, .architecture],
                lat: 55.6889, lon: 12.5786,
                category: "National Art Museum",
                why: "Denmark's largest art museum, from old masters to bold modern works.",
                description: "SMK spans 700 years of European and Danish art in grand galleries, with a light-filled modern wing and a relaxed sculpture-lined café.",
                address: "Sølvgade 48-50, Copenhagen",
                rating: 4.6, symbol: "paintpalette.fill", minutes: 80,
                hours: OpeningHours(opensAtHour: 10, closesAtHour: 18, closedWeekdays: [2])
            ),
            place(
                id: "cph-torvehallerne",
                name: "Torvehallerne Market",
                intentions: [.foodie, .shopping, .localClassics],
                lat: 55.6831, lon: 12.5713,
                category: "Gourmet Food Market",
                why: "Two glass halls packed with the best of new Nordic food culture.",
                description: "Over 60 stalls serve fresh produce, smørrebrød, coffee, pastries and global street food — a delicious crash course in how Copenhagen eats.",
                address: "Frederiksborggade 21, Copenhagen",
                rating: 4.6, symbol: "fork.knife", minutes: 50, price: 2,
                hours: OpeningHours(opensAtHour: 10, closesAtHour: 19, closedWeekdays: []),
                food: "Try the porridge at Grød or a classic herring smørrebrød."
            ),
            place(
                id: "cph-christiania",
                name: "Freetown Christiania",
                intentions: [.hiddenGems, .artCulture, .nightlife],
                lat: 55.6770, lon: 12.5960,
                category: "Alternative Arts Community",
                why: "A self-governing, car-free creative enclave unlike anywhere else.",
                description: "Founded in 1971, Christiania is a leafy warren of murals, workshops, music venues and homemade architecture — countercultural Copenhagen at its rawest.",
                address: "Christiania, 1440 Copenhagen",
                rating: 4.3, symbol: "sparkles", minutes: 45,
                tip: "Respect the local rule: no photos in certain areas — watch for the signs."
            ),
            place(
                id: "cph-kings-garden",
                name: "Kongens Have (King's Garden)",
                intentions: [.natureParks, .familyFriendly, .photography],
                lat: 55.6855, lon: 12.5800,
                category: "Royal Garden Park",
                why: "Copenhagen's oldest park and the locals' favorite picnic lawn.",
                description: "Laid out in the 1600s around Rosenborg Castle, these manicured lawns, rose gardens and tree-lined avenues are made for a relaxed Danish 'hygge' afternoon.",
                address: "Øster Voldgade 4A, Copenhagen",
                rating: 4.7, symbol: "leaf.fill", minutes: 35,
                hours: OpeningHours(opensAtHour: 7, closesAtHour: 22, closedWeekdays: [])
            ),
            place(
                id: "cph-parken",
                name: "Parken Stadium",
                intentions: [.sports],
                lat: 55.7029, lon: 12.5726,
                category: "National Football Stadium",
                why: "Home of F.C. København and the Danish national team.",
                description: "Catch a match or concert at Denmark's largest stadium, where the red-and-white 'Roligans' create one of football's friendliest atmospheres.",
                address: "Per Henrik Lings Allé 2, Copenhagen",
                rating: 4.5, symbol: "sportscourt.fill", minutes: 120, price: 2
            )
        ]
    )
}
