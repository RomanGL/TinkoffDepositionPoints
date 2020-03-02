//
//  ObtainDataOperation.swift
//  App
//
//  Created by r.gladkikh on 02.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

public final class ObtainDataOperation: AsyncOperation {
    public let url: URL
    public private(set) var result: Data?
    
    public init(url: URL) {
        self.url = url
        super.init()
    }
    
    public override func main() {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            self.result = data
            self.state = .finished
        }.resume()
    }
}

// MARK: - DataPass
extension ObtainDataOperation: DataPass {
    public var data: Data? { result }
}
