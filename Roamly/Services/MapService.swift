//
//  MapService.swift
//  Roamly
//
//  MapKit helpers: region framing, opening Apple Maps for turn-by-turn
//  navigation, and walking-route polyline calculation.
//

import Foundation
import MapKit

final class MapService {

    /// A map region that comfortably frames all the given coordinates.
    func region(forCoordinates coordinates: [Coordinate],
                paddingFactor: Double = 1.4,
                fallbackCenter: Coordinate) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: fallbackCenter.clCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)
        let minLat = lats.min()!, maxLat = lats.max()!
        let minLon = lons.min()!, maxLon = lons.max()!
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.01, (maxLat - minLat) * paddingFactor),
            longitudeDelta: max(0.01, (maxLon - minLon) * paddingFactor)
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    /// Opens Apple Maps with walking directions to a place.
    func openInAppleMaps(place: Place) {
        let placemark = MKPlacemark(coordinate: place.coordinate.clCoordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = place.name
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }

    /// Opens Apple Maps with a multi-stop walking itinerary.
    func openItineraryInAppleMaps(stops: [RouteStop]) {
        let items = stops.map { stop -> MKMapItem in
            let placemark = MKPlacemark(coordinate: stop.place.coordinate.clCoordinate)
            let item = MKMapItem(placemark: placemark)
            item.name = stop.place.name
            return item
        }
        guard !items.isEmpty else { return }
        MKMapItem.openMaps(with: items, launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }

    /// Requests an actual walking polyline between consecutive stops.
    ///
    /// Falls back to straight line segments if directions are unavailable
    /// (e.g. offline). Returns the ordered coordinates that form the path.
    ///
    /// TODO: Cache results and respect rate limits when used heavily.
    func walkingPolyline(through coordinates: [Coordinate]) async -> [CLLocationCoordinate2D] {
        guard coordinates.count >= 2 else { return coordinates.map(\.clCoordinate) }
        var path: [CLLocationCoordinate2D] = [coordinates[0].clCoordinate]
        for i in 0..<(coordinates.count - 1) {
            let segment = await walkingSegment(from: coordinates[i], to: coordinates[i + 1])
            path.append(contentsOf: segment.dropFirst())
        }
        return path
    }

    private func walkingSegment(from: Coordinate, to: Coordinate) async -> [CLLocationCoordinate2D] {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from.clCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to.clCoordinate))
        request.transportType = .walking
        do {
            let response = try await MKDirections(request: request).calculate()
            if let route = response.routes.first {
                return route.polyline.coordinates
            }
        } catch {
            // Offline / no route — fall back to a straight segment.
        }
        return [from.clCoordinate, to.clCoordinate]
    }
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](
            repeating: kCLLocationCoordinate2DInvalid,
            count: pointCount
        )
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}
