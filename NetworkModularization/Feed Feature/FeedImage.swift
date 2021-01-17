//
//  FeedImage.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 27/12/20.
//

import Foundation
public struct FeedImage: Equatable {
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
