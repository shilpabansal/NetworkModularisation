//
//  FeedStore.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 17/01/21.
//

import Foundation
/**
 Feed store protocol is the interface, which expects the feeds to be stored or return error in completion block passed
 */
enum CacheFeed {
    case empty
    case found([LocalFeedImage], Date)
}

protocol FeedStore {
    typealias RetrievalResult = Swift.Result<CacheFeed, Error>

    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrieveCompletion = (RetrievalResult?) -> Void
    
    func insert(feeds: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func deleteFeeds(completion: @escaping DeletionCompletion)
    func retrieve(completion: @escaping RetrieveCompletion)
}


