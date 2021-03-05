//
//  LocalFeedItem.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 17/01/21.
//

import Foundation
/**
 LocalFeedItem is the replica of FeedItem, to avoid tight coupling with FeedItem
 */
public struct LocalFeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    /**
        By default struct's default initialiser is internal, if it needs to be used outside module, it has to be provided explicitly
     */
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
