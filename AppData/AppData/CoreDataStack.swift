//
//  CoreDataStack.swift
//  App
//
//  Created by r.gladkikh on 05.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import CoreData

public final class CoreDataStack {
    public static let shared = CoreDataStack()
    
    private init() {}
    
    public lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: type(of: self))
        
        guard let modelUrl = bundle.url(forResource: "AppModel", withExtension: "momd") else {
            fatalError("Failed to find AppModel.momd")
        }
        
        guard let objectModel = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("Failed to create model from file: \(modelUrl)")
        }
        
        let container = NSPersistentContainer(name: "AppData", managedObjectModel: objectModel)
        container.loadPersistentStores() { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
}
