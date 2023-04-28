//
//  PetImageDataLoaderWithCacheDecorator.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/28.
//

import Foundation

final class PetImageDataLoaderWithCacheDecorator: PetImageDataLoader {
    private class PetImageDataLoaderWithCacheTask: PetImageDataLoaderTask {
        var decorateeTask: PetImageDataLoaderTask?
        
        func cancel() {
            decorateeTask?.cancel()
        }
    }
    
    private let decoratee: PetImageDataLoader
    private let cache: PetImageDataCache
    
    init(decoratee: PetImageDataLoader, cache: PetImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> FindYourOnlysClone.PetImageDataLoaderTask {
        let decoratorTask = PetImageDataLoaderWithCacheTask()
        decoratorTask.decorateeTask = decoratee.loadImageData(from: url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.cache.save(data: data, for: url) { _ in }
                
            default: break
            }
            completion(result)
        }
        return decoratorTask
    }
}
