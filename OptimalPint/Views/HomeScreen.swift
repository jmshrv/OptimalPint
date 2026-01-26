//
//  HomeScreen.swift
//  OptimalPint
//
//  Created by James Harvey on 04/12/2025.
//

import ErrorKit
import SwiftUI

struct HomeScreen: View {
    @State private var venueState = LoadingState<[Venue]>.initial

    var body: some View {
        NavigationStack {
            LoadingStateHandler(loadingState: venueState) { venues in
                VenueList(venues: venues)
                    .toolbar {
                        ToolbarItem {
                            NavigationLink(value: Route.map(venues)) {
                                Label("Map", systemImage: "map")
                            }
                        }
                    }
            }
            .navigationDestination(for: Route.self, destination: { route in
                switch route {
                case .map(let venues):
                    VenueMap(venues: venues)
                case .venue(let venue):
                    DrinksView(venue: venue)
                }
            })
        }
        .task {
            do {
                venueState = .loaded(try await SpoonsClient.venues())
            } catch {
                venueState = .error(error)
            }
        }
    }

    var venuesOrEmpty: [Venue] {
        if case .loaded(let venues) = venueState { venues } else { [] }
    }
}
