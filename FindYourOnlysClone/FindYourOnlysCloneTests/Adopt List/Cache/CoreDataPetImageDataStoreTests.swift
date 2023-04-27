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

        let exp = expectation(description: "Wait for completion")
        sut.insert(data: imageData, for: imageURL, timestamp: timestamp) { insertionResult in
            switch insertionResult {
            case .success:
                sut.retrieve(dataForURL: imageURL) { retrivalResult in
                    switch retrivalResult {
                    case let .success(cache):
                        XCTAssertEqual(cache?.timestamp, timestamp)
                        XCTAssertEqual(cache?.value, imageData)
                        XCTAssertEqual(cache?.url, imageURL)

                    default:
                        XCTFail("Expected successful retrival, got \(retrivalResult) instead")
                    }
                }

            default:
                XCTFail("Expected successful insertion, got \(insertionResult) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
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
        expect(sut, toCompleteWith: expectedResult)
        expect(sut, toCompleteWith: expectedResult)
    }
    
    private func expect(_ sut: CoreDataPetImageDataStore, toCompleteWith expectedResult: PetImageDataStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.retrieve(dataForURL: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, "Expected \(String(describing: expectedData)), got \(String(describing: receivedData)) instead")
                
            case (.failure, .failure): break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
