//
//  PlaceDetailView.swift
//  Roamly
//
//  Rich detail for a single place: visual, story, practical info and a map.
//

import SwiftUI
import MapKit

struct PlaceDetailView: View {
    @EnvironmentObject private var env: AppEnvironment
    let place: Place

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RoamlySpacing.md) {
                PlaceVisual(place: place, height: 200, cornerRadius: RoamlyRadius.lg)
                    .overlay(alignment: .bottomLeading) {
                        ratingBadge
                            .padding(RoamlySpacing.sm)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text(place.categoryLabel)
                        .roamlyOverline()
                        .foregroundStyle(RoamlyColor.accentOrange)
                    Text(place.name)
                        .font(RoamlyFont.title)
                        .foregroundStyle(RoamlyColor.textPrimary)
                    Text(place.whyItMatters)
                        .font(RoamlyFont.body)
                        .foregroundStyle(RoamlyColor.textSecondary)
                }

                intentionTags

                RoamlyCard {
                    Text(place.description)
                        .font(RoamlyFont.body)
                        .foregroundStyle(RoamlyColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                infoCard

                if let tip = place.insiderTip {
                    InsiderTipView(text: tip)
                }

                if let food = place.foodRecommendation {
                    RoamlyCard {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Eat nearby").roamlyOverline()
                                Text(food)
                                    .font(RoamlyFont.callout)
                                    .foregroundStyle(RoamlyColor.textPrimary)
                            }
                        } icon: {
                            Image(systemName: "fork.knife")
                                .foregroundStyle(RoamlyColor.accentOrange)
                        }
                    }
                }

                miniMap

                RoamlyButton(title: "Open in Apple Maps", systemImage: "map.fill", kind: .accent) {
                    env.mapService.openInAppleMaps(place: place)
                }
                Color.clear.frame(height: RoamlySpacing.lg)
            }
            .padding(.horizontal, RoamlySpacing.screenInset)
            .padding(.top, RoamlySpacing.sm)
        }
        .background(RoamlyColor.background.ignoresSafeArea())
        .navigationTitle(place.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var ratingBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill").font(.system(size: 12))
                .foregroundStyle(RoamlyColor.warning)
            Text(String(format: "%.1f", place.rating))
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
            if place.isIconic {
                Text("· Iconic")
                    .font(RoamlyFont.caption)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(.vertical, 6).padding(.horizontal, 10)
        .background(.black.opacity(0.45), in: Capsule())
    }

    private var intentionTags: some View {
        FlowLayout(spacing: 6) {
            ForEach(place.intentions) { intention in
                RoamlyTagChip(title: intention.title, systemImage: intention.symbol, tint: intention.tint)
            }
        }
    }

    private var infoCard: some View {
        RoamlyCard {
            VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
                infoRow("mappin.and.ellipse", "Address", place.address)
                Divider()
                infoRow("clock", "Hours", place.openingHours?.displayString ?? "Open access / varies")
                Divider()
                infoRow("hourglass", "Suggested visit", "~\(place.suggestedMinutes) minutes")
                if let price = place.priceTier {
                    Divider()
                    infoRow("creditcard", "Price", priceText(price))
                }
            }
        }
    }

    private func infoRow(_ symbol: String, _ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: RoamlySpacing.sm) {
            Image(systemName: symbol)
                .font(.system(size: 15))
                .foregroundStyle(RoamlyColor.primaryBlue)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 1) {
                Text(label).roamlyOverline()
                Text(value)
                    .font(RoamlyFont.callout)
                    .foregroundStyle(RoamlyColor.textPrimary)
            }
            Spacer()
        }
    }

    private func priceText(_ tier: Int) -> String {
        tier == 0 ? "Free" : String(repeating: "$", count: min(tier, 4))
    }

    private var miniMap: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: place.coordinate.clCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))) {
            Marker(place.name, coordinate: place.coordinate.clCoordinate)
                .tint(RoamlyColor.accentOrange)
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous))
        .allowsHitTesting(false)
    }
}
