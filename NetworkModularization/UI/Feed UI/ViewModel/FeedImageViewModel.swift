//
//  FeedImageViewModel.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 20/03/21.
//
import UIKit

final class FeedImageViewModel {
    var task: FeedImageDataLoaderTask? = nil
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader?
    init(model: FeedImage, imageLoader: FeedImageDataLoader?) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func loadImage(completion: @escaping ((UIImage?) -> Void)) {
        self.task = self.imageLoader?.loadImageData(from: self.model.url) { result in
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            completion(image)
        }
    }
    
    func preload() {
        task = self.imageLoader?.loadImageData(from: self.model.url) { _ in }
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
