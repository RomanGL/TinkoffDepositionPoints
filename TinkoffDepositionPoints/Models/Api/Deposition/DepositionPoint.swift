//
//  DepositionPoint.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 14.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

struct DepositionPoint: Decodable {
    let externalId: String
    let partnerName: String
    let workHours: String
    let phones: String
    let fullAddress: String
    
    let location: PointLocation
}
