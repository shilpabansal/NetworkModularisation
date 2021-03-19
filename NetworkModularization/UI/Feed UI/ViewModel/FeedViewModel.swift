//
//  FeedViewModel.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 19/03/21.
//

import Foundation
final class FeedViewModel {
    var onChange: ((FeedViewModel) -> Void)?
    let feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    enum State {
        case pending
        case loading
        case loaded(_ feeds: [FeedImage])
        case failed
    }
    
    private var state = State.pending {
        didSet {
            onChange?(self)
        }
    }
    
    func loadFeed() {
        state = .loading
        feedLoader.load(completion: {[weak self] result in
            if let feeds = try? result.get() {
                self?.state = .loaded(feeds)
            }
            else {
                self?.state = .failed
            }
        })
    }
    
    var isLoading: Bool {
        switch state {
        case .loading:
            return true
        default:
            return false
        }
    }
    
    var feeds: [FeedImage]? {
        switch state {
        case .loaded(let feeds):
            return feeds
        default:
            return nil
        }
    }
}
