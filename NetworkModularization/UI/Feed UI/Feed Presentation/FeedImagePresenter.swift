//
//  FeedImagePresenter.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 21/03/21.
//
import Foundation

protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let imageTransformer: ((Data) -> Image?)
    private let view: View
    
    init(imageTransformer: @escaping ((Data) -> Image?), view: View) {
        self.imageTransformer = imageTransformer
        self.view = view
    }

    private struct InvalidImageDataError: Error {}
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(location: model.location,
                                        description: model.description,
                                        image: nil,
                                        showRetry: false,
                                        isLoading: true))
    }
    
    func didFinishLoadingImageData(with data: Data,for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
            return
        }
        
        view.display(FeedImageViewModel(location: model.location,
                                        description: model.description,
                                        image: image,
                                        showRetry: false,
                                        isLoading: false))
    }
    
    func didFinishLoadingImageData(with error: Error,for model: FeedImage) {
       view.display(FeedImageViewModel(location: model.location,
                                        description: model.description,
                                        image: nil,
                                        showRetry: true,
                                        isLoading: false))
    }
}
