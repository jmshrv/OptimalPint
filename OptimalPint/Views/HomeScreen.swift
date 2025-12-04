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
        VenueMap(venues: [])
            .sheet(isPresented: .constant(true)) {
                LoadingStateHandler(loadingState: venueState) { venues in
                    VenueList(venues: venues)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
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
}
