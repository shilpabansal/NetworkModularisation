//
//  FeedViewControllerTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 13/03/21.
//

import XCTest
import UIKit
import NetworkModularization
 
final class FeedViewController: UITableViewController {
    var loader: FeedLoader? = nil
    convenience init(loader: FeedLoader) {
        self.init()
        
        self.loader = loader
    }
    
    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    @objc func load() {
        loader?.load(completion: { _ in })
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
    
    func test_pullToRefresh_loadFeed() {
        let (loader, sut) = makeSUT()
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (loader: LoaderSpy, sut: FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackMemoryLeak(loader, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        
        return (loader: loader, sut: sut)
    }
    
    class LoaderSpy: FeedLoader {
        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            loadCallCount += 1
        }
        
        private(set) var loadCallCount = 0
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach({target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}
