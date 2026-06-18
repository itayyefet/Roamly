//
//  SampleData+London.swift
//  Roamly
//

import Foundation

extension SampleData {
    static let london = City(
        id: "london",
        name: "London",
        country: "UK",
        countryFlag: "🇬🇧",
        center: Coordinate(latitude: 51.5074, longitude: -0.1278),
        neighborhoods: [
            Neighborhood(name: "Westminster", center: Coordinate(latitude: 51.4995, longitude: -0.1248)),
            Neighborhood(name: "South Bank", center: Coordinate(latitude: 51.5066, longitude: -0.1148)),
            Neighborhood(name: "Shoreditch", center: Coordinate(latitude: 51.5265, longitude: -0.0779)),
            Neighborhood(name: "Covent Garden", center: Coordinate(latitude: 51.5117, longitude: -0.1240))
        ],
        places: [
            place(
                id: "lon-westminster",
                name: "Westminster & Big Ben",
                intentions: [.architecture, .history, .photography, .localClassics],
                lat: 51.4995, lon: -0.1248,
                category: "Gothic Parliament & Clock Tower",
                why: "The postcard heart of London — Parliament, Big Ben and the Thames.",
                description: "The neo-Gothic Houses of Parliament and the chimes of Big Ben define the London skyline. Cross Westminster Bridge for the classic view.",
                address: "Westminster, London SW1A",
                rating: 4.7, symbol: "building.columns.fill", minutes: 40,
                tip: "Best photo is from the South Bank end of Westminster Bridge.",
                iconic: true
            ),
            place(
                id: "lon-british-museum",
                name: "The British Museum",
                intentions: [.history, .artCulture, .familyFriendly, .architecture],
                lat: 51.5194, lon: -0.1270,
                category: "Museum of World History",
                why: "The Rosetta Stone, Egyptian mummies and two million years of history — free.",
                description: "Under a spectacular glass-roofed Great Court, the British Museum holds treasures from every civilization. Admission is free; donations welcome.",
                address: "Great Russell St, London WC1B",
                rating: 4.8, symbol: "building.columns.fill", minutes: 100,
                hours: OpeningHours(opensAtHour: 10, closesAtHour: 17, closedWeekdays: []),
                tip: "Head straight to the Rosetta Stone early — it draws crowds by midday.",
                iconic: true
            ),
            place(
                id: "lon-tower-bridge",
                name: "Tower Bridge & Tower of London",
                intentions: [.history, .architecture, .photography, .familyFriendly],
                lat: 51.5055, lon: -0.0754,
                category: "Historic Bridge & Fortress",
                why: "A 1,000-year-old fortress and the city's most photogenic bridge.",
                description: "See the Crown Jewels at the Tower of London, then watch the Victorian bascules of Tower Bridge — often mistaken for London Bridge — rise over the Thames.",
                address: "Tower Hill, London EC3N",
                rating: 4.7, symbol: "building.2.fill", minutes: 90, price: 2,
                hours: OpeningHours(opensAtHour: 9, closesAtHour: 17, closedWeekdays: []),
                iconic: true
            ),
            place(
                id: "lon-borough-market",
                name: "Borough Market",
                intentions: [.foodie, .localClassics, .familyFriendly],
                lat: 51.5055, lon: -0.0909,
                category: "Historic Food Market",
                why: "London's oldest and most delicious food market, by London Bridge.",
                description: "A thousand years of trading and a paradise of artisan cheese, fresh oysters, sizzling street food and bakeries beneath Victorian rail arches.",
                address: "8 Southwark St, London SE1",
                rating: 4.7, symbol: "fork.knife", minutes: 50, price: 2,
                hours: OpeningHours(opensAtHour: 10, closesAtHour: 17, closedWeekdays: [1]),
                food: "Kappacasein's grilled-cheese toastie is the cult favorite."
            ),
            place(
                id: "lon-hyde-park",
                name: "Hyde Park & Kensington Gardens",
                intentions: [.natureParks, .familyFriendly, .photography],
                lat: 51.5073, lon: -0.1657,
                category: "Royal Park",
                why: "350 acres of royal parkland in the center of the city.",
                description: "Row on the Serpentine, see the Diana Memorial, or catch a soapbox orator at Speakers' Corner in London's most beloved green space.",
                address: "Hyde Park, London W2",
                rating: 4.7, symbol: "leaf.fill", minutes: 60,
                hours: OpeningHours(opensAtHour: 5, closesAtHour: 24, closedWeekdays: [])
            ),
            place(
                id: "lon-tate-modern",
                name: "Tate Modern & South Bank",
                intentions: [.artCulture, .architecture, .photography, .nightlife],
                lat: 51.5076, lon: -0.0994,
                category: "Modern Art Gallery",
                why: "World-class modern art in a former power station on the Thames.",
                description: "Cross the Millennium Bridge to this striking gallery, then stroll the buzzing South Bank with its street performers, bars and river views.",
                address: "Bankside, London SE1",
                rating: 4.6, symbol: "paintpalette.fill", minutes: 80,
                hours: OpeningHours(opensAtHour: 10, closesAtHour: 18, closedWeekdays: []),
                tip: "The free top-floor viewing level has a brilliant panorama of St. Paul's."
            ),
            place(
                id: "lon-wembley",
                name: "Wembley Stadium",
                intentions: [.sports],
                lat: 51.5560, lon: -0.2796,
                category: "National Football Stadium",
                why: "The home of English football and its iconic arch.",
                description: "Catch a match or major concert at this 90,000-seat national stadium, crowned by its unmistakable 134m illuminated arch.",
                address: "London HA9 0WS",
                rating: 4.6, symbol: "sportscourt.fill", minutes: 150, price: 2
            ),
            place(
                id: "lon-leadenhall",
                name: "Leadenhall Market",
                intentions: [.hiddenGems, .architecture, .photography, .shopping],
                lat: 51.5128, lon: -0.0836,
                category: "Hidden Victorian Arcade",
                why: "An ornate covered market that doubled as Diagon Alley on film.",
                description: "Tucked into the City's financial district, this gorgeous 14th-century market's painted ironwork and cobbles feel straight out of another era.",
                address: "Gracechurch St, London EC3V",
                rating: 4.6, symbol: "sparkles", minutes: 30,
                hours: OpeningHours(opensAtHour: 10, closesAtHour: 18, closedWeekdays: [1, 7]),
                tip: "Quietest (and most magical) on a weekend morning when the City sleeps."
            )
        ]
    )
}
