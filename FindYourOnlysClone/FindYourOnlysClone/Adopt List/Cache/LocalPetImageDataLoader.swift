//
//  LocalPetImageDataLoader.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/25.
//

import Foundation

final class LocalPetImageDataLoader: PetImageDataLoader {
    enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    typealias SaveResult = Swift.Result<Void, LoadError>
    
    private final class LocalPetImageDataLoaderTask: PetImageDataLoaderTask {
        private var completion: ((PetImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (PetImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(_ result: PetImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    private let store: PetImageDataStore
    
    init(store: PetImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
        let loaderTask = LocalPetImageDataLoaderTask(completion)
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
    
    func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data: data, for: url) { _ in }
    }
}
