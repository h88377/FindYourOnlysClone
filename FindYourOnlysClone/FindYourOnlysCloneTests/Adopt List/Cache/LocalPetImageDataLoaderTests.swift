//
//  LocalPetImageDataLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import XCTest

protocol PetStore {
    
}

final class LocalPetImageDataLoader {
    private let store: PetStore
    
    init(store: PetStore) {
        self.store = store
    }
}

class LocalPetImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestImageDataUponCreation() {
        let store = PetStoreSpy()
        _ = LocalPetImageDataLoader(store: store)
        
        XCTAssertEqual(store.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private class PetStoreSpy: PetStore {
        private(set) var loadCallCount = 0
        
        func loadImageData() {
            
        }
    }
}
