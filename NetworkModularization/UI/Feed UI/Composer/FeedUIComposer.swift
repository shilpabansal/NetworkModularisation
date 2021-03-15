//
//  FeedUIComposer.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 15/03/21.
//

import Foundation
public final class FeedUIComposer {
    private init() { }
    public static func composeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = {[weak feedController] feeds in
            feedController?.tableModel = adaptFeedImageToFeedImageCellController(feeds: feeds, imageLoader: imageLoader)
        }
        return feedController
    }
    
    //[FeedImage] -> Adapt -> [FeedImageCellController]
    static func adaptFeedImageToFeedImageCellController(feeds: [FeedImage], imageLoader: FeedImageDataLoader) -> [FeedImageCellController] {
       return feeds.map({
            FeedImageCellController(model: $0, imageLoader: imageLoader)
        })
    }
}
