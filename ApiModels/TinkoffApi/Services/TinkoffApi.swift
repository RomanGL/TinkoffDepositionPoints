//
//  ApiService.swift
//  TinkoffApi
//
//  Created by r.gladkikh on 18.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

public typealias Completion<Payload: Decodable> = (Result<Payload, Error>) -> Void

public class TinkoffApi {
    private static let apiBase = "https://api.tinkoff.ru/v1/"
    private static let supportedMimeType = "application/json"
}

// MARK: - Utils
extension TinkoffApi {
    func getResponse<Payload: Decodable>(from url: URL, completion: @escaping Completion<Payload>) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(ApiError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiError("Response data is not exists.")))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(.failure(ApiError("Server error.")))
                return
            }
            
            guard let mime = response.mimeType, mime.contains(TinkoffApi.supportedMimeType) else {
                completion(.failure(ApiError("Wrong MIME type. Expected: \(TinkoffApi.supportedMimeType)")))
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(Response<Payload>.self, from: data)
                
                switch apiResponse.resultCode {
                case .ok:
                    completion(.success(apiResponse.payload!))
                    
                default:
                    let responseError = ResponseError(resultCode: apiResponse.resultCode,
                                                      trackingId: apiResponse.trackingId,
                                                      errorMessage: apiResponse.errorMessage,
                                                      plainMessage: apiResponse.plainMessage)
                    
                    completion(.failure(responseError))
                }
                
            } catch {
                completion(.failure(ApiError(message: "JSON parsing error.", error: error)))
            }
        }
        
        task.resume()
    }
    
    func getUrl(endpoint: String) -> URL {
        let urlString = "\(TinkoffApi.apiBase)\(endpoint)"
        return URL(string: urlString)!
    }
}
