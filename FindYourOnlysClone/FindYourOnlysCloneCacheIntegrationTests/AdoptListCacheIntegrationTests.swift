//
//  FindYourOnlysCloneCacheIntegrationTests.swift
//  FindYourOnlysCloneCacheIntegrationTests
//
//  Created by 鄭昭韋 on 2023/4/27.
//

import XCTest
@testable import FindYourOnlysClone

final class AdoptListCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cleanStoreSideEffects()
    }
    
    func test_loadImageData_deliversNotFoundErrorOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toCompleteWith: failure(.notFound), from: anyURL())
    }
    
    func test_loadImageData_deliversSavedDataOnASeparatedInstance() {
        let imageData = anyData()
        let imageURL = anyURL()
        let loaderToSave = makeSUT()
        let loaderToLoad = makeSUT()

        save(data: imageData, for: imageURL, with: loaderToSave)
        
        expect(loaderToLoad, toCompleteWith: .success(imageData), from: imageURL)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalPetImageDataLoader {
        let bundle = Bundle(for: CoreDataPetImageDataStore.self)
        let testSpecificStoreURL = testSpecificStoreURL()
        let store = try! CoreDataPetImageDataStore(bundle: bundle, storeURL: testSpecificStoreURL)
        let sut = LocalPetImageDataLoader(store: store, currentDate: Date.init)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func save(data: Data, for url: URL, with sut: LocalPetImageDataLoader, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.save(data: data, for: url) { result in
            switch result {
            case .success: break
            default: XCTFail("Expected succeed save operation, got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalPetImageDataLoader, toCompleteWith expectedResult: LocalPetImageDataLoader.LoadResult, from url: URL, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, "Expected \(expectedData), got \(receivedData) instead", file: file, line: line)
                
            case let (.failure(receivedError as LocalPetImageDataLoader.LoadError), .failure(expectedError as LocalPetImageDataLoader.LoadError)):
                XCTAssertEqual(receivedError, expectedError, "Expected \(expectedError), got \(receivedError) instead", file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: LocalPetImageDataLoader.LoadError) -> LocalPetImageDataLoader.LoadResult {
        return .failure(error)
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).sqlite")
    }
    
    private func setUpEmptyStoreState() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func cleanStoreSideEffects() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
}
