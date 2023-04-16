//
//  RemotePetLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import XCTest
@testable import FindYourOnlysClone

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
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            client.completesWithError()
        })
    }
    
    func test_loadWithRequest_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        for (index, statusCode) in samples.enumerated() {
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.completesWith(statusCode: statusCode, at: index)
            })
        }
    }
    
    func test_loadWithRequest_deliversErrorOn200HTTPResponseWithInvalidData() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidData = Data("invalid data".utf8)
            client.completesWith(statusCode: 200, data: invalidData)
        })
    }
    
    func test_loadWithRequest_deliversEmptyResultOn200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyData = try! JSONSerialization.data(withJSONObject: [])
            client.completesWith(statusCode: 200, data: emptyData)
        })
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
    
    private func expect(_ sut: RemotePetLoader, toCompleteWith expectedResult: RemotePetLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
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
        
        private var receivedMessages = [(request: URLRequest, completion: RequestCompletion)]()
        
        var receivedURLs: [URL] {
            return receivedMessages.map { $0.request.url! }
        }
        
        func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
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
