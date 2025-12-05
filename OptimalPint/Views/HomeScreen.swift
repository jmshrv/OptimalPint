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
        VenueMap(venues: venuesOrEmpty)
            .sheet(isPresented: .constant(true)) {
                NavigationStack {
                    LoadingStateHandler(loadingState: venueState) { venues in
                        VenueList(venues: venues)
                    }
                    .navigationDestination(for: Venue.self) { venue in
                        DrinksView(venue: venue)
                    }
                }
                .presentationDetents([.medium, .large, .fraction(0.25)])
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled)
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
        if case let .loaded(venues) = venueState { venues } else { [] }
    }
}
