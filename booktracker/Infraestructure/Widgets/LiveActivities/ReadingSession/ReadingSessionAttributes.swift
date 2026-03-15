//
//  ReadingSessionAttributes.swift
//  booktracker
//
//  Created by Victor rolack on 14-03-26.
//

import Foundation
import ActivityKit

struct ReadingSessionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var isReading: Bool
        var currentSprintStartTime: Date?
        var accumulatedTime: TimeInterval
    }
    
    var bookTitle: String
    var author: String
    var bookId: UUID
}
