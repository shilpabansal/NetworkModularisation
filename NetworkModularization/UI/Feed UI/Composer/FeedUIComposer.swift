//
//  FeedUIComposer.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 15/03/21.
//

import Foundation
import UIKit

public final class FeedUIComposer {
    private init() { }
    public static func composeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader, presenter: presenter)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        presenter.loadingView = WeakRefVirtualProxy(object: refreshController)
        let feedController = FeedViewController(refreshController: refreshController)
        presenter.view = FeedViewAdapter(feedController: feedController, imageLoader: imageLoader)
        return feedController
    }
    
    //[FeedImage] -> Adapt -> [FeedImageCellController]
    static func adaptFeedImageToFeedImageCellController(feeds: [FeedImage], imageLoader: FeedImageDataLoader) -> [FeedImageCellController] {
       return feeds.map({
        let imageViewModel = FeedImageViewModel(model: $0, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: imageViewModel)
        })
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    init(object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ loadingViewModel: FeedLoadingViewModel) {
        object?.display(loadingViewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    func display(_ viewModel: FeedViewModel) {
        feedController?.tableModel = viewModel.feeds.map({
         let imageViewModel = FeedImageViewModel(model: $0, imageLoader: imageLoader, imageTransformer: UIImage.init)
             return FeedImageCellController(viewModel: imageViewModel)
         })
    }
    
    let imageLoader: FeedImageDataLoader
    weak var feedController: FeedViewController?
    
    init(feedController: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.feedController = feedController
        self.imageLoader = imageLoader
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    let feedLoader: FeedLoader
    let presenter: FeedPresenter
    
    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    
    func didRequestFeedRefresh() {
        presenter.didStartLoadingFeed()
        
        feedLoader.load {[weak self] (result) in
            switch result {
            case .success(let feeds):
                self?.presenter.didFinishLoadingFeeds(with: feeds)
            case .failure(let error):
                self?.presenter.didFinishLoadingWithError(with: error)
            }
        }
    }
}
