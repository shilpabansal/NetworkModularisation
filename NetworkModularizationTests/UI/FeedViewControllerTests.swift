//
//  FeedViewControllerTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 13/03/21.
//

import XCTest
import UIKit
import NetworkModularization
 
final class FeedViewController: UIViewController {
    var loader: FeedLoader? = nil
    convenience init(loader: FeedLoader) {
        self.init()
        
        self.loader = loader
    }
    
}

class FeedViewControllerTests: XCTestCase {
    func test_load_doesNotFeed() {
        let (loader, _) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_load_loadFeed() {
        let (loader, _) = makeSUT()
        
        loader.load(completion: {_ in})
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (loader: LoaderSpy, feedVC: FeedViewController){
        let loader = LoaderSpy()
        let feedVC = FeedViewController(loader: loader)
        
        trackMemoryLeak(loader, file: file, line: line)
        trackMemoryLeak(feedVC, file: file, line: line)
        
        return (loader: loader, feedVC: feedVC)
    }
    
    class LoaderSpy: FeedLoader {
        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            loadCallCount += 1
        }
        
        private(set) var loadCallCount = 0
    }
}
