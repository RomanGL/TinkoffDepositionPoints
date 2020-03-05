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
    
    override func viewDidLoad() {
        mapView.register(MapPointMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        checkLocationAuthorizationStatus()
        
        let location = locationManager.location ?? MapViewController.defaultLocation
        
        centerMapOn(coordinate: location.coordinate, withRadius: MapViewController.defaultViewRadius)
        loadPoints(around: location.coordinate, withRadius: MapViewController.defaultViewRadius)
        
        let managedContext = CoreDataStack.shared.persistentContainer.viewContext
        let result = try? managedContext.fetch(CachedIcon.fetchRequest())
    }
    
    @IBAction func geoButtonAction(_ sender: Any) {
        guard let location = locationManager.location else { return }
        
        let radius = mapView.currentRadius()
        centerMapOn(coordinate: location.coordinate, withRadius: radius)
    }
    
    @IBAction func zoomInAction(_ sender: Any) {
        let radius = mapView.currentRadius()
        let coordinate = mapView.centerCoordinate;
        
        centerMapOn(coordinate: coordinate, withRadius: radius / 2)
    }
    
    @IBAction func zoomOutAction(_ sender: Any) {
        let radius = mapView.currentRadius()
        let coordinate = mapView.centerCoordinate
        
        centerMapOn(coordinate: coordinate, withRadius: radius * 2)
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
}

// MARK: - Data Loading
private extension MapViewController {
    private func loadPoints(around coordinate: CLLocationCoordinate2D, withRadius radius: CLLocationDistance) {
        let radius = Int(mapView.currentRadius())
        DepositionPointsService.shared.obtainPoints(latitude: coordinate.latitude,
                                                    longitude: coordinate.longitude,
                                                    radius: radius)
        { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let points):
                self.handlePoints(points)
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alertController = UIAlertController(title: "An error occured",
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
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
    private func centerMapOn(coordinate: CLLocationCoordinate2D, withRadius radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate,
                                                       latitudinalMeters: radius,
                                                       longitudinalMeters: radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        mapView.showsUserLocation = true
    }
}
