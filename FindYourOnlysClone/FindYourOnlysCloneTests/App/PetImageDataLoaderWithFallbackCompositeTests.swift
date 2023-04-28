//
//  PetImageDataLoaderWithFallbackCompositeTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/28.
//

import XCTest
@testable import FindYourOnlysClone

class PetImageDataLoaderWithFallbackComposite: PetImageDataLoader {
    private struct PetImageDataLoaderWithFallbackTask: PetImageDataLoaderTask {
        func cancel() {}
    }
    
    private let primary: PetImageDataLoader
    private let fallback: PetImageDataLoader
    
    init(primary: PetImageDataLoader, fallback: PetImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> FindYourOnlysClone.PetImageDataLoaderTask {
        _ = primary.loadImageData(from: url) { result in
            switch result {
            case .success:
                completion(result)
            
            case .failure:
                _ = self.fallback.loadImageData(from: url) { result in
                    completion(result)
                }
            }
        }
        return PetImageDataLoaderWithFallbackTask()
    }
}

class PetImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadImageData_deliversPrimarySuccessfulResultOnPrimarySuccess() {
        let imageURL = URL(string: "https://imageURL-url")!
        let primaryData = Data("primary data".utf8)
        let fallbackData = Data("fallback data".utf8)
        
        let primaryLoader = PetImageDataLoaderStub(result: .success(primaryData))
        let fallbackLoader = PetImageDataLoaderStub(result: .success(fallbackData))
        
        let sut = PetImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: imageURL) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, primaryData, "Expected \(primaryData), got \(receivedData) instead")
                
            default:
                XCTFail("Expected to receive \(primaryData), got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageData_deliversFallbackSuccessfulResultOnPrimaryFailureAndFallbackSuccess() {
        let imageURL = URL(string: "https://imageURL-url")!
        let primaryError = anyNSError()
        let fallbackData = Data("fallback data".utf8)
        
        let primaryLoader = PetImageDataLoaderStub(result: .failure(primaryError))
        let fallbackLoader = PetImageDataLoaderStub(result: .success(fallbackData))
        
        let sut = PetImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: imageURL) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, fallbackData, "Expected \(fallbackData), got \(receivedData) instead")
                
            default:
                XCTFail("Expected to receive \(fallbackData), got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private class PetImageDataLoaderStub: PetImageDataLoader {
        private struct TaskStub: PetImageDataLoaderTask {
            func cancel() {
                
            }
        }
        
        private let result: PetImageDataLoader.Result
        
        init(result: PetImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
            completion(result)
            return TaskStub()
        }
    }
}
