//
//  FeedPresenter.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 21/03/21.
//
import Foundation

public protocol FeedLoadingView {
    func display(_ loadingViewModel: FeedLoadingViewModel)
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final public class FeedPresenter {
    let view: FeedView
    let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    public init(view: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
             tableName: "Feed",
             bundle: Bundle(for: FeedPresenter.self),
             comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeeds(with feeds: [FeedImage]) {
        view.display(FeedViewModel(feeds: feeds))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingWithError(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    static var title: String {
        return Bundle(for: FeedPresenter.self).localizedString(forKey: "FEED_VIEW_TITLE", value: nil, table: "Feed")
    }
}
