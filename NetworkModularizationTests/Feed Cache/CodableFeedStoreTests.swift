//
//  CodableFeedStoreTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 20/02/21.
//

import Foundation
import XCTest
@testable import NetworkModularization

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
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
                
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectOnReceivingEmptyCacheTwice() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_foundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_noSideEffectOnReceivingNonEmptyDataTwice() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversErrorOnInvalidData() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        assertThatRetrieveDeliversErrorOnInvalidData(on: sut, storeURL: storeURL)
    }
    
    func test_retrieve_noSideEffectOnRetrievingError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        assertThatRetrieveHasNoSideEffectsOnInvalidData(on: sut, storeURL: storeURL)
    }
    
    func test_insert_overridePreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        assertThatInsertOverridePreviouslyEnteredValue(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURLString = URL(string: "invalid://store-url")
        let storeURL = invalidURLString
        let sut = makeSUT(storeURL: storeURL)
        
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_insert_noSideEffectOnInsertionError() {
        let invalidURLString = URL(string: "invalid://store-url")
        let storeURL = invalidURLString
        let sut = makeSUT(storeURL: storeURL)
        
        assertThatInsertDeliversNoSideEffectsOnInsertionError(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
       let sut = makeSUT()
        
       assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
       let sut = makeSUT()
        
       assertThatDeleteDeliversNoSideEffectOnEmptyCache(on: sut)
    }
    
    func test_delete_emptyPreviouslyInsertedCache() {
       let sut = makeSUT()
        
       assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_delete_deliversErrorOnNoPermission() {
       let noPermissionURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
       let sut = makeSUT(storeURL: noPermissionURL)
        
       assertThatDeleteErrorOnFilePersmissionRestriction(on: sut)
    }
    
    func test_storeSideEffectsSerially() {
        let sut = makeSUT()
        
        assertThatOperationPerfomSerially(on: sut)
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
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL ?? testSpecificStoreURL())
        trackMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
