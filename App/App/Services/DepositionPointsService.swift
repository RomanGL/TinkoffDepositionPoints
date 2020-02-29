//
//  DepositionPointsService.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 19.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import TinkoffApi

typealias PartnersCompletion = (Result<[DepositionPartner], Error>) -> Void
typealias ObtainPointsCompletion = (Result<[MapDepositionPoint], Error>) -> Void

final class DepositionPointsService {
    private let depositionApi = DepositionApi.shared
    private var cachedPartners: [DepositionPartner]?
    
    static let shared = DepositionPointsService()
    
    private init() {}
    
    func obtainPoints(latitude: Double, longitude: Double, radius: Int, completion: @escaping ObtainPointsCompletion) {
        var partnersPayload: DepositionPartnersPayload?
        var pointsPayload: DepositionPointsPayload?
        
        let group = DispatchGroup()
        
        if let cachedPartners = cachedPartners {
            partnersPayload = cachedPartners
        } else {
            group.enter()
            
            depositionApi.obtainPartners() { [weak self] payload in
                if case .success(let partners) = payload {
                    partnersPayload = partners
                    self?.cachedPartners = partners
                }
                
                group.leave()
            }
        }
        
        group.enter()
        
        depositionApi.obtainPoints(latitude: latitude, longitude: longitude, radius: radius)
        { payload in
            if case .success(let points) = payload {
                pointsPayload = points
            }
            
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.global(qos: .utility)) { [weak self] in
            guard let partners = partnersPayload,
                  let points = pointsPayload else {
                    completion(.failure(AppError("At least one request was failed.")))
                    return
            }
            
            let mapPoints = self?.getMapPoints(partners: partners, points: points)
            completion(.success(mapPoints ?? []))
        }
    }
}

private extension DepositionPointsService {
    private func getMapPoints(partners: [DepositionPartner], points: [DepositionPoint]) -> [MapDepositionPoint] {
        return points.map { point in
            let partner = partners.first { $0.id == point.partnerName }
            return partner != nil ? MapDepositionPoint(point, partner: partner!) : nil
        }.compactMap { $0 }
    }
}
