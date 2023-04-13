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
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadPetCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (AdoptListViewController, PetLoaderSpy) {
        let loader = PetLoaderSpy()
        let sut = AdoptListViewController(loader: loader)
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private class PetLoaderSpy: PetLoader {
        private(set) var loadPetCallCount = 0
    }

}
