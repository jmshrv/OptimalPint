//
//  VenueList.swift
//  OptimalPint
//
//  Created by James Harvey on 04/12/2025.
//

import Catcher
import CoreLocation
import SwiftUI

struct VenueList: View {
    @Environment(CatchScope.self) private var scope
    
    @State private var location: CLLocation?
    @State private var searchTerm = ""
    @State private var venues: [Venue]
    
    init(venues: [Venue]) {
        _venues = State(initialValue: venues)
    }
    
    var body: some View {
        List(listContent) { venue in
            NavigationLink(value: Route.venue(venue)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(venue.name)
                        Text(venue.address.town)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if let location {
                        Text(
                            Measurement(
                                value: venue.address.location.cl.distance(from: location),
                                unit: UnitLength.meters
                            )
                            .formatted(.measurement(width: .abbreviated, usage: .road))
                        )
                    }
                }
            }
        }
        .navigationTitle("Pubs")
        .searchable(text: $searchTerm)
        .task {
            await scope.withCatchScopeAsync { @MainActor in
                for try await update in CLLocationUpdate.liveUpdates() {
                    location = update.location
                    
                    guard let location else { continue }
                    
                    venues.sort { a, b in
                        a.address.location.cl.distance(from: location) < b.address.location.cl.distance(from: location)
                    }
                }
            }
        }
    }
    
    private var listContent: [Venue] {
        if searchTerm.isEmpty {
            return venues
        }
        
        let trimmedSearchTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)

        return
            venues
            .filter {
                $0.name.localizedStandardContains(trimmedSearchTerm)
                    || $0.address.town.localizedStandardContains(trimmedSearchTerm)
            }
            .sorted { $0.name < $1.name }
    }
}

#Preview {
    VenueList(venues: Venue.mock)
        .withCatcher()
}
