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

final class MapViewController: UIViewController {
    /// Location of Moscow
    private static let defaultLocation = CLLocation(latitude: 55.751244, longitude: 37.618423)
    private static let defaultViewRadius: CLLocationDistance = 1000 // Meters
    
    @IBOutlet weak var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private let pointsService = DepositionPointsService.shared
    
    override func viewDidLoad() {
        locationManager.delegate = self
        mapView.register(MapPointMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        checkLocationAuthorizationStatus()
        
        let location = locationManager.location ?? MapViewController.defaultLocation
        mapView.centerMapOn(coordinate: location.coordinate, withRadius: MapViewController.defaultViewRadius)
    }
    
    @IBAction func geoButtonAction(_ sender: Any) {
        centerMapOnGeolocation()
    }
    
    @IBAction func zoomInAction(_ sender: Any) {
        mapView.zoomIn()
    }
    
    @IBAction func zoomOutAction(_ sender: Any) {
        mapView.zoomOut()
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
        
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) {
            view.annotation = annotation
            return view
        } else {
            let markerView = MKMarkerAnnotationView(annotation: annotation,
                                                    reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            markerView.canShowCallout = true
            markerView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            return markerView
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotationView = view as? MapPointMarkerView else { return }
        
        annotationView.loadImage()
    }
}

// MARK:- CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}

// MARK: - Data Loading
private extension MapViewController {
    
    private func loadPoints(around coordinate: CLLocationCoordinate2D, withRadius radius: CLLocationDistance) {
        let radius = Int(mapView.currentRadius())
        let lat = coordinate.latitude
        let lon = coordinate.longitude
        
        pointsService.obtainPoints(latitude: lat, longitude: lon, radius: radius) { [weak self] points in
            guard let self = self else { return }
            guard let points = points else {
                self.showLoadingError()
                return
            }
            
            self.handlePoints(points)
        }
    }
    
    private func showLoadingError() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alertController = UIAlertController(title: "An error occurred",
                                                    message: "We are sorry, an error occurred during loading deposition points.",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "Very sad", style: .default, handler: nil)
            alertController.addAction(action)
            
            self.present(alertController, animated: true)
        }
    }
    
    private func handlePoints(_ points: [MapDepositionPoint]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(points)
        }
    }
}

// MARK: - Utils
private extension MapViewController {
    
    func centerMapOnGeolocation() {
        guard let location = locationManager.location else { return }
        
        mapView.centerMapOn(coordinate: location.coordinate, withRadius: MapViewController.defaultViewRadius)
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        mapView.showsUserLocation = true
    }
}
