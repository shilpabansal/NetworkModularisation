//
//  NetworkModularizationCacheIntegrationTests.swift
//  NetworkModularizationCacheIntegrationTests
//
//  Created by Shilpa Bansal on 04/03/21.
//

import XCTest
@testable import NetworkModularization

class NetworkModularizationIntegrationTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        try setupEmptyStoreState()
    }
    
    override func tearDownWithError() throws {
        try undoStoreSideEffects()
        
        try super.tearDownWithError()
    }
        
    func test_retrieve_deliversEmptyOnEmptyCache() throws {
        let sut = try makeSUT()

        expect(sut: sut, expectedResult: .success(.none))
    }

    func test_retrieve_deliversFeedInsertedOnAnotherInstance() throws {
        let storeToInsert = try makeSUT()
        let storeToLoad = try makeSUT()
        let feeds = uniqueImageFeeds()
        let timestamp = Date()

        insert(sut: storeToInsert, feeds: feeds.local, timeStamp: timestamp)

        expect(sut: storeToLoad, expectedResult: .success(FeedStore.CachedFeed(feed: feeds.local, timestamp: timestamp)))
    }

    func test_insert_overridesFeedInsertedOnAnotherInstance() throws {
        let storeToInsert = try makeSUT()
        let storeToOverride = try makeSUT()
        let storeToLoad = try makeSUT()

        insert(sut: storeToInsert, feeds: uniqueImageFeeds().local, timeStamp: Date())

        let latestFeed = uniqueImageFeeds()
        let latestTimestamp = Date()
        insert(sut: storeToOverride, feeds: latestFeed.local, timeStamp: latestTimestamp)

        expect(sut: storeToLoad, expectedResult: .success(FeedStore.CachedFeed(feed: latestFeed.local, timestamp: latestTimestamp)))
    }

    func test_delete_deletesFeedInsertedOnAnotherInstance() throws {
        let storeToInsert = try makeSUT()
        let storeToDelete = try makeSUT()
        let storeToLoad = try makeSUT()

        insert(sut: storeToInsert, feeds: uniqueImageFeeds().local, timeStamp: Date())

        delete(sut: storeToDelete)

        expect(sut: storeToLoad, expectedResult: .success(.none))
    }
        
    // - MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) throws -> CoreDataFeedStore {
        let storeURL = testSpecificURL()
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func setupEmptyStoreState() throws {
        try dataCleanup()
    }
    
    private func undoStoreSideEffects() throws {
        try dataCleanup()
    }
    
    private func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificURL() -> URL {
        return cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func dataCleanup() throws {
        delete(sut: try CoreDataFeedStore(storeURL: testSpecificURL()))
    }

    
    private func expect(_ sut: LocalFeedLoader, feeds: [FeedImage], timeStamp: Date, expectedError: NSError?, action: (() -> Void),
                file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait to save feed")
        
        var receivedError: Error?
        sut.saveFeedInCache(feeds: feeds, timestamp: timeStamp) { (error) in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
}
