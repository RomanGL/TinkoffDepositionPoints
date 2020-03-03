//
//  ImageCache.swift
//  App
//
//  Created by r.gladkikh on 27.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import UIKit

typealias ImageHandler = (UIImage?) -> Void

final class ImageCache {
    private let cache = NSCache<NSString, NSData>()
    private let concurrentQueue = OperationQueue()
    private let serialQueue = OperationQueue()
    
    private var completions: [String: [ImageHandler]] = [:]
    
    static let shared = ImageCache()
    
    private init() {
        serialQueue.maxConcurrentOperationCount = 1
    }
    
    public func obtainImage(_ point: MapDepositionPoint, completion: @escaping ImageHandler) {
        serialQueue.addOperation { [unowned self] in
            let key = point.previewImage
            if let waitingCompletions = self.completions[key] {
                print("Waiting \(point.previewImage)")
                self.completions[key] = waitingCompletions + [completion]
                return
            }
            
            print("Starting \(point.previewImage)")
            self.completions[key] = [completion]
            self.checkCache(point)
        }
    }
    
    private func checkCache(_ point: MapDepositionPoint) {
        concurrentQueue.addOperation { [unowned self] in
            let cacheKey = NSString(string: point.previewImage)
            
            if let cachedData = self.cache.object(forKey: cacheKey) {
                print("In cache \(point.previewImage)")
                self.handleFromCache(cachedData as Data, point: point)
            } else {
                print("Not in cache \(point.previewImage)")
                self.reloadImage(point)
            }
        }
    }
    
    private func handleFromCache(_ data: Data, point: MapDepositionPoint) {
        let url = getImageUrl(for: point)
        
        let headRequest = HttpRequestOperation(with: url, method: .head)
        let imageLoad = ImageLoadOperation(data: data)
        
        let handler = BlockOperation { [unowned self, unowned headRequest, unowned imageLoad] in
            guard let image = imageLoad.output else {
                print("Corrupted cache \(point.previewImage)")
                self.reloadImage(point)
                return
            }
            
            guard let lastModified = headRequest.response?.value(forHTTPHeaderField: "Last-Modified") else {
                print("Failed Last-Modified \(point.previewImage)")
                self.raiseCompletions(image, point: point)
                return
            }
            
//            if lastModified != "TODO: Core Data" {
//                self.reloadImage(point)
//                return
//            }
            
            self.raiseCompletions(image, point: point)
        }
        
        handler.addDependency(headRequest)
        handler.addDependency(imageLoad)
        
        concurrentQueue.addOperations([headRequest, imageLoad, handler], waitUntilFinished: false)
    }
    
    private func reloadImage(_ point: MapDepositionPoint) {
        let url = getImageUrl(for: point)
        
        let request = HttpRequestOperation(with: url)
        let imageLoad = ImageLoadOperation(data: nil)
        
        // Pass the data to the imageLoad operation.
        let dataHandler = BlockOperation { [unowned self, unowned request, unowned imageLoad] in
            print("Request completed \(point.previewImage)")
            imageLoad.input = request.data
        }
        
        // Handle the response and the image.
        let totalHandler = BlockOperation { [unowned self, unowned request, unowned imageLoad] in
            guard let image = imageLoad.output else {
                print("Corrupted network \(point.previewImage)")
                self.raiseCompletions(nil, point: point)
                return
            }
            
            guard let lastModified = request.response?.value(forHTTPHeaderField: "Last-Modified") else {
                print("Failed reload Last-Modified \(point.previewImage)")
                self.raiseCompletions(image, point: point)
                return
            }
            
            print("Saving to cache \(point.previewImage)")
            let data = request.data!
            // TODO: Save Last-Modified to Core Data
            let cacheOperation = BlockOperation { [unowned self] in
                self.cache.setObject(data as NSData, forKey: NSString(string: point.previewImage))
            }
            
            let raiseOperation = BlockOperation { [unowned self] in
                self.raiseCompletions(image, point: point)
            }
            
            raiseOperation.addDependency(cacheOperation)
            
            OperationQueue.main.addOperation(cacheOperation)
            self.concurrentQueue.addOperation(raiseOperation)
        }
        
        dataHandler.addDependency(request)
        imageLoad.addDependency(dataHandler)
        
        totalHandler.addDependency(request)
        totalHandler.addDependency(imageLoad)
        
        concurrentQueue.addOperations([request, dataHandler, imageLoad, totalHandler], waitUntilFinished: false)
    }
    
    private func raiseCompletions(_ image: UIImage?, point: MapDepositionPoint) {
        serialQueue.addOperation { [unowned self] in
            print("Completion \(point.previewImage)")
            let key = point.previewImage
            
            if let waitingCompletions = self.completions.removeValue(forKey: key) {
                for completion in waitingCompletions {
                    completion(image)
                }
            }
        }
    }
    
    private func getImageUrl(for point: MapDepositionPoint) -> URL {
        let urlString = "https://static.tinkoff.ru/icons/deposition-partners-v3/mdpi/\(point.previewImage)"
        let url = URL(string: urlString)
        
        return url!
    }
}
