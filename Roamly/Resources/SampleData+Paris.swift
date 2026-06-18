//
//  SampleData+Paris.swift
//  Roamly
//

import Foundation

extension SampleData {
    static let paris = City(
        id: "paris",
        name: "Paris",
        country: "France",
        countryFlag: "🇫🇷",
        center: Coordinate(latitude: 48.8566, longitude: 2.3522),
        neighborhoods: [
            Neighborhood(name: "Le Marais", center: Coordinate(latitude: 48.8590, longitude: 2.3620)),
            Neighborhood(name: "Montmartre", center: Coordinate(latitude: 48.8867, longitude: 2.3431)),
            Neighborhood(name: "Latin Quarter", center: Coordinate(latitude: 48.8499, longitude: 2.3470)),
            Neighborhood(name: "Saint-Germain", center: Coordinate(latitude: 48.8540, longitude: 2.3340))
        ],
        places: [
            place(
                id: "par-eiffel",
                name: "Eiffel Tower",
                intentions: [.architecture, .photography, .localClassics, .history],
                lat: 48.8584, lon: 2.2945,
                category: "Iron Lattice Tower",
                why: "The defining symbol of Paris — and the view from the top is unforgettable.",
                description: "Built for the 1889 World's Fair, Gustave Eiffel's tower soars 330m over the city. Ascend for panoramic views or admire it sparkling on the hour after dark.",
                address: "Champ de Mars, Paris",
                rating: 4.7, symbol: "building.2.fill", minutes: 90, price: 2,
                hours: OpeningHours(opensAtHour: 9, closesAtHour: 24, closedWeekdays: []),
                tip: "Watch it from Trocadéro across the river — best photo, no ticket needed.",
                iconic: true
            ),
            place(
                id: "par-louvre",
                name: "The Louvre",
                intentions: [.artCulture, .history, .architecture, .familyFriendly],
                lat: 48.8606, lon: 2.3376,
                category: "World's Largest Art Museum",
                why: "Home to the Mona Lisa and 35,000 works across millennia.",
                description: "From ancient antiquities to Renaissance masterpieces beneath I.M. Pei's glass pyramid, the Louvre is impossibly vast — pick a wing and savor it.",
                address: "Rue de Rivoli, Paris",
                rating: 4.7, symbol: "paintpalette.fill", minutes: 120, price: 2,
                hours: OpeningHours(opensAtHour: 9, closesAtHour: 18, closedWeekdays: [3]),
                tip: "Enter via the Carrousel mall entrance to skip the pyramid queue.",
                iconic: true
            ),
            place(
                id: "par-notredame",
                name: "Notre-Dame & Île de la Cité",
                intentions: [.religiousHeritage, .architecture, .history, .photography],
                lat: 48.8530, lon: 2.3499,
                category: "Gothic Cathedral",
                why: "A masterpiece of Gothic architecture on the historic island heart of Paris.",
                description: "Even mid-restoration, Notre-Dame's flying buttresses and rose windows are spellbinding. The surrounding island is the medieval birthplace of the city.",
                address: "Île de la Cité, Paris",
                rating: 4.7, symbol: "building.columns.fill", minutes: 45,
                tip: "Cross to the Left Bank for the classic facade-and-river photo.",
                iconic: true
            ),
            place(
                id: "par-montmartre",
                name: "Montmartre & Sacré-Cœur",
                intentions: [.artCulture, .photography, .religiousHeritage, .localClassics],
                lat: 48.8867, lon: 2.3431,
                category: "Historic Artists' Hilltop",
                why: "Cobbled lanes, a white-domed basilica and the best free view of Paris.",
                description: "Once home to Picasso and Dalí, this hilltop village still buzzes with painters in the Place du Tertre and rewards the climb with a sweeping city panorama.",
                address: "Montmartre, 18th arr., Paris",
                rating: 4.6, symbol: "paintpalette.fill", minutes: 70,
                tip: "Take the funicular up to save your legs, then wander down the back streets."
            ),
            place(
                id: "par-marais-food",
                name: "Le Marais Food Trail",
                intentions: [.foodie, .shopping, .hiddenGems, .localClassics],
                lat: 48.8590, lon: 2.3620,
                category: "Historic Food & Shopping Quarter",
                why: "Falafel, fromageries and boutiques in Paris's most stylish old quarter.",
                description: "The Marais blends medieval mansions with vibrant Jewish bakeries, cheese shops, vintage boutiques and the famous falafel of Rue des Rosiers.",
                address: "Le Marais, 4th arr., Paris",
                rating: 4.6, symbol: "fork.knife", minutes: 60,
                food: "L'As du Fallafel on Rue des Rosiers — worth the line."
            ),
            place(
                id: "par-luxembourg",
                name: "Jardin du Luxembourg",
                intentions: [.natureParks, .familyFriendly, .photography],
                lat: 48.8462, lon: 2.3372,
                category: "Formal Palace Garden",
                why: "Parisians' favorite garden — tree-lined paths and a toy-sailboat pond.",
                description: "Elegant gravel paths, statues and green metal chairs around a central fountain make this the perfect spot to rest like a true Parisian.",
                address: "6th arr., Paris",
                rating: 4.7, symbol: "leaf.fill", minutes: 40,
                hours: OpeningHours(opensAtHour: 8, closesAtHour: 20, closedWeekdays: [])
            ),
            place(
                id: "par-parc-princes",
                name: "Parc des Princes",
                intentions: [.sports],
                lat: 48.8414, lon: 2.2530,
                category: "Football Stadium",
                why: "Home of Paris Saint-Germain and a temple of French football.",
                description: "Catch a PSG match for star power and electric atmosphere in this iconic 48,000-seat stadium in the west of the city.",
                address: "24 Rue du Commandant Guilbaud, Paris",
                rating: 4.5, symbol: "sportscourt.fill", minutes: 120, price: 2
            ),
            place(
                id: "par-promenade",
                name: "Promenade Plantée",
                intentions: [.hiddenGems, .natureParks, .architecture],
                lat: 48.8494, lon: 2.3770,
                category: "Hidden Elevated Garden Walk",
                why: "The world's first elevated park — and the one that inspired NYC's High Line.",
                description: "This leafy 4.7km walkway runs atop a former railway viaduct through the 12th arrondissement, a serene green secret most tourists never find.",
                address: "Coulée verte René-Dumont, Paris",
                rating: 4.6, symbol: "sparkles", minutes: 45,
                hours: OpeningHours(opensAtHour: 8, closesAtHour: 21, closedWeekdays: []),
                tip: "Start near Bastille and stroll east toward Bois de Vincennes."
            )
        ]
    )
}
