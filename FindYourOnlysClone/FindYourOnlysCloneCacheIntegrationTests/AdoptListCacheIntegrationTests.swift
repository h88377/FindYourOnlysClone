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
    
    func test_loadImageData_deliversSavedDataOnASeparatedInstance() {
        let imageData = anyData()
        let imageURL = anyURL()
        let loaderToSave = makeSUT()
        let loaderToLoad = makeSUT()

        save(data: imageData, for: imageURL, with: loaderToSave)
        
        expect(loaderToLoad, toLoad: imageData, from: imageURL)
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
    
    private func expect(_ sut: LocalPetImageDataLoader, toLoad expectedData: Data, from url: URL) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(expectedData, receivedData)
            default: XCTFail("Expected succeed with data \(expectedData), got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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
