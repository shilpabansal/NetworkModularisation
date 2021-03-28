//
//  FeedErrorViewModel.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 27/03/21.
//

struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
