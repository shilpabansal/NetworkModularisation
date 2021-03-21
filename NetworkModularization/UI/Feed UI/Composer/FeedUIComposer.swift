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
        
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        let presenter = FeedPresenter(view: FeedViewAdapter(feedController: feedController, imageLoader: imageLoader),
                                      loadingView: WeakRefVirtualProxy(object: refreshController))
        
        presentationAdapter.presenter = presenter
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
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load {[weak self] (result) in
            switch result {
            case .success(let feeds):
                self?.presenter?.didFinishLoadingFeeds(with: feeds)
            case .failure(let error):
                self?.presenter?.didFinishLoadingWithError(with: error)
            }
        }
    }
}
