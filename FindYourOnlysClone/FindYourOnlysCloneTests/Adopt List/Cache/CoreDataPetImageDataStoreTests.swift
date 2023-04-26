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
        let exp = expectation(description: "Wait for completion")
        
        sut.retrieve(dataForURL: anyURL()) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, .none, "Expected empty result, got \(String(describing: receivedData)) instead")
            default:
                XCTFail("Expected succeed with empty data, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataPetImageDataStore {
        let sut = CoreDataPetImageDataStore()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
}
