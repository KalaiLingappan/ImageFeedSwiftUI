//
//  ImageFeedViewModel.swift
//  ImageFeed
//
//  Created by Kalaiprabbha L on 15/02/22.
//

import UIKit

class ImageFeedViewModel {
    private var service: NetworkService

    init(service: NetworkService) {
        self.service = service
    }
    var photos: [Photo] = [Photo]() {
        didSet {
            reloadViewClosure?()
        }
    }
    var alertMessage: String? {
        didSet {
            showAlertClosure?()
        }
    }
    
    var reloadViewClosure: (()->())?
    var showAlertClosure: (()->())?
    
    
    func fetchPhotosForOffset<T: DataRequest>(_ offset: Int, request: T) {
        service.fetchDataFor(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                if let photos = data as? [Photo] {
                    self?.photos += photos
                }
            case .failure(let error):
                self?.alertMessage = error.localizedDescription
            }
        }
    }
}
