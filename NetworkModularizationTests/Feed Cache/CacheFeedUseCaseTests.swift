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
                self?.store.saveFeeds(items: items, timestamp: timestamp, completion: {error in
                    if error != nil {
                        completion(error)
                    }
                    else {
                        completion(nil)
                    }
                })
            }
        }
    }
}

class FeedStoreSpy: FeedStore {
    typealias FeedSuccess = (([FeedItem], Date) -> Void)
    var deletionCompletions = [DeletionError]()
    var insertionCompletions = [InsertionError]()
    
    var receivedMessages = [ReceivedMessage]()
    
    enum ReceivedMessage: Equatable {
        case deleteFeed
        case insertFeed([FeedItem], Date)
    }
    
    func saveFeeds(items: [FeedItem], timestamp: Date, completion: @escaping InsertionError) {
        receivedMessages.append(.insertFeed(items, timestamp))
        insertionCompletions.append(completion)
    }
    
    func deleteFeeds(completion: @escaping DeletionError) {
        receivedMessages.append(.deleteFeed)
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertionSuccessfully(index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func completeInsertion(with error: Error, index: Int = 0) {
        insertionCompletions[index](error)
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_NoDeletionOnFeedStoreCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_DeleteFeedWithError() {
        let (store, localFeedData) = makeSUT()
        
        let exp = expectation(description: "Wait to save feed")
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        var receivedError: Error?
        
        localFeedData.saveFeedInCache(items: [], timestamp: Date()) { (error) in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(with: error)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(store.receivedMessages, [.deleteFeed])
        XCTAssertNotNil(receivedError)
    }
    
    func test_DeletionFeedSuccessSaveSuccess() {
        let (store, localFeedData) = makeSUT()
        
        let exp = expectation(description: "Wait to save feed")
        var receivedError: Error?
        let timeStamp = Date()
        let feedItems = [uniqueItem(), uniqueItem()]
        localFeedData.saveFeedInCache(items: feedItems, timestamp: timeStamp) { (error) in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(store.receivedMessages, [.deleteFeed, .insertFeed(feedItems, timeStamp)])
        XCTAssertNil(receivedError)
    }
    
    func test_DeletionFeedSuccessSaveError() {
        let (store, localFeedData) = makeSUT()
        
        let exp = expectation(description: "Wait to save feed")
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        var receivedError: Error?
        let timeStamp = Date()
        let feedItems = [uniqueItem(), uniqueItem()]
        localFeedData.saveFeedInCache(items: feedItems, timestamp: timeStamp) { (error) in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: error)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(store.receivedMessages, [.deleteFeed, .insertFeed(feedItems, timeStamp)])
        XCTAssertNotNil(receivedError)
    }
    
    //MARK: - Helpers
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, localFeedData: LocalFeedStore){
        let store = FeedStoreSpy()
        let localFeedData = LocalFeedStore(store: store)
        
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(localFeedData, file: file, line: line)
        
        return (store: store, localFeedData: localFeedData)
    }
    
    func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url.com")!)
    }
}
