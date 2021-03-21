//
//  UITableView+Dequeuing.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 21/03/21.
//

import UIKit
extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
