//
//  LoadFeedFromCacheTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 24/01/21.
//

import XCTest
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
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, localFeedData: LocalFeedLoader){
        let store = FeedStoreSpy()
        let localFeedData = LocalFeedLoader(store: store)
        
        trackMemoryLeak(store, file: file, line: line)
        trackMemoryLeak(localFeedData, file: file, line: line)
        
        return (store: store, localFeedData: localFeedData)
    }
}
