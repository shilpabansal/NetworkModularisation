//
//  FeedViewController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 13/03/21.
//

import UIKit

final class FeedImageCellController {
    var task: FeedImageDataLoaderTask? = nil
    let model: FeedImage
    let imageLoader: FeedImageDataLoader?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader?) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }

            self.task = self.imageLoader?.loadImageData(from: self.model.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
            }
        }

        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    
    func preload() {
        task = self.imageLoader?.loadImageData(from: self.model.url) { _ in }
    }
    
    deinit {
        task?.cancel()
    }
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    var imageLoader: FeedImageDataLoader? = nil
    public var refreshController: FeedRefreshViewController? = nil
    var tableModel = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    var cellController: [IndexPath : FeedImageCellController] = [:]
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        
        self.imageLoader = imageLoader
        refreshController = FeedRefreshViewController(feedLoader: feedLoader)
    }
    
    public override func viewDidLoad() {
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view
        refreshController?.onRefresh = {[weak self] feeds in
            self?.tableModel = feeds
        }
        refreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let controller = cellController(forRowAt: indexPath)
        return controller.view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(indexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(forRowAt: indexPath)
            controller.preload()
        }
    }
    
    func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let cellModel = tableModel[indexPath.row]
        let controller = FeedImageCellController(model: cellModel, imageLoader: imageLoader)
        cellController[indexPath] = controller
        return controller
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    
    func removeCellController(indexPath: IndexPath) {
        cellController[indexPath] = nil
    }
}
