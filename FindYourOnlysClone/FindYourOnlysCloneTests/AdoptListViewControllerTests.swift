//
//  FindYourOnlysCloneTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/13.
//

import XCTest

struct AdoptPetRequest: Equatable {
    let page: Int
}

protocol PetLoader {
    func load(with request: AdoptPetRequest)
}

class AdoptListViewController: UICollectionViewController {
    private var loader: PetLoader?
    private var request = AdoptPetRequest(page: 0)
    
    convenience init(loader: PetLoader) {
        self.init(collectionViewLayout: UICollectionViewLayout())
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load(with: request)
    }
}

final class AdoptListViewControllerTests: XCTestCase {
    
    func test_init_doesNotRequestPetsFromLoader() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.messages.isEmpty)
    }
    
    func test_viewDidLoad_requestPetsFromLoader() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.messages, [.load(AdoptPetRequest(page: 0))])
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
        enum Message: Equatable {
            case load(AdoptPetRequest)
        }
        
        var loadPetCallCount: Int {
            return messages.count
        }
        
        private(set) var messages = [Message]()
        
        func load(with request: AdoptPetRequest) {
            messages.append(.load(request))
        }
    }

}
