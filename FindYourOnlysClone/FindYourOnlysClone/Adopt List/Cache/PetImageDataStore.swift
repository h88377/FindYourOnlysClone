//
//  PetImageDataStore.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import Foundation

struct CachedPetImageData: Equatable {
    let timestamp: Date
    let url: URL
    let value: Data
}

protocol PetImageDataStore {
    typealias RetrievalResult = Swift.Result<CachedPetImageData?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    typealias DeletionResult = Swift.Result<Void, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
    func insert(data: Data, for url: URL, timestamp: Date, completion: @escaping (InsertionResult) -> Void)
    func delete(dataForURL url: URL, completion: @escaping (DeletionResult) -> Void)
}
