//
//  CoreDataPetImageDataStore.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/26.
//

import Foundation
import CoreData

final class CoreDataPetImageDataStore: PetImageDataStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(bundle: Bundle = .main, storeURL: URL) throws {
        container = try NSPersistentContainer.load(modelName: "PetStore", in: bundle, storeURL: storeURL)
        context = container.newBackgroundContext()
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                guard let managedPetImageData = try ManagedPetImageData.find(for: url, in: context) else {
                    return nil
                }
                
                return CachedPetImageData(
                    timestamp: managedPetImageData.timestamp,
                    url: managedPetImageData.url,
                    value: managedPetImageData.value)
            })
        }
    }
    
    func insert(data: Data, for url: URL, timestamp: Date, completion: @escaping (InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                let managedPetImageData = try ManagedPetImageData.newInstance(for: url, in: context)
                managedPetImageData.url = url
                managedPetImageData.value = data
                managedPetImageData.timestamp = timestamp
                
                try context.save()
            })
        }
    }
    
    func delete(dataForURL url: URL, completion: @escaping (DeletionResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedPetImageData.find(for: url, in: context)
                    .map(context.delete)
                    .map(context.save)
            })
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
}
