//
//  RemoteFeedLoader.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 26/12/20.
//

import Foundation
import Network

/**
 Instead of creating success and error object, its always better to create an enum to have less maintenance for diff kinds of result, as at a time it will be only one kind of result
 */
public enum LoadFeedResult {
    case error(RemoteFeedLoader.Error)
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
        client.loadFeeds(url: url) {[weak self] (result) in
        guard self != nil else { return }
        
        switch result {
            case let .success(data, response):
                /**
                The benefit of taking the map method static is, though the self reference is deallocatd, it can still return the completion block
                 */
                completion(FeedItemMapper.map(data, response))
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
