//
//  CodableFeedStore.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 22/02/21.
//

import Foundation

class CodableFeedStore: FeedStore {
    let storeURL: URL
    
    init(_ storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct Cache: Codable {
        let feeds: [CodableFeedImage]
        let timeStamp: Date
        
        var localFeeds: [LocalFeedImage] {
            return feeds.map { return $0.local }
        }
    }
    
    let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ localFeedImage: LocalFeedImage) {
            id = localFeedImage.id
            description = localFeedImage.description
            location = localFeedImage.location
            url = localFeedImage.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    
    func retrieve(completion: @escaping FeedStore.RetrieveCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.success(.none))
            return
        }
        
        queue.async {
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(Cache.self, from: data)
                
                completion(.success(CachedFeed(feed: decoded.localFeeds, timestamp: decoded.timeStamp)))
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    func insert(feeds: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                
                let codableFeedImages = feeds.map({ return CodableFeedImage($0)})
                let encoded = try encoder.encode(Cache(feeds: codableFeedImages, timeStamp: timestamp))
                try encoded.write(to: storeURL)
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
    
    func deleteFeeds(completion: @escaping FeedStore.DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let data = try Data(contentsOf: storeURL)
                if data.isEmpty {
                    completion(nil)
                    return
                }
                
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
}
