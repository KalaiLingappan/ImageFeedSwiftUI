//
//  RestAPIHelper.swift
//  ImageFeed
//
//  Created by Kalaiprabbha L on 13/02/22.
//

import UIKit
import Reachability

struct AppURLs {
    static let baseURL = "https://picsum.photos/"
}

enum ErrorResponse: String, Error {
    case noNetwork = "No Network"
    case invalidEndpoint = "Invalid Endpoint"
    case invalidData = "Invalid Data"
    
    var errorCode: Int {
        404
    }
    
    var description: String {
        switch self {
        case .noNetwork: return "No internet connection"
        case .invalidData: return "Invalid Data"
        case .invalidEndpoint: return "Invalid URL"
        }
    }
    
    func getError() -> Error {
         NSError(
            domain: rawValue,
            code: errorCode,
            userInfo: [NSLocalizedDescriptionKey: description]
        )
    }
}

enum HTTPMethod: String {
    case get = "GET"
}

enum URLEndPoint: String {
    case list = "/v2/list"
    case detailImage = "/150/200"
}

protocol DataRequest {
    associatedtype ResponseData: Decodable
    
    var url: String { get }
    var method: HTTPMethod { get }
    var headers: [String : String] { get }
    var queryItems: [String : String] { get }
    
    func decode(_ data: Data) throws -> ResponseData
}

extension DataRequest {
    func decode(_ data: Data) throws -> ResponseData {
        let decoder = JSONDecoder()
        return try decoder.decode(ResponseData.self, from: data)
    }
}

protocol NetworkService {
    func fetchDataFor<Request: DataRequest>(request: Request) async throws -> Request.ResponseData? 
}

struct DataNetworkService: NetworkService {
    private func getURLComponent<Request: DataRequest>(request: Request) -> URLComponents? {
        URLComponents(string: request.url)
    }
    
    private func getQueryItems(queryItemsURL: [String : String]) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        queryItemsURL.forEach {
            let urlQueryItem = URLQueryItem(name: $0.key, value: $0.value)
            queryItems.append(urlQueryItem)
        }
        return queryItems
    }
    
    private func getURLRequest<Request: DataRequest>(request: Request) -> URLRequest? {
        guard var urlComponent = getURLComponent(request: request) else {
            return nil
        }
        
        urlComponent.queryItems = getQueryItems(queryItemsURL: request.queryItems)
        
        guard let url = urlComponent.url else {
           return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        return urlRequest
    }
    
    func isReachable() -> Bool {
        do {
            return try Reachability(hostname: AppURLs.baseURL).connection != .unavailable
        } catch {
            return false
        }
    }
    
    func fetchDataFor<Request: DataRequest>(request: Request) async throws -> Request.ResponseData? {
        guard isReachable() else {
            throw ErrorResponse.noNetwork.getError()
        }
        
        guard let urlRequest = getURLRequest(request: request) else {
           throw ErrorResponse.invalidEndpoint.getError()
        }
       
        let (data,_) =  try await URLSession.shared.data(for: urlRequest,delegate: nil)
        return try request.decode(data)
    }
    
}
