//
//  DepositionApi.swift
//  TinkoffApi
//
//  Created by r.gladkikh on 19.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

public final class DepositionApi: TinkoffApi {
    public static let shared = DepositionApi()
    
    private override init() {}
}

// MARK: - API Methods
public extension DepositionApi {
    func getDepositionPartners(completion: @escaping Completion<DepositionPartnersPayload>) {
        let endpoint = "deposition_partners?accountType=Credit"
        let url = getUrl(endpoint: endpoint)
        
        getResponse(from: url, completion: completion)
    }
    
    func getDepositionPoints(latitude: Double,
                             longitude: Double,
                             radius: Int,
                             completion: @escaping Completion<DepositionPointsPayload>) {
        let endpoint = "deposition_points?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)"
        let url = getUrl(endpoint: endpoint)
        
        getResponse(from: url, completion: completion)
    }
}
