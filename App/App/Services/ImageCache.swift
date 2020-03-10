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
        queue = DispatchQueue(label: "com.romangl.tdp.ImageCache", attributes: .concurrent)
    }
    
    func obtainImage(_ point: MapDepositionPoint, completion: @escaping (UIImage?) -> Void) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            debugPrint("Waiting \(point.previewImage)")
            
            if let worker = self.workers[point.previewImage] {
                let current = self.completions[worker] ?? []
                self.completions[worker] = current + [completion]
                
                return
            }
            
            let worker = ImageCacheWorker(point: point, completion: self.finishWorker)
            worker.start()
            
            self.workers[point.previewImage] = worker
            self.completions[worker] = [completion]
        }
    }
    
    private func finishWorker(name: String, image: UIImage?) {
        var completions: [(UIImage?) -> Void]?
        
        queue.sync {
            if let worker = self.workers.removeValue(forKey: name) {
                completions = self.completions.removeValue(forKey: worker)
            }
        }
        
        if let completions = completions {
            for completion in completions {
                completion(image)
                
                debugPrint("Completed \(name)")
            }
        }
    }
}
