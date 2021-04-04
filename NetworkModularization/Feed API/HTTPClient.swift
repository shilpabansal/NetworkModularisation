//
//  HTTPClient.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 27/12/20.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    @discardableResult
        func loadFeeds(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

public protocol HTTPClientTask {
    func cancel()
}
