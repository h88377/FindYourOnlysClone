//
//  LocalPetImageDataLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import XCTest
@testable import FindYourOnlysClone

protocol PetImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
    func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}

final class LocalPetImageDataLoader: PetImageDataLoader {
    enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    typealias SaveResult = Swift.Result<Void, Error>
    
    private final class LocalPetImageDataLoaderTask: PetImageDataLoaderTask {
        private var completion: ((PetImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (PetImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(_ result: PetImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    private let store: PetImageDataStore
    
    init(store: PetImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
        let loaderTask = LocalPetImageDataLoaderTask(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data):
                guard let data = data else { return loaderTask.complete(.failure(Error.notFound)) }
                
                loaderTask.complete(.success(data))
                
            case .failure:
                loaderTask.complete(.failure(Error.failed))
            }
        }
        
        return loaderTask
    }
    
    func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data: data, for: url) { _ in }
    }
}

class LocalPetImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestImageDataUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_saveImageData_requestImageDataInsertionForURL() {
        let imageData = anyData()
        let imageURL = anyURL()
        let (sut, store) = makeSUT()
        
        sut.save(data: imageData, for: imageURL) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(imageData, imageURL)])
    }
    
    func test_loadImageData_requestsImageDataFromURL() {
        let url = anyURL()
        let (sut, store) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(url)])
    }
    
    func test_loadImageData_failsOnStoreError() {
        let storeError = anyNSError()
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.failed), when: {
            store.completesWith(storeError)
        })
    }
    
    func test_loadImageData_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.notFound), when: {
            store.completesWith(.none)
        })
    }
    
    func test_loadImageData_deliversStoredDataOnFoundData() {
        let foundData = anyData()
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(foundData), when: {
            store.completesWith(foundData)
        })
    }
    
    func test_loadImageData_doesNotDeliverResultAfterTaskHasBeenCancelled() {
        let (sut, store) = makeSUT()
        
        var receivedResult: LocalPetImageDataLoader.Result?
        let task = sut.loadImageData(from: anyURL()) { result in receivedResult = result }
        task.cancel()
        
        store.completesWith(anyNSError())
        store.completesWith(anyData())
        store.completesWith(.none)
        
        XCTAssertNil(receivedResult)
    }
    
    func test_loadImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = PetStoreSpy()
        var sut: LocalPetImageDataLoader? = LocalPetImageDataLoader(store: store)
        var receivedResult: LocalPetImageDataLoader.Result?
        _ = sut?.loadImageData(from: anyURL()) { result in receivedResult = result }
        
        sut = nil
        
        store.completesWith(anyNSError())
        XCTAssertNil(receivedResult)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalPetImageDataLoader, PetStoreSpy) {
        let store = PetStoreSpy()
        let sut = LocalPetImageDataLoader(store: store)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalPetImageDataLoader, toCompleteWith expectedResult: LocalPetImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as LocalPetImageDataLoader.Error), .failure(expectedError as LocalPetImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, "Expected failure with \(expectedError), got \(receivedError) instead", file: file, line: line)
                
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, "Expected succeed with \(expectedData), got \(receivedData) instead", file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
     
    private func failure(_ error: LocalPetImageDataLoader.Error) -> LocalPetImageDataLoader.Result {
        return .failure(error)
    }
    
    private class PetStoreSpy: PetImageDataStore {
        enum Message: Equatable {
            case retrieve(URL)
            case insert(Data, URL)
        }
        
        typealias RetrievalCompletion = (PetImageDataStore.RetrievalResult) -> Void
        typealias InsertionCompletion = (PetImageDataStore.InsertionResult) -> Void
        
        private(set) var receivedMessages = [Message]()
        
        private var retrievalCompletions = [RetrievalCompletion]()
        
        func retrieve(dataForURL url: URL, completion: @escaping RetrievalCompletion) {
            receivedMessages.append(.retrieve(url))
            retrievalCompletions.append(completion)
        }
        
        func insert(data: Data, for url: URL, completion: @escaping InsertionCompletion) {
            receivedMessages.append(.insert(data, url))
        }
        
        func completesWith(_ error: Error, at index: Int = 0) {
            retrievalCompletions[index](.failure(error))
        }
        
        func completesWith(_ data: Data?, at index: Int = 0) {
            retrievalCompletions[index](.success(data))
        }
    }
}
