//
//  DepositionPointsServices.swift
//  App
//
//  Created by r.gladkikh on 10.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import TinkoffApi
import AppData

final class DepositionPointsService {
    private let queue: DispatchQueue
    private let depositionApi: DepositionApi
    
    static let shared = DepositionPointsService()
    
    private init() {
        self.queue = DispatchQueue.global(qos: .userInitiated)
        self.depositionApi = DepositionApi.shared
    }
    
    func obtainPoints(latitude: Double,
                      longitude: Double,
                      radius: Int,
                      completion: @escaping ([MapDepositionPoint]?) -> Void) {
        
        var points: [DepositionPoint]? = nil
        var partners: [DepositionPartnerEntity]? = nil
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        depositionApi.obtainPoints(latitude: latitude, longitude: longitude, radius: radius) { result in
            if case .success(let resultPoints) = result {
                points = resultPoints
            }
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        DepositionPartnersCache.shared.obtainPartners() { result in
            partners = result
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: queue) { [weak self] in
            guard let self = self else { return }
            guard let points = points, let partners = partners else {
                completion(nil)
                return
            }
            
            let result = self.mapToModel(partners: partners, points: points)
            completion(result)
        }
    }
}

// MARK:- Utils
private extension DepositionPointsService {
    
    func mapToModel(partners: [DepositionPartnerEntity], points: [DepositionPoint]) -> [MapDepositionPoint] {
        return points.map { point in
            let partner = partners.first { $0.id == point.partnerName }
            return partner != nil ? MapDepositionPoint(point, partner: partner!) : nil
        }.compactMap { $0 }
    }
}
