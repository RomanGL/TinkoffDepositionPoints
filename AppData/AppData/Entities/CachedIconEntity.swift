//
//  CachedIconEntity.swift
//  AppData
//
//  Created by r.gladkikh on 04.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import CoreData

@objc(CachedIconEntity)
public class CachedIconEntity: NSManagedObject {
    
    public convenience init(id: String,
                            lastModified: String?,
                            data: Data?,
                            context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.id = id
        self.lastModified = lastModified
        self.data = data
    }
}

// MARK:- Fetch Requests
public extension CachedIconEntity {
    static func idFetchRequest(id: String) -> NSFetchRequest<CachedIconEntity> {
        let request: NSFetchRequest<CachedIconEntity> = CachedIconEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        return request
    }
}

// MARK:- Utils
public extension CachedIconEntity {
    static func getBy(id: String, from context: NSManagedObjectContext) -> CachedIconEntity? {
        let fetchRequest = CachedIconEntity.idFetchRequest(id: id)
        let result = try? context.fetch(fetchRequest)
        
        return result?.first
    }
}
