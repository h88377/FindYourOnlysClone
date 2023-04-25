//
//  CachePetImageDataUseCaseTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import XCTest
@testable import FindYourOnlysClone

class CachePetImageDataUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestImageInsertionUponCreation() {
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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalPetImageDataLoader, PetStoreSpy) {
        let store = PetStoreSpy()
        let sut = LocalPetImageDataLoader(store: store)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
}

