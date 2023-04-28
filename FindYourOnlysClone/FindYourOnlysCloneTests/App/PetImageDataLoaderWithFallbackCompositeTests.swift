//
//  PetImageDataLoaderWithFallbackCompositeTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/28.
//

import XCTest
@testable import FindYourOnlysClone

class PetImageDataLoaderWithFallbackComposite: PetImageDataLoader {
    private class PetImageDataLoaderWithFallbackTask: PetImageDataLoaderTask {
        var compositeeTask: PetImageDataLoaderTask?
        
        func cancel() {
            compositeeTask?.cancel()
        }
    }
    
    private let primary: PetImageDataLoader
    private let fallback: PetImageDataLoader
    
    init(primary: PetImageDataLoader, fallback: PetImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> FindYourOnlysClone.PetImageDataLoaderTask {
        let compositeTask = PetImageDataLoaderWithFallbackTask()
        compositeTask.compositeeTask = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            
            case .failure:
                compositeTask.compositeeTask = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return compositeTask
    }
}

class PetImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
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
        
        XCTAssertEqual(primary.cancelledURLs, [url])
        XCTAssertTrue(fallback.cancelledURLs.isEmpty)
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
    
    private func expect(_ sut: PetImageDataLoaderWithFallbackComposite, toCompleteWith expectedResult: PetImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
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
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class PetImageDataLoaderSpy: PetImageDataLoader {
        private struct TaskStub: PetImageDataLoaderTask {
            let callback: () -> Void
            
            init(callback: @escaping () -> Void) {
                self.callback = callback
            }
            
            func cancel() {
                callback()
            }
        }
        
        private(set) var cancelledURLs = [URL]()
        private var receivedCompletions = [(PetImageDataLoader.Result) -> Void]()
        
        func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
            receivedCompletions.append(completion)
            return TaskStub { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func completeLoadSucessfully(with data: Data, at index: Int = 0) {
            receivedCompletions[index](.success(data))
        }
        
        func completeLoadWithError(_ error: Error, at index: Int = 0) {
            receivedCompletions[index](.failure(error))
        }
    }
}
