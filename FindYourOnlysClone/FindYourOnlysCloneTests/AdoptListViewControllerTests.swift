//
//  FindYourOnlysCloneTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/13.
//

import XCTest
@testable import FindYourOnlysClone

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
        assertThat(sut, isRendering: [])
        
        loader.completesPetsLoading(with: [pet0], at: 0)
        assertThat(sut, isRendering: [pet0])
        
        sut.simulateUserInitiatedPetsReload()
        loader.completesPetsLoading(with: [pet0, pet1], at: 1)
        assertThat(sut, isRendering: [pet0, pet1])
    }
    
    func test_loadPetsCompletions_doesNotAlterCurrentRenderingStateOnError() {
        let pet0 = makePet(id: 0)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completesPetsLoading(with: [pet0], at: 0)
        assertThat(sut, isRendering: [pet0])
        
        sut.simulateUserInitiatedPetsReload()
        loader.completesPetsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [pet0])
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
    
    private func assertThat(_ sut: AdoptListViewController, isRendering pets: [Pet], file: StaticString = #filePath, line: UInt = #line) {
        guard pets.count == sut.numberOfPets else {
            return XCTFail("Expected \(pets.count), got \(sut.numberOfPets) instead")
        }
        
        for (index, pet) in pets.enumerated() {
            assertThat(sut, hasViewConfiguredFor: pet, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: AdoptListViewController, hasViewConfiguredFor pet: Pet, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.itemAt(index: 0)
        guard let cell = view as? AdoptListCell else {
            return XCTFail("Expected \(AdoptListCell.self) instance, got \(String(describing: view.self)) instead")
        }
        
        XCTAssertEqual(cell.genderText, pet.gender == "M" ? "♂" : "♀", "Expected gender text should be \(pet.gender == "M" ? "♂" : "♀") at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.kindText, pet.kind, "Expected kind text should be \(pet.kind) at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.cityText, String(pet.address[...2]), "Expected city text should be \(String(pet.address[...2])) at index \(index)", file: file, line: line)
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

private extension AdoptListCell {
    var kindText: String? {
        return kindLabel.text
    }
    
    var genderText: String? {
        return genderLabel.text
    }
    
    var cityText: String? {
        return cityLabel.text
    }
}

private extension UIRefreshControl {
    func simulateRefresh() {
        sendActions(for: .valueChanged)
    }
}
