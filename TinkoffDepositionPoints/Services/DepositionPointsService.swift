//
//  DepositionPointsService.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 19.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

typealias PartnersCompletion = (Result<[DepositionPartner], Error>) -> Void

final class DepositionPointsService {
    private let apiService: ApiService = ApiService.shared
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
        
        apiService.getDepositionPartners() { [weak self] payload in
            completion(payload)
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
        apiService.getDepositionPartners() { payload in
            group.leave()
        }
        
        group.enter()
        apiService.getDepositionPoints(latitude: latitude, longitude: longitude, radius: radius)
        { payload in
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.global(qos: .utility)) {
            print("Loaded")
        }
    }
}
