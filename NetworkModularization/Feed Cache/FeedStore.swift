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
protocol FeedStore {
    typealias DeletionError = (Error?) -> Void
    typealias InsertionError = (Error?) -> Void
    typealias LoadError = (Error?) -> Void
    
    func insert(feeds: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionError)
    func deleteFeeds(completion: @escaping DeletionError)
    func retrieve(completion: @escaping LoadError)
}


