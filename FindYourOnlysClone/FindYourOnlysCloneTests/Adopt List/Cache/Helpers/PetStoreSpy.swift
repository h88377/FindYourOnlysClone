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
    }
    
    typealias RetrievalCompletion = (PetImageDataStore.RetrievalResult) -> Void
    typealias InsertionCompletion = (PetImageDataStore.InsertionResult) -> Void
    
    private(set) var receivedMessages = [Message]()
    
    private var retrievalCompletions = [RetrievalCompletion]()
    
    func retrieve(dataForURL url: URL, completion: @escaping RetrievalCompletion) {
        receivedMessages.append(.retrieve(url))
        retrievalCompletions.append(completion)
    }
    
    func insert(data: Data, for url: URL, completion: @escaping InsertionCompletion) {
        receivedMessages.append(.insert(data, url))
    }
    
    func completesRetrivalWith(_ error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completesRetrivalWith(_ data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
}
