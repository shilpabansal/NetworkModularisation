//
//  FeedImageCell.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 13/03/21.
//

import UIKit

public class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc func retryButtonTapped() {
        onRetry?()
    }
    
    var imageLoader: FeedImageDataLoader? = nil
    convenience init(imageLoader: FeedImageDataLoader?) {
        self.init()
        
        self.imageLoader = imageLoader
    }
    
    func configureCell(cellModel: FeedImage) -> FeedImageDataLoaderTask? {
        self.locationContainer.isHidden = (cellModel.location == nil)
        self.locationLabel.text = cellModel.location
        self.descriptionLabel.text = cellModel.description
        self.feedImageView.image = nil
        self.feedImageRetryButton.isHidden = true
        self.feedImageContainer.startShimmering()
        
        var imageTask: FeedImageDataLoaderTask? = nil
        let loadImage = { [weak self] in
            guard let self = self else { return }

            imageTask = self.imageLoader?.loadImageData(from: cellModel.url) { [weak self] result in
                guard let self = self else { return }
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                self.feedImageView.image = image
                self.feedImageRetryButton.isHidden = (image != nil)
                self.feedImageContainer.stopShimmering()
            }
        }
        
        self.onRetry = loadImage
        loadImage()
        
        return imageTask
    }
}
