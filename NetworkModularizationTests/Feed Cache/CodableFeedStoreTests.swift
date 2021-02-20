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
    let storeURL: URL
    
    init(_ storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct Cache: Codable {
        let feeds: [CodableFeedImage]
        let timeStamp: Date
        
        var localFeeds: [LocalFeedImage] {
            return feeds.map { return $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ localFeedImage: LocalFeedImage) {
            id = localFeedImage.id
            description = localFeedImage.description
            location = localFeedImage.location
            url = localFeedImage.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    
    func retrieve(completion: @escaping FeedStore.RetrieveResult) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        let decoder = JSONDecoder()
        let decoded = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(decoded.localFeeds, decoded.timeStamp))
    }
    
    func insert(feeds: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionError) {
        let encoder = JSONEncoder()
        
        let codableFeedImages = feeds.map({ return CodableFeedImage($0)})
        let encoded = try! encoder.encode(Cache(feeds: codableFeedImages, timeStamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        updoStoreSideEffect()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
                
        expect(sut: sut, expectedResult: .empty)
    }
    
    func test_retrieve_hasNoSideEffectOnReceivingEmptyCacheTwice() {
        let sut = makeSUT()
        
        expect(sut: sut, expectedResultTwice: .empty)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValue() {
        let sut = makeSUT()
        let timeStamp = Date()
        let feeds = uniqueImageFeeds().local
        let exp = expectation(description: "Wait for API")
        
        sut.insert(feeds: feeds, timestamp: timeStamp, completion: { (insertionError) in
            XCTAssertNil(insertionError, "Expected insertion to be successful")
            
            exp.fulfill()
        })
        
        expect(sut: sut, expectedResult: .found(feeds, timeStamp))
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_noSideEffectOnReceivingNonEmptyDataTwice() {
        let sut = makeSUT()
        let timeStamp = Date()
        let feeds = uniqueImageFeeds().local
        let exp = expectation(description: "Wait for API")
        
        sut.insert(feeds: feeds, timestamp: timeStamp, completion: { (insertionError) in
            XCTAssertNil(insertionError, "Expected insertion to be successful")
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        
        expect(sut: sut, expectedResultTwice: .found(feeds, timeStamp))
    }
    
    
    //MARK:- HELPERS
    private func expect(sut: CodableFeedStore, expectedResult: RetrieveCachedFeedResult, file: StaticString = #file,
                        line: UInt = #line) {
        sut.retrieve(completion: { retrievalResult in
            guard let retrievalResult = retrievalResult else { return }
            switch (expectedResult, retrievalResult) {
            case (.empty, .empty):
                break
            case  (let .found(expectedFeed, expectedTimeStamp), let .found(retrievedFeed, retrievedTimeStamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimeStamp,retrievedTimeStamp, file: file, line: line)
            default:
                XCTFail("Expected found result \(expectedResult), found \(retrievalResult) instead")
            }
        })
    }
    
    private func expect(sut: CodableFeedStore, expectedResultTwice: RetrieveCachedFeedResult, file: StaticString = #file,
                        line: UInt = #line) {
        expect(sut: sut, expectedResult: expectedResultTwice)
        expect(sut: sut, expectedResult: expectedResultTwice)
    }
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(testSpecificStoreURL())
        trackMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func updoStoreSideEffect() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
