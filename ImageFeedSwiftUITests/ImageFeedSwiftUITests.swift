//
//  ImageFeedSwiftUITests.swift
//  ImageFeedSwiftUITests
//
//  Created by Kalaiprabha L on 18/07/22.
//

import XCTest
@testable import ImageFeedSwiftUI

class ImageFeedSwiftUITests: XCTestCase {
    let viewmodel: ImageFeedViewModel = ImageFeedViewModel(service: DataNetworkService())
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testService() async throws {
        await viewmodel.fetchPhotosForOffset(0, request: MockRequest())
        XCTAssertEqual(viewmodel.photos.count, 10)
    }
    
    func testServiceFailure() async throws {
        await viewmodel.fetchPhotosForOffset(0, request: MockRequestFailure())
        let alertMessage = try XCTUnwrap(viewmodel.alertMessage)
        XCTAssertEqual(alertMessage.localizedDescription, "Error parsing JSON")
    }
    
    func testServiceError() async throws {
        await viewmodel.fetchPhotosForOffset(0, request: MockRequestURLFailure())
        let alertMessage = try XCTUnwrap(viewmodel.alertMessage)
        XCTAssertEqual(alertMessage.localizedDescription,ErrorResponse.invalidEndpoint.description)
    }
}

struct MockRequest: DataRequest {
     var url: String {
        return AppURLs.baseURL
    }

    var method: HTTPMethod { .get }
    var headers: [String : String] { [:] }
    var queryItems: [String : String] { [:] }
    
    func decode(_ data: Data) throws -> [Photo] {
        guard let jsonData = HelperClass.readLocalFile(forName: "Mock") else {
            return []
        }
        
        do {
            let decodedJSON = try JSONDecoder().decode(ResponseData.self, from: jsonData)
            return decodedJSON
        } catch {
            return []
        }
    }
}

struct MockRequestFailure: DataRequest {
    var url: String {
        return AppURLs.baseURL
    }
    
    var method: HTTPMethod { .get }
    var headers: [String : String] { [:] }
    var queryItems: [String : String] { [:] }
    
    func decode(_ data: Data) throws -> [Photo] {
        throw NSError(domain: "", code: 101, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON"])
    }
}

struct MockRequestURLFailure: DataRequest {
    typealias ResponseData = [Photo]
    
    var url: String { return "http://example.com:-80/" }
    var method: HTTPMethod { .get }
    var headers: [String : String] { [:] }
    var queryItems: [String : String] { [:] }
}

