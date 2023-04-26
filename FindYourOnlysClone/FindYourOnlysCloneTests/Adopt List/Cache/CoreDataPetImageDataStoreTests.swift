//
//  CoreDataPetImageDataStoreTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import XCTest
@testable import FindYourOnlysClone

final class CoreDataPetImageDataStore: PetImageDataStore {
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        
    }
}

class CoreDataPetImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversEmptyResultOnEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteWith: .success(.none))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataPetImageDataStore {
        let sut = CoreDataPetImageDataStore()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
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
