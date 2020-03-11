//
//  DepositionPartnersCache.swift
//  App
//
//  Created by r.gladkikh on 10.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import TinkoffApi
import AppData
import CoreData

final class DepositionPartnersCache {
    private let queue: DispatchQueue
    private let depositionApi: DepositionApi
    private let context: NSManagedObjectContext
    
    private var isRunning: Bool = false
    private var completions: [([DepositionPartnerEntity]?) -> Void] = []
    
    static let shared = DepositionPartnersCache()
    
    private init() {
        self.queue = DispatchQueue(label: "com.romangl.tdp.DepositionPartnersCache", qos: .userInitiated)
        self.depositionApi = DepositionApi.shared
        self.context = CoreDataStack.shared.persistentContainer.newBackgroundContext()
    }
    
    func obtainPartners(completion: @escaping ([DepositionPartnerEntity]?) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            self.completions.append(completion)
            
            if self.isRunning {
                return
            }
            
            self.isRunning = true
            self.obtainCachedPartners() { [weak self] cachedPartners in
                guard let self = self else { return }
                
                if cachedPartners != nil {
                    self.finishExecuting(partners: cachedPartners)
                    return
                }
                
                self.obtainApiPartners() { apiPartners in
                    self.finishExecuting(partners: apiPartners)
                }
            }
        }
    }
}

// MARK:- Lifecycle
private extension DepositionPartnersCache {
    
    func finishExecuting(partners: [DepositionPartnerEntity]?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            for completion in self.completions {
                completion(partners)
            }
            
            self.completions = []
            self.isRunning = false
        }
    }
    
    func obtainCachedPartners(completion: @escaping ([DepositionPartnerEntity]?) -> Void) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let cachedPartners = DepositionPartnerEntity.getAll(from: self.context)
            if cachedPartners.count > 0 {
                debugPrint("Using cached partners")
                completion(cachedPartners)
                return
            }
            
            completion(nil)
        }
    }
    
    func obtainApiPartners(completion: @escaping ([DepositionPartnerEntity]?) -> Void) {
        depositionApi.obtainPartners() { [weak self] payload in
            guard let self = self else { return }
            
            if case .success(let partners) = payload {
                self.savePartners(partners: partners, completion: completion)
                return
            }
            
            debugPrint("Partners from API is nil")
            completion(nil)
        }
    }
    
    func savePartners(partners: [DepositionPartner], completion: @escaping ([DepositionPartnerEntity]) -> Void) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            var resultPartners = [DepositionPartnerEntity]()
            for partner in partners {
                let entity = DepositionPartnerEntity(from: partner, context: self.context)
                resultPartners.append(entity)
            }
            
            try? self.context.save()
            
            self.queue.async {
                debugPrint("Using API partners")
                completion(resultPartners)
            }
        }
    }
}

