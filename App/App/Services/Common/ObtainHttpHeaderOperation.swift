//
//  ObtainHttpHeaderOperation.swift
//  App
//
//  Created by r.gladkikh on 02.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

public final class ObtainHttpHeaderOperation: AsyncOperation {
    public let url: URL
    public let header: String
    public private (set) var value: String?
    
    public init(for url: URL, header: String) {
        self.url = url
        self.header = header
        super.init()
    }
    
    override public func main() {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        URLSession.shared.dataTask(with: url) { [weak self] _, response, _ in
            guard let self = self else { return }
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            self.value = httpResponse.value(forHTTPHeaderField: self.header)
            self.state = .finished
        }.resume()
    }
}

// MARK:- StringPass
extension ObtainHttpHeaderOperation: StringPass {
    public var string: String? { value }
}
