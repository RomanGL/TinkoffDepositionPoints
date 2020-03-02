//
//  StringOutputOperation.swift
//  App
//
//  Created by r.gladkikh on 02.03.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

public final class StringOutputOperation: StringTakeOperation {
    private let completion: (String?) -> Void
    
    public init(completion: @escaping (String?) -> Void) {
        self.completion = completion
        super.init(string: nil)
    }
    
    public override func main() {
        if isCancelled { return }
        
        completion(inputString)
    }
}
