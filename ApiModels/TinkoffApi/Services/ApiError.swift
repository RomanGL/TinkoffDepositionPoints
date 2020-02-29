//
//  ApiError.swift
//  TinkoffApi
//
//  Created by r.gladkikh on 18.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

public enum ApiError {
    case unknownError
    case emptyResponse
    case serverError(code: Int)
    case wrongMimeType(mime: String?)
    case parsingFailed(error: Error)
}

// MARK: - LocalizedError
extension ApiError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "A response data is not exists."
        case .serverError(let code):
            return "Server error. Code: \(code)."
        case .wrongMimeType(let mime):
            return "Wrong MIME type: \(mime ?? "empty")."
        case .parsingFailed(let error):
            return "JSON parsing failed: \(error.localizedDescription)"
        case .unknownError:
            return "Unknown error."
        }
    }
}
