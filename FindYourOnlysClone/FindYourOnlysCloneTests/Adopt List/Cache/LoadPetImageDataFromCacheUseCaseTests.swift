//
//  LocalPetImageDataLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import XCTest
@testable import FindYourOnlysClone

class LoadPetImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestImageDataUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
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
            store.completesRetrivalWith(storeError)
        })
    }
    
    func test_loadImageData_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.notFound), when: {
            store.completesRetrivalWith(.none)
        })
    }
    
    func test_loadImageData_deliversImageDataOnNonExpiredCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT { currentDate }
        
        let nonExpiredTimestamp = currentDate.adding(days: -1)
        let imageData = anyData()
        let foundCache = CachedPetImageData(timestamp: nonExpiredTimestamp, value: imageData)
        
        expect(sut, toCompleteWith: .success(imageData), when: {
            store.completesRetrivalWith(foundCache)
        })
    }
    
    func test_loadImageData_deliversNotFoundErrorOnExpiredCache() {
        let currentDate = Date()
        let (sut, store) = makeSUT { currentDate }
        
        let expiredTimestamp = currentDate.adding(days: -7).adding(second: -1)
        let expiredCache = CachedPetImageData(timestamp: expiredTimestamp, value: anyData())
        
        expect(sut, toCompleteWith: failure(.notFound), when: {
            store.completesRetrivalWith(expiredCache)
        })
    }
    
    func test_loadImageData_doesNotDeliverResultAfterTaskHasBeenCancelled() {
        let (sut, store) = makeSUT()
        
        var receivedResult: LocalPetImageDataLoader.Result?
        let task = sut.loadImageData(from: anyURL()) { result in receivedResult = result }
        task.cancel()
        
        store.completesRetrivalWith(anyNSError())
        store.completesRetrivalWith(CachedPetImageData(timestamp: Date(), value: anyData()))
        store.completesRetrivalWith(.none)
        
        XCTAssertNil(receivedResult)
    }
    
    func test_loadImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = PetStoreSpy()
        var sut: LocalPetImageDataLoader? = LocalPetImageDataLoader(store: store, currentDate: Date.init)
        var receivedResult: LocalPetImageDataLoader.Result?
        _ = sut?.loadImageData(from: anyURL()) { result in receivedResult = result }
        
        sut = nil
        
        store.completesRetrivalWith(anyNSError())
        XCTAssertNil(receivedResult)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalPetImageDataLoader, PetStoreSpy) {
        let store = PetStoreSpy()
        let sut = LocalPetImageDataLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalPetImageDataLoader, toCompleteWith expectedResult: LocalPetImageDataLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as LocalPetImageDataLoader.LoadError), .failure(expectedError as LocalPetImageDataLoader.LoadError)):
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
     
    private func failure(_ error: LocalPetImageDataLoader.LoadError) -> LocalPetImageDataLoader.Result {
        return .failure(error)
    }
}

private extension Date {
    func adding(second: Double) -> Date {
        return self + second
    }
    
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}
