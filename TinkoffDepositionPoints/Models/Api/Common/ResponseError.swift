//
//  ResponseError.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 19.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

/// Представляет ошибку API.
struct ResponseError: Error {
    let resultCode: ResultCode
    let trackingId: String?
    let errorMessage: String?
    let plainMessage: String?
}

// MARK: - LocalizedError
extension ResponseError: LocalizedError {
    var errorDescription: String? {
        return plainMessage ?? errorMessage ?? "Unknown error"
    }
}
