//
//  RouteMapView.swift
//  Roamly
//
//  A MapKit map that shows numbered stop pins, the user's location and a route
//  path. Uses the iOS 17 SwiftUI Map APIs.
//

import SwiftUI
import MapKit

struct RouteMapView: View {
    let stops: [RouteStop]
    var userCoordinate: Coordinate?
    /// Optional precomputed walking path; falls back to straight segments.
    var pathCoordinates: [CLLocationCoordinate2D] = []
    var highlightedStopID: String? = nil
    var onSelectStop: ((RouteStop) -> Void)? = nil

    @State private var position: MapCameraPosition = .automatic

    private var linePoints: [CLLocationCoordinate2D] {
        pathCoordinates.isEmpty ? stops.map { $0.place.coordinate.clCoordinate } : pathCoordinates
    }

    var body: some View {
        Map(position: $position) {
            if userCoordinate != nil {
                UserAnnotation()
            }

            if linePoints.count >= 2 {
                MapPolyline(coordinates: linePoints)
                    .stroke(RoamlyColor.primaryBlue, style: StrokeStyle(
                        lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [1, 8]
                    ))
            }

            ForEach(stops) { stop in
                Annotation(stop.place.name, coordinate: stop.place.coordinate.clCoordinate) {
                    StopPin(number: stop.order,
                            isHighlighted: stop.id == highlightedStopID)
                        .onTapGesture { onSelectStop?(stop) }
                }
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
        .onChange(of: highlightedStopID) { _, newValue in
            guard let id = newValue, let stop = stops.first(where: { $0.id == id }) else { return }
            withAnimation {
                position = .region(MKCoordinateRegion(
                    center: stop.place.coordinate.clCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                ))
            }
        }
    }
}

/// A numbered, brand-styled map pin.
struct StopPin: View {
    let number: Int
    var isHighlighted: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(isHighlighted ? RoamlyColor.accentOrange : RoamlyColor.primaryBlue)
                .frame(width: isHighlighted ? 38 : 30, height: isHighlighted ? 38 : 30)
                .overlay(Circle().stroke(.white, lineWidth: 2.5))
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
            Text("\(number)")
                .font(.system(size: isHighlighted ? 16 : 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .animation(.spring(response: 0.3), value: isHighlighted)
    }
}
