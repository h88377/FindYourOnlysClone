//
//  CachePetImageDataUseCaseTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import XCTest
@testable import FindYourOnlysClone

class CachePetImageDataUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_saveImageData_requestImageDataDeletionForURL() {
        let imageURL = anyURL()
        let (sut, store) = makeSUT()

        sut.save(data: anyData(), for: imageURL) { _ in }

        XCTAssertEqual(store.receivedMessages, [.delete(imageURL)])
    }
    
    func test_saveImageData_doesNotRequestInsertionOnDeletionError() {
        let imageURL = anyURL()
        let (sut, store) = makeSUT()

        sut.save(data: anyData(), for: imageURL) { _ in }
        store.completesDeletionWith(anyNSError())

        XCTAssertEqual(store.receivedMessages, [.delete(imageURL)])
    }

    func test_saveImageData_requestImageDataInsertionForURLOnSuccessfulDeletion() {
        let imageData = anyData()
        let imageURL = anyURL()
        let (sut, store) = makeSUT()

        sut.save(data: imageData, for: imageURL) { _ in }
        store.completesDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.delete(imageURL), .insert(imageData, imageURL)])
    }
    
    func test_saveImageData_failsOnDeletionError() {
        let deletionError = anyNSError()
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: deletionFailure(.failed), when: {
            store.completesDeletionWith(deletionError)
        })
    }
    
    func test_saveImageData_failsOnSuccessfulDeletionAndInsertionError() {
        let insertionError = anyNSError()
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: saveFailure(.failed), when: {
            store.completesDeletionSuccessfully()
            store.completesInsertionWith(insertionError)
        })
    }

    func test_saveImageData_succeedsOnSuccessfulDeletionAndInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(()), when: {
            store.completesDeletionSuccessfully()
            store.completesInsertionSuccessfully()
        })
    }

    func test_saveImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = PetStoreSpy()
        var sut: LocalPetImageDataLoader? = LocalPetImageDataLoader(store: store)
        var receivedResult: LocalPetImageDataLoader.SaveResult?
        sut?.save(data: anyData(), for: anyURL()) { result in receivedResult = result }
        
        sut = nil
        store.completesDeletionSuccessfully()
        
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
    
    private func expect(_ sut: LocalPetImageDataLoader, toCompleteWith expectedResult: LocalPetImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.save(data: anyData(), for: anyURL())  { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as LocalPetImageDataLoader.SaveError), .failure(expectedError as LocalPetImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError, "Expected failure with \(expectedError), got \(receivedError) instead", file: file, line: line)
                
            case let (.failure(receivedError as LocalPetImageDataLoader.DeleteError), .failure(expectedError as LocalPetImageDataLoader.DeleteError)):
                XCTAssertEqual(receivedError, expectedError, "Expected failure with \(expectedError), got \(receivedError) instead", file: file, line: line)
                
            case (.success, .success): break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func saveFailure(_ error: LocalPetImageDataLoader.SaveError) -> LocalPetImageDataLoader.SaveResult {
        return .failure(error)
    }
    
    private func deletionFailure(_ error: LocalPetImageDataLoader.DeleteError) -> LocalPetImageDataLoader.SaveResult {
        return .failure(error)
    }
}

