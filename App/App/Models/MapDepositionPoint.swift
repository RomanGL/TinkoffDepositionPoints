//
//  MapDepositionPoint.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 18.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import MapKit
import TinkoffApi
import AppData

final class MapDepositionPoint: NSObject {
    private let point: DepositionPoint
    private let partner: DepositionPartnerEntity
    
    init(_ point: DepositionPoint, partner: DepositionPartnerEntity) {
        self.point = point
        self.partner = partner
    }
}

// MARK: - Properties
extension MapDepositionPoint {
    var previewImage: String { partner.picture ?? "" }
    
    var color: UIColor {
        point.partnerName == "TINKOFF"
            ? UIColor.fromRGBA(red: 255, green: 241, blue: 85)
            : .darkGray
    }
    
    var isHighPriority: Bool { point.partnerName == "TINKOFF" }
    
    var glyph: String { String(partner.name?.first ?? "?") }
}

// MARK: - MKAnnotation
extension MapDepositionPoint: MKAnnotation {
    var title: String? {
        return partner.name
    }
    
    var subtitle: String? {
        return point.fullAddress
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: point.location.latitude,
                                      longitude: point.location.longitude)
    }
}
