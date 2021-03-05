//
//  HTTPClient.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 27/12/20.
//

import Foundation
import Network

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func loadFeeds(url: URL, completion: @escaping ((Result) -> Void))
}
