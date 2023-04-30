//
//  MainThreadDispatchDecorator.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/28.
//

import Foundation

final class MainThreadDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { completion() }
        }
        
        completion()
    }
}

extension MainThreadDispatchDecorator: PetLoader where T == PetLoader {
    func load(with request: AdoptListRequest, completion: @escaping (PetLoader.Result) -> Void) {
        decoratee.load(with: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainThreadDispatchDecorator: PetImageDataLoader where T == PetImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
