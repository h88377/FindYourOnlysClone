//
//  PetLoader.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import Foundation

protocol PetLoader {
    typealias Result = Swift.Result<[Pet], Error>
    
    func load(with request: AdoptListRequest, completion: @escaping (Result) -> Void)
}
