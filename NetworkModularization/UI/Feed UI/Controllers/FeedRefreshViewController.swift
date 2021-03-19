//
//  FeedRefreshViewController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 15/03/21.
//
import UIKit

final public class FeedRefreshViewController: NSObject {
    var viewModel: FeedViewModel?
    
    convenience init(viewModel: FeedViewModel) {
        self.init()
        
        self.viewModel = viewModel
    }

    public lazy var view: UIRefreshControl = binded(UIRefreshControl())
    
    @objc func refresh() {
        viewModel?.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel?.isLoadingStateChange = {[weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            }
            else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
