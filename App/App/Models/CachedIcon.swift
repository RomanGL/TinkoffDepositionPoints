//
//  CachedIcon.swift
//  App
//
//  Created by r.gladkikh on 04.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import CoreData

@objc(CachedIcon)
public class CachedIcon: NSManagedObject {
    
}

// MARK:- Fetch Requests
public extension CachedIcon {
    static func imageNameFetchRequest(imageName: String) -> NSFetchRequest<CachedIcon> {
        let request: NSFetchRequest<CachedIcon> = CachedIcon.fetchRequest()
        request.predicate = NSPredicate(format: "imageName == %@", imageName)
        
        return request
    }
}

// MARK:- Utils
extension CachedIcon {
    static func add(imageName: String, lastModified: String, context: NSManagedObjectContext) -> CachedIcon {
        let entity = CachedIcon(context: context)
        entity.imageName = imageName
        entity.lastModified = lastModified
        
        return entity
    }
    
    static func getBy(imageName: String, context: NSManagedObjectContext) -> CachedIcon? {
        let fetchRequest = CachedIcon.imageNameFetchRequest(imageName: imageName)
        let result = try? context.fetch(fetchRequest)
        
        return result?.first
    }
}
