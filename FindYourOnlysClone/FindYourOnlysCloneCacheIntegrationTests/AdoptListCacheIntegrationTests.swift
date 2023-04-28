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
        
        loaderToSave.save(data: imageData, for: imageURL) { result in
            switch result {
            case .success: break
            default: XCTFail()
            }
        }

        _ = loaderToLoad.loadImageData(from: imageURL) { result in
            switch result {
            case let .success(data):
                XCTAssertEqual(imageData, data)
            default: XCTFail()
            }
        }
        
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
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathExtension("\(type(of: self)).sqlite")
    }
    
    private func setUpEmptyStoreState() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func cleanStoreSideEffects() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
}
