//
//  CoreDataFeedStoreTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 04/03/21.
//

import Foundation
import XCTest
import NetworkModularization

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() throws {
        let sut = try makeSUT()

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectOnReceivingEmptyCacheTwice() throws {
        let sut = try makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_foundValuesOnNonEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatRetrieveFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_noSideEffectOnRetrievingError() throws {
        let sut = try makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatInsertOverridePreviouslyEnteredValue(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()
        insert(sut: sut, feeds: [], timeStamp: Date())
        
        let deletionError = delete(sut: sut)
        XCTAssertNil(deletionError, "Delete returned no error on empty cache")
    }
    
    func test_insert_overridePreviouslyInsertedCacheValues() throws {
        let sut = try makeSUT()
        assertThatInsertOverridePreviouslyEnteredValue(on: sut)
    }
    
    func test_delete_deliversErrorOnNoPermission() throws {
        
    }
    
    func test_storeSideEffectsSerially() throws {
        let sut = try makeSUT()
        
        assertThatOperationPerfomSerially(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() throws {
        let sut = try makeSUT()
        assertThatInsertOverridePreviouslyEnteredValue(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatDeleteDeliversNoSideEffectOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() throws {
        let sut = try makeSUT()
        
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    private func testSpecificURL() -> URL {
        return URL(fileURLWithPath: "/dev/null")
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) throws -> CoreDataFeedStore {
        let sut = try CoreDataFeedStore(storeURL: testSpecificURL())
        trackMemoryLeak(sut, file: file, line: line)
        return sut
    }
}
