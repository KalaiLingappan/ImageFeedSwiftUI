//
//  PhotoDataRequest.swift
//  ImageFeed
//
//  Created by Kalaiprabbha L on 14/02/22.
//

import UIKit

struct PhotoDataRequest: DataRequest {
    var url: String {
        return AppURLs.baseURL + endPoint.rawValue
    }
    
    var method: HTTPMethod { .get }
    var headers: [String : String] { [:] }
    var queryItems: [String : String] {
        ["page" : "\(page)",
         "limit": "10"]
    }
    
    private var endPoint: URLEndPoint
    private var page: Int = 0

    typealias ResponseData = [Photo]
    init(endPoint: URLEndPoint, page: Int = 0) {
        self.endPoint = endPoint
        self.page = page
    }
}

