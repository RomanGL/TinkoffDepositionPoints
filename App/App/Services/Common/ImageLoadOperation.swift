//
//  ImageLoadOperation.swift
//  App
//
//  Created by r.gladkikh on 02.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import UIKit

public final class ImageLoadOperation: Operation {
    public var input: Data?
    public private(set) var output: UIImage?
    
    public init(data: Data?) {
        self.input = data
        super.init()
    }
    
    public override func main() {
        if isCancelled { return }
        if let input = input {
            output = UIImage(data: input)
        }
    }
}
