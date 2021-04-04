//
//  URLSessionHTTPClient.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 07/01/21.
//

import Foundation

/**
 The class which implements HTTPClient protocol,
 as currently we are using URLSession to get the feeds from network, its named accordingly
 */
public final class URLSessionHTTPClient: HTTPClient {
    public func loadFeeds(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { (data, response, error) in
            completion(Result {
                if let error = error {
                    throw error
                }
                if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
               }
                else {
                    throw UnexpectedValueRepresentation()
                }
            })
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
    
    var session: URLSession
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct UnexpectedValueRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask

        func cancel() {
            wrapped.cancel()
        }
    }
}
