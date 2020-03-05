//
//  DatabaseService.swift
//  App
//
//  Created by r.gladkikh on 05.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import UIKit
import Foundation
import CoreData

final class DatabaseService {
    private let persistentContainer: NSPersistentContainer
    
    let shared = DatabaseService()
    
    private init() {
        persistentContainer = CoreDataStack.shared.persistentContainer
    }
}
