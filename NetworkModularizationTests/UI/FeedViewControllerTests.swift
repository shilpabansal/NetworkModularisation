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
        
        refreshControl?.beginRefreshing()
        load()
    }
    
    @objc func load() {
        loader?.load(completion: {[weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_load_doesNotFeed() {
        let (loader, _) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_load_loadFeed() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_userInitiatedFeedLoad_loadFeed() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.userInitiatedFeedLoad()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.userInitiatedFeedLoad()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showLoadingIndicator() {
        let (_, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssert(sut.isShowingLoadingIndicator == true)
    }
    
    func test_viewDidLoad_hideLoadingIndicatorOnCompletion() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.loadCompleted()
        XCTAssert(sut.isShowingLoadingIndicator == false)
    }
    
    func test_userInitiatedFeedLoad_hideLoadingIndicatorOnCompletion() {
        let (loader, sut) = makeSUT()
        
        sut.userInitiatedFeedLoad()
        loader.loadCompleted()
        XCTAssert(sut.isShowingLoadingIndicator == false)
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
        var completions = [((FeedLoader.Result) -> Void)]()
        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            loadCallCount += 1
            
            completions.append(completion)
        }
        
        func loadCompleted(index: Int = 0) {
            completions[0](.success([]))
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

private extension FeedViewController {
    func userInitiatedFeedLoad() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing ?? false
    }
}
