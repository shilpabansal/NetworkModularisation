//
//  FeedPresenterTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 28/03/21.
//

import XCTest

class FeedLoadingViewTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (view, _) = makeSUT()
        
        XCTAssert(view.messages.isEmpty)
    }
    
    func test_init_displayNoErrorMessageAndLoadingView() {
        let (view, sut) = makeSUT()
        
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: nil),
                                       .display(isLoading: true)])
    }
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (ViewSpy, FeedPresenter) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view, loadingView: view)
        trackMemoryLeak(view, file:file, line: line)
        trackMemoryLeak(sut, file:file, line: line)
        return (view, sut)
    }
}

class FeedPresenter {
    private let errorView: FeedErrorView
    let loadingView: FeedLoadingView
    
    init(errorView: FeedErrorView,
         loadingView: FeedLoadingView) {
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
}

class ViewSpy: FeedErrorView, FeedLoadingView {
    enum Message: Hashable {
        case display(errorMessage: String?)
        case display(isLoading: Bool)
    }
    
    private(set) var messages = Set<Message>()
    
    func display(_ viewModel: FeedErrorViewModel) {
        messages.insert(.display(errorMessage: nil))
    }
    
    func display(_ loadingViewModel: FeedLoadingViewModel) {
        messages.insert(.display(isLoading: loadingViewModel.isLoading))
    }
}

protocol FeedLoadingView {
    func display(_ loadingViewModel: FeedLoadingViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

struct FeedLoadingViewModel {
    var isLoading: Bool
}
