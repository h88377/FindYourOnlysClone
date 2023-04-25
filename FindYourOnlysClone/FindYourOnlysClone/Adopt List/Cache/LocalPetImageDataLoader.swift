//
//  LocalPetImageDataLoader.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import Foundation

final class LocalPetImageDataLoader {
    private let store: PetImageDataStore
    
    init(store: PetImageDataStore) {
        self.store = store
    }
}

extension LocalPetImageDataLoader {
    typealias SaveResult = Swift.Result<Void, Error>
    
    enum SaveError: Swift.Error {
        case failed
    }
    
    func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data: data, for: url) { [weak self] result in
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
            guard self != nil else { return }
            
            switch result {
            case let .success(data):
                guard let data = data else { return loaderTask.complete(.failure(LoadError.notFound)) }
                
                loaderTask.complete(.success(data))
                
            case .failure:
                loaderTask.complete(.failure(LoadError.failed))
            }
        }
        
        return loaderTask
    }
}
