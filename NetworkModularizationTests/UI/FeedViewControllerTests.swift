//
//  FeedViewControllerTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 13/03/21.
//

import XCTest
import UIKit
import NetworkModularization

class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestFeedFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no load count initially as API is not called")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected load count as 1 on view loaded")
        
        sut.simulateUserInitiatedFreeLoad()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected load count to 2 when user initiate the load")
        
        sut.simulateUserInitiatedFreeLoad()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected load count to 3 when user initiate the load again")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoading() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator to be shown when view is loading")
        loader.completeFeedLoading(with:[], at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator to be hidden when load completes")
        
        sut.simulateUserInitiatedFreeLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator to be shown when user initiates the loading")
        loader.completeFeedLoading(with:[], at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator to be hidden when load completes")
    }
    
    func test_loadingFeedImages() {
        let feedImage = uniqueFeed()
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfRenderedImageView, 0)
        loader.completeFeedLoading(with: [feedImage])
        XCTAssertEqual(sut.numberOfRenderedImageView, 1)
        
        let view = sut.feedImageView(at: 0) as? FeedImageCell
        XCTAssertNotNil(view)
        
        XCTAssertEqual(view?.isShowingLocation, true)
        XCTAssertEqual(view?.locationText, feedImage.location)
        XCTAssertEqual(view?.descriptionText, feedImage.description)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (loader: LoaderSpy, sut: FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackMemoryLeak(loader, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        
        return (loader: loader, sut: sut)
    }
    
    private func uniqueFeed() -> FeedImage {
        return FeedImage(id: UUID(), description: "Description", location: "Location", url: URL(string: "https://a-url.com")!)
    }
    
    class LoaderSpy: FeedLoader {
        var completions = [((FeedLoader.Result) -> Void)]()
        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            loadCallCount += 1
            
            completions.append(completion)
        }
        
        func completeFeedLoading(with feeds:[FeedImage], at index: Int = 0) {
            completions[index](.success(feeds))
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
    
    var numberOfRenderedImageView: Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let row = IndexPath(row: row, section: feedImageSection)
        return dataSource?.tableView(tableView, cellForRowAt: row)
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String {
        return locationLabel.text ?? ""
    }
    
    var descriptionText: String {
        return descriptionLabel.text ?? ""
    }
}
