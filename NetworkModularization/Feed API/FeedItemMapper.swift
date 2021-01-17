//
//  FeedItemMapper.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 27/12/20.
//

import Foundation
import Network

/**
 As the data expected from Api has image as the key name and the the param name is imageURL in FeedItem
 To keep FeedItem generic in RemoteFeedLoader the mapping is done to avoid the changes in the FeedLoader module on API change
 */
internal struct RemoteFeedItem : Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

final class FeedItemMapper {
    private struct Root: Decodable {
        var items: [RemoteFeedItem]
    }
    
    internal static var OK_200 : Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        /**
         if the status code is not 200 or the json parsing fails, returns invalid data
         */
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
