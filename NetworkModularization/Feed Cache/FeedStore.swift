//
//  FeedStore.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 17/01/21.
//

import Foundation
/**
 Feed store protocol is the interface, which expects the feeds to be stored or return error in completion block passed
 */
protocol FeedStore {
    typealias DeletionError = (Error?) -> Void
    typealias InsertionError = (Error?) -> Void
    
    func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionError)
    func deleteFeeds(completion: @escaping DeletionError)
}

/**
 LocalFeedItem is the replica of FeedItem, to avoid tight coupling with FeedItem
 */
struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    /**
        By default struct's default initialiser is internal, if it needs to be used outside module, it has to be provided explicitly
     */
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
