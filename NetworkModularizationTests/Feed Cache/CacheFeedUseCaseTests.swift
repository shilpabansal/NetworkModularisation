//
//  CacheFeedUseCaseTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 16/01/21.
//

import Foundation
import XCTest

@testable import NetworkModularization
/**
 Delete the existing cache
    On successful deletion, save the feed items
    On failure in deletion, delivers the error
 Save the feed items in cache
  On successful Save, delivers the success message
  On failure in Save, delivers the error
 */

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
        let items = uniqueItems()
        let timeStamp = Date()
        expect(localFeedData, feedItems: items.model, timeStamp: timeStamp, expectedError: error) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: error)
        }
        /**
                To check the order in which the functions are called and with correct data
         */
        XCTAssertEqual(store.receivedMessages, [.deleteFeed, .insertFeed(items.local, timeStamp)])
    }
    
    func test_DeletionFeedSuccessSaveSuccess() {
        let (store, localFeedData) = makeSUT()
                
        let items = uniqueItems()
        let timeStamp = Date()
        expect(localFeedData, feedItems: items.model, timeStamp: timeStamp, expectedError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
        XCTAssertEqual(store.receivedMessages, [.deleteFeed, .insertFeed(items.local, timeStamp)])
    }
    
    func test_deleteDoesNotDeliverErrorAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var localFeedData: LocalFeedLoader? = LocalFeedLoader(store: store)
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        
        var deletionError: Error?
        localFeedData?.saveFeedInCache(items: uniqueItems().model, timestamp: Date()) { (error) in
            deletionError = error
        }
        localFeedData = nil
        store.completeDeletion(with: error)
        
        XCTAssertNil(deletionError)
    }
    
    func test_saveDoesNotDeliverErrorAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var localFeedData: LocalFeedLoader? = LocalFeedLoader(store: store)
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        
        var insertionError: Error?
        localFeedData?.saveFeedInCache(items: uniqueItems().model, timestamp: Date()) { (error) in
            insertionError = error
        }
        store.completeDeletionSuccessfully()
        localFeedData = nil
        store.completeInsertion(with: error)
        
        XCTAssertNil(insertionError)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, localFeedData: LocalFeedLoader){
        let store = FeedStoreSpy()
        let localFeedData = LocalFeedLoader(store: store)
        
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(localFeedData, file: file, line: line)
        
        return (store: store, localFeedData: localFeedData)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url.com")!)
    }
    
    private func uniqueItems() -> (model: [FeedItem], local: [LocalFeedItem]) {
        let items = [uniqueItem(), uniqueItem()]
        let localItems = items.map({item in
            LocalFeedItem(id: item.id, description: item.description, location: item.location, imageURL: item.imageURL)
        })
        
        return (model: items, local: localItems)
    }
    
    private func expect(_ sut: LocalFeedLoader, feedItems: [FeedItem], timeStamp: Date, expectedError: NSError?, action: (() -> Void),
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
    
    
    private class FeedStoreSpy: FeedStore {
        typealias FeedSuccess = (([LocalFeedItem], Date) -> Void)
        var deletionCompletions = [DeletionError]()
        var insertionCompletions = [InsertionError]()
        
        var receivedMessages = [ReceivedMessage]()
        
        enum ReceivedMessage: Equatable {
            case deleteFeed
            case insertFeed([LocalFeedItem], Date)
        }
        
        func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionError) {
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
}
