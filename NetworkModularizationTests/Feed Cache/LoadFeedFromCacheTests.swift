//
//  LoadFeedFromCacheTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 24/01/21.
//

import XCTest
import EventKit
@testable import NetworkModularization

/**
 Load the feeds from cache if they are saved in last 7 days
 Loads no cache if the cache is >= 7 days old
 
 */
class LoadFeedFromCacheTests: XCTestCase {
    /*
     This method is same as CacheFeedUseCaseTests, but in future if there are 2 separate classes for saving, deleting and loading.
     To make sure that loading test cases cover checking that the creation of object is not deleting the feeds
     */
    func test_NoDeletionOnFeedStoreCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_feedRequest() {
        let (store, feedLoader) = makeSUT()
        feedLoader.getFeeds(completion: {_ in})
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_load_feedRequestError() {
        let (store, feedLoader) = makeSUT()
        let retrievalError = anyNSError()
        expect(feedLoader, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (store, feedLoader) = makeSUT()
        expect(feedLoader, toCompleteWith: .success([]), when: {
            store.completionRetrievalWithEmptyCache()
        })
    }
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let (store, feedLoader) = makeSUT()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let lessThanSevenDays = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        expect(feedLoader, toCompleteWith: .success(feeds.model), when: {
            store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: lessThanSevenDays)
        })
    }
    
    func test_load_DoesntDeliversCachedImagesSevenDaysOldCache() {
        let (store, feedLoader) = makeSUT()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let sevenDays = fixedCurrentDate.adding(days: -7)
        expect(feedLoader, toCompleteWith: .success([]), when: {
            store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: sevenDays)
        })
    }
    
    func test_load_DoesntDeliversCachedImagesOnMoreThanSevenDaysOldCache() {
        let (store, feedLoader) = makeSUT()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let sevenDays = fixedCurrentDate.adding(days: -8)
        expect(feedLoader, toCompleteWith: .success([]), when: {
            store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: sevenDays)
        })
    }
    
    func test_load_doesnotDeleteCacheImagesForSevenOrMoreDaysOldCache() {
        let (store, feedLoader) = makeSUT()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let sevenDays = fixedCurrentDate.adding(days: -8)
        
        expect(feedLoader, toCompleteWith: .success([]), when: {
            store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: sevenDays)
            XCTAssertEqual(store.receivedMessages, [.retrieval])
        })
    }
    
    func test_load_doesntDeleteForSevenOrMoreDaysOldCache() {
        let (store, feedLoader) = makeSUT()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let sevenDays = fixedCurrentDate.adding(days: -8)
        
        expect(feedLoader, toCompleteWith: .success([]), when: {
            store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: sevenDays)
            XCTAssertEqual(store.receivedMessages, [.retrieval])
        })
    }
    
    func test_doesNotHaveAnySideEffectOnRetrievalError() {
        let (store, feedLoader) = makeSUT()
        let retrievalError = anyNSError()
        
        feedLoader.getFeeds(completion:{_ in})
        store.completeRetrieval(with: retrievalError)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
        
    }
    
    func test_dontDeleteCacheFeedOnEmpty() {
        let (store, feedLoader) = makeSUT()
        
        feedLoader.getFeeds(completion: {_ in})
        store.completionRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
        
    }
    
    func test_load_DoesntDeleteIfCachedIsLessThanSevenDaysOldCache() {
        let (store, feedLoader) = makeSUT()
        let feeds = uniqueImageFeeds()
        let fixedCurrentDate = Date()
        let sevenDays = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        
        feedLoader.getFeeds(completion: {_ in})
        store.completeRetrievalSuccessfully(with: feeds.local, timeStamp: sevenDays)
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_load_doesnotDeliverResultIfSUTIsDeallocated() {
        let store = FeedStoreSpy()
        var localFeedData: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.LoadResult]()
        localFeedData?.getFeeds(completion: {result in
            receivedResult.append(result)
        })
        
        localFeedData = nil
        
        store.completionRetrievalWithEmptyCache()
        XCTAssert(receivedResult.isEmpty)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, localFeedData: LocalFeedLoader){
        let store = FeedStoreSpy()
        let localFeedData = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(localFeedData, file: file, line: line)
        
        return (store: store, localFeedData: localFeedData)
    }
    
    private func expect(_ sut: LocalFeedLoader,
                        toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
                        when action: (() -> Void),
                        file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for api")
        sut.getFeeds(completion: {receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
               XCTAssertEqual(receivedImages, expectedImages)
            case let (.failure(receivedError as NSError?), .failure(expectedError as NSError?)):
               XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Expected \(expectedResult), received \(receivedResult)")
            }
            exp.fulfill()
        })
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
