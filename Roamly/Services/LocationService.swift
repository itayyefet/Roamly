//
//  LocationService.swift
//  Roamly
//
//  CoreLocation wrapper. Publishes authorization + coordinate updates and
//  supports a demo/simulator mode that supplies a fixed coordinate.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject {

    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var coordinate: Coordinate?
    @Published private(set) var isLocating: Bool = false
    @Published private(set) var lastError: String?

    /// When set, the service returns this coordinate instead of using GPS.
    /// Used for demo mode and the manual city-selection fallback.
    var demoCoordinate: Coordinate?

    private let manager = CLLocationManager()
    private var hasRequestedLocation = false

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    var isDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    /// Requests when-in-use permission. Safe to call repeatedly.
    func requestPermission() {
        guard authorizationStatus == .notDetermined else {
            // Already decided — just try to use what we have.
            if isAuthorized { requestLocation() }
            return
        }
        manager.requestWhenInUseAuthorization()
    }

    /// Requests a one-shot location fix (or returns the demo coordinate).
    func requestLocation() {
        if let demoCoordinate {
            self.coordinate = demoCoordinate
            return
        }
        guard isAuthorized else { return }
        isLocating = true
        lastError = nil
        hasRequestedLocation = true
        manager.requestLocation()
    }

    /// Overrides the active coordinate (manual city selection).
    func overrideCoordinate(_ coordinate: Coordinate) {
        self.coordinate = coordinate
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if self.isAuthorized, self.coordinate == nil {
                self.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.isLocating = false
            self.coordinate = Coordinate(loc.coordinate)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isLocating = false
            self.lastError = error.localizedDescription
        }
    }
}
