//
//  ImageTakeOperation.swift
//  App
//
//  Created by r.gladkikh on 02.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import UIKit

open class ImageTakeOperation: Operation {
    private let input: UIImage?

    public final var inputImage: UIImage? {
        if let input = input {
            return input
        }

        let provider = dependencies
            .filter { $0 is ImagePass }
            .first as? ImagePass

        return provider?.image
    }

    public init(image: UIImage?) {
        input = image
        super.init()
    }
}

// MARK:- ImagePass
extension ImageTakeOperation: ImagePass {
    public final var image: UIImage? { inputImage }
}
