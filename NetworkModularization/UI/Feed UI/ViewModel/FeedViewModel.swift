//
//  FeedViewModel.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 19/03/21.
//

import Foundation
final class FeedViewModel {
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    let feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load(completion: {[weak self] result in
            if let feeds = try? result.get() {
                self?.onFeedLoad?(feeds)
            }
            self?.isLoading = false
        })
    }
    
    private(set) var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }
}
