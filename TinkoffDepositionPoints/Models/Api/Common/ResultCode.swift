//
//  ResultCode.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 18.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

enum ResultCode {
    case ok
    case internalError
    case unknownError(String)
}

// MARK: - Decodable
extension ResultCode: Decodable {
    init(from decoder: Decoder) throws {
        let label = try decoder.singleValueContainer().decode(String.self)
        
        switch label {
        case "OK":
            self = .ok
        case "INTERNAL_ERROR":
            self = .internalError
        default:
            self = .unknownError(label)
        }
    }
}
