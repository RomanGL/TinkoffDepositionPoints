//
//  DepositionPartnerEntity.swift
//  AppData
//
//  Created by r.gladkikh on 06.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import CoreData
import TinkoffApi

@objc(DepositionPartnerEntity)
public class DepositionPartnerEntity: NSManagedObject {
    
    public convenience init(id: String,
                            name: String,
                            picture: String,
                            url: String,
                            context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.id = id
        self.name = name
        self.picture = picture
        self.url = url
    }
    
    public convenience init(from partner: DepositionPartner, context: NSManagedObjectContext) {
        self.init(id: partner.id, name: partner.name, picture: partner.picture, url: partner.url, context: context)
    }
}

// MARK:- Utils
extension DepositionPartnerEntity {
    static func getAll(from context: NSManagedObjectContext) -> [DepositionPartnerEntity] {
        let request: NSFetchRequest<DepositionPartnerEntity> = DepositionPartnerEntity.fetchRequest()
        let result = try? context.fetch(request)
        
        return result ?? []
    }
}
