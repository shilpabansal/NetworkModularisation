//
//  FeedImageViewModel.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 21/03/21.
//

public struct FeedImageViewModel<Image> {
    public var location: String?
    public var description: String?
    public var image: Image?
    public var showRetry: Bool
    public var isLoading: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}
