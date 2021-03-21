//
//  FeedRefreshViewController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 15/03/21.
//
import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final public class FeedRefreshViewController: NSObject, FeedLoadingView {
    var delegate: FeedRefreshViewControllerDelegate?
    convenience init(delegate: FeedRefreshViewControllerDelegate) {
        self.init()
        
        self.delegate = delegate
    }

    public lazy var view = loadView()
    
    @objc func refresh() {
        delegate?.didRequestFeedRefresh()
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
