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
        XCTAssertEqual(loader.loadPetsRequests, [.load(AdoptListRequest(page: 0))], "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedPetsReload()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 0))
        ], "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedPetsReload()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 0))
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
    
    func test_petImageViewRetryButton_isVisibleOnPetImageLoadedError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet(), makePet()], at: 0)
        
        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        let view1 = sut.simulatePetImageViewIsVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageRetryAction, false, "Expected first view no retry action before first image loading completion")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected second view no retry action before second image loading completion")
        
        loader.completesImageLoadingWithError(at: 0)
        XCTAssertEqual(view0?.isShowingImageRetryAction, true, "Expected first view is showing retry action once first image completes with error")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected no retry action state change for second view once first image loading completes with error")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completesImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.isShowingImageRetryAction, true, "Expected first view is showing retry action once first image completes with error")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected second view no retry action once second image loading completes successfully")
    }
    
    func test_petImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet(), makePet()], at: 0)
        
        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        let view1 = sut.simulatePetImageViewIsVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageRetryAction, false, "Expected first view no retry action before first image loading completion")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected second view no retry action before second image loading completion")
        
        let invalidImageData = Data("invalid data".utf8)
        loader.completesImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view0?.isShowingImageRetryAction, true, "Expected first view is showing retry action once first image completes with invalid data")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected no retry action state change for second view once first image loading completes with invalid data")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completesImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.isShowingImageRetryAction, true, "Expected first view is showing retry action once first image completes with invalid data")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected second view no retry action once second image loading completes successfully")
    }
    
    func test_petImageViewRetryAction_retriesImageLoad() {
        let pet0 = makePet(photoURL: URL(string:"https://url-0.com")!)
        let pet1 = makePet(photoURL: URL(string:"https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [pet0, pet1], at: 0)
        
        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        let view1 = sut.simulatePetImageViewIsVisible(at: 1)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL, pet1.photoURL], "Expected two image URL requests for the two visible views")
        
        loader.completesImageLoadingWithError(at: 0)
        loader.completesImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL, pet1.photoURL], "Expected only two URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL, pet1.photoURL, pet0.photoURL], "Expected third image URL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL, pet1.photoURL, pet0.photoURL, pet1.photoURL], "Expected fourth image URL request after second view retry action")
    }
    
    func test_petImageView_preloadsImageURLWhenNearVisible() {
        let pet0 = makePet(photoURL: URL(string:"https://url-0.com")!)
        let pet1 = makePet(photoURL: URL(string:"https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [pet0, pet1], at: 0)
        XCTAssertEqual(loader.requestedImageURLs, [], "Expected no requested image url until cells near visible")
        
        sut.simulatePetImageViewIsNearVisible(at: 0)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL], "Expected first requested image url when first cell near visible")
        
        sut.simulatePetImageViewIsNearVisible(at: 1)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL, pet1.photoURL], "Expected second requested image url when second cell near visible")
    }
    
    func test_petImageView_cancelsImageURLWhenIsNotNearVisibleAnymore() {
        let pet0 = makePet(photoURL: URL(string:"https://url-0.com")!)
        let pet1 = makePet(photoURL: URL(string:"https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.cancelledURLs, [], "Expected no cancelled URL request until cells are not near visible")
        loader.completesPetsLoading(with: [pet0, pet1], at: 0)
        
        sut.simulatePetImageViewIsNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledURLs, [pet0.photoURL], "Expected first cancelled URL request when first view is not near visible anymore")
        
        sut.simulatePetImageViewIsNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledURLs, [pet0.photoURL, pet1.photoURL], "Expected second cancelled URL request when second view is not near visible anymore")
    }
    
    func test_paginationActions_requestsPetsFromLoader() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadPetsRequests, [.load(AdoptListRequest(page: 0))], "Expected a loading request once view is loaded")

        loader.completesPetsLoading(with: [makePet(id: 1)], at: 0)
        sut.simulatePaginationScrolling()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 1))
        ], "Expected pagination loading request once user scrolling the view")
        
        loader.completesPetsLoading(with: [makePet(id: 1)], at: 1)
        sut.simulateUserInitiatedPetsReload()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 1)),
            .load(AdoptListRequest(page: 0))
        ], "Expected request first page once user initiated a reload")
        
        loader.completesPetsLoading(with: [makePet(id: 2)], at: 2)
        sut.simulatePaginationScrolling()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 1)),
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 1))
        ], "Expected another pagination loading request once user scrolling the view")
    }
    
    func test_refresh_afterPaginationRequest_rendersOnlyTheFirstPage() {
        let firstPage = (0...3).map { makePet(id: $0) }
        let secondPage = (4...6).map { makePet(id: $0) }
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completesPetsLoading(with: firstPage, at: 0)
        assertThat(sut, isRendering: firstPage)
        
        sut.simulatePaginationScrolling()
        loader.completesPetsLoading(with: secondPage, at: 1)
        assertThat(sut, isRendering: firstPage + secondPage)
        
        sut.simulateUserInitiatedPetsReload()
        loader.completesPetsLoading(with: firstPage, at: 2)
        assertThat(sut, isRendering: firstPage)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (AdoptListViewController, PetLoaderSpy) {
        let loader = PetLoaderSpy()
        let viewModel = AdoptListViewModel(petLoader: loader)
        let sut = AdoptListViewController(viewModel: viewModel)
        
        viewModel.isPetsRefreshingStateOnChange = { [weak sut] pets in
            let cellControllers = pets.map { pet in
                let cellViewModel = AdoptListCellViewModel(pet: pet, imageLoader: loader, imageTransformer: UIImage.init)
                let cellController = AdoptListCellViewController(viewModel: cellViewModel)
                return cellController
            }
            sut?.set(cellControllers)
        }
        viewModel.isPetsAppendingStateOnChange = { [weak sut] pets in
            let cellControllers = pets.map { pet in
                let cellViewModel = AdoptListCellViewModel(pet: pet, imageLoader: loader, imageTransformer: UIImage.init)
                let cellController = AdoptListCellViewController(viewModel: cellViewModel)
                return cellController
            }
            sut?.append(cellControllers)
        }
        
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
            case load(AdoptListRequest)
        }
        
        var loadPetsRequests: [Request] {
            return loadPetsMessages.map { $0.request }
        }
        
        private var loadPetsMessages = [(request: Request, completion: (PetLoader.Result) -> Void)]()
        
        func load(with request: AdoptListRequest, completion: @escaping (PetLoader.Result) -> Void) {
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
    
    func simulatePetImageViewIsNearVisible(at index: Int) {
        let dataSource = collectionView.prefetchDataSource
        dataSource?.collectionView(collectionView, prefetchItemsAt: [IndexPath(item: index, section: petsSection)])
    }
    
    func simulatePetImageViewIsNotNearVisible(at index: Int) {
        simulatePetImageViewIsNearVisible(at: index)
        let dataSource = collectionView.prefetchDataSource
        dataSource?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [IndexPath(item: index, section: petsSection)])
    }
    
    func simulatePaginationScrolling() {
        let scrollView = DraggingScrollView()
        scrollView.contentOffset.y = 1000
        scrollViewDidScroll(scrollView)
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
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
    
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
    
    var isShowingImageRetryAction: Bool {
        return !retryButton.isHidden
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

private extension UIButton {
    func simulateTap() {
        sendActions(for: .touchUpInside)
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

private class DraggingScrollView: UIScrollView {
    override var isDragging: Bool {
        return true
    }
}
