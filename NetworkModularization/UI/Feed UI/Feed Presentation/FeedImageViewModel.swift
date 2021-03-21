//
//  FeedImageViewModel.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 20/03/21.
//
import Foundation

final class FeedImageViewModel<Image> {
    var task: FeedImageDataLoaderTask? = nil
    var onImageLoadingStateChange: ((Bool) -> Void)?
    var onImageLoad: ((Image) -> Void)?
    var showRetryButton: ((Bool) -> Void)?
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: ((Data) -> Image?)
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping ((Data) -> Image?)) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }

    func loadImage() {
        onImageLoadingStateChange?(true)
        self.task = self.imageLoader.loadImageData(from: self.model.url) {[weak self] result in
            guard let self = self else { return }
            if let image = (try? result.get()).flatMap(self.imageTransformer) {
                self.onImageLoad?(image)
                self.showRetryButton?(false)
            }
            else {
                self.showRetryButton?(true)
            }
    
            self.onImageLoadingStateChange?(false)
        }
    }
    
    func preload() {
        task = self.imageLoader.loadImageData(from: self.model.url) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
    
    var location: String? {
        return model.location
    }
    
    var hasLocation: Bool {
        return model.location != nil
    }
    
    var description: String? {
        return model.description
    }
}
