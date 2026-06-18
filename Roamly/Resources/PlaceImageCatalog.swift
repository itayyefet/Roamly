//
//  PlaceImageCatalog.swift
//  Roamly
//
//  Maps sample-catalog place IDs to Wikipedia article titles, which
//  `PlaceImageService` resolves into real photos at runtime. Kept in one place
//  so the place data files stay clean and titles are easy to curate.
//
//  Any title that fails to resolve simply falls back to the styled gradient,
//  so an occasional miss is harmless.
//

enum PlaceImageCatalog {

    /// Returns the best Wikipedia title for a place: an inline override on the
    /// place wins, otherwise the curated mapping below.
    static func title(for place: Place) -> String? {
        place.imageTitle ?? titles[place.id]
    }

    static let titles: [String: String] = [
        // Miami
        "mia-wynwood-walls": "Wynwood Walls",
        "mia-ocean-drive": "Ocean Drive (Miami Beach)",
        "mia-vizcaya": "Villa Vizcaya",
        "mia-calle-ocho": "Little Havana",
        "mia-bayfront-park": "Bayfront Park (Miami)",
        "mia-perez-art": "Pérez Art Museum Miami",
        "mia-marlins-park": "LoanDepot Park",
        "mia-secret-garden": "The Kampong",

        // Rome
        "rom-colosseum": "Colosseum",
        "rom-pantheon": "Pantheon, Rome",
        "rom-trevi": "Trevi Fountain",
        "rom-vatican": "St. Peter's Basilica",
        "rom-trastevere": "Trastevere",
        "rom-borghese": "Villa Borghese gardens",
        "rom-testaccio-market": "Testaccio",
        "rom-stadio-olimpico": "Stadio Olimpico",
        "rom-aventine-keyhole": "Aventine Hill",

        // New York / Manhattan
        "nyc-central-park": "Central Park",
        "nyc-met": "Metropolitan Museum of Art",
        "nyc-highline": "High Line",
        "nyc-brooklyn-bridge": "Brooklyn Bridge",
        "nyc-chelsea-market": "Chelsea Market",
        "nyc-times-square": "Times Square",
        "nyc-yankee": "Yankee Stadium",
        "nyc-whisper-gallery": "Grand Central Terminal",

        // Paris
        "par-eiffel": "Eiffel Tower",
        "par-louvre": "Louvre",
        "par-notredame": "Notre-Dame de Paris",
        "par-montmartre": "Sacré-Cœur, Paris",
        "par-marais-food": "Le Marais",
        "par-luxembourg": "Luxembourg Gardens",
        "par-parc-princes": "Parc des Princes",
        "par-promenade": "Coulée verte René-Dumont",

        // London
        "lon-westminster": "Big Ben",
        "lon-british-museum": "British Museum",
        "lon-tower-bridge": "Tower Bridge",
        "lon-borough-market": "Borough Market",
        "lon-hyde-park": "Hyde Park, London",
        "lon-tate-modern": "Tate Modern",
        "lon-wembley": "Wembley Stadium",
        "lon-leadenhall": "Leadenhall Market",

        // Copenhagen
        "cph-nyhavn": "Nyhavn",
        "cph-tivoli": "Tivoli Gardens",
        "cph-little-mermaid": "The Little Mermaid (statue)",
        "cph-rosenborg": "Rosenborg Castle",
        "cph-smk": "Statens Museum for Kunst",
        "cph-torvehallerne": "Torvehallerne",
        "cph-christiania": "Freetown Christiania",
        "cph-kings-garden": "Kongens Have",
        "cph-parken": "Parken Stadium"
    ]
}
