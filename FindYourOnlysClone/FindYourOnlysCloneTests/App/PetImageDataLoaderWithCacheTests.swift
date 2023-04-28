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
        return PetImageDataLoaderWithCacheTask()
    }
    
    
}

class PetImageDataLoaderWithCacheDecoratorTests: XCTestCase {
    
    func test_init_doesNotMessageDecorateeCreation() {
        let loader = PetImageDataLoaderSpy()
        _ = PetImageDataLoaderWithCacheDecorator(decoratee: loader)
        
        XCTAssertEqual(loader.receivedURLs, [])
    }
}
