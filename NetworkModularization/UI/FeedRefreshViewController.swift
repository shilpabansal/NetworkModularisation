//
//  FeedRefreshViewController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 15/03/21.
//
import UIKit

final public class FeedRefreshViewController: NSObject {
    let feedLoader: FeedLoader
    var onRefresh: (([FeedImage]) -> Void)?
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    public lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load(completion: {[weak self] result in
            if let feeds = try? result.get() {
                self?.onRefresh?(feeds)
            }
            self?.view.endRefreshing()
        })
    }
}
