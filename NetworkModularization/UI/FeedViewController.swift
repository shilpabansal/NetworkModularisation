//
//  FeedViewController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 13/03/21.
//

import UIKit

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL)
    func cancelImageLoader(from url: URL)
}

public final class FeedViewController: UITableViewController {
    var imageLoader: FeedImageDataLoader? = nil
    var feedLoader: FeedLoader? = nil
    var tableModel = [FeedImage]()
    
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
        
        imageLoader?.loadImageData(from: cellModel.url)
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        
        imageLoader?.cancelImageLoader(from: cellModel.url)
    }
}
