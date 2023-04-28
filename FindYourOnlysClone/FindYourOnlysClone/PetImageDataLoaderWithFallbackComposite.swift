//
//  PetImageDataLoaderWithFallbackComposite.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/28.
//

import Foundation

class PetImageDataLoaderWithFallbackComposite: PetImageDataLoader {
    private class PetImageDataLoaderWithFallbackTask: PetImageDataLoaderTask {
        var compositeeTask: PetImageDataLoaderTask?
        
        func cancel() {
            compositeeTask?.cancel()
        }
    }
    
    private let primary: PetImageDataLoader
    private let fallback: PetImageDataLoader
    
    init(primary: PetImageDataLoader, fallback: PetImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> FindYourOnlysClone.PetImageDataLoaderTask {
        let compositeTask = PetImageDataLoaderWithFallbackTask()
        compositeTask.compositeeTask = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            
            case .failure:
                compositeTask.compositeeTask = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return compositeTask
    }
}
