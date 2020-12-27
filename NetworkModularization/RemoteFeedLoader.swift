//
//  RemoteFeedLoader.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 26/12/20.
//

import Foundation
import Network

public protocol HTTPClient {
    func loadFeeds(url: URL, completion: @escaping ((HTTPClientResult) -> Void))
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case error(Error)
}
/**
 Instead of creating success and error object, its always better to create an enum to have less maintenance for diff kinds of result, as at a time it will be only one kind of result
 */
public enum LoadFeedResult {
    case error(RemoteFeedLoader.Error)
}

public protocol FeedLoader {
    func getFeeds(completion: @escaping ((RemoteFeedLoader.Result) -> Void))
}

public final class RemoteFeedLoader : FeedLoader {
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func getFeeds(completion: @escaping ((RemoteFeedLoader.Result) -> Void)) {
        /**
            Network library is unaware of common errors and responses, the viewmodel receives the respoonse and convert it into the expected enum responses which can be handled by the views
         */
        client.loadFeeds(url: url) {(result) in
            switch result {
            case let .success(data, response):
                do {
                    let items = try FeedItemMapper.map(data: data, response)
                    completion(.success(items))
                }
                catch {
                    /**
                    Instead of json object, if any other kind of data is passed, it should return invalid dat
                     */
                    completion(.failure(.invalidData))
                }
            case .error(_):
                completion(.failure(.connectivity))
            }
        }
    }
    
    private var client: HTTPClient
    private var url : URL
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
}

private class FeedItemMapper {
    static func map(data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).items.map ({$0.item})
    }
    
    private struct Root: Decodable {
        var items: [Item]
    }

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

}
