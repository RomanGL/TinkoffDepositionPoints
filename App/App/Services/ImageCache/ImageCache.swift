//
//  ImageCache.swift
//  App
//
//  Created by r.gladkikh on 27.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import UIKit

final class ImageCache {
    private let cache = NSCache<NSString, NSData>()
    
    private let concurrentQueue = OperationQueue()
    private let serialQueue = OperationQueue()
    
    static let shared = ImageCache()
    
    private init() {
        serialQueue.maxConcurrentOperationCount = 1
    }
    
    public func obtainImage(_ point: MapDepositionPoint, completion: @escaping (UIImage?) -> Void) {
        let checkCache = BlockOperation { [weak self, weak point] in
            guard let self = self else { return }
            guard let point = point else { return }
            
            self.checkCache(point, completion: completion)
        }
        
        serialQueue.addOperation(checkCache)
    }
    
    private func checkCache(_ point: MapDepositionPoint, completion: @escaping (UIImage?) -> Void) {
        let key = NSString(string: point.previewImage)
        let urlString = "https://static.tinkoff.ru/icons/deposition-partners-v3/mdpi/\(point.previewImage)"
        let url = URL(string: urlString)!
        
        if let cachedData = self.cache.object(forKey: key) {
            let headRequest = HttpRequestOperation(with: url, method: .head)
            let imageLoad = ImageLoadOperation(data: cachedData as Data)
            
            let handle = BlockOperation { [unowned headRequest, unowned imageLoad, unowned point] in
                let response = headRequest.response
                let image = imageLoad.output
                
                if let lastModified = response?.value(forHTTPHeaderField: "Last-Modified") {
                    // TODO: Check Last-Modified
                    print("\(point.previewImage): \(lastModified)")
                    completion(image)
                } else {
                    completion(image)
                }
            }
            
            handle.addDependency(headRequest)
            handle.addDependency(imageLoad)
            
            concurrentQueue.addOperations([headRequest, imageLoad, handle], waitUntilFinished: false)
        } else {
            let requestData = HttpRequestOperation(with: url)
            let imageLoad = ImageLoadOperation(data: nil)
            
            let handleData = BlockOperation { [unowned requestData, unowned imageLoad] in
                imageLoad.input = requestData.data
            }
            let handleImage = BlockOperation { [unowned imageLoad, unowned point] in
                if let image = imageLoad.output,
                    let data = imageLoad.input {
                    
                    print("Save \(point.previewImage)")
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.cache.setObject(data as NSData, forKey: key)
                    }
                    
                    completion(image)
                }
                
                completion(nil)
            }
            
            handleData.addDependency(requestData)
            imageLoad.addDependency(handleData)
            handleImage.addDependency(imageLoad)
            
            serialQueue.addOperation(handleImage)
            concurrentQueue.addOperations([requestData, imageLoad, handleData], waitUntilFinished: false)
        }
    }
    
    private func handleDataFromNetwork(_ data: Data?, point: MapDepositionPoint, completion: @escaping (UIImage?) -> Void) {
        
    }
    
    private func handleImageFromCache(_ image: UIImage?, point: MapDepositionPoint, completion: @escaping (UIImage?) -> Void) {
        if let image = image {
            completion(image)
            return
        }
        
        let removeFromCache = BlockOperation { [weak self] in
            self?.cache.removeObject(forKey: NSString(string: point.previewImage))
        }
        let startLoad = BlockOperation {
            print("startLoad") // TODO
        }
        
        startLoad.addDependency(removeFromCache)
        
        serialQueue.addOperations([removeFromCache, startLoad], waitUntilFinished: false)
    }
}
