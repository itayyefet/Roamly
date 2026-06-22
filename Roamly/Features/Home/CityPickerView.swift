//
//  CityPickerView.swift
//  Roamly
//
//  Manual city-selection fallback (used when location is denied/unavailable or
//  the user simply wants to explore another city).
//

import SwiftUI

struct CityPickerView: View {
    @EnvironmentObject private var env: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    let onSelect: (City) -> Void
    @State private var cities: [City] = []

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(cities) { city in
                        Button {
                            onSelect(city)
                            dismiss()
                        } label: {
                            HStack(spacing: RoamlySpacing.sm) {
                                Text(city.countryFlag)
                                    .font(.system(size: 28))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(city.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(RoamlyColor.textPrimary)
                                    Text("\(city.country) · \(city.places.count) spots")
                                        .font(RoamlyFont.caption)
                                        .foregroundStyle(RoamlyColor.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(RoamlyColor.textSecondary)
                            }
                        }
                    }
                } header: {
                    Text("Choose a city to explore")
                } footer: {
                    Text("Roamly ships with curated guides for these cities. More are added over time.")
                }
            }
            .navigationTitle("Pick a City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                cities = await env.dataService.allCities()
            }
        }
    }
}
