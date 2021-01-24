//
//  LocalFeedLoader.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 17/01/21.
//

import Foundation
/**
 This class will be responsible for deleting the feeds from feedstore and if its successful, saves the feeds
 */
final class LocalFeedLoader {
    var store: FeedStore
    typealias LoadResult = LoadFeedResult
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func saveFeedInCache(feeds: [FeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        store.deleteFeeds {[weak self] (error) in
            guard let strongSelf = self else { return }
            if error != nil {
                completion(error)
            }
            else {
                strongSelf.cacheInsertion(feeds: feeds, timestamp: timestamp, completion: completion)
            }
        }
    }
    
    func loadFeeds(_ completion: @escaping (LoadResult) -> Void) {
        store.retrieve(completion: {result in
            switch result {
            case .empty:
                completion(.success([]))
            case .failure(let error):
                completion(.failure(error))
            case let .found(images, _):
                completion(.success(images.toModels()))
            default:
                break
            }
        })
    }
    
    private func cacheInsertion(feeds: [FeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        store.insert(feeds: feeds.toLocal(), timestamp: timestamp, completion: {[weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map({return LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map({
            return FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        })
    }
}
