//
//  ApiService.swift
//  TinkoffDepositionPoints
//
//  Created by r.gladkikh on 18.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation

typealias ApiResult<Payload: Decodable> = Result<Payload, Error>
typealias Completion<Payload: Decodable> = (ApiResult<Payload>) -> Void

final class ApiService {
    private static let apiBase = "https://api.tinkoff.ru/v1/"
    private static let supportedMimeType = "application/json"
    
    static let shared = ApiService()
    
    private init() {}
}

// MARK: - DepositionPoints
extension ApiService {
    func getDepositionPartners(completion: @escaping Completion<DepositionPartnersPayload>) {
        let endpoint = "deposition_partners?accountType=Credit"
        let url = getUrl(endpoint: endpoint)
        getResponse(from: url, completion: completion)
    }
    
    func getDepositionPoints(latitude: Double,
                             longitude: Double,
                             radius: Int,
                             completion: @escaping Completion<DepositionPointsPayload>) {
        let endpoint = "deposition_points?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)"
        let url = getUrl(endpoint: endpoint)
        
        getResponse(from: url, completion: completion)
    }
}

// MARK: - Utils
private extension ApiService {
    private func getResponse<Payload: Decodable>(from url: URL, completion: @escaping Completion<Payload>) {
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
            
            guard let mime = response.mimeType, mime.contains(ApiService.supportedMimeType) else {
                completion(.failure(ApiError("Wrong MIME type. Expected: \(ApiService.supportedMimeType)")))
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
    
    private func getUrl(endpoint: String) -> URL {
        let urlString = "\(ApiService.apiBase)\(endpoint)"
        return URL(string: urlString)!
    }
}
