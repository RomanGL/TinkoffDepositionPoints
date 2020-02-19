//
//  DepositionPartner.swift
//  TinkoffApi
//
//  Created by r.gladkikh on 18.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

public struct DepositionPartner: Decodable {
    public let id: String
    public let externalPartnerId: String
    
    public let name: String
    public let picture: String
    public let url: String
    
    public let hasLocations: Bool
    public let isMomentary: Bool
    
    public let depositionDuration: String
    public let limitations: String
    public let description: String
}
