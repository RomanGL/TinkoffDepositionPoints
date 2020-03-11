//
//  HttpRequestOperation.swift
//  AppCommon
//
//  Created by r.gladkikh on 02.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

/// Performs a HTTP request by the specified url and the HTTP method.
public final class HttpRequestOperation: AsyncOperation {
    public enum HttpMethod: String {
        case get, head
        
        fileprivate var value: String { rawValue.uppercased() }
    }
    
    public let url: URL
    public let method: HttpMethod
    
    public private(set) var response: HTTPURLResponse?
    public private(set) var data: Data?
    public private(set) var error: Error?
    
    public init(with url: URL, method: HttpMethod) {
        self.url = url
        self.method = method
    }
    
    public convenience init(with url: URL) {
        self.init(with: url, method: .get)
    }
    
    public override func main() {
        if isCancelled { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.value
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if self.isCancelled { return }

            self.data = data
            self.response = response as? HTTPURLResponse
            self.error = error
            
            self.state = .finished
        }.resume()
    }
}
