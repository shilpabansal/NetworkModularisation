//
//  FeedImageCellController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 15/03/21.
//

import UIKit

final class FeedImageCellController {
    let viewModel: FeedImageViewModel
    init(viewModel: FeedImageViewModel) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }

            self.viewModel.loadImage(completion: {[weak cell] (image) in
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
            })
        }

        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
}
