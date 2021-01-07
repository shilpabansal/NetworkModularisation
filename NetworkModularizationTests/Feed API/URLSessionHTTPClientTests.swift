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
    var session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func loadFeeds(url: URL, completion: @escaping ((HTTPClientResult) -> Void)) {
        let url = URL(string: "https://wrong-url")!
        session.dataTask(with: url) { (_, _, error) in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

/**
 Instead of hitting the real network calls, we have created the spy for URL session and the fake tasks
 */
class URLSessionHTTPClientTests: XCTestCase {
    func test_loadFeedFromURL_Error() {
        URLProtolcolStub.startInterceptingRequest()
        let url = URL(string: "http://a-url.com")!
        let error = NSError(domain: "Test Error", code: 1, userInfo: nil)
        URLProtolcolStub.stub(data: nil, response: nil, error: error)
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Test API")
        sut.loadFeeds(url: url) { (result) in
            switch result {
            case let .failure(expectedError as NSError):
                XCTAssertEqual(expectedError.code, error.code)
                XCTAssertEqual(expectedError.domain, error.domain)
            default:
                fatalError("Expected failure, received something else")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtolcolStub.stopInterceptingRequest()
    }
    
    //MARK: - Helpers
    private class URLProtolcolStub: URLProtocol {
        static var stub: Stub?
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtolcolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtolcolStub.self)
            stub = nil
        }
        
        struct Stub {
            var data: Data?
            var response: URLResponse?
            var error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
           return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        /*
         startLoading is the instance method of the URL Protocol class which tells the system startloading the url
         */
        override func startLoading() {
            if let data = URLProtolcolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtolcolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            /**
            Here client is the object of NSURLProtocolClient, which provides the interface to the URL
             loading system
             */
            if let error = URLProtolcolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        /**
          Though this method is not doing anything, it must be implemented, otherwise crash will occur
         */
        override func stopLoading() {}
    }
}
