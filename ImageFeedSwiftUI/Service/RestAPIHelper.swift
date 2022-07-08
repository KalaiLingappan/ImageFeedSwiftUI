//
//  RestAPIHelper.swift
//  ImageFeed
//
//  Created by Kalaiprabbha L on 13/02/22.
//

import UIKit

struct AppURLs {
    static let baseURL = "https://picsum.photos/"
}

enum ErrorResponse: String, Error {
    case noNetwork = "No Network"
    case invalidEndpoint = "Invalid Endpoint"
    case invalidData = "Invalid Data"
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
    func fetchDataFor<Request: DataRequest>(request: Request, completionHandler: @escaping ((Result<Request.ResponseData,Error>) -> Void))
}

struct DataNetworkService: NetworkService {
    func fetchDataFor<Request: DataRequest>(request: Request, completionHandler: @escaping ((Result<Request.ResponseData,Error>) -> Void)) {
        
        /****check for network and return error for no network
         
         *****/
        guard var urlComponent = URLComponents(string: request.url) else {
            let error = NSError(
                domain: ErrorResponse.invalidEndpoint.rawValue,
                code: 404,
                userInfo: nil
            )
            
            return completionHandler(.failure(error))
        }
        
        var queryItems: [URLQueryItem] = []
        request.queryItems.forEach {
            let urlQueryItem = URLQueryItem(name: $0.key, value: $0.value)
            urlComponent.queryItems?.append(urlQueryItem)
            queryItems.append(urlQueryItem)
        }
        urlComponent.queryItems = queryItems
        
        guard let url = urlComponent.url else {
            let error = NSError(
                domain: ErrorResponse.invalidEndpoint.rawValue,
                code: 404,
                userInfo: nil
            )
            
            return completionHandler(.failure(error))
        }
        
    
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers

        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                return completionHandler(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode,let data = data {
                do {
                    try completionHandler(.success(request.decode(data)))
                } catch let error as NSError {
                    completionHandler(.failure(error))
                }
                return
            }
            
            return completionHandler(.failure(NSError()))
        }
        .resume()
    }
}
