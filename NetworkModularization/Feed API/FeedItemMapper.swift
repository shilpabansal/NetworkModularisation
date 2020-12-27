//
//  FeedItemMapper.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 27/12/20.
//

import Foundation
import Network

final class FeedItemMapper {
    private struct Root: Decodable {
        var items: [Item]
        
        var feeds: [FeedItem] {
            return items.map({$0.item})
        }
    }
    
    internal static var OK_200 : Int { return 200 }
    /**
     As the data expected from Api has image as the key name and the the param name is imageURL in FeedItem
     To keep FeedItem generic in RemoteFeedLoader the mapping is done to avoid the changes in the FeedLoader module on API change
     */
    private struct Item : Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        public var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        /**
         if the status code is not 200 or the json parsing fails, returns invalid data
         */
        guard response.statusCode == OK_200,
              let items = try? JSONDecoder().decode(Root.self, from: data).feeds else {
            return .failure(.invalidData)
        }
        return .success(items)
    }
}
