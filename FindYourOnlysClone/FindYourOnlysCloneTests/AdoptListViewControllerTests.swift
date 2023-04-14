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
        XCTAssertTrue(loader.loadPetsRequests.isEmpty, "Expected no loading request before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadPetsRequests, [.load(AdoptPetRequest(page: 0))], "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedPetsReload()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptPetRequest(page: 0)),
            .load(AdoptPetRequest(page: 0))
        ], "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedPetsReload()
        XCTAssertEqual(loader.loadPetsRequests, [
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
    
    func test_petImageView_loadsImageURLWhenVisible() {
        let pet0 = makePet(photoURL: URL(string:"https://url-0.com")!)
        let pet1 = makePet(photoURL: URL(string:"https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [pet0, pet1], at: 0)
        XCTAssertEqual(loader.requestedImageURLs, [], "Expected no requested image url until cells become visible")
        
        sut.simulatePetImageViewIsVisible(at: 0)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL], "Expected first requested image url when first cell become visible")
        
        sut.simulatePetImageViewIsVisible(at: 1)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL, pet1.photoURL], "Expected second requested image url when second cell become visible")
    }
    
    func test_petImageView_cancelsImageURLWhenIsNotVisibleAnymore() {
        let pet0 = makePet(photoURL: URL(string:"https://url-0.com")!)
        let pet1 = makePet(photoURL: URL(string:"https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.cancelledURLs, [], "Expected no cancelled URL request until cells become visible")
        loader.completesPetsLoading(with: [pet0, pet1], at: 0)
        
        sut.simulatePetImageViewIsNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledURLs, [pet0.photoURL], "Expected first cancelled URL request when first view is not visible anymore")
        
        sut.simulatePetImageViewIsNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledURLs, [pet0.photoURL, pet1.photoURL], "Expected second cancelled URL request when second view is not visible anymore")
    }
    
    func test_petImageViewLoadingIndicator_isVisibleWhenLoadingPet() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet(), makePet()], at: 0)
        
        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        let view1 = sut.simulatePetImageViewIsVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected first image loading indicator when loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected second image loading indicator when loading second image")
        
        loader.completesImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no image loading indicator when first image loading completes successfully")
        
        loader.completesImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no image loading indicator when second image loading completes with error")
    }
    
    func test_petImageView_rendersSuccessfullyLoadedImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet(), makePet()], at: 0)
        
        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        let view1 = sut.simulatePetImageViewIsVisible(at: 1)
        XCTAssertNil(view0?.renderedImageData, "Expected first view no image before first image loading completion")
        XCTAssertNil(view1?.renderedImageData, "Expected second view no image before second image loading completion")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completesImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImageData, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertNil(view1?.renderedImageData, "Expected no state change for secod image before completing image loading")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completesImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImageData, imageData0, "Expected no state change for first image once second view completes image loading successfully")
        XCTAssertEqual(view1?.renderedImageData, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (AdoptListViewController, PetLoaderSpy) {
        let loader = PetLoaderSpy()
        let sut = AdoptListViewController(loader: loader, imageLoader: loader)
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
    
    private func makePet(id: Int = 0, location: String = "any location", kind: String = "any kind", gender: String = "M", bodyType: String = "any body", color: String = "any color", age: String = "any age", sterilization: String = "NA", bacterin: String = "NA", foundPlace: String = "any place", status: String = "any status", remark: String = "NA", openDate: Date = Date(), closedDate: Date = Date(), updatedDate: Date = Date(), createdDate: Date = Date(), photoURL: URL = URL(string:"https://any-url.com")!, address: String = "any place", telephone: String = "02", variety: String = "any variety", shelterName: String = "any shelter") -> Pet {
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
    
    private class PetLoaderSpy: PetLoader, PetImageDataLoader {
        
        // MARK: - PetLoader
        
        enum Request: Equatable {
            case load(AdoptPetRequest)
        }
        
        var loadPetsRequests: [Request] {
            return loadPetsMessages.map { $0.request }
        }
        
        private var loadPetsMessages = [(request: Request, completion: (PetLoader.Result) -> Void)]()
        
        func load(with request: AdoptPetRequest, completion: @escaping (PetLoader.Result) -> Void) {
            loadPetsMessages.append((.load(request), completion))
        }
        
        func completesPetsLoading(with pets: [Pet] = [], at index: Int = 0) {
            loadPetsMessages[index].completion(.success(pets))
        }
        
        func completesPetsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "any error", code: 0)
            loadPetsMessages[index].completion(.failure(error))
        }
        
        // MARK: - PetImageDataLoader
        
        private struct TaskSpy: PetImageDataLoaderTask {
            let cancelHandler: () -> Void
            
            func cancel() {
                cancelHandler()
            }
        }
        
        private var requestedImageMessages = [(url: URL, completion: (PetImageDataLoader.Result) -> Void)]()
        
        var requestedImageURLs: [URL] {
            return requestedImageMessages.map { $0.url }
        }
        
        private(set) var cancelledURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
            requestedImageMessages.append((url, completion))
            
            return TaskSpy { [weak self] in  self?.cancelledURLs.append(url) }
        }
        
        func completesImageLoading(with data: Data = Data(), at index: Int = 0) {
            requestedImageMessages[index].completion(.success(data))
        }
        
        func completesImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "any error", code: 0)
            requestedImageMessages[index].completion(.failure(error))
        }
    }

}

private extension AdoptListViewController {
    func simulateUserInitiatedPetsReload() {
        collectionView.refreshControl?.simulateRefresh()
    }
    
    @discardableResult
    func simulatePetImageViewIsVisible(at index: Int) -> AdoptListCell? {
        let cell = itemAt(index: index)!
        let delegate = collectionView.delegate
        delegate?.collectionView?(collectionView, willDisplay: cell, forItemAt: IndexPath(item: index, section: petsSection))
        return cell as? AdoptListCell
    }
    
    func simulatePetImageViewIsNotVisible(at index: Int) {
        let cell = simulatePetImageViewIsVisible(at: index)!
        let delegate = collectionView.delegate
        delegate?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: IndexPath(item: index, section: petsSection))
    }
    
    func itemAt(index: Int) -> UICollectionViewCell? {
        let dataSource = collectionView.dataSource
        let cell = dataSource?.collectionView(collectionView, cellForItemAt: IndexPath(item: index, section: petsSection))
        return cell
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
    
    var isShowingImageLoadingIndicator: Bool {
        return petImageContainer.isShimmering
    }
    
    var renderedImageData: Data? {
        return petImageView.image?.pngData()
    }
}

private extension UIRefreshControl {
    func simulateRefresh() {
        sendActions(for: .valueChanged)
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
