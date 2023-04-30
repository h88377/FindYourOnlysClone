//
//  PetImageDataLoaderWithFallbackCompositeTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/28.
//

import XCTest
@testable import FindYourOnlysClone

class PetImageDataLoaderWithFallbackCompositeTests: XCTestCase, PetImageDataLoaderTestCase {
    
    func test_loadImageData_deliversPrimarySuccessfulResultOnPrimarySuccess() {
        let primaryData = anyData()

        let (sut, primary, _) = makeSUT()

        expect(sut, toCompleteWith: .success(primaryData), when: {
            primary.completeLoadSucessfully(with: primaryData)
        })
    }

    func test_loadImageData_deliversFallbackSuccessfulResultOnPrimaryFailureAndFallbackSuccess() {
        let primaryError = anyNSError()
        let fallbackData = anyData()

        let (sut, primary, fallback) = makeSUT()

        expect(sut, toCompleteWith: .success(fallbackData), when: {
            primary.completeLoadWithError(primaryError)
            fallback.completeLoadSucessfully(with: fallbackData)
        })
    }

    func test_loadImageData_deliversFallbackFailureResultOnBothPrimaryAndFallbackAreFailure() {
        let primaryError = NSError(domain: "primary error", code: 0)
        let fallbackError = NSError(domain: "fallback error", code: 0)

        let (sut, primary, fallback) = makeSUT()

        expect(sut, toCompleteWith: .failure(fallbackError), when: {
            primary.completeLoadWithError(primaryError)
            fallback.completeLoadWithError(fallbackError)
        })
    }
    
    func test_cancelsLoadImageDataTask_cancelsPrimaryLoaderTask() {
        let url = anyURL()
        let (sut, primary, fallback) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(primary.cancelledURLs, [url], "Expected cancel primary task")
        XCTAssertTrue(fallback.cancelledURLs.isEmpty, "Expected does not cancel fallback task since task haven't started")
    }
    
    func test_cancelsLoadImageDataTask_cancelsFallbackLoaderTaskOnPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primary, fallback) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        
        primary.completeLoadWithError(anyNSError())
        task.cancel()
        
        XCTAssertTrue(primary.cancelledURLs.isEmpty, "Expected does not cancel primary task since task has been completed")
        XCTAssertEqual(fallback.cancelledURLs, [url], "Expected cancel fallback task")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: PetImageDataLoaderWithFallbackComposite, primary: PetImageDataLoaderSpy, fallback: PetImageDataLoaderSpy) {
        let primaryLoader = PetImageDataLoaderSpy()
        let fallbackLoader = PetImageDataLoaderSpy()
        let sut = PetImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(primaryLoader, file: file, line: line)
        trackForMemoryLeak(fallbackLoader, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
}
