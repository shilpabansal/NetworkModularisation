//
//  CodableFeedStoreTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 20/02/21.
//

import Foundation
import XCTest
@testable import NetworkModularization

class CodableFeedStore {
    private struct Cache: Codable {
        let feeds: [LocalFeedImage]
        let timeStamp: Date
    }
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    func retrieve(completion: @escaping FeedStore.RetriveResult) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        let decoder = JSONDecoder()
        let decoded = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(decoded.feeds, decoded.timeStamp))
    }
    
    func insert(feeds: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionError) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feeds: feeds, timeStamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for API")
        sut.retrieve(completion: {result in
            guard let result = result else { return }
            switch result {
            case .empty:
                break
            
            default:
                XCTFail("Expected empty result, found \(result) instead")
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for API")
        sut.retrieve(completion: {firstResult in
            sut.retrieve(completion: {secondResult in
                guard let firstResult = firstResult, let secondResult = secondResult else { return }
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                break
                
                default:
                    XCTFail("Expected empty result, found \(firstResult) \(secondResult) instead")
                }
            })
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValue() {
        let sut = CodableFeedStore()
        let timeStamp = Date()
        let feeds = uniqueImageFeeds().local
        let exp = expectation(description: "Wait for API")
        
        sut.insert(feeds: feeds, timestamp: timeStamp, completion: { (insertionError) in
            XCTAssertNil(insertionError, "Expected insertion to be successful")
            
            sut.retrieve(completion: { retrievalResult in
                guard let retrievalResult = retrievalResult else { return }
                switch retrievalResult {
                case let .found(retrievalImages, retrievalTimeStamp):
                    XCTAssertEqual(retrievalImages, feeds)
                    XCTAssertEqual(retrievalTimeStamp, timeStamp)
                    
                break
                
                default:
                    XCTFail("Expected found result \(feeds) and \(timeStamp), found \(retrievalResult) instead")
                }
            })
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
}
