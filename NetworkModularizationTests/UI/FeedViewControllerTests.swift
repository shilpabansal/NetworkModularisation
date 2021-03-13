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
        refreshControl?.beginRefreshing()
        loader?.load(completion: {[weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestFeedFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateUserInitiatedFreeLoad()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedFreeLoad()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_load_loadIndicator() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        loader.loadCompleted(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiatedFreeLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        loader.loadCompleted(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
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
        
        func loadCompleted(at index: Int = 0) {
            completions[index](.success([]))
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
    func simulateUserInitiatedFreeLoad() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing ?? false
    }
}
