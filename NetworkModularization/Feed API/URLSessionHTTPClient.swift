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
            else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }
            else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }.resume()
    }
}
