//
//  CoreDataPetImageDataStore.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/26.
//

import Foundation
import CoreData

final class CoreDataPetImageDataStore: PetImageDataStore {
    enum LoadingError: Error {
        case modelNotFound
        case failedToLoadPersistentStore(Error)
    }
    
    private let container: NSPersistentContainer
    
    init(bundle: Bundle = .main) throws {
        guard let modelURL = bundle.url(forResource: "PetStore", withExtension: "momd"), let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw LoadingError.modelNotFound
        }
        
        container = NSPersistentContainer(name: "PetStore", managedObjectModel: model)
        
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        try loadError.map { throw LoadingError.failedToLoadPersistentStore($0) }
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    func insert(data: Data, for url: URL, timestamp: Date, completion: @escaping (InsertionResult) -> Void) {
        
    }
    
    func delete(dataForURL url: URL, completion: @escaping (DeletionResult) -> Void) {
        
    }
}
