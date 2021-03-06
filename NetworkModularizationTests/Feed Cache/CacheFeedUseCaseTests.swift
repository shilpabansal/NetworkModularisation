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
    On successful deletion, save the feed feeds
    On failure in deletion, delivers the error
 Save the feed feeds in cache
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
                
        let timeStamp = Date()
        expect(localFeedData, feeds: [], timeStamp: timeStamp, expectedError: anyNSError()) {
            store.completeDeletion(with: anyNSError())
        }
        XCTAssertEqual(store.receivedMessages, [.deleteFeed])
    }
    
    func test_DeletionFeedSuccessSaveError() {
        let (store, localFeedData) = makeSUT()
        
        let feeds = uniqueImageFeeds()
        let timeStamp = Date()
        expect(localFeedData, feeds: feeds.model, timeStamp: timeStamp, expectedError: anyNSError()) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: anyNSError())
        }
        /**
                To check the order in which the functions are called and with correct data
         */
        XCTAssertEqual(store.receivedMessages, [.deleteFeed, .insertFeed(feeds.local, timeStamp)])
    }
    
    func test_DeletionFeedSuccessSaveSuccess() {
        let (store, localFeedData) = makeSUT()
                
        let feeds = uniqueImageFeeds()
        let timeStamp = Date()
        expect(localFeedData, feeds: feeds.model, timeStamp: timeStamp, expectedError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
        XCTAssertEqual(store.receivedMessages, [.deleteFeed, .insertFeed(feeds.local, timeStamp)])
    }
    
    func test_deleteDoesNotDeliverErrorAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var localFeedData: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var deletionError: Error?
        localFeedData?.saveFeedInCache(feeds: uniqueImageFeeds().model, timestamp: Date()) { (result) in
            switch result {
            case .failure(let error):
                deletionError = error
            default:
                deletionError = nil
            }
        }
        localFeedData = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertNil(deletionError)
    }
    
    func test_saveDoesNotDeliverErrorAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var localFeedData: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var insertionError: Error?
        localFeedData?.saveFeedInCache(feeds: uniqueImageFeeds().model, timestamp: Date()) { (result) in
            switch result {
            case .failure(let error):
                insertionError = error
            default:
                insertionError = nil
            }
        }
        store.completeDeletionSuccessfully()
        localFeedData = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertNil(insertionError)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, localFeedData: LocalFeedLoader){
        let store = FeedStoreSpy()
        let localFeedData = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(localFeedData, file: file, line: line)
        
        return (store: store, localFeedData: localFeedData)
    }
    
    private func expect(_ sut: LocalFeedLoader, feeds: [FeedImage], timeStamp: Date, expectedError: NSError?, action: (() -> Void),
                file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait to save feed")
        
        var receivedError: Error?
        sut.saveFeedInCache(feeds: feeds, timestamp: timeStamp) { (result) in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                receivedError = nil
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
}
