//
//  FeedPresenter.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 21/03/21.
//

protocol FeedLoadingView: class {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feeds: [FeedImage])
}

final class FeedPresenter {
    typealias Observer<T> = ((T) -> Void)
   
    var view: FeedView?
    weak var loadingView: FeedLoadingView?
    let feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load(completion: {[weak self] result in
            if let feeds = try? result.get() {
                self?.view?.display(feeds: feeds)
            }
            self?.loadingView?.display(isLoading: false)
        })
    }
}
