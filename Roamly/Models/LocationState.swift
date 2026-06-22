//
//  LocationState.swift
//  Roamly
//
//  Models the location-resolution lifecycle so the UI can react cleanly.
//

import Foundation
import CoreLocation

enum LocationState: Equatable {
    /// Not yet started.
    case idle
    /// Permission not yet requested.
    case notDetermined
    /// Actively resolving coordinates / city.
    case resolving
    /// Successfully resolved a coordinate and a city.
    case resolved(coordinate: Coordinate, city: City)
    /// Permission denied — we fall back to manual selection.
    case denied
    /// Something failed (no GPS, no matching city, etc.).
    case failed(reason: String)

    var resolvedCity: City? {
        if case let .resolved(_, city) = self { return city }
        return nil
    }

    var resolvedCoordinate: Coordinate? {
        if case let .resolved(coordinate, _) = self { return coordinate }
        return nil
    }

    var isResolving: Bool {
        if case .resolving = self { return true }
        return false
    }

    static func == (lhs: LocationState, rhs: LocationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.notDetermined, .notDetermined),
             (.resolving, .resolving), (.denied, .denied):
            return true
        case let (.resolved(c1, city1), .resolved(c2, city2)):
            return c1 == c2 && city1.id == city2.id
        case let (.failed(r1), .failed(r2)):
            return r1 == r2
        default:
            return false
        }
    }
}
