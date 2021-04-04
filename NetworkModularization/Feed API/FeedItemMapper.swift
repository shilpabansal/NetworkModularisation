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
        var items: [RemoteFeedItem]
    }
        
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        /**
         if the status code is not 200 or the json parsing fails, returns invalid data
         */
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
