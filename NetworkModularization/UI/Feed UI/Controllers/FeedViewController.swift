//
//  FeedViewController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 13/03/21.
//

import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    public var refreshController: FeedRefreshViewController? = nil
    var tableModel = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        
        refreshController?.onRefresh = {[weak self] feeds in
            guard let self = self else { return }
            self.tableModel = feeds.map({
                FeedImageCellController(model: $0, imageLoader: imageLoader)
            })
        }
    }
    
    public override func viewDidLoad() {
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view
        
        refreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(indexPath: indexPath)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    
    func removeCellController(indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
