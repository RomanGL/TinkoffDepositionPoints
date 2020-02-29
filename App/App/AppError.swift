//
//  AppError.swift
//  App
//
//  Created by r.gladkikh on 26.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

struct AppError: LocalizedError {
    let errorDescription: String?
    
    init(_ description: String) {
        errorDescription = description
    }
}
