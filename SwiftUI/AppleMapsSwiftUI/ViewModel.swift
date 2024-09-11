//
//  ViewModel.swift
//  AppleMapsSwiftUI
//
//  Created by Manav Prakash on 10/09/24.
//

import SwiftUI
import MapKit

class MapViewModel: ObservableObject {
    @Published var startCoordinate: CLLocationCoordinate2D
    let destinationCoordinate: CLLocationCoordinate2D

    init(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        self.startCoordinate = startCoordinate
        self.destinationCoordinate = destinationCoordinate
    }
}
