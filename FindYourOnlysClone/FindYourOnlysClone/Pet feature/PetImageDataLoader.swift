//
//  PetImageDataLoader.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import Foundation

protocol PetImageDataLoaderTask {
    func cancel()
}

protocol PetImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> PetImageDataLoaderTask
}
