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
    
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping InsertionError)
    func deleteFeeds(completion: @escaping DeletionError)
}
    
/**
 This class will be responsible for deleting the feeds from feedstore and if its successful, saves the feeds
 */
class LocalFeedLoader {
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
                self?.store.insert(items: items, timestamp: timestamp, completion: completion)
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
    
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping InsertionError) {
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
        
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        
        let timeStamp = Date()
        expect(localFeedData, feedItems: [], timeStamp: timeStamp, expectedError: error) {
            store.completeDeletion(with: error)
        }
        XCTAssertEqual(store.receivedMessages, [.deleteFeed])
    }
    
    func test_DeletionFeedSuccessSaveError() {
        let (store, localFeedData) = makeSUT()
        
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        let items = [uniqueItem(), uniqueItem()]
        let timeStamp = Date()
        expect(localFeedData, feedItems: items, timeStamp: timeStamp, expectedError: error) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: error)
        }
        XCTAssertEqual(store.receivedMessages, [.deleteFeed, .insertFeed(items, timeStamp)])
    }
    
    func test_DeletionFeedSuccessSaveSuccess() {
        let (store, localFeedData) = makeSUT()
                
        let items = [uniqueItem(), uniqueItem()]
        let timeStamp = Date()
        expect(localFeedData, feedItems: items, timeStamp: timeStamp, expectedError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
        XCTAssertEqual(store.receivedMessages, [.deleteFeed, .insertFeed(items, timeStamp)])
    }
    
    //MARK: - Helpers
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, localFeedData: LocalFeedLoader){
        let store = FeedStoreSpy()
        let localFeedData = LocalFeedLoader(store: store)
        
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(localFeedData, file: file, line: line)
        
        return (store: store, localFeedData: localFeedData)
    }
    
    func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url.com")!)
    }
    
    func expect(_ sut: LocalFeedLoader, feedItems: [FeedItem], timeStamp: Date, expectedError: NSError?, action: (() -> Void),
                file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait to save feed")
        
        var receivedError: Error?
        sut.saveFeedInCache(items: feedItems, timestamp: timeStamp) { (error) in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
}
