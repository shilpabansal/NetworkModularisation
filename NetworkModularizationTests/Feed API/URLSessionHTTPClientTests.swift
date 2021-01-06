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
        session.dataTask(with: url) { (data, response, error) in
            
        }
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
        let sut = URLSessionHTTPClient(session: session)
        sut.loadFeeds(url: url) { (result) in
            
        }
        XCTAssertEqual(session.requestURLS, [url])
    }
    
    //MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var requestURLS: [URL] = [URL]()
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestURLS.append(url)
            
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask { }
}
