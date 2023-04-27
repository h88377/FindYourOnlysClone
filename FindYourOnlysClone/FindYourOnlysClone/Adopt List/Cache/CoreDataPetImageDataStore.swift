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
    
    init(bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "PetStore", in: bundle)
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    func insert(data: Data, for url: URL, timestamp: Date, completion: @escaping (InsertionResult) -> Void) {
        
    }
    
    func delete(dataForURL url: URL, completion: @escaping (DeletionResult) -> Void) {
        
    }
}

extension NSPersistentContainer {
    enum LoadingError: Error {
        case modelNotFound
        case failedToLoadPersistentStore(Error)
    }
    
    static func load(modelName: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd"), let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw LoadingError.modelNotFound
        }
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        try loadError.map { throw LoadingError.failedToLoadPersistentStore($0) }
        
        return container
    }
}
