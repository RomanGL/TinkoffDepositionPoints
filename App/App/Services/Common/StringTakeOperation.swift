//
//  StringTakeOperation.swift
//  App
//
//  Created by r.gladkikh on 02.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

open class StringTakeOperation: Operation {
    private let input: String?
    
    public final var inputString: String? {
        if let input = input {
            return input
        }
        
        let provider = dependencies
            .filter { $0 is StringPass }
            .first as? StringPass
        
        return provider?.string
    }
    
    public init(string: String?) {
        input = string
        super.init()
    }
}

// MARK:- StringPass
extension StringTakeOperation: StringPass {
    public final var string: String? { inputString }
}
