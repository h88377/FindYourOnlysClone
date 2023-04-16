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
    private let baseURL: URL
    private let client: HTTPClient
    
    init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    func load(with request: AdoptListRequest) {
        let url = enrich(baseURL, with: request)
        client.dispatch(URLRequest(url: url))
    }
    
    private func enrich(_ baseURL: URL, with request: AdoptListRequest) -> URL {
        var component = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        component?.queryItems = [
            URLQueryItem(name: "UnitId", value: "QcbUEzN6E6DL"),
            URLQueryItem(name: "$top", value: "20"),
            URLQueryItem(name: "$skip", value: "\(20 * request.page)"),
        ]
        
        return component?.url ?? baseURL
    }
}

class RemotePetLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.receivedURLs.isEmpty)
    }
    
    func test_loadWithRequest_requestsDataFromRequest() {
        let request = AdoptListRequest(page: 0)
        let url = URL(string: "https://any-url.com")!
        let expectedURL = makeExpectedURL(url, with: request)
        let (sut, client) = makeSUT(baseURL: url)
        
        sut.load(with: request)
        
        XCTAssertEqual(client.receivedURLs, [expectedURL])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(baseURL: URL = URL(string: "https://any-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemotePetLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemotePetLoader(baseURL: baseURL, client: client)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        return (sut, client)
    }
    
    private func makeExpectedURL(_ url: URL, with request: AdoptListRequest) -> URL {
        let urlString = url.absoluteString
        let expectedURL = URL(string: "\(urlString)?UnitId=QcbUEzN6E6DL&$top=20&$skip=\(20 * request.page)")!
        return expectedURL
    }
    
    private class HTTPClientSpy: HTTPClient {
        private(set) var receivedURLs = [URL]()
        
        func dispatch(_ request: URLRequest) {
            receivedURLs.append(request.url!)
        }
    }
}
