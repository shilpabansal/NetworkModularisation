//
//  FeedRefreshViewController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 15/03/21.
//
import UIKit

final public class FeedRefreshViewController: NSObject {
    var viewModel: FeedViewModel?
    var onRefresh: (([FeedImage]) -> Void)?
    
    convenience init(feedLoader: FeedLoader) {
        self.init()
        
        self.viewModel = FeedViewModel(feedLoader: feedLoader)
        bind(view)
    }

    public lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    @objc func refresh() {
        viewModel?.loadFeed()
    }
    
    private func bind(_ view: UIRefreshControl) {
        viewModel?.onChange = {[weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            }
            else {
                self?.view.endRefreshing()
            }
            
            if let feeds = viewModel.feeds {
                self?.onRefresh?(feeds)
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
}
