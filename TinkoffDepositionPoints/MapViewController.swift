//
//  MapViewController.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 14.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    /// Location of Moscow
    private static let defaultLocation = CLLocation(latitude: 55.751244, longitude: 37.618423)
    private static let defaultViewRadius: CLLocationDistance = 1000 // Meters
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        centerMapOn(location: MapViewController.defaultLocation)
    }
}

// MARK: - Helpers
private extension MapViewController {
    private func centerMapOn(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,
                                                       latitudinalMeters: MapViewController.defaultViewRadius,
                                                       longitudinalMeters: MapViewController.defaultViewRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
