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
        let viewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: viewModel)
        
        let feedController = FeedViewController(refreshController: refreshController)
        viewModel.onFeedLoad = {[weak feedController] feeds in
            feedController?.tableModel = adaptFeedImageToFeedImageCellController(feeds: feeds, imageLoader: imageLoader)
        }
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
