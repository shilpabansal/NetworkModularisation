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
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: presenter)
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
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

private final class FeedViewAdapter: FeedView {
    let imageLoader: FeedImageDataLoader
    weak var feedController: FeedViewController?
    
    init(feedController: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.feedController = feedController
        self.imageLoader = imageLoader
    }
    
    func display(feeds: [FeedImage]) {
        feedController?.tableModel = feeds.map({
         let imageViewModel = FeedImageViewModel(model: $0, imageLoader: imageLoader, imageTransformer: UIImage.init)
             return FeedImageCellController(viewModel: imageViewModel)
         })
    }
}
