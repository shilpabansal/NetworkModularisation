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
    
    struct UnexpectedValueRepresentation: Error {}
    
    func loadFeeds(url: URL, completion: @escaping ((HTTPClientResult) -> Void)) {
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data, data.count > 0, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }
            else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }.resume()
    }
}

/**
 Instead of hitting the real network calls, we have created the spy for URL session and the fake tasks
 */
class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtolcolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtolcolStub.stopInterceptingRequest()
    }
    
    func test_loadFeedFromURL_AllInvalidRepresentationCases() {
        //Received data, response and error nil in api response
        XCTAssertNotNil(requestErrorFor(data: nil, response: nil, error: nil))
        
        XCTAssertNotNil(requestErrorFor(data: nil, response: anyURLResponse(), error: nil))
        
        XCTAssertNotNil(requestErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        
        XCTAssertNotNil(requestErrorFor(data: anyData(), response: nil, error: nil))
        
        XCTAssertNotNil(requestErrorFor(data: anyData(), response: nil, error: anyNSError()))
        
        XCTAssertNotNil(requestErrorFor(data: nil, response: anyURLResponse(), error: anyNSError()))
        
        XCTAssertNotNil(requestErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        
        XCTAssertNotNil(requestErrorFor(data: anyData(), response: anyURLResponse(), error: anyNSError()))
        
        XCTAssertNotNil(requestErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        
        XCTAssertNotNil(requestErrorFor(data: anyData(), response: anyURLResponse(), error: nil))
    }
       
    
    func test_loadFeedFromURL_success() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        URLProtolcolStub.stub(data: data, response: response, error: nil)
        
        let exp = expectation(description: "Wait for api")
        makeSUT().loadFeeds(url: anyURL()) { (result) in
            switch result {
            case let .success(receivedData, receivedResponse):
                XCTAssertEqual(data, receivedData)
                XCTAssertEqual(response.url, receivedResponse.url)
                XCTAssertEqual(response.statusCode, receivedResponse.statusCode)
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadFeedFromURL_RequestError() {
        let requestError = anyNSError()
        let receivedError = requestErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual(receivedError?.code, requestError.code)
        XCTAssertEqual(receivedError?.domain, requestError.domain)
    }
    
    /**
        Checks if the request details are same  as intercepted request
     */
    func test_getFromURL_performGetRequestFromURL() {
        let url = anyURL()
        
        let exp = expectation(description: "Wait for API")
        /**
         CanInit method gets all the api requests, which calls the observer block on the request
         Here the observer is set before making the api call, if the intercepted url is not as expected the test case will fail
         */
        URLProtolcolStub.observeRequests(observer: {request in
           XCTAssertEqual( request.url, url)
           XCTAssertEqual( request.httpMethod, "GET")
           exp.fulfill()
        })
        makeSUT().loadFeeds(url: url) {_ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    private func requestErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> NSError? {
        URLProtolcolStub.stub(data: data, response: response, error: error)
       
        var receivedError: Error?
        let exp = expectation(description: "Test API")
        makeSUT().loadFeeds(url: anyURL()) {(result) in
            switch result {
            case let .failure(expectedError as NSError):
                receivedError = expectedError
            default:
                fatalError("Expected failure, received \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError as NSError?
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Test Error", code: 1)
    }
    
    private func anyData() -> Data {
        return Data("Any data".utf8)
    }
    
    private func anyURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
    
    private class URLProtolcolStub: URLProtocol {
        static var stub: Stub?
        static var requestObserver: ((URLRequest) -> Void)?
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtolcolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtolcolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            URLProtolcolStub.requestObserver = observer
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
           requestObserver?(request)
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
