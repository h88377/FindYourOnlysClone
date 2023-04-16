//
//  RemotePetLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import XCTest
@testable import FindYourOnlysClone

protocol HTTPClient {
    func dispatch(_ request: URLRequest)
}

final class RemotePetLoader {
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(with request: AdoptListRequest) {
        var component = URLComponents(url: url, resolvingAgainstBaseURL: false)
        component?.queryItems = [
            URLQueryItem(name: "UnitId", value: "QcbUEzN6E6DL"),
            URLQueryItem(name: "$top", value: "20"),
            URLQueryItem(name: "$skip", value: "\(20 * request.page)"),
        ]
        
        let enrichedURL = component?.url ?? url
        let request = URLRequest(url: enrichedURL)
        
        client.dispatch(request)
    }
}

class RemotePetLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        _ = RemotePetLoader(url: url, client: client)
        
        XCTAssertTrue(client.receivedURLs.isEmpty)
    }
    
    func test_loadWithRequest_requestsDataFromRequest() {
        let page = 0
        let url = URL(string: "https://any-url.com")!
        let expectedURL = URL(string: "https://any-url.com?UnitId=QcbUEzN6E6DL&$top=20&$skip=\(20 * page)")!
        let client = HTTPClientSpy()
        let sut = RemotePetLoader(url: url, client: client)
        
        sut.load(with: AdoptListRequest(page: page))
        
        XCTAssertEqual(client.receivedURLs, [expectedURL])
    }
    
    private class HTTPClientSpy: HTTPClient {
        private(set) var receivedURLs = [URL]()
        
        func dispatch(_ request: URLRequest) {
            receivedURLs.append(request.url!)
        }
    }
}
