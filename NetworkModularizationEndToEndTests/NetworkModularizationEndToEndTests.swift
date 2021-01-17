//
//  NetworkModularizationEndToEndTests.swift
//  NetworkModularizationEndToEndTests
//
//  Created by Shilpa Bansal on 09/01/21.
//

import XCTest
@testable import NetworkModularization

class NetworkModularizationEndToEndTests: XCTestCase {
    /*
     The disk and memory size can be increaed for cache.
     in case we want to increase, it should be done in didFinishLoading to avoid inconsistent caching
     */
   /* func demoMemoryUpdateForCache() -> URLSession{
        let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        
        let session = URLSession(configuration: configuration)
        
        URLCache.shared = cache
        return session
    }*/
    
    func test_EndToEndLoadFeed_UsingTestServer() {
        
        /**
         To check the default location of the caches
         let documentsUrl =  fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first! as NSURL
         let documentsPath = documentsUrl.path
         print(documentsPath)
         */
        
        switch getFeedResult() {
        case let .success(feeds)?:
            XCTAssert(feeds.count == 8, "feeds count has 8 elements as expected")
            
            feeds.enumerated().forEach({(index, item) in
                XCTAssertEqual(item, expectationResult(index: index), "expected feed value at \(index)")
            })
            
        case let .failure(error)?:
            XCTFail("Expected success result, but received \(error)")
        default:
            XCTFail()
        }
    }
    
    //MARK: Helper
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> LoadFeedResult? {
        let testURL = URL(string: "http://essentialdeveloper.com/feed-case-study/test-api/feed")!
        /**
                   By default URLSession's shared object has caching available, if the data shouldn't be cached, ephemeral object can be used
         */
        //let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let client = URLSessionHTTPClient()
        let feedLoader = RemoteFeedLoader(url: testURL, client: client)
        
        trackMemoryLeak(client, file: file, line: line)
        trackMemoryLeak(feedLoader, file: file, line: line)
        
        var receivedResult: LoadFeedResult?
        let exp = expectation(description: "Wait for API")
        feedLoader.getFeeds() { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }
    
    private func expectationResult(index: Int) -> FeedImage {
        return FeedImage(id: id(at: index),
                        description: description(at: index),
                        location: location(at: index),
                        url: URL(string: image(at: index))!)
    }
    
    private func id(at index: Int) -> UUID {
        switch index {
        case 0: return UUID(uuidString:"73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6")!
        case 1: return UUID(uuidString:"BA298A85-6275-48D3-8315-9C8F7C1CD109")!
        case 2: return UUID(uuidString:"5A0D45B3-8E26-4385-8C5D-213E160A5E3C")!
        case 3: return UUID(uuidString:"FF0ECFE2-2879-403F-8DBE-A83B4010B340")!
        case 4: return UUID(uuidString:"DC97EF5E-2CC9-4905-A8AD-3C351C311001")!
        case 5: return UUID(uuidString:"557D87F1-25D3-4D77-82E9-364B2ED9CB30")!
        case 6: return UUID(uuidString:"A83284EF-C2DF-415D-AB73-2A9B8B04950B")!
        case 7: return UUID(uuidString:"F79BD7F8-063F-46E2-8147-A67635C3BB01")!
        default: return UUID(uuidString:"")!
        }
    }
    
    private func description(at index: Int) -> String? {
        switch index {
        case 0: return "Description 1"
        case 2: return "Description 3"
        case 4: return "Description 5"
        case 5: return "Description 6"
        case 6: return "Description 7"
        case 7: return "Description 8"
        default: return nil
        }
    }
    
    private func image(at index: Int) -> String {
        switch index {
        case 0: return "https://url-1.com"
        case 1: return "https://url-2.com"
        case 2: return "https://url-3.com"
        case 3: return "https://url-4.com"
        case 4: return "https://url-5.com"
        case 5: return "https://url-6.com"
        case 6: return "https://url-7.com"
        case 7: return "https://url-8.com"
        default: return ""
        }
    }
    
    private func location(at index: Int) -> String? {
        switch index {
        case 0: return "Location 1"
        case 1: return "Location 2"
        case 4: return "Location 5"
        case 5: return "Location 6"
        case 6: return "Location 7"
        case 7: return "Location 8"
        default: return nil
        }
    }
}
