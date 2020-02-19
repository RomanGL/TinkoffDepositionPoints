//
//  ResultCode.swift
//  TinkoffApi
//
//  Created by r.gladkikh on 18.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

/// Представляет код ответа API.
public enum ResultCode {
    case ok
    case other(String)
}

// MARK: - Decodable
extension ResultCode: Decodable {
    public init(from decoder: Decoder) throws {
        let label = try decoder.singleValueContainer().decode(String.self)
        
        switch label {
        case "OK":
            self = .ok
            
        default:
            self = .other(label)
        }
    }
}
