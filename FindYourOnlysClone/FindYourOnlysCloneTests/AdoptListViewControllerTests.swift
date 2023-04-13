//
//  FindYourOnlysCloneTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/13.
//

import XCTest
@testable import FindYourOnlysClone

extension StringProtocol {
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
}

class AdoptListViewController: UICollectionViewController {
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, Pet> = {
        .init(collectionView: collectionView) { collectionView, indexPath, pet in
            let cell = AdoptListPetCell()
            cell.genderLabel.text = pet.gender == "M" ? "♂" : "♀"
            cell.kindLabel.text = pet.kind
            cell.cityLabel.text = String(pet.address[...2])
            return cell
        }
    }()
    
    private var request = AdoptPetRequest(page: 0)
    private var loader: PetLoader?
    
    convenience init(loader: PetLoader) {
        self.init(collectionViewLayout: UICollectionViewLayout())
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(loadPets), for: .valueChanged)
        collectionView.dataSource = self.dataSource
        loadPets()
    }
    
    @objc private func loadPets() {
        collectionView.refreshControl?.beginRefreshing()
        loader?.load(with: request) { [weak self] result in
            if let pets = try? result.get() {
                self?.set(pets)
            }
            self?.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    private func set(_ newItems: [Pet]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Pet>()
        snapshot.appendSections([0])
        snapshot.appendItems(newItems, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
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
        
        loader.completesPetsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes with error")
    }
    
    func test_loadPetsCompletions_rendersSuccessfullyLoadedPets() {
        let pet0 = makePet(id: 0)
        let pet1 = makePet(id: 0)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completesPetsLoading(at: 0)
        XCTAssertEqual(sut.numberOfPets, 0)
        
        sut.simulateUserInitiatedPetsReload()
        loader.completesPetsLoading(with: [pet0, pet1], at: 1)
        
        XCTAssertEqual(sut.numberOfPets, 2)
        let cell0 = sut.itemAt(index: 0) as? AdoptListPetCell
        XCTAssertEqual(cell0?.genderLabel.text, pet0.gender == "M" ? "♂" : "♀")
        XCTAssertEqual(cell0?.kindLabel.text, pet0.kind)
        XCTAssertEqual(cell0?.cityLabel.text, String(pet0.address[...2]))
        
        let cell1 = sut.itemAt(index: 1) as? AdoptListPetCell
        XCTAssertEqual(cell1?.genderLabel.text, pet0.gender == "M" ? "♂" : "♀")
        XCTAssertEqual(cell1?.kindLabel.text, pet0.kind)
        XCTAssertEqual(cell1?.cityLabel.text, String(pet0.address[...2]))
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
    
    private func makePet(id: Int, location: String = "any location", kind: String = "any kind", gender: String = "M", bodyType: String = "any body", color: String = "any color", age: String = "any age", sterilization: String = "NA", bacterin: String = "NA", foundPlace: String = "any place", status: String = "any status", remark: String = "NA", openDate: Date = Date(), closedDate: Date = Date(), updatedDate: Date = Date(), createdDate: Date = Date(), photoURL: URL = URL(string:"https://any-url.com")!, address: String = "any place", telephone: String = "02", variety: String = "any variety", shelterName: String = "any shelter") -> Pet {
        let pet = Pet(
            id: id,
            location: location,
            kind: kind,
            gender: gender,
            bodyType: bodyType,
            color: color,
            age: age,
            sterilization: sterilization,
            bacterin: bacterin,
            foundPlace: foundPlace,
            status: status,
            remark: remark,
            openDate: openDate,
            closedDate: closedDate,
            updatedDate: updatedDate,
            createdDate: createdDate,
            photoURL: photoURL,
            address: address,
            telephone: telephone,
            variety: variety,
            shelterName: shelterName
        )
        return pet
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
        
        func completesPetsLoading(with pets: [Pet] = [], at index: Int = 0) {
            completions[index](.success(pets))
        }
        
        func completesPetsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "any error", code: 0)
            completions[index](.failure(error))
        }
    }

}

private extension AdoptListViewController {
    func simulateUserInitiatedPetsReload() {
        collectionView.refreshControl?.simulateRefresh()
    }
    
    func itemAt(index: Int) -> UICollectionViewCell? {
        let dataSource = collectionView.dataSource
        return dataSource?.collectionView(collectionView, cellForItemAt: IndexPath(item: index, section: 0))
    }
    
    var isShowingLoadingIndicator: Bool {
        return collectionView.refreshControl?.isRefreshing == true
    }
    
    var numberOfPets: Int {
        return collectionView.numberOfSections == 0 ? 0 : collectionView.numberOfItems(inSection: petsSection)
    }
    
    private var petsSection: Int { return 0 }
}

private extension UIRefreshControl {
    func simulateRefresh() {
        sendActions(for: .valueChanged)
    }
}
