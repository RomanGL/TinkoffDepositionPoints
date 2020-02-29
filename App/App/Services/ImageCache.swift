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
    
    static let shared = ImageCache()
    
    private init() {}
    
    public func obtainImage(_ point: MapDepositionPoint, completion: @escaping(Result<UIImage, Error>) -> Void) {
        let url = "https://static.tinkoff.ru/icons/deposition-partners-v3/mdpi/\(point.previewImage)"
        let key = NSString(string: url)
        
        if let cachedData = cache.object(forKey: key) {
            if let image = UIImage(data: cachedData as Data) {
                completion(.success(image))
                return
            }
            
            cache.removeObject(forKey: key)
        }
        
        URLSession.shared.dataTask(with: URL(string: url)!) { [weak self] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                self?.cache.setObject(data as NSData, forKey: key)
                
                completion(.success(image))
                return
            }
            
            completion(.failure(AppError("Unknown error.")))
        }.resume()
    }
}
