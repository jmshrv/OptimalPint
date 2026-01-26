//
//  VenueMap.swift
//  OptimalPint
//
//  Created by James Harvey on 29/11/2025.
//

import MapKit
import SwiftUI

struct VenueMap: View {
    let venues: [Venue]
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var locationManager = CLLocationManager()
    @State private var selectedVenue: Venue?
    
    var body: some View {
        Map(position: $position, selection: $selectedVenue) {
            ForEach(venues) { venue in
                UserAnnotation()
                
                Marker(
                    venue.name,
                    systemImage: "wineglass", // damn you sf symbols for not having a pint
                    coordinate: venue.address.location.cl.coordinate
                )
                .tint(.blue)
                .tag(venue)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .sheet(item: $selectedVenue) { venue in
            NavigationStack {
                DrinksView(venue: venue)
            }
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
}

#Preview {
    VenueMap(venues: Venue.mock)
}
