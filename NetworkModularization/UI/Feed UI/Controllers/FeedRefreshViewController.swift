//
//  FeedRefreshViewController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 15/03/21.
//
import UIKit

final public class FeedRefreshViewController: NSObject, FeedLoadingView {
    var loadFeed: (() -> Void)?
    convenience init(loadFeed: (() -> Void)?) {
        self.init()
        
        self.loadFeed = loadFeed
    }

    public lazy var view = loadView()
    
    @objc func refresh() {
        loadFeed?()
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    func display(_ loadingViewModel: FeedLoadingViewModel) {
        if loadingViewModel.isLoading {
            view.beginRefreshing()
        }
        else {
            view.endRefreshing()
        }
    }
}
