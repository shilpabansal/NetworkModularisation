//
//  FeedErrorViewModel.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 27/03/21.
//

public struct FeedErrorViewModel {
    public let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
