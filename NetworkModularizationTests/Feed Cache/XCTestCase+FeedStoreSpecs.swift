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
    //MARK:- HELPERS
    @discardableResult
    func insert(sut: CodableFeedStore, feeds: [LocalFeedImage], timeStamp: Date) -> Error? {
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
    func delete(sut: CodableFeedStore) -> Error? {
        var deletionError: Error?
        
        let exp = expectation(description: "Wait for API")
        sut.deleteFeeds { (error) in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(sut: CodableFeedStore, expectedResult: RetrieveCachedFeedResult, file: StaticString = #file,
                        line: UInt = #line) {
        sut.retrieve(completion: { retrievalResult in
            guard let retrievalResult = retrievalResult else { return }
            switch (expectedResult, retrievalResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break
            case  (let .found(expectedFeed, expectedTimeStamp), let .found(retrievedFeed, retrievedTimeStamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimeStamp,retrievedTimeStamp, file: file, line: line)
            default:
                XCTFail("Expected found result \(expectedResult), found \(retrievalResult) instead")
            }
        })
    }
    
    func expect(sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file,
                        line: UInt = #line) {
        expect(sut: sut, expectedResult: expectedResult)
        expect(sut: sut, expectedResult: expectedResult)
    }
    
    func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL ?? testSpecificStoreURL())
        trackMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
