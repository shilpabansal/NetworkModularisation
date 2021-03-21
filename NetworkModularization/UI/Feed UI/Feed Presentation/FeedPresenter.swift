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

final class FeedPresenter {
    let view: FeedView
    let loadingView: FeedLoadingView
    
    init(view: FeedView, loadingView: FeedLoadingView) {
        self.view = view
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeeds(with feeds: [FeedImage]) {
        view.display(FeedViewModel(feeds: feeds))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingWithError(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    static var title: String {
        return NSLocalizedString("Feed_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: self),
                                 comment: "Title for feed view")
    }
}
