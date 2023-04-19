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
        case connectivity
    }
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    private final class RemotePetImageDataLoaderTask: PetImageDataLoaderTask {
        private var completion: ((PetImageDataLoader.Result) -> Void)?
        var clientTask: HTTPClientTask?
        
        init(_ completion: @escaping (PetImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(_ result: PetImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            clientTask?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
        let loaderTask = RemotePetImageDataLoaderTask(completion)
        loaderTask.clientTask = client.dispatch(URLRequest(url: url)) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                guard response.statusCode == 200, !data.isEmpty else {
                    return loaderTask.complete(.failure(Error.invalidData))
                }
                
                loaderTask.complete(.success(data))
                
            case .failure:
                loaderTask.complete(.failure(Error.connectivity))
            }
        }
        
        return loaderTask
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
    
    func test_loadImageData_deliversConnectivityErrorOnClientError() {
        let clientError = anyNSError()
        let (sut, client) = makeSUT()
        
        expect(sut, toComplete: failure(.connectivity), when: {
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
    
    func test_loadImageData_deliversReceivedNonEmptyDataOn200HTTPURLResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyata = Data("non-empty data".utf8)
        
        expect(sut, toComplete: .success(nonEmptyata), when: {
            client.completesWith(statusCode: 200, data: nonEmptyata)
        })
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.cancelledURLs, [], "Expected no cancelled URL until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL after task is cancelled")
    }
    
    func test_loadImageData_doesNotDeliversResultsAfterTasksAreCancelled() {
        let nonEmptyData = Data("non-empty data".utf8)
        let (sut, client) = makeSUT()
        
        var receivedResults = [PetImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { receivedResults.append($0) }
        task.cancel()
        
        client.completesWith(error: anyNSError())
        client.completesWith(statusCode: 200, data: nonEmptyData)
        client.completesWith(statusCode: 404, data: anyData())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_loadImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemotePetImageDataLoader? = RemotePetImageDataLoader(client: client)
        
        var receivedResult: PetImageDataLoader.Result?
        sut?.loadImageData(from: anyURL()) { result in
            receivedResult = result
        }
        
        sut = nil
        client.completesWith(error: anyNSError())
        
        XCTAssertNil(receivedResult)
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
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
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
}
