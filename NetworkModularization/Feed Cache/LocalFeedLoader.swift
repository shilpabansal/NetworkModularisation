//
//  LocalFeedLoader.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 17/01/21.
//

import Foundation
import EventKit
/**
 This class will be responsible for deleting the feeds from feedstore and if its successful, saves the feeds
 */

final class LocalFeedLoader {
    var store: FeedStore
    private let calendar = Calendar(identifier: .gregorian)
    let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    func saveFeedInCache(feeds: [FeedImage], timestamp: Date, completion: @escaping (SaveResult) -> Void) {
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
    
    private func cacheInsertion(feeds: [FeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        store.insert(feeds: feeds.toLocal(), timestamp: timestamp, completion: {[weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

extension LocalFeedLoader: FeedLoader {
    typealias LoadResult = FeedLoader.Result
    func getFeeds(completion: @escaping (FeedLoader.Result) -> Void) {
        store.retrieve(completion: {[weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            
            case .failure(let error):
                completion(.failure(error))
                
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: strongSelf.currentDate()):
                completion(.success(cache.feed.toModels()))
                
            case .success(.none), .success(.some):
                completion(.success([]))
                
            default:
                break
            }
        })
    }
}
  
extension LocalFeedLoader {
    func validateCache() {
        store.retrieve {[weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .failure(_):
                strongSelf.store.deleteFeeds{_ in}
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: strongSelf.currentDate()):
                strongSelf.store.deleteFeeds{_ in}
            default:
            break
            }
        }
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
