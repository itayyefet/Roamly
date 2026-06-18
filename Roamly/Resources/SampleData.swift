//
//  SampleData.swift
//  Roamly
//
//  The hand-authored sample catalog powering the MVP. Cities live in their own
//  files (SampleData+Miami.swift, etc.) and are aggregated here.
//
//  TODO: This entire catalog is replaced by live data once a provider is wired
//  into `PlacesDataProviding`. The shape of `Place`/`City` mirrors what those
//  APIs return so the migration is mechanical.
//

import Foundation

enum SampleData {

    /// All cities shipped with the MVP.
    static var cities: [City] {
        [
            miami,
            rome,
            newYork,
            paris,
            london
        ]
    }

    /// The city used in demo mode / Simulator when no real location exists.
    static var demoCity: City { miami }

    // MARK: - Place builder
    /// Convenience builder so city files stay readable. Defaults cover the
    /// common case (no price tier, always-ish open, no tip/food, not iconic).
    static func place(
        id: String,
        name: String,
        intentions: [Intention],
        lat: Double,
        lon: Double,
        category: String,
        why: String,
        description: String,
        address: String,
        rating: Double,
        symbol: String,
        minutes: Int,
        price: Int? = nil,
        hours: OpeningHours? = nil,
        tip: String? = nil,
        food: String? = nil,
        iconic: Bool = false
    ) -> Place {
        Place(
            id: id,
            name: name,
            intentions: intentions,
            coordinate: Coordinate(latitude: lat, longitude: lon),
            categoryLabel: category,
            whyItMatters: why,
            description: description,
            address: address,
            rating: rating,
            priceTier: price,
            symbol: symbol,
            suggestedMinutes: minutes,
            openingHours: hours,
            insiderTip: tip,
            foodRecommendation: food,
            isIconic: iconic
        )
    }
}
