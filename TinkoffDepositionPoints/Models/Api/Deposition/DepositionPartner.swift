//
//  DepositionPartner.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 18.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

struct DepositionPartner: Decodable {
    let id: String
    let externalPartnerId: String
    
    let name: String
    let picture: String
    let url: String
    
    let hasLocations: Bool
    let isMomentary: Bool
    
    let depositionDuration: String
    let limitations: String
    let description: String
}
