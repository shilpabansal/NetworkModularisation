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
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Cache.self, from: data)
            
            completion(.found(decoded.localFeeds, decoded.timeStamp))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func insert(feeds: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionError) {
        do {
            let encoder = JSONEncoder()
            
            let codableFeedImages = feeds.map({ return CodableFeedImage($0)})
            let encoded = try encoder.encode(Cache(feeds: codableFeedImages, timeStamp: timestamp))
            try encoded.write(to: storeURL)
            completion(nil)
        }
        catch {
            completion(error)
        }
    }
    
    func deleteFeeds(completion: @escaping FeedStore.DeletionError) {
        do {
            let data = try Data(contentsOf: storeURL)
            if data.isEmpty {
                completion(nil)
                return
            }
            
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        }
        catch {
            completion(error)
        }
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
        
        expect(sut: sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_foundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let timeStamp = Date()
        let feeds = uniqueImageFeeds().local
        
        let insertionError = insert(sut: sut, feeds: feeds, timeStamp: timeStamp)
        
        XCTAssertNil(insertionError)
        expect(sut: sut, expectedResult: .found(feeds, timeStamp))
    }
    
    func test_retrieve_noSideEffectOnReceivingNonEmptyDataTwice() {
        let sut = makeSUT()
        let timeStamp = Date()
        let feeds = uniqueImageFeeds().local
        
        let insertionError = insert(sut: sut, feeds: feeds, timeStamp: timeStamp)
        
        XCTAssertNil(insertionError)
        expect(sut: sut, toRetrieveTwice: .found(feeds, timeStamp))
    }
    
    func test_retrieve_deliversErrorOnInvalidData() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut: sut, expectedResult: .failure(anyNSError()))
    }
    
    func test_retrieve_noSideEffectOnRetrievingError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut: sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridePreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstFeeds = uniqueImageFeeds().local
        let firstInsertionError = insert(sut: sut, feeds: firstFeeds, timeStamp: Date())
        XCTAssertNil(firstInsertionError)
        
        let secondFeeds = uniqueImageFeeds().local
        let secondTimeStamp = Date()
        let secondInsertionError = insert(sut: sut, feeds: secondFeeds, timeStamp: secondTimeStamp)
        
        XCTAssertNil(secondInsertionError)
        expect(sut: sut, expectedResult: .found(secondFeeds, secondTimeStamp))
    }
    
    func test_insertion_deliversErrorOnInvalidFile() {
        let invalidURLString = URL(string: "invalid://store-url")
        let storeURL = invalidURLString
        let sut = makeSUT(storeURL: storeURL)
        
        let feeds = uniqueImageFeeds().local
        let timeStamp = Date()
        let insertionError = insert(sut: sut, feeds: feeds, timeStamp: timeStamp)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with error")
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
       let sut = makeSUT()
        
       insert(sut: sut, feeds: [], timeStamp: Date())
        
       let deletionError = delete(sut: sut)
       XCTAssertNil(deletionError, "Expected no deletion error if store doesn't exist")
        
       expect(sut: sut, expectedResult: .empty)
    }
    
    func test_delete_emptyPreviouslyInsertedCache() {
       let sut = makeSUT()
        
       let feeds = uniqueImageFeeds().local
       let timeStamp = Date()
       insert(sut: sut, feeds: feeds, timeStamp: timeStamp)
        
       let deletionError = delete(sut: sut)
       XCTAssertNil(deletionError, "Expected succesful deletion")
        
       expect(sut: sut, expectedResult: .empty)
    }
    
    func test_delete_deliversErrorOnNoPermission() {
       let noPermissionURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
       let sut = makeSUT(storeURL: noPermissionURL)
        
       let deletionError = delete(sut: sut)
       XCTAssertNotNil(deletionError, "Expected error if deletion permission is restricted")
    }
    
    //MARK:- HELPERS
    @discardableResult
    private func insert(sut: CodableFeedStore, feeds: [LocalFeedImage], timeStamp: Date) -> Error? {
        var insertionError: Error?
        let exp = expectation(description: "Wait for API")
        sut.insert(feeds: feeds, timestamp: timeStamp) { (error) in
            insertionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func delete(sut: CodableFeedStore) -> Error? {
        var deletionError: Error?
        
        let exp = expectation(description: "Wait for API")
        sut.deleteFeeds { (error) in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    private func expect(sut: CodableFeedStore, expectedResult: RetrieveCachedFeedResult, file: StaticString = #file,
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
    
    private func expect(sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file,
                        line: UInt = #line) {
        expect(sut: sut, expectedResult: expectedResult)
        expect(sut: sut, expectedResult: expectedResult)
    }
    
    func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL ?? testSpecificStoreURL())
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
