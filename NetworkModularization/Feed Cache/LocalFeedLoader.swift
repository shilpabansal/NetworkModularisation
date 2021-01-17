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
    init(store: FeedStore) {
        self.store = store
    }
    
    func saveFeedInCache(items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        store.deleteFeeds {[weak self] (error) in
            guard let strongSelf = self else { return }
            if error != nil {
                completion(error)
            }
            else {
                strongSelf.cacheInsertion(items: items, timestamp: timestamp, completion: completion)
            }
        }
    }
    
    private func cacheInsertion(items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        store.insert(items: items, timestamp: timestamp, completion: {[weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}
