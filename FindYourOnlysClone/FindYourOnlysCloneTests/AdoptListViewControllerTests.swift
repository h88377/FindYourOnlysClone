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
    func load(with request: AdoptPetRequest, completion: @escaping () -> Void)
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
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(loadPets), for: .valueChanged)
        loadPets()
    }
    
    @objc private func loadPets() {
        collectionView.refreshControl?.beginRefreshing()
        loader?.load(with: request) { [weak self] in
            self?.collectionView?.refreshControl?.endRefreshing()
        }
    }
}

final class AdoptListViewControllerTests: XCTestCase {
    
    func test_loadPetsActions_requestsPetsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertTrue(loader.messages.isEmpty, "Expected no loading request before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.messages, [.load(AdoptPetRequest(page: 0))], "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedPetsReload()
        XCTAssertEqual(loader.messages, [
            .load(AdoptPetRequest(page: 0)),
            .load(AdoptPetRequest(page: 0))
        ], "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedPetsReload()
        XCTAssertEqual(loader.messages, [
            .load(AdoptPetRequest(page: 0)),
            .load(AdoptPetRequest(page: 0)),
            .load(AdoptPetRequest(page: 0))
        ], "Expected yet another loading request once user initiates a reload")
    }
    
    func test_loadingIndicator_showsLoadingIndicatorWhileLoadingPets() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completesPetsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedPetsReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiate a reload")
        
        loader.completesPetsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
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
        private var completions = [() -> Void]()
        
        func load(with request: AdoptPetRequest, completion: @escaping () -> Void) {
            messages.append(.load(request))
            completions.append(completion)
        }
        
        func completesPetsLoading(at index: Int = 0) {
            completions[index]()
        }
    }

}

private extension AdoptListViewController {
    func simulateUserInitiatedPetsReload() {
        collectionView.refreshControl?.simulateRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return collectionView.refreshControl?.isRefreshing == true
    }
}

private extension UIRefreshControl {
    func simulateRefresh() {
        sendActions(for: .valueChanged)
    }
}
