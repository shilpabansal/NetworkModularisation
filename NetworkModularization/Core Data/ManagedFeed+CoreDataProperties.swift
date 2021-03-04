//
//  ManagedFeed+CoreDataProperties.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 04/03/21.
//
//

import Foundation
import CoreData


extension ManagedFeed {

    @nonobjc class func fetchRequest() -> NSFetchRequest<ManagedFeed> {
        return NSFetchRequest<ManagedFeed>(entityName: "ManagedFeed")
    }

    @NSManaged public var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache?

}

extension ManagedFeed : Identifiable {
    var feedImage: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
    
    internal static func feedImages(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let feedImage = ManagedFeed(context: context)
            
            feedImage.id = local.id
            feedImage.location = local.location
            feedImage.imageDescription = local.description
            feedImage.url = local.url
            return feedImage
        })
    }
}
