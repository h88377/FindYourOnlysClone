//
//  ManagedPetImageData.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/27.
//

import CoreData

@objc(ManagedPetImageData)
class ManagedPetImageData: NSManagedObject {
    @NSManaged var url: URL
    @NSManaged var timestamp: Date
    @NSManaged var value: Data
}
