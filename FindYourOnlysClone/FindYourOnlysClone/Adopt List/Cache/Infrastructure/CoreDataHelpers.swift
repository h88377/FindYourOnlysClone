//
//  CoreDataHelpers.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/27.
//

import CoreData

extension NSPersistentContainer {
    static func load(modelName: String, model: NSManagedObjectModel, storeURL: URL) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        try loadError.map { throw ($0) }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd"), let model = NSManagedObjectModel(contentsOf: modelURL) else { return nil }
        
        return model
    }
}
