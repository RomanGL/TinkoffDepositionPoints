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
    private let queue = OperationQueue()
    private let cache = NSCache<NSString, NSData>()
    
    static let shared = ImageCache()
    
    private init() {}
    
    public func obtainImage(_ point: MapDepositionPoint, completion: @escaping (UIImage?) -> Void) {
        let urlString = "https://static.tinkoff.ru/icons/deposition-partners-v3/mdpi/\(point.previewImage)"
        let url = URL(string: urlString)!
        
        let obtainLastModified = ObtainHttpHeaderOperation(for: url, header: "Last-Modified")
        let stringOutput = StringOutputOperation() { lastModified in
            print(lastModified ?? "")
        }
        
        stringOutput.addDependency(obtainLastModified)
        
        let obtainData = ObtainDataOperation(url: url)
        let imageLoad = ImageLoadOperation(data: nil)
        let imageOutput = ImageOutputOperation() { completion($0) }
        
        imageLoad.addDependency(obtainData)
        imageOutput.addDependency(imageLoad)
        
        queue.addOperations([obtainLastModified, stringOutput, obtainData, imageLoad, imageOutput], waitUntilFinished: false)
    }
}
