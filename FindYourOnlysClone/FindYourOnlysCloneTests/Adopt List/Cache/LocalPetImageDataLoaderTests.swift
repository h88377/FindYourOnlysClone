//
//  LocalPetImageDataLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import XCTest
@testable import FindYourOnlysClone

protocol PetImageDataStore {
    func retrieve(dataForURL url: URL)
}

final class LocalPetImageDataLoader: PetImageDataLoader {
    private struct LocalPetImageDataLoaderTask: PetImageDataLoaderTask {
        func cancel() {}
    }
    
    private let store: PetImageDataStore
    
    init(store: PetImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
        store.retrieve(dataForURL: url)
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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalPetImageDataLoader, PetStoreSpy) {
        let store = PetStoreSpy()
        let sut = LocalPetImageDataLoader(store: store)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private class PetStoreSpy: PetImageDataStore {
        private(set) var receivedURLs = [URL]()
        
        func retrieve(dataForURL url: URL) {
            receivedURLs.append(url)
        }
    }
}
