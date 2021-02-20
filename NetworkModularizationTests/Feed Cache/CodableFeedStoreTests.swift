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
    func retrieve(completion: @escaping FeedStore.RetriveResult) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
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
}
