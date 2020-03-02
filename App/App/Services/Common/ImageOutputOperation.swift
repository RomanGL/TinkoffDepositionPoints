//
//  ImageOutputOperation.swift
//  App
//
//  Created by r.gladkikh on 02.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import UIKit

public final class ImageOutputOperation: ImageTakeOperation {
    private let completion: (UIImage?) -> Void
    
    public init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        super.init(image: nil)
    }
    
    public override func main() {
        if isCancelled { return }
        
        completion(inputImage)
    }
}
