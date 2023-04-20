//
//  RemotePetImageDataLoader.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/20.
//

import Foundation

final class RemotePetImageDataLoader {
    enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    private final class RemotePetImageDataLoaderTask: PetImageDataLoaderTask {
        private var completion: ((PetImageDataLoader.Result) -> Void)?
        var clientTask: HTTPClientTask?
        
        init(_ completion: @escaping (PetImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(_ result: PetImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            clientTask?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
        let loaderTask = RemotePetImageDataLoaderTask(completion)
        loaderTask.clientTask = client.dispatch(URLRequest(url: url)) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                guard response.statusCode == 200, !data.isEmpty else {
                    return loaderTask.complete(.failure(Error.invalidData))
                }
                
                loaderTask.complete(.success(data))
                
            case .failure:
                loaderTask.complete(.failure(Error.connectivity))
            }
        }
        
        return loaderTask
    }
}
