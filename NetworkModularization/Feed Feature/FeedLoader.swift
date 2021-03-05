//
//  FeedLoader.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 27/12/20.
//

import Foundation
public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func getFeeds(completion: @escaping ((LoadFeedResult) -> Void))
}
