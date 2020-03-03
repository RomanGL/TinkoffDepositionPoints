//
//  MapViewController.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 14.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import UIKit
import MapKit
import TinkoffApi

class MapViewController: UIViewController {
    /// Location of Moscow
    private static let defaultLocation = CLLocation(latitude: 55.751244, longitude: 37.618423)
    private static let defaultViewRadius: CLLocationDistance = 1000 // Meters
    private static let mapAnnotationViewReuseId = "AnnotationViewId"
    
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        mapView.register(MapPointMarkerView.self, forAnnotationViewWithReuseIdentifier: MapViewController.mapAnnotationViewReuseId)
        
        checkLocationAuthorizationStatus()
        
        let location = locationManager.location ?? MapViewController.defaultLocation
        
        centerMapOn(coordinate: location.coordinate, withRadius: MapViewController.defaultViewRadius)
        loadPoints(around: location.coordinate, withRadius: MapViewController.defaultViewRadius)
    }
    
    @IBAction func geoButtonClick(_ sender: Any) {
        guard let location = locationManager.location else { return }
        
        let radius = mapView.currentRadius()
        centerMapOn(coordinate: location.coordinate, withRadius: radius)
    }
    
    private func loadPoints(around coordinate: CLLocationCoordinate2D, withRadius radius: CLLocationDistance) {
        let radius = Int(mapView.currentRadius())
        DepositionPointsService.shared.obtainPoints(latitude: coordinate.latitude,
                                                    longitude: coordinate.longitude,
                                                    radius: radius)
        { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let points):
                    self?.handlePoints(points)
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func handlePoints(_ points: [MapDepositionPoint]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(points)
    }
    
    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        mapView.showsUserLocation = true
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let radius = mapView.currentRadius()
        let currentCoordinate = mapView.centerCoordinate
        
        loadPoints(around: currentCoordinate, withRadius: radius)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapDepositionPoint else { return nil }
        
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: MapViewController.mapAnnotationViewReuseId) {
            view.annotation = annotation
            return view
        } else {
            let markerView = MKMarkerAnnotationView(annotation: annotation,
                                                    reuseIdentifier: MapViewController.mapAnnotationViewReuseId)
            markerView.canShowCallout = true
            markerView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            return markerView
        }
    }
}

// MARK: - Data Loading
private extension MapViewController {
}

// MARK: - Utils
private extension MapViewController {
    private func centerMapOn(coordinate: CLLocationCoordinate2D, withRadius radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate,
                                                       latitudinalMeters: radius,
                                                       longitudinalMeters: radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func handleError(_ error: Error) {
        showErrorAlert(error.localizedDescription)
    }
    
    private func showErrorAlert(_ message: String) {
        let alertController = UIAlertController(title: "An error occured",
                                                message: message,
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
}
