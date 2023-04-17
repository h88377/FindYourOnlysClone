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
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static func map(with data: Data, _ response: HTTPURLResponse) throws -> [RemotePet] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        guard response.statusCode == OK_200, let remotePets = try? decoder.decode([RemotePet].self, from: data) else {
            throw RemotePetLoader.Error.invalidData
        }
        
        return remotePets
    }
}
