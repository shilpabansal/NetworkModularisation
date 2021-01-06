//
//  URLSessionHTTPClientTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 06/01/21.
//

import Foundation
import XCTest
@testable import NetworkModularization

/**
 The class which implements HTTPClient protocol,
 as currently we are using URLSession to get the feeds from network, its named accordingly
 */
class URLSessionHTTPClient: HTTPClient {
    func loadFeeds(url: URL, completion: @escaping ((HTTPClientResult) -> Void)) {
        session.dataTask(with: url) { (data, response, error) in }.resume()
    }
    
    var session: URLSession
    init(session: URLSession) {
        self.session = session
    }
}

/**
 Instead of hitting the real network calls, we have created the spy for URL session and the fake tasks
 */
class URLSessionHTTPClientTests: XCTestCase {
    func testURLSession() {
        let url = URL(string: "http://a-url.com")!
        
        let session = URLSessionSpy()
        let dataTask = URLSessionDataTaskSpy()
        
        /**
          stubbing the datatask for url, to test if expected datatask is returned for url or not
         */
        session.stub(url: url, dataTask: dataTask)
        let sut = URLSessionHTTPClient(session: session)
        sut.loadFeeds(url: url) { (result) in }
        XCTAssertEqual(dataTask.resumeCallCount, 1)
    }
    
    //MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var stub = [URL: URLSessionDataTask]()
        
        func stub(url: URL, dataTask: URLSessionDataTask) {
            stub[url] = dataTask
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            /**
            If the array doesnt have item for the url, will return fake task
             */
            return stub[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        override func resume() {
            resumeCallCount += 1
        }
    }
}
