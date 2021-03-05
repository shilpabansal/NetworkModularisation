//
//  FeedLoader.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 27/12/20.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func getFeeds(completion: @escaping ((Result) -> Void))
}
