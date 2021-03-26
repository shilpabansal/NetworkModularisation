//
//  FeedPresenter.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 21/03/21.
//
import Foundation
protocol FeedLoadingView {
    func display(_ loadingViewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final public class FeedPresenter {
    let view: FeedView
    let loadingView: FeedLoadingView
    
    init(view: FeedView, loadingView: FeedLoadingView) {
        self.view = view
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {[weak self] in
                self?.didStartLoadingFeed()
            }
            return
        }
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeeds(with feeds: [FeedImage]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {[weak self] in
                self?.didFinishLoadingFeeds(with: feeds)
            }
            return
        }
        view.display(FeedViewModel(feeds: feeds))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingWithError(with error: Error) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {[weak self] in
                self?.didFinishLoadingWithError(with: error)
            }
            return
        }
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    static var title: String {
        return Bundle(for: FeedPresenter.self).localizedString(forKey: "FEED_VIEW_TITLE", value: nil, table: "Feed")
    }
}
