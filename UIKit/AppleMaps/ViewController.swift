//
//  ViewController.swift
//  AppleMaps
//
//  Created by Manav Prakash on 04/09/24.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize and add the map view
        mapView = MKMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // To support rotation
        self.view.addSubview(mapView)
        
        // Draw the route on the map
        showRouteOnMap()
    }
    
    func showRouteOnMap() {
        // Define source and destination coordinates
        let sourceCoordinate = CLLocationCoordinate2D(latitude: 28.457768, longitude: 77.055287)
        let destinationCoordinate = CLLocationCoordinate2D(latitude: 28.470871, longitude: 77.048795)
        
      let startAnnotation = MKPointAnnotation()
              startAnnotation.coordinate = sourceCoordinate
              startAnnotation.title = "Start"
              startAnnotation.subtitle = "Home"
              
              let endAnnotation = MKPointAnnotation()
              endAnnotation.coordinate = destinationCoordinate
              endAnnotation.title = "End"
              endAnnotation.subtitle = "Office"
              
              // Add the annotations to the map
              mapView.addAnnotations([startAnnotation, endAnnotation])
        // Create placemarks for source and destination
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        // Create map items
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        // Create a request for directions
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceItem
        directionsRequest.destination = destinationItem
        directionsRequest.transportType = .automobile
        
        // Calculate the directions
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { response, error in
            guard let response = response, let route = response.routes.first else {
                print("Error calculating directions: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Add route overlay to the map
            self.mapView.addOverlay(route.polyline)
          let edgePadding = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)
          self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: edgePadding, animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate method to render the route
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .orange
            renderer.lineWidth = 2.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
