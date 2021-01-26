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

final class FeedCachePolicy {
    private let calendar = Calendar(identifier: .gregorian)
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    func validate(_ timeStamp: Date, against date: Date) -> Bool {
        /**
            Checking the difference between the date sent and current is less than 7
         */
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else {
            return false
        }
        return date < maxCacheAge
    }
}

final class LocalFeedLoader {
    private let cachePolicy = FeedCachePolicy()
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
    typealias LoadResult = LoadFeedResult
    func getFeeds(completion: @escaping (LoadResult) -> Void) {
        store.retrieve(completion: {[weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            
            case .failure(let error):
                completion(.failure(error))
                
            case let .found(images, timestamp) where strongSelf.cachePolicy.validate(timestamp, against: strongSelf.currentDate()):
                completion(.success(images.toModels()))
                
            case .empty, .found:
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
            case let .found(_, timestamp) where !strongSelf.cachePolicy.validate(timestamp, against: strongSelf.currentDate()):
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
