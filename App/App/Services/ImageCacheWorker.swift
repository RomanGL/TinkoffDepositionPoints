//
//  ImageCacheWorker.swift
//  App
//
//  Created by r.gladkikh on 10.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import CoreData
import AppData
import UIKit

final class ImageCacheWorker {
    private let queue: DispatchQueue
    private let context: NSManagedObjectContext
    private let point: MapDepositionPoint
    private let workerCompletion: (String, UIImage?) -> Void
    
    init(point: MapDepositionPoint, completion: @escaping (String, UIImage?) -> Void) {
        self.point = point
        self.workerCompletion = completion
        self.context = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        self.queue = DispatchQueue(label: "com.romangl.tdp.ImageCacheWorker.\(point.previewImage)", attributes: .concurrent)
    }
    
    func start() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            self.obtainCachedIcon(completion: self.checkCached(cachedIcon:))
        }
    }
}

// MARK:- Lifecycle
private extension ImageCacheWorker {
    
    func checkCached(cachedIcon: CachedIconEntity?) {
        guard let cachedIcon = cachedIcon else {
            load(cachedIcon: nil)
            return
        }
        
        obtainLastModified() { [weak self] lastModified in
            self?.compareLastModified(cachedIcon: cachedIcon, lastModified: lastModified)
        }
    }
    
    func compareLastModified(cachedIcon: CachedIconEntity, lastModified: String?) {
        if cachedIcon.lastModified == lastModified {
            if let data = cachedIcon.data {
                if let image = UIImage(data: data) {
                    debugPrint("Found in cache \(self.imageName)")
                    
                    self.workerCompletion(self.imageName, image)
                    return
                }
            }
        }
        
        // Reload image
        load(cachedIcon: cachedIcon)
    }
    
    func load(cachedIcon: CachedIconEntity?) {
        debugPrint("Loading \(imageName)")
        
        obtainImageData() { [weak self] data, lastModified in
            guard let self = self else { return }
            
            if let data = data {
                if let image = UIImage(data: data) {
                    self.context.performAndWait { [weak self] in
                        guard let self = self else { return }
                        
                        if let cachedIcon = cachedIcon {
                            // Update existent CachedIconEntity
                            cachedIcon.data = data
                            cachedIcon.lastModified = lastModified
                        } else {
                            // Create new CachedIconEntity
                            _ = CachedIconEntity(id: self.imageName, lastModified: lastModified, data: data, context: self.context)
                        }
                        
                        try? self.context.save()
                    }
                    
                    // Success
                    self.workerCompletion(self.imageName, image)
                }
            } else {
                // Failed
                self.workerCompletion(self.imageName, nil)
            }
            
            debugPrint("Completed \(self.imageName)")
        }
    }
}

// MARK:- Obtain Data
private extension ImageCacheWorker {
    
    func obtainCachedIcon(completion: @escaping (CachedIconEntity?) -> Void) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let cachedIcon = CachedIconEntity.getBy(id: self.imageName, from: self.context)
            self.queue.async {
                completion(cachedIcon)
            }
        }
    }
    
    func obtainLastModified(completion: @escaping (String?) -> Void) {
        var request = URLRequest(url: imageUrl)
        request.httpMethod = "HEAD"
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, _ in
            guard let self = self else { return }
            
            let httpResponse = response as? HTTPURLResponse
            let lastModified = httpResponse?.value(forHTTPHeaderField: "Last-Modified")
            
            self.queue.async {
                completion(lastModified)
            }
        }.resume()
    }
    
    func obtainImageData(completion: @escaping (Data?, String?) -> Void) {
        URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, _ in
            guard let self = self else { return }
            
            let httpResponse = response as? HTTPURLResponse
            let lastModified = httpResponse?.value(forHTTPHeaderField: "Last-Modified")
            
            self.queue.async {
                completion(data, lastModified)
            }
        }.resume()
    }
}

// MARK:- Common Properties
private extension ImageCacheWorker {
    
    var imageName: String {
        return point.previewImage
    }
    
    var imageUrl: URL {
        let urlString = "https://static.tinkoff.ru/icons/deposition-partners-v3/mdpi/\(imageName)"
        let url = URL(string: urlString)
        
        return url!
    }
}

// MARK:- Hashable
extension ImageCacheWorker: Hashable {
    
    static func == (lhs: ImageCacheWorker, rhs: ImageCacheWorker) -> Bool {
        return lhs.imageName == rhs.imageName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.imageName)
    }
}
