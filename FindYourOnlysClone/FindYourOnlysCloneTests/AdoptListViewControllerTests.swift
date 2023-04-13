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

struct Pet {
    let id: Int
    let location: String
    let kind: String
    let gender: String
    let bodyType: String
    let color: String
    let age: String
    let sterilization: String
    let bacterin: String
    let foundPlace: String
    let status: String
    let remark: String
    let openDate: Date
    let closedDate: Date
    let updatedDate: Date
    let createdDate: Date
    let photoURL: URL
    let address: String
    let telephone: String
    let variety: String
    let shelterName: String
}

protocol PetLoader {
    typealias Result = Swift.Result<[Pet], Error>
    
    func load(with request: AdoptPetRequest, completion: @escaping (Result) -> Void)
}

class AdoptListViewController: UICollectionViewController {
    private var request = AdoptPetRequest(page: 0)
    private var pets = [Pet]()
    
    private var loader: PetLoader?
    
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
        loader?.load(with: request) { [weak self] _ in
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
        private var completions = [(PetLoader.Result) -> Void]()
        
        func load(with request: AdoptPetRequest, completion: @escaping (PetLoader.Result) -> Void) {
            messages.append(.load(request))
            completions.append(completion)
        }
        
        func completesPetsLoading(at index: Int = 0, with pets: [Pet] = []) {
            completions[index](.success(pets))
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
