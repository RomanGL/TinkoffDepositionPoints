//
//  Response.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 18.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

/// Представляет ответ API Tinkoff.
final class Response<Payload: Decodable>: Decodable {
    let resultCode: ResultCode
    let payload: Payload?
    let trackingId: String?
    
    let errorMessage: String?
    let plainMessage: String?
}
