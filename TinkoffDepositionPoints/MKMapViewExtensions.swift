//
//  MKMapView.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 19.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    /// Возвращает координаты верхней центральной точки области видимости карты.
    func topCenterCoordinate() -> CLLocationCoordinate2D {
        let point = CGPoint(x: self.frame.size.width, y: 0)
        return self.convert(point, toCoordinateFrom: self)
    }
    
    /// Возвращает радиус видимости (от центра до верхней точки) в метрах.
    func currentRadius() -> Double {
        let topCenterCoordinate = self.topCenterCoordinate()
        
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude,
                                           longitude: topCenterCoordinate.longitude)
        let centerLocation = CLLocation(latitude: self.centerCoordinate.latitude,
                                        longitude: self.centerCoordinate.longitude)
        
        return centerLocation.distance(from: topCenterLocation)
    }
}
