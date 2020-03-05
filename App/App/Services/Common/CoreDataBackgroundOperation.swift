//
//  NSManagedObjectContextOperation.swift
//  App
//
//  Created by r.gladkikh on 05.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import CoreData

/// Performs a Core Data operation with a new background managed context.
/// - Important: The operation saving changes automatically.
public final class CoreDataBackgroundOperation: AsyncOperation {
    private let persistentContainer: NSPersistentContainer
    private let block: (NSManagedObjectContext) -> Void
    
    public init(container persistentContainer: NSPersistentContainer, block: @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer = persistentContainer
        self.block = block
        
        super.init()
    }
    
    public override func main() {
        if isCancelled { return }
        
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.perform { [weak self, unowned taskContext] in
            guard let self = self else { return }
            if self.isCancelled { return }
            
            self.block(taskContext)
            
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch let error {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                
                taskContext.reset()
            }
            
            self.state = .finished
        }
    }
}
