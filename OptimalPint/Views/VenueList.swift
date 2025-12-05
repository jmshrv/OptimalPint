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
    @State private var venues: [Venue]
    
    init(venues: [Venue]) {
        _venues = State(initialValue: venues)
    }
    
    var body: some View {
        List(venues) { venue in
            NavigationLink(value: venue) {
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
}

#Preview {
    VenueList(venues: Venue.mock)
        .withCatcher()
}
