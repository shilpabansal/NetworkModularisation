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
        session.dataTask(with: url) { (_, _, error) in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
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
    func testURLSession_dataTask() {
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
    
    func test_loadFeedFromURL_Error() {
        let url = URL(string: "http://a-url.com")!
        
        let session = URLSessionSpy()
        let dataTask = URLSessionDataTaskSpy()
        
        let error = NSError(domain: "Test Error", code: 1)
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Test API")
        sut.loadFeeds(url: url) { (result) in
            switch result {
            case let .failure(expectedError as NSError):
                XCTAssertEqual(expectedError, error)
            default:
                fatalError("Expected failure, received something else")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var stub = [URL: Stub]()
        
        struct Stub {
            var task: URLSessionDataTask
            var error: Error?
        }
        
        func stub(url: URL, dataTask: URLSessionDataTask = URLSessionDataTask(), error: Error? = nil) {
            stub[url] = Stub(task: dataTask, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let result = stub[url] else {
                fatalError("Couldn't find stub for given URL")
            }
            completionHandler(nil, nil, result.error)
            return stub[url]?.task ?? FakeURLSessionDataTask()
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
