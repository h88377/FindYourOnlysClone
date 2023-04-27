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
    private let calendar = Calendar(identifier: .gregorian)
    
    init(store: PetImageDataStore, currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
        self.store = store
    }
}

extension LocalPetImageDataLoader {
    typealias SaveResult = Swift.Result<Void, Error>
    
    enum SaveError: Swift.Error {
        case failed
    }
    
    enum DeleteError: Swift.Error {
        case failed
    }
    
    func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.delete(dataForURL: url) { [weak self] result in
            switch result {
            case .success:
                self?.cache(data: data, for: url, completion: completion)
                
            case .failure:
                completion(.failure(DeleteError.failed))
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
                guard let data = data, self.validate(data.timestamp, against: self.currentDate()) else { return loaderTask.complete(.failure(LoadError.notFound)) }
                
                loaderTask.complete(.success(data.value))
                
            case .failure:
                loaderTask.complete(.failure(LoadError.failed))
            }
        }
        
        return loaderTask
    }
    
    private var maxCacheAgeInDays: Int { return 7 }
    
    private func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        
        return maxCacheAge > date
    }
}
