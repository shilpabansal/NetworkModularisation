//
//  FeedStoreSpecs.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 22/02/21.
//

import Foundation
@testable import NetworkModularization

protocol FeedStoreSpecs {
     func test_retrieve_deliversEmptyOnEmptyCache() throws
     func test_retrieve_hasNoSideEffectOnReceivingEmptyCacheTwice() throws
     func test_retrieve_foundValuesOnNonEmptyCache() throws
     func test_retrieve_noSideEffectOnRetrievingError() throws
     func test_insert_overridePreviouslyInsertedCacheValues() throws
     func test_delete_deliversNoErrorOnEmptyCache() throws
     func test_delete_deliversErrorOnNoPermission() throws
     func test_storeSideEffectsSerially() throws
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_noSideEffectOnReceivingNonEmptyDataTwice()
    func test_retrieve_deliversErrorOnInvalidData()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_noSideEffectOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_hasNoSideEffectOnEmptyCache()
    func test_delete_emptyPreviouslyInsertedCache()
}

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
