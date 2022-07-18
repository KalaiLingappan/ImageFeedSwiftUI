//
//  ImageFeedViewModel.swift
//  ImageFeed
//
//  Created by Kalaiprabbha L on 15/02/22.
//

import Combine
import UIKit

class ImageFeedViewModel: ObservableObject {
    private var service: NetworkService

    init(service: NetworkService) {
        self.service = service
    }
    @Published var photos: [Photo] = [Photo]()
    @Published var alertMessage: Error?

    @MainActor func fetchPhotosForOffset<T: DataRequest>(_ offset: Int, request: T) async {
        do {
            self.photos = try await service.fetchDataFor(request: request) as? [Photo] ?? []
        } catch {
            self.alertMessage = error
        }
    }
}

