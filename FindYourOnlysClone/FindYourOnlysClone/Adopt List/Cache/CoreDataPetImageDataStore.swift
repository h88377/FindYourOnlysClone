//
//  CoreDataPetImageDataStore.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/26.
//

import Foundation

final class CoreDataPetImageDataStore: PetImageDataStore {
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    func insert(data: Data, for url: URL, timestamp: Date, completion: @escaping (InsertionResult) -> Void) {
        
    }
    
    func delete(dataForURL url: URL, completion: @escaping (DeletionResult) -> Void) {
        
    }
}
