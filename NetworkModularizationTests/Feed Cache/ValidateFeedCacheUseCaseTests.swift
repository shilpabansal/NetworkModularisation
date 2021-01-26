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
    
    func test_validate_deleteCacheIfMoreThanSevenDaysOld() {
        let (store, sut) = makeSUT()
        sut.validateCache()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let date = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        
        store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: date)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteFeed])
    }
    
    func test_validate_deleteCacheIfSevenDaysOld() {
        let (store, sut) = makeSUT()
        sut.validateCache()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let date = fixedCurrentDate.adding(days: -7)
        
        store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: date)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteFeed])
    }
    
    func test_validate_dontDeleteCacheIfLessThanSevenDaysOld() {
        let (store, sut) = makeSUT()
        sut.validateCache()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let date = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        
        store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: date)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, localFeedData: LocalFeedLoader){
        let store = FeedStoreSpy()
        let localFeedData = LocalFeedLoader(store: store)
        
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(localFeedData, file: file, line: line)
        
        return (store: store, localFeedData: localFeedData)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Test Error", code: 1)
    }
    
    private func uniqueFeed() -> FeedImage {
        return FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://a-url.com")!)
    }
    
    private func uniqueImageFeeds() -> (model: [FeedImage], local: [LocalFeedImage]) {
        let feeds = [uniqueFeed(), uniqueFeed()]
        let localFeeds = feeds.map({feed in
            LocalFeedImage(id: feed.id, description: feed.description, location: feed.location, url: feed.url)
        })
        
        return (model: feeds, local: localFeeds)
    }
}
