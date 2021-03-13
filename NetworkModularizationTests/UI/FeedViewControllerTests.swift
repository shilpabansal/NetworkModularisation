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
        let image0 = makeImage("Location 0", "Description 0")
        let image1 = makeImage("Location 1", "Description 1")
        let image2 = makeImage("Location 2", "Description 2")
        let image3 = makeImage("Location 3", "Description 3")
        
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfRenderedImageView, 0)
        loader.completeFeedLoading(with: [image0])
        XCTAssertEqual(sut.numberOfRenderedImageView, 1)
        
        assertThat(sut: sut, hasViewConfiguredFor: image0, at: 0)
        
        
        sut.simulateUserInitiatedFreeLoad()
        loader.completeFeedLoading(with: [image0, image1, image2, image3])
        XCTAssertEqual(sut.numberOfRenderedImageView, 4)
        
        
        assertThat(sut: sut, hasViewConfiguredFor: image0, at: 0)
        assertThat(sut: sut, hasViewConfiguredFor: image1, at: 1)
        assertThat(sut: sut, hasViewConfiguredFor: image2, at: 2)
        assertThat(sut: sut, hasViewConfiguredFor: image3, at: 3)
    }
    
    //MARK: - Helpers
    private func assertThat(sut: FeedViewController,hasViewConfiguredFor image: FeedImage,at index: Int = 0) {
        let view = sut.feedImageView(at: index) as? FeedImageCell
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.isShowingLocation, true)
        XCTAssertEqual(view?.locationText, image.location)
        XCTAssertEqual(view?.descriptionText, image.description)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (loader: LoaderSpy, sut: FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackMemoryLeak(loader, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        
        return (loader: loader, sut: sut)
    }
    
    private func makeImage(_ location: String,_ description: String) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: URL(string: "https://a-url.com")!)
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
