//
//  MapDepositionPoint.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 18.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import MapKit

final class MapDepositionPoint: NSObject {
    private let point: DepositionPoint
    
    init(_ point: DepositionPoint) {
        self.point = point
    }
}

// MARK: - MKAnnotation
extension MapDepositionPoint: MKAnnotation {
    var title: String? {
        return point.partnerName
    }
    
    var subtitle: String? {
        return point.fullAddress
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: point.location.latitude,
                                      longitude: point.location.longitude)
    }
}
