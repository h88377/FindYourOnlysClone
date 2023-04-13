//
//  FindYourOnlysCloneTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/13.
//

import XCTest

protocol PetLoader {
    
}

class AdoptListViewController: UICollectionViewController {
    private var loader: PetLoader?
    
    convenience init(loader: PetLoader) {
        self.init()
        self.loader = loader
    }
}

final class AdoptListViewControllerTests: XCTestCase {
    
    func test_init_doesNotRequestPetsFromLoader() {
        let loader = PetLoaderSpy()
        let _ = AdoptListViewController(loader: loader)
        
        XCTAssertEqual(loader.loadPetCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private class PetLoaderSpy: PetLoader {
        private(set) var loadPetCallCount = 0
    }

}
