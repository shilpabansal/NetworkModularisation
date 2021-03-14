//
//  FeedViewController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 13/03/21.
//

import UIKit

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping ((Result) -> Void)) -> FeedImageDataLoaderTask
}

public final class FeedViewController: UITableViewController {
    var imageLoader: FeedImageDataLoader? = nil
    var feedLoader: FeedLoader? = nil
    var tableModel = [FeedImage]()
    var tasks: [IndexPath : FeedImageDataLoaderTask] = [:]
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        
        self.imageLoader = imageLoader
        self.feedLoader = feedLoader
    }
    
    public override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load(completion: {[weak self] result in
            if let feeds = try? result.get() {
                self?.tableModel = feeds
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        })
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        
        let cell = FeedImageCell()
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.locationContainer.isHidden = cellModel.location == nil
        
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadImage = {[weak self, weak cell] in
            guard let self = self else { return }
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.url, completion: {[weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                
                cell?.feedImageContainer.stopShimmering()
            })
        }
        
        loadImage()
        cell.onRetry = loadImage
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
