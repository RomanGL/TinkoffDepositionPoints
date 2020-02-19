//
//  ApiError.swift
//  TinkoffApi
//
//  Created by r.gladkikh on 18.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

public struct ApiError: LocalizedError {
    public let innerError: Error?
    public let errorDescription: String?
}

// MARK: - Initializers
extension ApiError {
    init(_ message: String) {
        errorDescription = message
        innerError = nil
    }
    
    init(_ error: Error?) {
        innerError = error
        errorDescription = error?.localizedDescription ?? "Unknown error."
    }
    
    init(message: String?, error: Error?) {
        errorDescription = message ?? error?.localizedDescription ?? "Unknown error."
        innerError = error
    }
}
