//
//  PetImageDataCache.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/28.
//

import Foundation

protocol PetImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
