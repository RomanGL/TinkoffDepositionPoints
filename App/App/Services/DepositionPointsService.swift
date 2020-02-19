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

final class DepositionPointsService {
    private let depositionApi = DepositionApi.shared
    private var partners: [DepositionPartner]?
    
    static let shared = DepositionPointsService()
    
    private init() {}
    
    /// Возвращает кэшированную коллекцию партнеров или делает сетевой запрос для их получения.
    /// - Parameter completion: Вызывается по готовности результата.
    func getPartners(completion: @escaping PartnersCompletion) {
        if let partners = partners {
            completion(.success(partners))
            return
        }
        
        depositionApi.getDepositionPartners() { [weak self] payload in
            switch payload {
            case .success(let receivedPartners):
                self?.partners = receivedPartners
                completion(.success(receivedPartners))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getPoints(latitude: Double, longitude: Double, radius: Int) {
        let group = DispatchGroup()
        
        group.enter()
        depositionApi.getDepositionPartners() { payload in
            group.leave()
        }
        
        group.enter()
        depositionApi.getDepositionPoints(latitude: latitude, longitude: longitude, radius: radius)
        { payload in
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.global(qos: .utility)) {
            print("Loaded")
        }
    }
}
