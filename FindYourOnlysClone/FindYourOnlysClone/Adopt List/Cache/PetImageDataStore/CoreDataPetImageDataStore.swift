//
//  CoreDataPetImageDataStore.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/26.
//

import Foundation
import CoreData

final class CoreDataPetImageDataStore: PetImageDataStore {
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentStore(Error)
    }
    
    private static let modelName = "PetStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataPetImageDataStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(storeURL: URL) throws {
        guard let model = CoreDataPetImageDataStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(modelName: CoreDataPetImageDataStore.modelName, model: model, storeURL: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentStore(error)
        }
    }
    
    deinit {
        cleanUpReferenceToPersistentStore()
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
    
    private func cleanUpReferenceToPersistentStore() {
        context.performAndWait {
            let coordinator = container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
}
