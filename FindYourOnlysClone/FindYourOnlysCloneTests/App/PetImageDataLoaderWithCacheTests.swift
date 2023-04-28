//
//  PetImageDataLoaderWithCacheTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/28.
//

import XCTest
@testable import FindYourOnlysClone

final class PetImageDataLoaderWithCacheDecorator: PetImageDataLoader {
    private struct PetImageDataLoaderWithCacheTask: PetImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    private let decoratee: PetImageDataLoader
    
    init(decoratee: PetImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> FindYourOnlysClone.PetImageDataLoaderTask {
        _ = decoratee.loadImageData(from: url, completion: completion)
        return PetImageDataLoaderWithCacheTask()
    }
    
    
}

class PetImageDataLoaderWithCacheDecoratorTests: XCTestCase {
    
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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (PetImageDataLoaderWithCacheDecorator, PetImageDataLoaderSpy) {
        let loader = PetImageDataLoaderSpy()
        let sut = PetImageDataLoaderWithCacheDecorator(decoratee: loader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        return (sut, loader)
    }
}
