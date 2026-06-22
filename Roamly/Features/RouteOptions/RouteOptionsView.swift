//
//  RouteOptionsView.swift
//  Roamly
//
//  Presents the three generated route options for the chosen intention & time.
//

import SwiftUI

@MainActor
final class RouteOptionsViewModel: ObservableObject {
    enum State {
        case loading
        case loaded([Route])
        case failed(String)
    }

    @Published private(set) var state: State = .loading

    func generate(query: RouteQuery, engine: RouteGenerationService) async {
        state = .loading
        do {
            // A tiny delay makes the generation feel intentional & premium.
            try? await Task.sleep(nanoseconds: 450_000_000)
            let routes = try await engine.generateRoutes(for: query.makeRequest())
            if routes.isEmpty {
                state = .failed(RouteGenerationError.noMatchingPlaces.localizedDescription)
            } else {
                state = .loaded(routes)
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

struct RouteOptionsView: View {
    @EnvironmentObject private var env: AppEnvironment
    let query: RouteQuery
    @Binding var path: [AppRoute]

    @StateObject private var vm = RouteOptionsViewModel()

    var body: some View {
        Group {
            switch vm.state {
            case .loading:
                LoadingStateView(message: "Crafting routes through \(query.city.name)…")
            case .failed(let message):
                ErrorStateView(
                    title: "No route just yet",
                    message: message
                ) {
                    Task { await vm.generate(query: query, engine: env.routeEngine) }
                }
            case .loaded(let routes):
                content(routes)
            }
        }
        .background(RoamlyColor.background.ignoresSafeArea())
        .navigationTitle("Your Routes")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if case .loading = vm.state {
                await vm.generate(query: query, engine: env.routeEngine)
            }
        }
    }

    private func content(_ routes: [Route]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RoamlySpacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: query.intention.symbol)
                            .foregroundStyle(query.intention.tint)
                        Text(query.intention == .surpriseMe ? "Surprise route" : query.intention.title)
                            .font(RoamlyFont.subheadline)
                            .foregroundStyle(RoamlyColor.textPrimary)
                    }
                    Text("\(query.duration.title) in \(query.city.name) · pick the route that fits your mood.")
                        .font(RoamlyFont.callout)
                        .foregroundStyle(RoamlyColor.textSecondary)
                }
                .padding(.top, RoamlySpacing.xs)

                ForEach(routes) { route in
                    RouteCardView(route: route) {
                        path.append(.routeDetail(route))
                    }
                }
            }
            .padding(.horizontal, RoamlySpacing.screenInset)
            .padding(.bottom, RoamlySpacing.lg)
        }
    }
}
