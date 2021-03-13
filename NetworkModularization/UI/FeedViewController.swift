//
//  FeedViewController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 13/03/21.
//

import UIKit

public final class FeedViewController: UITableViewController {
    var loader: FeedLoader? = nil
    var tableModel = [FeedImage]()
    public convenience init(loader: FeedLoader) {
        self.init()
        
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load(completion: {[weak self] result in
            self?.tableModel = (try? result.get()) ?? []
            self?.tableView.reloadData()
            
            self?.refreshControl?.endRefreshing()
        })
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
}
