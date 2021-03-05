//
//  RemoteFeedLoader.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 26/12/20.
//

import Foundation
import Network

public final class RemoteFeedLoader : FeedLoader {
    public typealias Result = FeedLoader.Result
    
    private var client: HTTPClient
    private var url : URL
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func getFeeds(completion: @escaping ((Result) -> Void)) {
        /**
            Network library is unaware of common errors and responses, the viewmodel receives the respoonse and convert it into the expected enum responses which can be handled by the views
         */
        client.loadFeeds(url: url) {[weak self] (result) in
        guard self != nil else { return }
        
        switch result {
        case let .success((data, response)):
                completion(RemoteFeedLoader.map(data, response: response))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemMapper.map(data, response)
            /**
            The benefit of taking the map method static is, though the self reference is deallocatd, it can still return the completion block
             */
            return .success(items.toModels())
        }
        catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map({
            return FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)
        })
    }
}
