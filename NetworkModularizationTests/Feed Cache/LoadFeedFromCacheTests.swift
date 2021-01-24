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
        feedLoader.loadFeeds({_ in})
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
    
    private func expect(_ sut: LocalFeedLoader,
                        toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
                        when action: (() -> Void),
                        file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for api")
        sut.loadFeeds({receivedResult in
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

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}

private extension Array where Element == FeedImage {
    func toModels() -> [FeedImage] {
        return map({return FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map({
            return FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)
        })
    }
}
