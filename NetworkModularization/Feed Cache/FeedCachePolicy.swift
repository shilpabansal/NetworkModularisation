//
//  FeedCachePolicy.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 26/01/21.
//

import Foundation
internal struct FeedCachePolicy {
    private init() { }
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    internal static func validate(_ timeStamp: Date, against date: Date) -> Bool {
        /**
            Checking the difference between the date sent and current is less than 7
         */
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
