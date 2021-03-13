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
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no load count initially as API is not called")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected load count as 1 on view loaded")
        
        sut.simulateUserInitiatedFreeLoad()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected load count to 2 when user initiate the load")
        
        sut.simulateUserInitiatedFreeLoad()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected load count to 3 when user initiate the load again")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoading() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator to be shown when view is loading")
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator to be hidden when load completes")
        
        sut.simulateUserInitiatedFreeLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator to be shown when user initiates the loading")
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator to be hidden when load error occurs")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "Description 0", location: "Location 0")
        let image1 = makeImage(description: nil, location: "Location 1")
        let image2 = makeImage(description: "Description 2", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfRenderedImageView, 0)
        loader.completeFeedLoading(with: [image0])
        assertThat(sut: sut, isRendering: [image0])
        
        
        sut.simulateUserInitiatedFreeLoad()
        let feedImageArray = [image0, image1, image2, image3]
        loader.completeFeedLoading(with: feedImageArray)
        
        assertThat(sut: sut, isRendering: feedImageArray)
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "Description 0", location: "Location 0")
        
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut: sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFreeLoad()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut: sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second view also becomes visible")
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        sut.simulateFeedImageNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateFeedImageNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    //MARK: - Helpers
    private func assertThat(sut: FeedViewController, isRendering feedImages: [FeedImage]) {
        guard sut.numberOfRenderedImageView == feedImages.count else {
            return XCTFail("Expected \(feedImages.count), fount \(sut.numberOfRenderedImageView)")
        }
        
        feedImages.enumerated().forEach {
            assertThat(sut: sut, hasViewConfiguredFor: $1, at: $0)
        }
    }
    
    private func assertThat(sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index) as? FeedImageCell
        guard let cell = view else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let atLocationBeVisibile = image.location != nil
        XCTAssertEqual(cell.isShowingLocation, atLocationBeVisibile, "Expected location's visibility to \(atLocationBeVisibile), found \(cell.isShowingLocation)")
        
        XCTAssertEqual(cell.locationText, image.location, "Expected image location \(String(describing: image.location)) at index \(index)")
        XCTAssertEqual(cell.descriptionText, image.description, "Expected image location \(String(describing: image.description)) at index \(index)")
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (loader: LoaderSpy, sut: FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        
        trackMemoryLeak(loader, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        
        return (loader: loader, sut: sut)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
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
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int = 0) -> FeedImageCell? {
        return feedImageView(at: row) as? FeedImageCell
    }
    
    func simulateFeedImageNotVisible(at row: Int = 0) {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
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
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
}

class LoaderSpy: FeedLoader, FeedImageDataLoader {
    private(set) var loadFeedCallCount = 0
    var feedRequests = [((FeedLoader.Result) -> Void)]()
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        loadFeedCallCount += 1
        
        feedRequests.append(completion)
    }
    
    func completeFeedLoading(with feeds:[FeedImage] = [], at index: Int = 0) {
        feedRequests[index](.success(feeds))
    }
    
    func completeFeedLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "Error", code: 0)
        feedRequests[index](.failure(error))
    }
    
    //MARK: - FeedImageDataLoader
    private(set) var loadedImageURLs = [URL]()
    private(set) var cancelledImageURLs = [URL]()
    func loadImageData(from url: URL) -> FeedImageDataLoaderTask {
        loadedImageURLs.append(url)
        return TaskSpy {[weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }
    
    public struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
}
