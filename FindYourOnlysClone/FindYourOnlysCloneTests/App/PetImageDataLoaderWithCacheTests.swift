//
//  PetImageDataLoaderWithCacheTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/28.
//

import XCTest
@testable import FindYourOnlysClone

final class PetImageDataLoaderWithCacheDecorator: PetImageDataLoader {
    private class PetImageDataLoaderWithCacheTask: PetImageDataLoaderTask {
        var decorateeTask: PetImageDataLoaderTask?
        
        func cancel() {
            decorateeTask?.cancel()
        }
    }
    
    private let decoratee: PetImageDataLoader
    
    init(decoratee: PetImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> FindYourOnlysClone.PetImageDataLoaderTask {
        let decoratorTask = PetImageDataLoaderWithCacheTask()
        decoratorTask.decorateeTask = decoratee.loadImageData(from: url, completion: completion)
        return decoratorTask
    }
}

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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (PetImageDataLoaderWithCacheDecorator, PetImageDataLoaderSpy) {
        let loader = PetImageDataLoaderSpy()
        let sut = PetImageDataLoaderWithCacheDecorator(decoratee: loader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        return (sut, loader)
    }
}
