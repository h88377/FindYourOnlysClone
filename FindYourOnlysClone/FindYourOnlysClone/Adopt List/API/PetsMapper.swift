//
//  PetsMapper.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import Foundation

final class PetsMapper {
    private init() {}
    
    private static var OK_200: Int { return 200 }
    
    static func map(with data: Data, _ response: HTTPURLResponse) throws -> [RemotePet] {
        guard response.statusCode == OK_200, let remotePets = try? JSONDecoder().decode([RemotePet].self, from: data) else {
            throw RemotePetLoader.Error.invalidData
        }
        
        return remotePets
    }
}
