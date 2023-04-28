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
        let primaryResult: PetImageDataLoader.Result = .success(Data("primary data".utf8))
        let fallbackResult: PetImageDataLoader.Result = .success(Data("fallback data".utf8))
        
        let sut = makeSUT(primaryResult: primaryResult, fallbackResult: fallbackResult)
        
        expect(sut, toCompleteWith: primaryResult)
    }
    
    func test_loadImageData_deliversFallbackSuccessfulResultOnPrimaryFailureAndFallbackSuccess() {
        let primaryResult: PetImageDataLoader.Result = .failure(anyNSError())
        let fallbackResult: PetImageDataLoader.Result = .success(anyData())
        
        let sut = makeSUT(primaryResult: primaryResult, fallbackResult: fallbackResult)
        
        expect(sut, toCompleteWith: fallbackResult)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(primaryResult: PetImageDataLoader.Result, fallbackResult: PetImageDataLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> PetImageDataLoaderWithFallbackComposite {
        let primaryLoader = PetImageDataLoaderStub(result: primaryResult)
        let fallbackLoader = PetImageDataLoaderStub(result: fallbackResult)
        let sut = PetImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(primaryLoader, file: file, line: line)
        trackForMemoryLeak(fallbackLoader, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: PetImageDataLoaderWithFallbackComposite, toCompleteWith expectedResult: PetImageDataLoader.Result, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, "Expected \(expectedData), got \(receivedData) instead", file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, "Expected \(expectedError), got \(receivedError) instead", file: file, line: line)
                
            default:
                XCTFail("Expected to receive \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
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
