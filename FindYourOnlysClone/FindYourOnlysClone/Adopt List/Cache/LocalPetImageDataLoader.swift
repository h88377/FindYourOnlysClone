//
//  LocalPetImageDataLoader.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import Foundation

final class LocalPetImageDataLoader {
    private let currentDate: () -> Date
    private let store: PetImageDataStore
    
    init(store: PetImageDataStore, currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
        self.store = store
    }
}

protocol PetImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

extension LocalPetImageDataLoader: PetImageDataCache {
    typealias SaveResult = PetImageDataCache.Result
    
    enum SaveError: Swift.Error {
        case failed
    }
    
    func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.delete(dataForURL: url) { [weak self] result in
            switch result {
            case .success:
                self?.cache(data: data, for: url, completion: completion)
                
            case .failure:
                completion(.failure(SaveError.failed))
            }
        }
    }
    
    private func cache(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data: data, for: url, timestamp: currentDate()) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success:
                completion(.success(()))
                
            case .failure:
                completion(.failure(SaveError.failed))
            }
        }
    }
}

extension LocalPetImageDataLoader: PetImageDataLoader {
    typealias LoadResult = PetImageDataLoader.Result
    
    enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    private final class LocalLoadPetImageDataTask: PetImageDataLoaderTask {
        private var completion: ((LoadResult) -> Void)?
        
        init(_ completion: @escaping (LoadResult) -> Void) {
            self.completion = completion
        }
        
        func complete(_ result: LoadResult) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> PetImageDataLoaderTask {
        let loaderTask = LocalLoadPetImageDataTask(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(data):
                guard let data = data, CachePolicy.validate(data.timestamp, against: self.currentDate()) else { return loaderTask.complete(.failure(LoadError.notFound)) }
                
                loaderTask.complete(.success(data.value))
                
            case .failure:
                loaderTask.complete(.failure(LoadError.failed))
            }
        }
        
        return loaderTask
    }
}
