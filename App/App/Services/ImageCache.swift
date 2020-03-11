//
//  ImageCache.swift
//  App
//
//  Created by r.gladkikh on 10.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import UIKit

final class ImageCache {
    private let queue: DispatchQueue
    private var workers: [String: ImageCacheWorker] = [:]
    private var completions: [ImageCacheWorker: [(UIImage?) -> Void]] = [:]
    
    static let shared = ImageCache()
    
    private init() {
        queue = DispatchQueue(label: "com.romangl.tdp.ImageCache", qos: .userInitiated)
    }
    
    func obtainImage(_ point: MapDepositionPoint, completion: @escaping (UIImage?) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if let worker = self.workers[point.previewImage] {
                let current = self.completions[worker] ?? []
                self.completions[worker] = current + [completion]
                
                return
            }
            
            let worker = ImageCacheWorker(point: point, completion: self.finishWorker(name:image:))
            worker.start()
            
            self.workers[point.previewImage] = worker
            self.completions[worker] = [completion]
        }
    }
    
    private func finishWorker(name: String, image: UIImage?) {
        var waitingCompletions: [(UIImage?) -> Void]?
        
        queue.sync {
            if let worker = workers.removeValue(forKey: name) {
                waitingCompletions = completions.removeValue(forKey: worker)
            }
        }
        
        if let waitingCompletions = waitingCompletions {
            for completion in waitingCompletions {
                completion(image)
            }
        }
    }
}
