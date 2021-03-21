//
//  UIImageView+Animation.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 21/03/21.
//

import UIKit
extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        guard newImage != nil else { return }
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
