//
//  RemotePetLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import XCTest
@testable import FindYourOnlysClone

protocol HTTPClient {
    func dispatch()
}

final class RemotePetLoader {
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
}

class RemotePetLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        _ = RemotePetLoader(url: url, client: client)
        
        XCTAssertTrue(client.receivedURLs.isEmpty)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private(set) var receivedURLs = [URL]()
        
        func dispatch() {
            
        }
    }
}
