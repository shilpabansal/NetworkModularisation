//
//  FeedViewModel.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 19/03/21.
//

import Foundation
final class FeedViewModel {
    typealias Observer<T> = ((T) -> Void)
    var isLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    let feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        isLoadingStateChange?(true)
        feedLoader.load(completion: {[weak self] result in
            if let feeds = try? result.get() {
                self?.onFeedLoad?(feeds)
            }
            self?.isLoadingStateChange?(false)
        })
    }
}
