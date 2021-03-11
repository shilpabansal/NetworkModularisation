//
//  FeedViewControllerTests.swift
//  NetworkModularizationUITests
//
//  Created by Shilpa Bansal on 09/03/21.
//

import XCTest
import UIKit

final class FeedViewController: UIViewController {
    var loader: FeedViewControllerTests.LoaderSpy? = nil
    
    convenience init(loader: FeedViewControllerTests.LoaderSpy) {
        self.init()
        
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
}

class FeedViewControllerTests: XCTestCase {
    
    func test_load_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_load_loadsFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    struct LoaderSpy {
        private(set) var loadCallCount = 0
        
        mutating func load() {
            loadCallCount += 1
        }
    }
}
