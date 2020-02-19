//
//  ResponseError.swift
//  TinkoffApi
//
//  Created by r.gladkikh on 19.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

/// Представляет ошибку API.
public struct ResponseError: Error {
    public let resultCode: ResultCode
    public let trackingId: String?
    public let errorMessage: String?
    public let plainMessage: String?
}

// MARK: - LocalizedError
extension ResponseError: LocalizedError {
    public var errorDescription: String? {
        return plainMessage ?? errorMessage ?? "Unknown error"
    }
}
