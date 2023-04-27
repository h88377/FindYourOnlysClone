//
//  CoreDataPetImageDataStoreTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import XCTest
@testable import FindYourOnlysClone

class CoreDataPetImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversEmptyResultOnEmpty() {
        let sut = makeSUT()

        expect(sut, toCompleteWith: .success(.none))
    }

    func test_retrieveImageData_hasNoSideEffectsOnEmptyResult() {
        let sut = makeSUT()

        expect(sut, toCompleteTwiceWith: .success(.none))
    }
    
    func test_retrieveImageData_deliversFoundValuesOnNonEmptyCache() {
        let imageData = anyData()
        let imageURL = anyURL()
        let timestamp = Date()
        let sut = makeSUT()

        insert(data: imageData, for: imageURL, timestamp: timestamp, in: sut)
        
        expect(sut, toCompleteWith: .success(CachedPetImageData(timestamp: timestamp, url: imageURL, value: imageData)))
    }
    
    func test_retrieveImageData_hasNoSideEffectsOnNonEmptyCache() {
        let imageData = anyData()
        let imageURL = anyURL()
        let timestamp = Date()
        let sut = makeSUT()

        insert(data: imageData, for: imageURL, timestamp: timestamp, in: sut)
        
        expect(sut, toCompleteTwiceWith: .success(CachedPetImageData(timestamp: timestamp, url: imageURL, value: imageData)))
    }
    
    func test_insertImageData_succeedsOnEmptyCache() {
        let sut = makeSUT()

        let result = insert(data: anyData(), for: anyURL(), timestamp: Date(), in: sut)
        switch result {
            case .success: break
            default: XCTFail("Expected successful insertion, got \(String(describing: result)) instead")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataPetImageDataStore {
        let bundle = Bundle(for: CoreDataPetImageDataStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataPetImageDataStore(bundle: bundle, storeURL: storeURL)
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CoreDataPetImageDataStore, toCompleteTwiceWith expectedResult: PetImageDataStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteWith: expectedResult, file: file, line: line)
        expect(sut, toCompleteWith: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CoreDataPetImageDataStore, toCompleteWith expectedResult: PetImageDataStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.retrieve(dataForURL: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, "Expected \(String(describing: expectedData)), got \(String(describing: receivedData)) instead", file: file, line: line)
                
            case (.failure, .failure): break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    private func insert(data: Data, for url: URL, timestamp: Date, in sut: CoreDataPetImageDataStore) -> PetImageDataStore.InsertionResult? {
        let exp = expectation(description: "Wait for completion")
        
        var insertionResult: PetImageDataStore.InsertionResult?
        sut.insert(data: data, for: url, timestamp: timestamp) { result in
            insertionResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionResult
    }
}
