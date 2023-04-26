//
//  PetStoreSpy.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import Foundation
@testable import FindYourOnlysClone

class PetStoreSpy: PetImageDataStore {
    enum Message: Equatable {
        case retrieve(URL)
        case insert(Data, URL)
        case delete(URL)
    }
    
    typealias RetrievalCompletion = (PetImageDataStore.RetrievalResult) -> Void
    typealias InsertionCompletion = (PetImageDataStore.InsertionResult) -> Void
    typealias DeletionCompletion = (PetImageDataStore.InsertionResult) -> Void
    
    private(set) var receivedMessages = [Message]()
    
    private var retrievalCompletions = [RetrievalCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var deletionCompletions = [DeletionCompletion]()
    
    func retrieve(dataForURL url: URL, completion: @escaping RetrievalCompletion) {
        receivedMessages.append(.retrieve(url))
        retrievalCompletions.append(completion)
    }
    
    func insert(data: Data, for url: URL, completion: @escaping InsertionCompletion) {
        receivedMessages.append(.insert(data, url))
        insertionCompletions.append(completion)
    }
    
    func delete(dataForURL url: URL, completion: @escaping (DeletionResult) -> Void) {
        receivedMessages.append(.delete(url))
        deletionCompletions.append(completion)
    }
    
    func completesRetrivalWith(_ error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completesRetrivalWith(_ data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func completesInsertionWith(_ error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completesInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func completesDeletionWith(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completesDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
}
