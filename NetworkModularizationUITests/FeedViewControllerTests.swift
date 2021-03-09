//
//  FeedViewControllerTests.swift
//  NetworkModularizationUITests
//
//  Created by Shilpa Bansal on 09/03/21.
//

import Foundation
import XCTest

final class FeedViewController {
    let loader: FeedViewControllerTests.LoaderSpy
    
    init(loader: FeedViewControllerTests.LoaderSpy) {
        self.loader = loader
    }
}

class FeedViewControllerTests: XCTestCase {
    
    func test_load_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    struct LoaderSpy {
        let loadCallCount = 0
    }
}
