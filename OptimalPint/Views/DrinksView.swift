//
//  DrinksView.swift
//  OptimalPint
//
//  Created by James Harvey on 05/12/2025.
//

import SwiftUI

struct DrinksView: View {
    let venue: Venue
    
    @State private var drinksState: LoadingState<[Drink]> = .initial
    
    var body: some View {
        LoadingStateHandler(loadingState: drinksState) { drinks in
            DrinksList(drinks: drinks)
        }
        .navigationTitle(Text(venue.name))
        .task {
            do {
                drinksState = .loaded(try await SpoonsClient.drinks(for: venue))
            } catch {
                drinksState = .error(error)
            }
        }
    }
}
