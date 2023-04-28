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

extension ManagedPetImageData {
    static func find(for url: URL, in context: NSManagedObjectContext) throws -> ManagedPetImageData? {
        guard let entityName = ManagedPetImageData.entity().name else { return nil }
        
        let request: NSFetchRequest<ManagedPetImageData> = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedPetImageData.url), url])
        
        return try context.fetch(request).first
    }
    
    static func newInstance(for url: URL, in context: NSManagedObjectContext) throws -> ManagedPetImageData {
        try ManagedPetImageData.find(for: url, in: context)
            .map(context.delete)
        
        return ManagedPetImageData(context: context)
    }
}
