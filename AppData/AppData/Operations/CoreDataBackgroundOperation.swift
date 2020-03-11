//
//  NSManagedObjectContextOperation.swift
//  AppData
//
//  Created by r.gladkikh on 05.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import CoreData
import AppCommon

/// Performs a Core Data operation with a new background managed context.
/// - Important: The operation saving changes automatically.
public final class CoreDataBackgroundOperation: AsyncOperation {
    private let container: NSPersistentContainer?
    private let context: NSManagedObjectContext?
    private let block: (NSManagedObjectContext) -> Void
    
    public init(container: NSPersistentContainer, block: @escaping (NSManagedObjectContext) -> Void) {
        self.container = container
        self.context = nil
        self.block = block
        
        super.init()
    }
    
    public init(context: NSManagedObjectContext, block: @escaping (NSManagedObjectContext) -> Void) {
        self.container = nil
        self.context = context
        self.block = block
        
        super.init()
    }
    
    public override func main() {
        if isCancelled { return }
        guard let taskContext = context ?? container?.newBackgroundContext() else { return }
        
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
                
                if self.context == nil {
                    taskContext.reset()
                }
            }
            
            self.state = .finished
        }
    }
}
