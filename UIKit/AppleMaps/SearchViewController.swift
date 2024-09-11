//
//  SearchViewController.swift
//  AppleMaps
//
//  Created by Manav Prakash on 04/09/24.
//

import UIKit
import MapKit

class SearchResultsController: UITableViewController {
    
    var mapView: MKMapView?
    var places: [MKMapItem] = []
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        cell.detailTextLabel?.text = place.placemark.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = places[indexPath.row]
        mapView?.setRegion(MKCoordinateRegion(center: selectedPlace.placemark.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}
