//
//  RemoteFeedLoaderTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 26/12/20.
//

import XCTest
import NetworkModularization

/**
 Since we are testing view model only,
 the HTTPClientSpy is created which implements HTTPClient and mock all the responses
 */
class RemoteFeedLoaderTests: XCTestCase {
    func test_init_requestURLNil() {
        let (client, _) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestURL() {
        let url = URL(string: "abc")!
        let (client, feed) = makeSUT(url: url)
        feed.getFeeds(completion: {_ in })
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestUR() {
        let url = URL(string: "abc")!
        let (client, feed) = makeSUT(url: url)
        
        feed.getFeeds(completion: {_ in })
        feed.getFeeds(completion: {_ in })
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_ConnectivityError_requestUR() {
        let (client, feed) = makeSUT()
        
        expect(sut: feed, expectedResult: failure(.connectivity)) {
            /**
            Instead of mocking the error, we are calling the completion block of network library and checking if viewModel's completion block is called as expected error or not
             */
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: clientError, index: 0)
        }
    }
    
    func test_Non200Error_requestUR() {
        let (client, feed) = makeSUT()
        
        /**
            Different possibilities of error codes are considered, the error is complared to see if on the completion index expected error is there or not
         */
        let errorCodes = [199, 201, 400, 401, 500, 501]
        errorCodes.enumerated().forEach({(index, item) in
            expect(sut: feed, expectedResult: failure(.invalidData)) {
                let jsonData = makeData(items: [])
                client.complete(with: item, data: jsonData, index: index)
            }
        })
    }
    
    func test_Non200InvalidData_requestUR() {
        let (client, feed) = makeSUT()
        
        expect(sut: feed, expectedResult: failure(.invalidData)) {
            let clientData = Data("invalid data".utf8)
            client.complete(with: 200, data: clientData)
        }
    }
    
    func test_Non200EmptyList_requestUR() {
        let (client, feed) = makeSUT()
        
        expect(sut: feed, expectedResult: .success([])) {
            let clientData = Data("{\"items\": []}".utf8)
            client.complete(with: 200, data: clientData)
        }
    }
    
    func test_Non200ValidResponse_requestUR() {
        let (client, feed) = makeSUT()
        
        let (feedItem1, itemJSON1) = makeItems(id: UUID(),
                                description: nil,
                                location: nil,
                                imageURL: URL(string: "https://a-string.com")!)
       
        let (feedItem2, itemJSON2) = makeItems(id: UUID(),
                                description: nil,
                                location: nil,
                                imageURL: URL(string: "https://a-string.com")!)
        let jsonArray = [itemJSON1, itemJSON2]
    
        expect(sut: feed, expectedResult: .success([feedItem1, feedItem2])) {
            let clientData = makeData(items: jsonArray)
            client.complete(with: 200, data: clientData)
        }
    }
    
    func test_doesNotDeliverResultAfterFeedInstanceHasBeenDeallocated() {
        let url = URL(string: "abc")!
        let client = HttpClientSpy()
        var feed: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResult = [RemoteFeedLoader.Result]()
        feed?.getFeeds(completion: { capturedResult.append($0) })
        
        feed = nil
        let clientData = Data("{\"items\": []}".utf8)
        client.complete(with: 200, data: clientData)
        
        /**
        As the getFeeds method of RemoteFeedLoader is checking for self != nil, capturedResult returns empty
         */
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    private func makeData(items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return  try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    private func makeItems(id: UUID, description: String?, location: String?, imageURL: URL) -> (items: FeedItem, json: [String: Any]) {
        let feedItem = FeedItem(id: id,
                                description: description,
                                location: location,
                                imageURL: imageURL)
        let itemJSON = ["id": feedItem.id.uuidString,
                         "image": feedItem.imageURL.absoluteString]
        
        return (feedItem, itemJSON)
    }
    
    //MARK: - Helpers
    //SUT: System under test
    private func makeSUT(url: URL = URL(string: "abc")!,
                         file: StaticString = #file,
                         line: UInt = #line) -> (HttpClientSpy, RemoteFeedLoader) {
        let url = URL(string: "abc")!
        let client = HttpClientSpy()
        let feed = RemoteFeedLoader(url: url, client: client)
        
        trackMemoryLeak(feed, file: file, line: line)
        return (client, feed)
    }
    
    private func expect(sut: RemoteFeedLoader,
                        expectedResult: RemoteFeedLoader.Result,
                        action:(() -> Void),
                        file: StaticString = #file,
                        line: UInt = #line) {
        _ = [RemoteFeedLoader.Result]()
        
        let expect = expectation(description: "wait for feed completion")
        sut.getFeeds(completion: {receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as! RemoteFeedLoader.Error, expectedError as! RemoteFeedLoader.Error)
            default:
                XCTFail("Test case failure")
            }
            expect.fulfill()
        })
        
        action()
        
        wait(for: [expect], timeout: 1.0)
    }
    /**
        private class since its only needed for testcases, wont be part of production code
     */
    private class HttpClientSpy : HTTPClient {
        private var error: Error?
        /**
            An array is taken in order to track how many reqquests are made and in what order they are made
         */
        var messages = [(url: URL, completion: ((HTTPClientResult) -> Void))]()
        var requestedURLs: [URL] {
            return messages.map({$0.url})
        }
        
        func loadFeeds(url: URL, completion: @escaping ((HTTPClientResult) -> Void)) {
            messages.append((url, completion))
        }
        
        /**
            When test case calls loadFeeds the url and completion block is saved in messageArray,
            Testcase calls ccomplete with error or statuscode to call the completion block
         */
        func complete(with error: Error, index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with statusCode: Int, data: Data, index: Int = 0) {
            if let response = HTTPURLResponse(url: messages[index].url,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil) {
                messages[index].completion(.success(data, response))
            }
        }
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
}
