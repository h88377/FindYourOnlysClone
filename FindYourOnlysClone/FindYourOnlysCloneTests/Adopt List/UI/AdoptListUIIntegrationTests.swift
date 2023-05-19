//
//  FindYourOnlysCloneTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/13.
//

import XCTest
@testable import FindYourOnlysClone

class AdoptListUIIntegrationTests: XCTestCase {
    
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
    
    func test_loadPetsCompletions_showsErrorViewOnError() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completesPetsLoadingWithError()
        XCTAssertTrue(sut.isShowingErrorView, "Expected error view once pets loading completes with error")
        
        let exp = expectation(description: "Wait for error view hiding completion")
        DispatchQueue.main.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
        XCTAssertFalse(sut.isShowingErrorView, "Expected no error view once shows animation completes")
    }
    
    func test_loadPetsCompletions_showsNoResultOnEmptyResult() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingNoResultReminder, "Expected no reminder before pets loading completion")
        
        loader.completesPetsLoadingWithError(at: 0)
        XCTAssertTrue(sut.isShowingNoResultReminder, "Expected reminder after pets loading completes with error")
        
        sut.simulateUserInitiatedPetsReload()
        loader.completesPetsLoading(with: [makePet()], at: 1)
        XCTAssertFalse(sut.isShowingNoResultReminder, "Expected no reminder after pets loading completes with pets")
        
        sut.simulateUserInitiatedPetsReload()
        loader.completesPetsLoadingWithError(at: 2)
        XCTAssertFalse(sut.isShowingNoResultReminder, "Expected no reminder after pets loading completes with error but there are pets from previous request")
        
        sut.simulateUserInitiatedPetsReload()
        loader.completesPetsLoading(with: [], at: 3)
        XCTAssertTrue(sut.isShowingNoResultReminder, "Expected no reminder after pets loading completes with empty result")
    }
    
    func test_petImageView_loadsImageURLWhenVisible() {
        let pet0 = makePet(photoURL: URL(string:"https://url-0.com")!)
        let pet1 = makePet(photoURL: nil)
        let pet2 = makePet(photoURL: URL(string:"https://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [pet0, pet1, pet2], at: 0)
        XCTAssertEqual(loader.requestedImageURLs, [], "Expected no requested image url until cells become visible")

        sut.simulatePetImageViewIsVisible(at: 0)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL], "Expected first requested image url when first cell become visible")

        sut.simulatePetImageViewIsVisible(at: 1)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL], "Expected no requested image url state change when second cell become visible")

        sut.simulatePetImageViewIsVisible(at: 2)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL, pet2.photoURL], "Expected second requested image url when third cell become visible")
    }

    func test_petImageViewLoadingIndicator_isVisibleWhenLoadingPet() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet(), makePet(), makePet(photoURL: nil)], at: 0)

        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        let view1 = sut.simulatePetImageViewIsVisible(at: 1)
        let view2 = sut.simulatePetImageViewIsVisible(at: 2)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected first image loading indicator when loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected second image loading indicator when loading second image")
        XCTAssertEqual(view2?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change when third view is visible")

        loader.completesImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no image loading indicator when first image loading completes successfully")

        loader.completesImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no image loading indicator when second image loading completes with error")
    }

    func test_petImageView_rendersSuccessfullyLoadedImage() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet(photoURL: nil), makePet(), makePet()], at: 0)

        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        let view1 = sut.simulatePetImageViewIsVisible(at: 1)
        let view2 = sut.simulatePetImageViewIsVisible(at: 2)
        XCTAssertNil(view0?.renderedImageData, "Expected first view no image when it is visible")
        XCTAssertNil(view1?.renderedImageData, "Expected second view no image before second image loading completion")
        XCTAssertNil(view2?.renderedImageData, "Expected third view no image before third image loading completion")

        let imageData1 = UIImage.make(withColor: .red).pngData()!
        loader.completesImageLoading(with: imageData1, at: 0)
        XCTAssertNil(view0?.renderedImageData, "Expected no state change for first image once second view completes image loading successfully")
        XCTAssertEqual(view1?.renderedImageData, imageData1, "Expected image for second view once first image loading completes successfully")
        XCTAssertNil(view2?.renderedImageData, "Expected no state change for third image before completing image loading")

        let imageData2 = UIImage.make(withColor: .blue).pngData()!
        loader.completesImageLoading(with: imageData2, at: 1)
        XCTAssertNil(view0?.renderedImageData, "Expected no state change for first image once third view completes image loading successfully")
        XCTAssertEqual(view1?.renderedImageData, imageData1, "Expected no state change for second image once second view completes image loading successfully")
        XCTAssertEqual(view2?.renderedImageData, imageData2, "Expected image for third view once third image loading completes successfully")
    }

    func test_petImageViewRetryButton_isVisibleOnPetImageLoadedError() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet(), makePet(), makePet(photoURL: nil)], at: 0)

        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        let view1 = sut.simulatePetImageViewIsVisible(at: 1)
        let view2 = sut.simulatePetImageViewIsVisible(at: 2)
        XCTAssertEqual(view0?.isShowingImageRetryAction, false, "Expected first view no retry action before first image loading completion")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected second view no retry action before second image loading completion")
        XCTAssertEqual(view2?.isShowingImageRetryAction, false, "Expected third view no retry action when it is visible")

        loader.completesImageLoadingWithError(at: 0)
        XCTAssertEqual(view0?.isShowingImageRetryAction, true, "Expected first view is showing retry action once first image completes with error")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected no retry action state change for second view once first image loading completes with error")
        XCTAssertEqual(view2?.isShowingImageRetryAction, false, "Expected no retry action state change for third view once first image loading completes with error")

        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completesImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.isShowingImageRetryAction, true, "Expected first view is showing retry action once first image completes with error")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected second view no retry action once second image loading completes successfully")
        XCTAssertEqual(view2?.isShowingImageRetryAction, false, "Expected no retry action state change for third view once second image loading completes successfully")
    }

    func test_petImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet(), makePet(), makePet(photoURL: nil)], at: 0)

        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        let view1 = sut.simulatePetImageViewIsVisible(at: 1)
        let view2 = sut.simulatePetImageViewIsVisible(at: 2)
        XCTAssertEqual(view0?.isShowingImageRetryAction, false, "Expected first view no retry action before first image loading completion")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected second view no retry action before second image loading completion")
        XCTAssertEqual(view2?.isShowingImageRetryAction, false, "Expected third view no retry action when it is visible")

        let invalidImageData = Data("invalid data".utf8)
        loader.completesImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view0?.isShowingImageRetryAction, true, "Expected first view is showing retry action once first image completes with invalid data")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected no retry action state change for second view once first image loading completes with invalid data")
        XCTAssertEqual(view2?.isShowingImageRetryAction, false, "Expected no retry action state change for third view once first image loading completes with invalid data")

        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completesImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.isShowingImageRetryAction, true, "Expected first view is showing retry action once first image completes with invalid data")
        XCTAssertEqual(view1?.isShowingImageRetryAction, false, "Expected second view no retry action once second image loading completes successfully")
        XCTAssertEqual(view2?.isShowingImageRetryAction, false, "Expected no retry action state change for third view once second image loading completes with invalid data")

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
        let pet2 = makePet(photoURL: nil)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [pet0, pet1, pet2], at: 0)
        XCTAssertEqual(loader.requestedImageURLs, [], "Expected no requested image url until cells near visible")

        sut.simulatePetImageViewIsNearVisible(at: 0)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL], "Expected first requested image url when first cell near visible")

        sut.simulatePetImageViewIsNearVisible(at: 1)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL, pet1.photoURL], "Expected second requested image url when second cell near visible")

        sut.simulatePetImageViewIsNearVisible(at: 2)
        XCTAssertEqual(loader.requestedImageURLs, [pet0.photoURL, pet1.photoURL], "Expected no requested image url state change when third cell near visible")
    }

    func test_petImageView_cancelsImageURLWhenIsNotNearVisibleAnymore() {
        let pet0 = makePet(photoURL: URL(string:"https://url-0.com")!)
        let pet1 = makePet(photoURL: URL(string:"https://url-1.com")!)
        let pet2 = makePet(photoURL: nil)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.cancelledURLs, [], "Expected no cancelled URL request until cells are not near visible")
        loader.completesPetsLoading(with: [pet0, pet1, pet2], at: 0)

        sut.simulatePetImageViewIsNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledURLs, [pet0.photoURL], "Expected first cancelled URL request when first view is not near visible anymore")

        sut.simulatePetImageViewIsNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledURLs, [pet0.photoURL, pet1.photoURL], "Expected second cancelled URL request when second view is not near visible anymore")

        sut.simulatePetImageViewIsNotNearVisible(at: 2)
        XCTAssertEqual(loader.cancelledURLs, [pet0.photoURL, pet1.photoURL], "Expected no cancelled URL request state change when third view is not near visible anymore")
    }

    func test_paginationActions_requestsPetsFromLoader() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptListRequest(page: 0))
        ], "Expected a loading request once view is loaded")

        loader.completesPetsLoadingWithError(at: 0)
        sut.simulatePaginationScrolling()
        sut.simulatePaginationScrolling()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptListRequest(page: 0))
        ], "Expected no loading request from pagination when no result on the screen")

        sut.simulateUserInitiatedPetsReload()
        sut.simulatePaginationScrolling()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 0))
        ], "Expected request only page 0 once user initiated a reload and can't trigger a pagination before completion")

        loader.completesPetsLoading(with: [makePet(id: 2)], at: 1)
        sut.simulatePaginationScrolling()
        sut.simulatePaginationScrolling()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 1))
        ], "Expected only page 1 pagination loading request once user scrolling the view and can't trigger another pagination before completion")

        loader.completesPetsLoading(with: [makePet(id: 2)], at: 2)
        sut.simulatePaginationScrolling()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 1)),
            .load(AdoptListRequest(page: 2))
        ], "Expected page 2 pagination loading request once user scrolling the view and previous pagination request have completed successfully")
        
        loader.completesPetsLoadingWithError(at: 3)
        sut.simulatePaginationScrolling()
        XCTAssertEqual(loader.loadPetsRequests, [
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 0)),
            .load(AdoptListRequest(page: 1)),
            .load(AdoptListRequest(page: 2)),
            .load(AdoptListRequest(page: 2))
        ], "Expected another page 2 pagination loading request once user scrolling the view and previous pagination request have completed with error")
    }
    
    func test_paginationActions_showsErrorViewOnError() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet()], at: 0)
        
        sut.simulatePaginationScrolling()
        loader.completesPetsLoadingWithError(at: 1)
        XCTAssertTrue(sut.isShowingErrorView)
    }
    
    func test_refresh_afterPaginationRequest_rendersOnlyTheFirstPage() {
        let firstPage = (0...3).map { makePet(id: $0) }
        let secondPage = (4...6).map { makePet(id: $0, photoURL: nil) }
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
    
    func test_petImageView_cancelsImageURLWhenCellIsReused() {
        let pet0 = makePet(photoURL: URL(string:"https://url-0.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [pet0])

        XCTAssertEqual(loader.cancelledURLs, [], "Expected no cancelled URL request until view become visible")
        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        
        view0?.prepareForReuse()
        XCTAssertEqual(loader.cancelledURLs, [pet0.photoURL], "Expected a cancelled URL request after view is being reused")
    }
    
    func test_petImageView_doesNotDeliverImageFromPreviousRequestWhenCellIsReused() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet(), makePet()])

        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        view0?.prepareForReuse()

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completesImageLoading(with: imageData0, at: 0)

        XCTAssertEqual(view0?.renderedImageData, .none, "Expected no image state change for reused view once image loading completes successfully")
    }

    func test_petImageView_imageIsNilWhenCellIsReused() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet(), makePet()])

        let view0 = sut.simulatePetImageViewIsVisible(at: 0)
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completesImageLoading(with: imageData0, at: 0)
        view0?.prepareForReuse()

        XCTAssertEqual(view0?.renderedImageData, .none, "Expected no image for reused view after image loading completes successfully")
    }

    func test_petImageView_imageIsNilWhenViewIsVisibleAgain() throws {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet()])

        let image0 = UIImage.make(withColor: .red).pngData()!
        let view0 = try XCTUnwrap(sut.simulatePetImageViewIsVisible(at: 0))
        loader.completesImageLoading(with: image0, at: 0)

        sut.simulateIsNotVisibleAndVisibleAgain(with: view0)
        XCTAssertNil(view0.renderedImageData)
    }

    func test_loadPetsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completesPetsLoading()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_loadPetImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [makePet()], at: 0)

        sut.simulatePetImageViewIsVisible(at: 0)

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completesImageLoading(with: imageData0, at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_didSelectItem_notifiesObserver() {
        var output: (pet: Pet, imageData: Data?)? = nil
        let pet = makePet()
        let (sut, loader) = makeSUT(select: { pet, image in output = (pet, image?.pngData()) })
        
        sut.loadViewIfNeeded()
        loader.completesPetsLoading(with: [pet], at: 0)
        
        sut.simulatePetImageViewIsVisible(at: 0)
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completesImageLoading(with: imageData, at: 0)
        
        sut.simulateSelectItem(at: 0)
        XCTAssertEqual(output?.pet, pet)
        XCTAssertEqual(output?.imageData, imageData)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(select: @escaping (Pet, UIImage?) -> Void = { _,_  in }, file: StaticString = #filePath, line: UInt = #line) -> (AdoptListViewController, PetLoaderSpy) {
        let loader = PetLoaderSpy()
        let sut = AdoptListUIComposer.adoptListComposedWith(petLoader: loader, imageLoader: loader, select: select)
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
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
    
    private func makePet(id: Int = 0, location: String = "any location", kind: String = "any kind", gender: String = "M", bodyType: String = "any body", color: String = "any color", age: String = "any age", sterilization: String = "NA", bacterin: String = "NA", foundPlace: String = "any place", status: String = "any status", remark: String = "NA", openDate: String = "2023-04-22", closedDate: String = "2023-04-22", updatedDate: String = "2023-04-22", createdDate: String = "2023-04-22", photoURL: URL? = URL(string:"https://any-url.com")!, address: String = "any place", telephone: String = "02", variety: String = "any variety", shelterName: String = "any shelter") -> Pet {
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
            shelterName: shelterName)
        return pet
    }
}
