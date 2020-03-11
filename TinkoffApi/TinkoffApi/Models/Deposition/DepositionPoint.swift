//
//  DepositionPoint.swift
//  TinkoffApi
//
//  Created by r.gladkikh on 14.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

public struct DepositionPoint: Decodable {
    public let externalId: String
    public let partnerName: String
    public let fullAddress: String
    public let workHours: String?
    public let phones: String?
    
    public let location: PointLocation
}
