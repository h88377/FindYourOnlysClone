//
//  RemotePetImageDataLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/19.
//

import XCTest
@testable import FindYourOnlysClone

final class RemotePetImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL) {
        client.dispatch(URLRequest(url: url)) { _ in
            
        }
    }
}

class RemotePetImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestImageDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.receivedURLs, [])
    }
    
    func test_loadImageData_requestsImageDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url)
        XCTAssertEqual(client.receivedURLs, [url])
    }
    
    func test_loadImageDataTwice_requestsImageDataFromURLTwice() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url)
        sut.loadImageData(from: url)
        
        XCTAssertEqual(client.receivedURLs, [url, url])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RemotePetImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemotePetImageDataLoader(client: client)
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private(set) var receivedURLs = [URL]()
        
        func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
            receivedURLs.append(request.url!)
        }
        
    }
}
