//
//  FeedImageCellController.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 15/03/21.
//

import UIKit

final class FeedImageCellController {
    let viewModel: FeedImageViewModel<UIImage>
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        

        viewModel.onImageLoadingStateChange = {[weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onImageLoad = {[weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.showRetryButton = {[weak cell] isRetryButton in
            cell?.feedImageRetryButton.isHidden = !isRetryButton
        }

        cell.onRetry = viewModel.loadImage
        viewModel.loadImage()
        
        return cell
    }
}
