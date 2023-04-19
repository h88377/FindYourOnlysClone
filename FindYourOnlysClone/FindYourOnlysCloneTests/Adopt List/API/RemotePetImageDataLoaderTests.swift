//
//  RemotePetImageDataLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/19.
//

import XCTest
@testable import FindYourOnlysClone

final class RemotePetImageDataLoader {
    enum Error: Swift.Error {
        case invalidData
    }
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) {
        client.dispatch(URLRequest(url: url)) { result in
            switch result {
            case let .success((_, response)):
                guard response.statusCode == 200 else {
                    return completion(.failure(RemotePetImageDataLoader.Error.invalidData))
                }
                
            case let .failure(error):
                completion(.failure(error))
            }
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
        
        sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.receivedURLs, [url])
    }
    
    func test_loadImageDataTwice_requestsImageDataFromURLTwice() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.receivedURLs, [url, url])
    }
    
    func test_loadImageData_deliversErrorOnClientError() {
        let clientError = anyNSError()
        let (sut, client) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        client.completesWith(error: clientError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual((receivedError! as NSError).domain, clientError.domain)
        XCTAssertEqual((receivedError! as NSError).code, clientError.code)
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPURLResponse() {
        let (sut, client) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: RemotePetImageDataLoader.Error?
        sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .failure(error as RemotePetImageDataLoader.Error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        client.completesWith(statusCode: 299)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError, .invalidData)
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
        typealias ReceivedCompletion = (HTTPClient.Result) -> Void
        
        private var receivedMessages = [(url: URL, completion: ReceivedCompletion)]()
        
        var receivedURLs: [URL] {
            return receivedMessages.map { $0.url }
        }
        
        func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
            receivedMessages.append((request.url!, completion))
        }
        
        func completesWith(error: Error, at index: Int = 0) {
            receivedMessages[index].completion(.failure(error))
        }
        
        func completesWith(statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: receivedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            receivedMessages[index].completion(.success((data, response)))
        }
    }
}
