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
    
    var body: some View {
        Map(position: $position) {
            ForEach(venues) { venue in
                UserAnnotation()
                
                Marker(
                    venue.name,
                    systemImage: "wineglass", // damn you sf symbols for not having a pint
                    coordinate: venue.address.location.cl.coordinate
                )
                .tint(.blue)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
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
