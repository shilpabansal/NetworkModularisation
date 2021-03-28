//
//  UIRefreshControl+Helpers.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 28/03/21.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
