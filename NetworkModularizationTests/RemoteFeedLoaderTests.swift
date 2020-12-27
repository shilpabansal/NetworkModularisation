//
//  RemoteFeedLoaderTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 26/12/20.
//

import XCTest
import NetworkModularization

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
        
        expect(sut: feed, result: .failure(.connectivity)) {
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
            expect(sut: feed, result: .failure(.invalidData)) {
                let jsonData = makeData(items: [])
                client.complete(with: item, data: jsonData, index: index)
            }
        })
    }
    
    func test_Non200InvalidData_requestUR() {
        let (client, feed) = makeSUT()
        
        expect(sut: feed, result: .failure(.invalidData)) {
            let clientData = Data("invalid data".utf8)
            client.complete(with: 200, data: clientData)
        }
    }
    
    func test_Non200EmptyList_requestUR() {
        let (client, feed) = makeSUT()
        
        expect(sut: feed, result: .success([])) {
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
    
        expect(sut: feed, result: .success([feedItem1, feedItem2])) {
            let clientData = makeData(items: jsonArray)
            client.complete(with: 200, data: clientData)
        }
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
    private func makeSUT(url: URL = URL(string: "abc")!) -> (HttpClientSpy, RemoteFeedLoader) {
        let url = URL(string: "abc")!
        let client = HttpClientSpy()
        let feed = RemoteFeedLoader(url: url, client: client)
        return (client, feed)
    }
    
    private func expect(sut: RemoteFeedLoader,
                        result: RemoteFeedLoader.Result,
                        action:(() -> Void),
                        file: StaticString = #file,
                        line: UInt = #line) {
        var capturedResult = [RemoteFeedLoader.Result]()
        sut.getFeeds(completion: { capturedResult.append($0) })
        
        action()
        
        XCTAssertEqual(capturedResult, [result], file: file, line: line)
    }
    /**
        private class since its only needed for testcases, wont be part of production code
     */
    class HttpClientSpy : HTTPClient {
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
        
        func complete(with error: Error, index: Int = 0) {
    
            messages[index].completion(.error(error))
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
}
