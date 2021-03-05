//
//  CoreDataFeedStore.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 04/03/21.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    func deleteFeeds(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
    
    private let persistentContainer: NSPersistentContainer
    private let managedContext: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        let modelName = "FeedStoreDataModel"
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        
        guard let model = NSManagedObjectModel.with(name: modelName, in: storeBundle) else {
            throw NSError(domain: "Couldn't find the object model in Bundle", code: 0, userInfo: nil)
        }
        
        persistentContainer = NSPersistentContainer(name: modelName, managedObjectModel: model)
        
        try persistentContainer.load(storeURL: storeURL)
        managedContext = persistentContainer.newBackgroundContext()
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let managedContext = self.managedContext
        managedContext.perform { action(managedContext) }
    }
    
    func insert(feeds: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.uniqueNewInstance(context: context, timestamp: timestamp)
                managedCache.feeds = ManagedFeed.feedImages(from: feeds, in: context)

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func retrieve(completion: @escaping RetrieveCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    let feedArray = cache.feeds.compactMap { ($0 as? ManagedFeed)?.feedImage }
                    completion(.success(.found(feedArray, cache.timestamp)))
                }
                else {
                    completion(.success(.empty))
                }
                
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
    
    static func urlWith(name: String, in bundle: Bundle) -> URL? {
        return bundle
            .url(forResource: name, withExtension: "momd")
    }
}

extension NSPersistentContainer {
    func load(storeURL: URL) throws {
        let description = NSPersistentStoreDescription(url: storeURL)
        self.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        loadPersistentStores { loadError = $1 }
        
        if let loadError = loadError {
            throw loadError
        }
    }
}
