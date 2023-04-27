//
//  CachePolicy.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/27.
//

import Foundation

final class CachePolicy {
    private init() {}
    
    static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int { return 7 }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        
        return maxCacheAge > date
    }
}
