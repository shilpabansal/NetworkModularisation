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
    typealias LoadResult = LoadFeedResult
    private let calendar = Calendar(identifier: .gregorian)
    private let maxCacheAgeInDays = 7
    
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
        store.retrieve(completion: {[weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            
            case .failure(let error):
                strongSelf.store.deleteFeeds { _ in }
                completion(.failure(error))
                
            case let .found(images, timestamp) where strongSelf.validate(timestamp):
                completion(.success(images.toModels()))
                
            case .empty:
                completion(.success([]))
                
            case .found:
                strongSelf.store.deleteFeeds {_ in }
                completion(.success([]))
            default:
                break
            }
        })
    }
    
    private func validate(_ timeStamp: Date) -> Bool {
        let currentDate = Date()
        /**
                Checking the difference between the date sent and current is less than 7
         */
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else {
            return false
        }
        return currentDate < maxCacheAge
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
