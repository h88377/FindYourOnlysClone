//
//  PetLoaderSpy.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/20.
//

import Foundation
@testable import FindYourOnlysClone

class PetLoaderSpy: PetLoader, PetImageDataLoader {
    
    // MARK: - PetLoader
    
    enum Request: Equatable {
        case load(AdoptListRequest)
    }
    
    var loadPetsRequests: [Request] {
        return loadPetsMessages.map { $0.request }
    }
    
    private var loadPetsMessages = [(request: Request, completion: (PetLoader.Result) -> Void)]()
    
    func load(with request: AdoptListRequest, completion: @escaping (PetLoader.Result) -> Void) {
        loadPetsMessages.append((.load(request), completion))
    }
    
    func completesPetsLoading(with pets: [Pet] = [], at index: Int = 0) {
        loadPetsMessages[index].completion(.success(pets))
    }
    
    func completesPetsLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "any error", code: 0)
        loadPetsMessages[index].completion(.failure(error))
    }
    
    // MARK: - PetImageDataLoader
    
    private struct TaskSpy: PetImageDataLoaderTask {
        let cancelHandler: () -> Void
        
        func cancel() {
            cancelHandler()
        }
    }
    
    private var requestedImageMessages = [(url: URL, completion: (PetImageDataLoader.Result) -> Void)]()
    
    var requestedImageURLs: [URL] {
        return requestedImageMessages.map { $0.url }
    }
    
    private(set) var cancelledURLs = [URL]()
    
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
        requestedImageMessages.append((url, completion))
        
        return TaskSpy { [weak self] in  self?.cancelledURLs.append(url) }
    }
    
    func completesImageLoading(with data: Data = Data(), at index: Int = 0) {
        requestedImageMessages[index].completion(.success(data))
    }
    
    func completesImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "any error", code: 0)
        requestedImageMessages[index].completion(.failure(error))
    }
}
