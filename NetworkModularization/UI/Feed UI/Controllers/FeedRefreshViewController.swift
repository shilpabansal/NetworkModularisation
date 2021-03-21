//
//  FeedRefreshViewController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 15/03/21.
//
import UIKit

final public class FeedRefreshViewController: NSObject, FeedLoadingView {
    var presenter: FeedPresenter?
    
    convenience init(presenter: FeedPresenter) {
        self.init()
        
        self.presenter = presenter
    }

    public lazy var view = loadView()
    
    @objc func refresh() {
        presenter?.loadFeed()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        }
        else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
