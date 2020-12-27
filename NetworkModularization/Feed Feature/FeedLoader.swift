//
//  FeedLoader.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 27/12/20.
//

import Foundation
public protocol FeedLoader {
    func getFeeds(completion: @escaping ((RemoteFeedLoader.Result) -> Void))
}
