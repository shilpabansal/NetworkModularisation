//
//  ManagedCache+CoreDataProperties.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 04/03/21.
//
//

import Foundation
import CoreData


extension ManagedCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedCache> {
        return NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var feeds: NSOrderedSet

}

// MARK: Generated accessors for feeds
extension ManagedCache {

    @objc(insertObject:inFeedsAtIndex:)
    @NSManaged public func insertIntoFeeds(_ value: ManagedFeed, at idx: Int)

    @objc(removeObjectFromFeedsAtIndex:)
    @NSManaged public func removeFromFeeds(at idx: Int)

    @objc(insertFeeds:atIndexes:)
    @NSManaged public func insertIntoFeeds(_ values: [ManagedFeed], at indexes: NSIndexSet)

    @objc(removeFeedsAtIndexes:)
    @NSManaged public func removeFromFeeds(at indexes: NSIndexSet)

    @objc(replaceObjectInFeedsAtIndex:withObject:)
    @NSManaged public func replaceFeeds(at idx: Int, with value: ManagedFeed)

    @objc(replaceFeedsAtIndexes:withFeeds:)
    @NSManaged public func replaceFeeds(at indexes: NSIndexSet, with values: [ManagedFeed])

    @objc(addFeedsObject:)
    @NSManaged public func addToFeeds(_ value: ManagedFeed)

    @objc(removeFeedsObject:)
    @NSManaged public func removeFromFeeds(_ value: ManagedFeed)

    @objc(addFeeds:)
    @NSManaged public func addToFeeds(_ values: NSOrderedSet)

    @objc(removeFeeds:)
    @NSManaged public func removeFromFeeds(_ values: NSOrderedSet)

}

extension ManagedCache : Identifiable {

    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
        return try context.fetch(request).first
    }
    
    static func uniqueNewInstance(context: NSManagedObjectContext, timestamp: Date) throws -> ManagedCache {
        try ManagedCache.find(in: context).map(context.delete)
        
        let cache = ManagedCache(context: context)
        cache.timestamp = timestamp
        return cache
    }
    
    var localFeed: [LocalFeedImage] {
        return feeds.compactMap { ($0 as? ManagedFeed)?.feedImage }
    }
}
