//
//  HTTPClient.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 27/12/20.
//

import Foundation
import Network

public protocol HTTPClient {
    func loadFeeds(url: URL, completion: @escaping ((HTTPClientResult) -> Void))
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case error(Error)
}
