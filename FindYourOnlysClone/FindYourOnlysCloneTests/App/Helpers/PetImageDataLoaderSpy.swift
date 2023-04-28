//
//  PetImageDataLoaderSpy.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/28.
//

import Foundation
@testable import FindYourOnlysClone

class PetImageDataLoaderSpy: PetImageDataLoader, PetImageDataCache {
    
    // MARK: - PetImageDataLoader
    
    private struct TaskStub: PetImageDataLoaderTask {
        let callback: () -> Void
        
        init(callback: @escaping () -> Void) {
            self.callback = callback
        }
        
        func cancel() {
            callback()
        }
    }
    
    private(set) var receivedURLs = [URL]()
    private(set) var cancelledURLs = [URL]()
    private var receivedCompletions = [(PetImageDataLoader.Result) -> Void]()
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
        receivedURLs.append(url)
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
    
    // MARK: - PetImageDataCache
    
    enum SavedMessage: Equatable {
        case saved(data: Data, url: URL)
    }
    
    private(set) var savedMessages = [SavedMessage]()
    
    func save(data: Data, for url: URL, completion: @escaping (PetImageDataCache.Result) -> Void) {
        savedMessages.append(.saved(data: data, url: url))
    }
}
