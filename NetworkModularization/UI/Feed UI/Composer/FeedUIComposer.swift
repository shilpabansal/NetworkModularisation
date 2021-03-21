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
        
        let bundle = Bundle(for: FeedViewController.self)
        let storyBoard = UIStoryboard(name: "Main", bundle: bundle)
        let feedController = storyBoard.instantiateInitialViewController() as! FeedViewController
        feedController.refreshController = refreshController
        
        let presenter = FeedPresenter(view: FeedViewAdapter(feedController: feedController, imageLoader: imageLoader),
                                      loadingView: WeakRefVirtualProxy(object: refreshController))
        
        presentationAdapter.presenter = presenter
        return feedController
    }
    
    //[FeedImage] -> Adapt -> [FeedImageCellController]
    static func adaptFeedImageToFeedImageCellController(feeds: [FeedImage], imageLoader: FeedImageDataLoader) -> [FeedImageCellController] {
       return feeds.map({
        let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: $0, imageLoader: imageLoader)
        let view = FeedImageCellController(delegate: adapter)
        
        adapter.imagePresenter = FeedImagePresenter(imageTransformer: UIImage.init,
                                                    view: WeakRefVirtualProxy(object: view))
        return view
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

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    typealias Image = UIImage
    
    func display(_ viewModel: FeedImageViewModel<Image>) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    func display(_ viewModel: FeedViewModel) {
        feedController?.tableModel = viewModel.feeds.map({
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: $0, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            adapter.imagePresenter = FeedImagePresenter(
                    imageTransformer: UIImage.init,
                view: WeakRefVirtualProxy(object: view))
            return view
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

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    func didCancelImageRequest() {
        task?.cancel()
    }
    
    var task: FeedImageDataLoaderTask? = nil
    private let model: FeedImage
    let imageLoader: FeedImageDataLoader
    var imagePresenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    func didRequestImage() {
        imagePresenter?.didStartLoadingImageData(for: model)
        
        task = imageLoader.loadImageData(from: model.url) {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.imagePresenter?.didFinishLoadingImageData(with: data, for: self.model)
            case .failure(let error):
                self.imagePresenter?.didFinishLoadingImageData(with: error, for: self.model)
            }
        }
    }
}
