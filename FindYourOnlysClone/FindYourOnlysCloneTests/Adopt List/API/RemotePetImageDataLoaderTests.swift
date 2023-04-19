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
            case let .success((data, response)):
                guard response.statusCode == 200, !data.isEmpty else {
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
        
        expect(sut, toComplete: .failure(clientError), when: {
            client.completesWith(error: clientError)
        })
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPURLResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { (index, statusCode) in
            expect(sut, toComplete: failure(.invalidData), when: {
                client.completesWith(statusCode: statusCode, at: index)
            })
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOn200HTTPURLResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        let emptyData = Data()
        
        expect(sut, toComplete: failure(.invalidData), when: {
            client.completesWith(statusCode: 200, data: emptyData)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RemotePetImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemotePetImageDataLoader(client: client)
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemotePetImageDataLoader, toComplete expectedResult: PetImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError.domain, expectedError.domain, file: file, line: line)
                XCTAssertEqual(receivedError.code, expectedError.code, file: file, line: line)
                
            case let (.failure(receivedError as RemotePetImageDataLoader.Error), .failure(expectedError as RemotePetImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemotePetImageDataLoader.Error) -> PetImageDataLoader.Result {
        return .failure(error)
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
