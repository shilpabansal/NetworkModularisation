//
//  FeedStoreSpy.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 24/01/21.
//

import Foundation
@testable import NetworkModularization

public class FeedStoreSpy: FeedStore {
    typealias FeedSuccess = (([LocalFeedImage], Date) -> Void)
    var deletionCompletions = [DeletionError]()
    var insertionCompletions = [InsertionError]()
    var retrieveCompletions = [LoadError]()
    
    var receivedMessages = [ReceivedMessage]()
    
    enum ReceivedMessage: Equatable {
        case deleteFeed
        case insertFeed([LocalFeedImage], Date)
        case retrieval
    }
    
    public func insert(feeds: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionError) {
        receivedMessages.append(.insertFeed(feeds, timestamp))
        insertionCompletions.append(completion)
    }
    
    public func deleteFeeds(completion: @escaping DeletionError) {
        receivedMessages.append(.deleteFeed)
        deletionCompletions.append(completion)
    }
    
    public func retrieve(completion: @escaping LoadError) {
        receivedMessages.append(.retrieval)
        retrieveCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertionSuccessfully(index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func completeInsertion(with error: Error, index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeRetrieval(with error: Error, index: Int = 0) {
        retrieveCompletions[index](error)
    }
    
    func completeRetrievalSuccessfully(index: Int = 0) {
        retrieveCompletions[index](nil)
    }
}
