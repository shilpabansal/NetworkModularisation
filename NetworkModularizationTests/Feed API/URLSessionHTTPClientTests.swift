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
 Instead of hitting the real network calls, we are intercepting all the network calls by extending URLProtocol class,
 every test case needs to register the class which is extending URLProtocol and de-register at the end
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
    
    /**
          All the responses except below are considered invalid
          1. Only Data and HttpURLResponse
          2. Only error
     */
    func test_loadFeedFromURL_AllInvalidRepresentationCases() {
        XCTAssertNotNil(requestErrorFor(data: nil, response: nil, error: nil))
        
        XCTAssertNotNil(requestErrorFor(data: nil, response: anyURLResponse(), error: nil))
                
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
            
        let receivedValue = receivedValueFor(data: data, response: response)
        
        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }
    
    func test_loadFeedFromURL_succeedWithEmptyDataWhenDataIsNil() {
        let response = anyHTTPURLResponse()
        let receivedValue = receivedValueFor(data: nil, response: response)
        
        XCTAssertEqual(receivedValue?.data, Data())
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
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
        
        var receivedRequest: URLRequest?
        /**
         CanInit method gets all the api requests, which calls the observer block on the request
         Here the observer is set before making the api call, if the intercepted url is not as expected the test case will fail
         */
        URLProtolcolStub.observeRequests(observer: {request in
            receivedRequest = request
        })
        
        let exp = expectation(description: "Wait for Request completion")
        makeSUT().loadFeeds(url: url) {result in
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedRequest?.url, url)
        XCTAssertEqual(receivedRequest?.httpMethod, "GET")
    }
    
    private func receivedValueFor(data: Data?, response: HTTPURLResponse?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let receivedResult = resultFor(data: data, response: response, error: nil)
        
        switch receivedResult {
        case let .success(receivedData, receivedResponse):
            return (receivedData, receivedResponse)
        default:
            XCTFail("Expected success, got \(receivedResult) instead", file: file, line: line)
            return nil
        }
    }
    
    //MARK: - Helpers
    private func requestErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> NSError? {
        let receivedResult = resultFor(data: data, response: response, error: error)
       
        switch receivedResult {
        case let .failure(expectedError as NSError):
            return  expectedError
        default:
            XCTFail("Expected failure, received \(receivedResult)", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        URLProtolcolStub.stub(data: data, response: response, error: error)
       
        var receivedResult: HTTPClientResult!
        let exp = expectation(description: "Test API")
        makeSUT().loadFeeds(url: anyURL()) {(result) in
            switch result {
            case let .failure(expectedError as NSError):
                receivedResult = .failure(expectedError)
            case let .success(receivedData, receivedResponse):
                receivedResult = .success(receivedData, receivedResponse)
            default:
                fatalError("Expected failure, received \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
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
           return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        /*
         startLoading is the instance method of the URL Protocol class which tells the system startloading the url
         */
        override func startLoading() {
            /**
                To avoid calling observer before urlProtocolDidFinishLoading
             */
            if let requestObserver = URLProtolcolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                requestObserver(request)
                return
            }
            
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
