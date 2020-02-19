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
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        centerMapOn(location: MapViewController.defaultLocation)
        loadData()
    }
    
    private func loadData() {
        DepositionPointsService.shared.getPoints(latitude: MapViewController.defaultLocation.coordinate.latitude,
                                                 longitude: MapViewController.defaultLocation.coordinate.longitude,
                                                 radius: Int(MapViewController.defaultViewRadius))
        
        DepositionApi.shared.getDepositionPoints(latitude: MapViewController.defaultLocation.coordinate.latitude,
                                                 longitude: MapViewController.defaultLocation.coordinate.longitude,
                                                 radius: Int(MapViewController.defaultViewRadius))
        { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let points):
                    self?.handlePoints(points)
                    
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func handlePoints(_ points: [DepositionPoint]) {
        mapView.removeAnnotations(mapView.annotations)
        
        let mapPoints = points.map { point in MapDepositionPoint(point) }
        mapView.addAnnotations(mapPoints)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let radius = Int(mapView.currentRadius())
        
        DepositionApi.shared.getDepositionPoints(latitude: mapView.centerCoordinate.latitude,
                                                 longitude: mapView.centerCoordinate.longitude,
                                                 radius: radius)
        { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let points):
                    self?.handlePoints(points)
                    
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
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
    private func centerMapOn(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,
                                                       latitudinalMeters: MapViewController.defaultViewRadius,
                                                       longitudinalMeters: MapViewController.defaultViewRadius)
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
