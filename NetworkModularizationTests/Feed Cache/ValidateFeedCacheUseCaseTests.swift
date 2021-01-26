//
//  ValidateFeedCacheUseCaseTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 26/01/21.
//

import Foundation
import XCTest
import EventKit
@testable import NetworkModularization

class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_NoDeletionOnFeedStoreCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validate_deleteCacheIfRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteFeed])
    }
    
    func test_validate_dontDeleteCacheIsEmpty() {
        let (store, sut) = makeSUT()
        
        sut.validateCache()
        store.completionRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_validate_deleteCacheOnExpiredCache() {
        let (store, sut) = makeSUT()
        sut.validateCache()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        
        store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteFeed])
    }
    
    func test_validate_deleteCacheOnCacheExpiration() {
        let (store, sut) = makeSUT()
        sut.validateCache()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        
        store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteFeed])
    }
    
    func test_validate_dontDeleteCacheOnNonExpiredCache() {
        let (store, sut) = makeSUT()
        sut.validateCache()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        
        store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: nonExpiredTimeStamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_validate_doesntDeleteCacheIfSUTIsAllocated() {
        let store = FeedStoreSpy()
        var localFeedData: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        localFeedData?.validateCache()
        localFeedData = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, localFeedData: LocalFeedLoader){
        let store = FeedStoreSpy()
        let localFeedData = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(localFeedData, file: file, line: line)
        
        return (store: store, localFeedData: localFeedData)
    }
}
