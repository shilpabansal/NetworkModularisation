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
    
    func saveFeeds(items: [FeedItem], timestamp: Date, completion: @escaping InsertionError)
    func deleteFeeds(completion: @escaping DeletionError)
}
    
/**
 This class will be responsible for deleting the feeds from feedstore and if its successful, saves the feeds
 */
class LocalFeedStore {
    var store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    
    func saveFeedInCache(items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        store.deleteFeeds {[weak self] (error) in
            if error != nil {
                completion(error)
            }
            else {
                self?.store.saveFeeds(items: items, timestamp: timestamp, completion: completion)
            }
        }
    }
}

class FeedStoreSpy: FeedStore {
    var deletionFeedStoreCount = 0
    typealias DeletionCompletion = ((Error?) -> Void)
    typealias InsertionCompletion = ((Error?) -> Void)
    
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [DeletionCompletion]()
    
    func saveFeeds(items: [FeedItem], timestamp: Date, completion: InsertionCompletion) {
        
    }
    
    func deleteFeeds(completion: @escaping DeletionCompletion) {
        deletionFeedStoreCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, index: Int = 0) {
        deletionCompletions[0](error)
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_NoDeletionOnFeedStoreCreation() {
        let store = FeedStoreSpy()
        _ = LocalFeedStore(store: store)
        
        XCTAssertEqual(store.deletionFeedStoreCount, 0)
    }
    
    func test_DeletionOnFeed() {
        let store = FeedStoreSpy()
        let localFeedData = LocalFeedStore(store: store)
        
        let exp = expectation(description: "Wait to save feed")
        let expectedError = NSError(domain: "Test", code: 0, userInfo: nil)
        localFeedData.saveFeedInCache(items: [], timestamp: Date()) { (error) in
            exp.fulfill()
        }
        
        store.completeDeletion(with: expectedError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(store.deletionFeedStoreCount, 1)
    }
}
