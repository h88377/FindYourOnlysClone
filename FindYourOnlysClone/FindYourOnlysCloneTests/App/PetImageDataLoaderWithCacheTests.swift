//
//  PetImageDataLoaderWithCacheTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/28.
//

import XCTest
@testable import FindYourOnlysClone

class PetImageDataLoaderWithCacheDecoratorTests: XCTestCase, PetImageDataLoaderTestCase {
    
    func test_init_doesNotMessageDecorateeCreation() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.receivedURLs, [])
    }
    
    func test_loadImageData_requestsImageDataFromURL() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.receivedURLs, [url])
    }
    
    func test_cancelsLoadImageData_cancelsDecorateeLoadImageDataTask() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url])
    }
    
    func test_loadImageData_deliversImageDataOnLoadSuccessfully() {
        let imageData = anyData()
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(imageData), when: {
            loader.completeLoadSucessfully(with: imageData)
        })
    }
    
    func test_loadImageData_deliversFailureOnDecorateeError() {
        let decorateeError = anyNSError()
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(decorateeError), when: {
            loader.completeLoadWithError(decorateeError)
        })
    }
    
    func test_loadImageData_requestsCacheOnSuccessfulyLoad() {
        let imageURL = anyURL()
        let imageData = anyData()
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: imageURL) { _ in }
        loader.completeLoadSucessfully(with: imageData)
        
        XCTAssertEqual(cache.savedMessages, [.saved(data: imageData, url: imageURL)])
    }
    
    func test_loadImageData_doesNotRequestCacheOnDecorateeFailure() {
        let decorateeError = anyNSError()
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: anyURL()) { _ in }
        loader.completeLoadWithError(decorateeError)
        
        XCTAssertEqual(cache.savedMessages, [])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(cache: CacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> (PetImageDataLoaderWithCacheDecorator, PetImageDataLoaderSpy) {
        let loader = PetImageDataLoaderSpy()
        let sut = PetImageDataLoaderWithCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private class CacheSpy: PetImageDataCache {
        enum SavedMessage: Equatable {
            case saved(data: Data, url: URL)
        }
        
        private(set) var savedMessages = [SavedMessage]()
        
        func save(data: Data, for url: URL, completion: @escaping (PetImageDataCache.Result) -> Void) {
            savedMessages.append(.saved(data: data, url: url))
        }
    }
}
