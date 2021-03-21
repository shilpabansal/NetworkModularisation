//
//  FeedImageViewModel.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 21/03/21.
//

struct FeedImageViewModel<Image> {
    var location: String?
    var description: String?
    var image: Image?
    var showRetry: Bool
    var isLoading: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
