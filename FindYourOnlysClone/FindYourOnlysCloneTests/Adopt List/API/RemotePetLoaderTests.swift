//
//  RemotePetLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import XCTest
@testable import FindYourOnlysClone

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void)
}

final class RemotePetLoader {
    enum Error: Swift.Error {
        case connectivity
    }
    
    private let baseURL: URL
    private let client: HTTPClient
    
    init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    func load(with request: AdoptListRequest, completion: @escaping (Error) -> Void) {
        let url = enrich(baseURL, with: request)
        client.dispatch(URLRequest(url: url)) { _ in
            completion(.connectivity)
        }
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
        
        sut.load(with: request) { _ in }
        
        XCTAssertEqual(client.receivedURLs, [expectedURL])
    }
    
    func test_loadWithRequestTwice_requestsDataFromRequestTwice() {
        let request = AdoptListRequest(page: 0)
        let url = URL(string: "https://any-url.com")!
        let expectedURL = makeExpectedURL(url, with: request)
        let (sut, client) = makeSUT(baseURL: url)
        
        sut.load(with: request) { _ in }
        sut.load(with: request) { _ in }
        
        XCTAssertEqual(client.receivedURLs, [expectedURL, expectedURL])
    }
    
    func test_loadWithRequest_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithError: .connectivity, when: {
            client.completesWithError()
        })
    }
    
    func test_loadWithRequest_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        for (index, statusCode) in samples.enumerated() {
            expect(sut, toCompleteWithError: .connectivity, when: {
                client.completesWith(statusCode: statusCode, at: index)
            })
        }
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
    
    private func expect(_ sut: RemotePetLoader, toCompleteWithError expectedResult: RemotePetLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.load(with: anyRequest()) { receivedResult in
            XCTAssertEqual(receivedResult, expectedResult, "Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyRequest() -> AdoptListRequest {
        return AdoptListRequest(page: 0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        typealias RequestCompletion = (HTTPClient.Result) -> Void
        private(set) var receivedURLs = [URL]()
        
        private var receivedMessages = [(request: URLRequest, completion: RequestCompletion)]()
        
        func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
            receivedURLs.append(request.url!)
            receivedMessages.append((request, completion))
        }
        
        func completesWithError(at index: Int = 0) {
            let error = NSError(domain: "any error", code: 0)
            receivedMessages[index].completion(.failure(error))
        }
        
        func completesWith(statusCode: Int = 200, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: receivedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            receivedMessages[index].completion(.success((data, response)))
        }
    }
}
