//
//  ContentView.swift
//  AppleMapsSwiftUI
//
//  Created by Manav Prakash on 10/09/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = MapViewModel(
        startCoordinate: CLLocationCoordinate2D(latitude: 28.457768, longitude: 77.055287),
        destinationCoordinate: CLLocationCoordinate2D(latitude: 28.470871, longitude: 77.048795)
    )
    
    var body: some View {
        ScrollView {
            DirectionsMapView(viewModel: viewModel)
                .frame(height: 200)
        }
    }
}
