//
//  PhotoCellViewModel.swift
//  ImageFeed
//
//  Created by Kalaiprabbha L on 15/02/22.
//

import Foundation

struct PhotoCellViewModel {
    private var photo: Photo?
    
    init(_ photo: Photo?) {
        self.photo = photo
    }
    
    var url: URL? {
        var urlStr = AppURLs.baseURL

        if let id = photo?.id {
            urlStr += "id/\(id)"
        }
            
        return URL(string: urlStr + URLEndPoint.detailImage.rawValue)
    }
}
