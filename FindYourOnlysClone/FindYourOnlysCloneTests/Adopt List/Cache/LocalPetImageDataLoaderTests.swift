//
//  LocalPetImageDataLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import XCTest
@testable import FindYourOnlysClone

protocol PetImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

final class LocalPetImageDataLoader: PetImageDataLoader {
    enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private struct LocalPetImageDataLoaderTask: PetImageDataLoaderTask {
        func cancel() {}
    }
    
    private let store: PetImageDataStore
    
    init(store: PetImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
        store.retrieve(dataForURL: url) { result in
            switch result {
            case let .success(data):
                if data == nil {
                    completion(.failure(Error.notFound))
                }
            case .failure:
                completion(.failure(Error.failed))
            }
        }
        
        return LocalPetImageDataLoaderTask()
    }
}

class LocalPetImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestImageDataUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedURLs, [])
    }
    
    func test_loadImageData_requestsImageDataFromURL() {
        let url = anyURL()
        let (sut, store) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedURLs, [url])
    }
    
    func test_loadImageData_failsOnStoreError() {
        let storeError = anyNSError()
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .failure(receivedError as LocalPetImageDataLoader.Error):
                XCTAssertEqual(receivedError, .failed)
                
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completesWith(storeError)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageData_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .failure(receivedError as LocalPetImageDataLoader.Error):
                XCTAssertEqual(receivedError, .notFound)
                
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completesWith(.none)
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalPetImageDataLoader, PetStoreSpy) {
        let store = PetStoreSpy()
        let sut = LocalPetImageDataLoader(store: store)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private class PetStoreSpy: PetImageDataStore {
        var receivedURLs: [URL] {
            return receivedMessages.map { $0.url }
        }
        
        private var receivedMessages = [(url: URL, completion: (PetImageDataStore.Result) -> Void)]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (PetImageDataStore.Result) -> Void) {
            receivedMessages.append((url, completion))
        }
        
        func completesWith(_ error: Error, at index: Int = 0) {
            receivedMessages[index].completion(.failure(error))
        }
        
        func completesWith(_ data: Data?, at index: Int = 0) {
            receivedMessages[index].completion(.success(data))
        }
    }
}
