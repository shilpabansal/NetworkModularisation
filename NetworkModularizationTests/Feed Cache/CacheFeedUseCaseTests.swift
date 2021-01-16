//
//  CacheFeedUseCaseTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 16/01/21.
//

import Foundation
import NetworkModularization
import XCTest
/**
 Delete the existing cache
    On successful deletion, save the feed items
    On failure in deletion, delivers the error
 Save the feed items in cache
  On successful Save, delivers the success message
  On failure in Save, delivers the error
 */

/**
 Feed store protocol is the interface, which expects the feeds to be stored or return error in completion block passed
 */
protocol FeedStore {
    typealias DeletionError = (Error?) -> Void
    typealias InsertionError = (Error?) -> Void
    
    func saveFeeds(items: [FeedItem], timestamp: Date, completion: InsertionError)
    func deleteFeeds(completion: DeletionError)
}

/**
 This class will be responsible for deleting the feeds from feedstore and if its successful, saves the feeds
 */
class LocalFeedStore {
    var store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    
    func saveFeedInCache(items: [FeedItem], timestamp: Date, completion: (Error?) -> Void) {
        store.deleteFeeds { (error) in
            if error != nil {
                completion(error)
            }
            else {
                store.saveFeeds(items: items, timestamp: timestamp, completion: completion)
            }
        }
    }
}

class FeedStoreSpy: FeedStore {
    var deletionFeedStoreCount = 0
    func saveFeeds(items: [FeedItem], timestamp: Date, completion: (Error?) -> Void) {
        
    }
    
    func deleteFeeds(completion: (Error?) -> Void) {
        
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_NoDeletionOnFeedStoreCreation() {
        let store = FeedStoreSpy()
        _ = LocalFeedStore(store: store)
        
        XCTAssertEqual(store.deletionFeedStoreCount, 0)
    }
}
