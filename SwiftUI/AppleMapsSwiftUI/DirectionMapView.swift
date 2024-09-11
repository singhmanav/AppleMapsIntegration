//
//  DirectionMapView.swift
//  AppleMapsSwiftUI
//
//  Created by Manav Prakash on 10/09/24.
//
import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct DirectionsMapView: UIViewRepresentable {
  @ObservedObject var viewModel: MapViewModel
  let mapView = MKMapView()
  
  func makeUIView(context: Context) -> MKMapView {
    mapView.delegate = context.coordinator
    mapView.showsUserLocation = true
    mapView.isZoomEnabled = true
    mapView.isUserInteractionEnabled = false
    
    context.coordinator.mapView = mapView
    context.coordinator.setupTimer()
    
    context.coordinator.addAnnotations()
    context.coordinator.calculateDirections()
    
    return mapView
  }
  
  func updateUIView(_ uiView: MKMapView, context: Context) {
    // No need to update the view here since we handle updates in the Coordinator
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self, mapView: mapView)
  }
  
  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: DirectionsMapView
    var mapView: MKMapView
    var timer: Timer?
    var isFirstTime: Bool = true
    var polyline: MKPolyline?
    
    init(_ parent: DirectionsMapView, mapView: MKMapView) {
      self.parent = parent
      self.mapView = mapView
    }
    
    func setupTimer() {
      timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
        self.updateStartLocation()
        self.updateAnnotations()
        self.checkIfArrived()
        self.calculateDirections()
      }
    }
    
    func addAnnotations() {
      let startAnnotation = MKPointAnnotation()
      startAnnotation.coordinate = parent.viewModel.startCoordinate
      startAnnotation.title = "Start"
      
      let endAnnotation = MKPointAnnotation()
      endAnnotation.coordinate = parent.viewModel.destinationCoordinate
      endAnnotation.title = "End"
      
      mapView.addAnnotations([startAnnotation, endAnnotation])
    }
    
    func calculateDirections() {
      let sourcePlacemark = MKPlacemark(coordinate: parent.viewModel.startCoordinate)
      let destinationPlacemark = MKPlacemark(coordinate: parent.viewModel.destinationCoordinate)
      
      let request = MKDirections.Request()
      request.source = MKMapItem(placemark: sourcePlacemark)
      request.destination = MKMapItem(placemark: destinationPlacemark)
      request.transportType = .automobile
      
      let directions = MKDirections(request: request)
      directions.calculate { response, error in
        guard let response = response else {
          print("Error calculating directions: \(error?.localizedDescription ?? "Unknown error")")
          return
        }
        
        self.mapView.removeOverlays(self.mapView.overlays)
        
        for route in response.routes {
          self.polyline = route.polyline
          self.mapView.addOverlay(route.polyline, level: .aboveLabels)
          let rect = route.polyline.boundingMapRect
          if self.isFirstTime {
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 20, bottom: 20, right: 20), animated: false)
            self.isFirstTime.toggle()
          }
        }
      }
    }
    
    func updateStartLocation() {
      parent.viewModel.startCoordinate = (self.polyline?.coordinates[1])!
    }
    
    func updateAnnotations() {
      for annotation in mapView.annotations {
        if let pointAnnotation = annotation as? MKPointAnnotation {
          if pointAnnotation.title == "Start" {
            pointAnnotation.coordinate = parent.viewModel.startCoordinate
          }
        }
      }
    }
    
    func checkIfArrived() {
      let startCoordinate = parent.viewModel.startCoordinate
      let endCoordinate = parent.viewModel.destinationCoordinate
      
      let distance = MKMapPoint(startCoordinate).distance(to: MKMapPoint(endCoordinate))
      if distance < 10 {
        timer?.invalidate()
      }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      if let polyline = overlay as? MKPolyline {
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 5
        return renderer
      }
      return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      if annotation is MKUserLocation {
        return nil // Default view for user location
      }
      
      let identifier = "CustomAnnotation"
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
      
      if annotationView == nil {
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.canShowCallout = true
      } else {
        annotationView?.annotation = annotation
      }
      
      if let title = annotation.title {
        switch title {
          case "Start":
            annotationView?.image = resizeImage(image: UIImage(named: "start"), targetSize: CGSize(width: 30, height: 30))
          case "End":
            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
                    circleView.backgroundColor = .red
                    circleView.layer.cornerRadius = 7
            circleView.layer.borderColor = UIColor.white.cgColor
            circleView.layer.borderWidth = 2
                    circleView.layer.masksToBounds = true
                    annotationView?.frame = circleView.frame
                    annotationView?.addSubview(circleView)
          default:
            annotationView?.image = resizeImage(image: UIImage(named: "default"), targetSize: CGSize(width: 30, height: 30))
        }
      }
      
      return annotationView
    }
    
    private func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
      guard let image = image else { return nil }
      
      let size = image.size
      
      let widthRatio  = targetSize.width  / size.width
      let heightRatio = targetSize.height / size.height
      
      let scaleFactor = min(widthRatio, heightRatio)
      
      let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
      
      UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
      image.draw(in: CGRect(origin: .zero, size: newSize))
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return newImage
    }
  }
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        let count = self.pointCount
        var coords = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: count)
        self.getCoordinates(&coords, range: NSRange(location: 0, length: count))
        return coords
    }
}
