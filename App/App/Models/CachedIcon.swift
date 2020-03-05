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
    func configure(imageName: String, lastModified: String) {
        self.imageName = imageName
        self.lastModified = lastModified
    }
}
