//
//  XCTestCase+FeedStoreSpecs.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 22/02/21.
//

import Foundation
import XCTest
@testable import NetworkModularization

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, expectedResult: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let timeStamp = Date()
        let feeds = uniqueImageFeeds().local
        
        let insertionError = insert(sut: sut, feeds: feeds, timeStamp: timeStamp)
        
        XCTAssertNil(insertionError)
        expect(sut: sut, expectedResult: .success(FeedStore.CachedFeed(feed: feeds, timestamp: timeStamp)))
    }
    
    func assertThatRetrieveHasNoSideEffectOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let timeStamp = Date()
        let feeds = uniqueImageFeeds().local
        
        let insertionError = insert(sut: sut, feeds: feeds, timeStamp: timeStamp)
        
        XCTAssertNil(insertionError)
        expect(sut: sut, toRetrieveTwice: .success(FeedStore.CachedFeed(feed: feeds, timestamp: timeStamp)))
    }
    
    func assertThatRetrieveDeliversErrorOnInvalidData(on sut: FeedStore, storeURL: URL, file: StaticString = #file, line: UInt = #line) {
        try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut: sut, expectedResult: .failure(anyNSError()))
    }
    
    func assertThatRetrieveHasNoSideEffectsOnInvalidData(on sut: FeedStore, storeURL: URL, file: StaticString = #file, line: UInt = #line) {
        try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut: sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func assertThatInsertOverridePreviouslyEnteredValue(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let firstFeeds = uniqueImageFeeds().local
        let firstInsertionError = insert(sut: sut, feeds: firstFeeds, timeStamp: Date())
        XCTAssertNil(firstInsertionError)
        
        let secondFeeds = uniqueImageFeeds().local
        let secondTimeStamp = Date()
        let secondInsertionError = insert(sut: sut, feeds: secondFeeds, timeStamp: secondTimeStamp)
        
        XCTAssertNil(secondInsertionError)
        expect(sut: sut, expectedResult: .success(FeedStore.CachedFeed(feed: secondFeeds, timestamp: secondTimeStamp)))
    }
    
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feeds = uniqueImageFeeds().local
        let timeStamp = Date()
        let insertionError = insert(sut: sut, feeds: feeds, timeStamp: timeStamp)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with error")
    }
    
    func assertThatInsertDeliversNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feeds = uniqueImageFeeds().local
        let timeStamp = Date()
        insert(sut: sut, feeds: feeds, timeStamp: timeStamp)
        
        expect(sut: sut, expectedResult: .success(.none))
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(sut: sut, feeds: [], timeStamp: Date())
         
        let deletionError = delete(sut: sut)
        XCTAssertNil(deletionError, "Expected no deletion error if store doesn't exist")
    }
    
    func assertThatDeleteDeliversNoSideEffectOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {         
        insert(sut: sut, feeds: [], timeStamp: Date())
         
        delete(sut: sut)
         
        expect(sut: sut, expectedResult: .success(.none))
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feeds = uniqueImageFeeds().local
        let timeStamp = Date()
        insert(sut: sut, feeds: feeds, timeStamp: timeStamp)
         
        let deletionError = delete(sut: sut)
        XCTAssertNil(deletionError, "Expected succesful deletion")
         
        expect(sut: sut, expectedResult: .success(.none))
    }
    
    func assertThatDeleteErrorOnFilePersmissionRestriction(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = delete(sut: sut)
        XCTAssertNotNil(deletionError, "Expected error if deletion permission is restricted")
    }
    
    func assertThatOperationPerfomSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        var completedOperationInOrder = [XCTestExpectation]()
        let firstFeeds = uniqueImageFeeds().local
        let firstTimeStamp = Date()
        let op1 = expectation(description: "Operarion 1")
        sut.insert(feeds: firstFeeds, timestamp: firstTimeStamp) { (_) in
            completedOperationInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operarion 1")
        sut.deleteFeeds { (_) in
            completedOperationInOrder.append(op2)
            op2.fulfill()
        }
        
        let secondFeeds = uniqueImageFeeds().local
        let secondTimeStamp = Date()
        let op3 = expectation(description: "Operarion 2")
        sut.insert(feeds: secondFeeds, timestamp: secondTimeStamp) { (_) in
            completedOperationInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 0.5)
        XCTAssertEqual(completedOperationInOrder, [op1, op2, op3],
                       "Expected side-effects to run serially, but operation finished in wrong order")
    }
}

extension XCTestCase {
    //MARK:- HELPERS
    @discardableResult
    func insert(sut: FeedStore, feeds: [LocalFeedImage], timeStamp: Date) -> Error? {
        var insertionError: Error?
        let exp = expectation(description: "Wait for API")
        sut.insert(feeds: feeds, timestamp: timeStamp) { (error) in
            insertionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func delete(sut: FeedStore) -> Error? {
        var deletionError: Error?
        
        let exp = expectation(description: "Wait for API")
        sut.deleteFeeds { (error) in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(sut: FeedStore, expectedResult: FeedStore.RetrievalResult, file: StaticString = #file,
                        line: UInt = #line) {
        sut.retrieve(completion: { retrievalResult in
            guard let retrievalResult = retrievalResult else { return }
            switch (expectedResult, retrievalResult) {
            case (.success(.none), .success(.none)),
                 (.failure, .failure):
                break
            case  (let .success(.some(expectedcache)), let .success(.some(retrievedCache))):
                XCTAssertEqual(expectedcache.feed, retrievedCache.feed, file: file, line: line)
                XCTAssertEqual(expectedcache.timestamp, retrievedCache.timestamp, file: file, line: line)
            default:
                XCTFail("Expected found result \(expectedResult), found \(retrievalResult) instead")
            }
        })
    }
    
    func expect(sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #file,
                        line: UInt = #line) {
        expect(sut: sut, expectedResult: expectedResult)
        expect(sut: sut, expectedResult: expectedResult)
    }
}
