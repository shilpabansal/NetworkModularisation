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
public class URLSessionHTTPClient: HTTPClient {
    var session: URLSession
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValueRepresentation: Error {}
    
    public func loadFeeds(url: URL, completion: @escaping ((HTTPClient.Result) -> Void)) {
        session.dataTask(with: url) { (data, response, error) in
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
        }.resume()
    }
}
