//
//  ImageLoadOperation.swift
//  App
//
//  Created by r.gladkikh on 02.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import UIKit

public final class ImageLoadOperation: Operation {
    private let data: Data?
    
    public private(set) var output: UIImage?
    public var input: Data? {
        if let inputData = data {
            return inputData
        }
        
        let dataProvider = dependencies
            .filter { $0 is DataPass }
            .first as? DataPass
        
        return dataProvider?.data
    }
    
    public init(data: Data?) {
        self.data = data
        super.init()
    }
    
    public override func main() {
        if let inputData = input {
            output = UIImage(data: inputData)
        }
    }
}

// MARK: - ImagePass
extension ImageLoadOperation: ImagePass {
    public var image: UIImage? { output }
}
