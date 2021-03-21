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
    @IBOutlet var view: UIRefreshControl?
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ loadingViewModel: FeedLoadingViewModel) {
        if loadingViewModel.isLoading {
            view?.beginRefreshing()
        }
        else {
            view?.endRefreshing()
        }
    }
}
