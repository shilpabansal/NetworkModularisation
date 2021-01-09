//
//  NetworkModularizationEndToEndTests.swift
//  NetworkModularizationEndToEndTests
//
//  Created by Shilpa Bansal on 09/01/21.
//

import XCTest
@testable import NetworkModularization

class NetworkModularizationEndToEndTests: XCTestCase {

    func test_EndToEndLoadFeed_UsingTestServer() {
        let testURL = URL(string: "http://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let feedLoader = RemoteFeedLoader(url: testURL, client: client)
        
        var receivedResult: LoadFeedResult?
        let exp = expectation(description: "Wait for API")
        feedLoader.getFeeds() { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        switch receivedResult {
        case let .success(feeds)?:
            XCTAssert(feeds.count == 8, "feeds count has 8 elements as expected")
        case let .failure(error)?:
            XCTFail("Expected success result, but received \(error)")
        default:
            XCTFail()
        }
    }

}
